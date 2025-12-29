
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/services.dart';

import 'photo_analyzer.dart';
import 'face_detector_service.dart'; 

//##############################################################################
//# 1. ISOLATE DATA STRUCTURES & TOP-LEVEL FUNCTION
//##############################################################################

class IsolateAnalysisResult {
  final String assetId;
  final PhotoAnalysisResult analysis;
  IsolateAnalysisResult(this.assetId, this.analysis);
}

class IsolateData {
  final RootIsolateToken token;
  final String assetId;
  final bool isFromScreenshotAlbum;

  // Add a field for the file path for face detection
  final String filePath;

  IsolateData(this.token, this.assetId, this.isFromScreenshotAlbum, this.filePath);
}

class DeleteIsolateData {
  final RootIsolateToken token;
  final List<String> ids;
  DeleteIsolateData(this.token, this.ids);
}

Future<dynamic> analyzePhotoInIsolate(IsolateData isolateData) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);

    // Face detection is now the first step inside the isolate.
    final faceDetector = FaceDetectorService();
    final bool hasFace = await faceDetector.hasFaces(isolateData.filePath);
    faceDetector.dispose(); // Dispose after use to free up resources

    if (hasFace) {
      return null; // Skip this photo entirely if it has a face
    }

    final asset = await AssetEntity.fromId(isolateData.assetId);
    if (asset == null) return null;

    final imageBytes = await asset.thumbnailDataWithSize(const ThumbnailSize(32, 32));
    if (imageBytes == null) return null;

    final analyzer = PhotoAnalyzer();
    final analysisResult = await analyzer.analyze(
      imageBytes,
      isFromScreenshotAlbum: isolateData.isFromScreenshotAlbum,
    );
    return IsolateAnalysisResult(asset.id, analysisResult);
  } catch (e, s) {
    developer.log('Analysis failed for asset ${isolateData.assetId}', name: 'photo_cleaner.isolate', error: e, stackTrace: s);
    return null;
  }
}

Future<List<String>> _deletePhotosInIsolate(DeleteIsolateData isolateData) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);
  if (isolateData.ids.isEmpty) return [];
  try {
    return await PhotoManager.editor.deleteWithIds(isolateData.ids);
  } catch (e, s) {
    developer.log('Failed to delete photos in isolate', name: 'photo_cleaner.isolate', error: e, stackTrace: s);
    return [];
  }
}

//##############################################################################
//# 2. MAIN SERVICE & DATA MODELS
//##############################################################################

class PhotoResult {
  final AssetEntity asset;
  final PhotoAnalysisResult analysis;
  double get score => analysis.finalScore;
  PhotoResult(this.asset, this.analysis);
}

class PhotoCleanerService {
  static final PhotoCleanerService instance = PhotoCleanerService._internal();
  factory PhotoCleanerService() => instance;
  PhotoCleanerService._internal();

  final DiskSpacePlus _diskSpace = DiskSpacePlus();
  final List<PhotoResult> _allPhotos = [];
  final Set<String> _seenPhotoIds = {};
  Future<void>? _scanFuture;

  void reset() {
    _seenPhotoIds.clear();
    _allPhotos.clear();
    _scanFuture = null;
  }

  void dispose() {
    // The face detector is now managed within the isolate, so no top-level dispose needed.
  }

  Future<void> scanPhotosInBackground({
    required String permissionErrorMessage,
    List<String> excludedIds = const [],
  }) async {
    _scanFuture ??= _scanPhotos(
      permissionErrorMessage: permissionErrorMessage,
      excludedIds: excludedIds,
    );
    return _scanFuture;
  }

  Future<void> _scanPhotos({
    required String permissionErrorMessage,
    required List<String> excludedIds,
  }) async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );
    if (albums.isEmpty) return;

    final AssetPathEntity mainAlbum = albums.first;
    final int totalPhotos = await mainAlbum.assetCountAsync;
    const int photosToFetch = 300;
    final List<AssetEntity> recentAssets = await mainAlbum.getAssetListRange(
      start: 0,
      end: totalPhotos < photosToFetch ? totalPhotos : photosToFetch,
    );

    final Set<String> excludedIdsSet = Set<String>.from(excludedIds);
    final List<AssetEntity> assetsToProcess = recentAssets.where((asset) => !excludedIdsSet.contains(asset.id)).toList();

    _allPhotos.clear();
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw Exception("Failed to get RootIsolateToken.");
    }

    final screenshotAlbum = albums.firstWhere((album) => album.name.toLowerCase() == 'screenshots', orElse: () => mainAlbum);
    final screenshotAssetIds = (await screenshotAlbum.getAssetListRange(start: 0, end: 1000)).map((a) => a.id).toSet();

    final List<Future<dynamic>> analysisFutures = [];
    for (final asset in assetsToProcess) {
        final file = await asset.file; // We need the file path for the isolate
        if (file != null) {
            final bool isScreenshot = screenshotAssetIds.contains(asset.id);
            analysisFutures.add(
                compute(analyzePhotoInIsolate, IsolateData(rootIsolateToken, asset.id, isScreenshot, file.path)),
            );
        }
    }

    final List<IsolateAnalysisResult> analysisResults = [];
    const batchSize = 12;
    for (int i = 0; i < analysisFutures.length; i += batchSize) {
      final end = (i + batchSize > analysisFutures.length) ? analysisFutures.length : i + batchSize;
      final List<dynamic> batchResults = await Future.wait(analysisFutures.sublist(i, end));
      analysisResults.addAll(batchResults.whereType<IsolateAnalysisResult>());
      await PhotoManager.clearFileCache();
    }

    final Map<String, AssetEntity> assetMap = {for (var asset in assetsToProcess) asset.id: asset};
    _allPhotos.addAll(
      analysisResults
          .where((r) => assetMap.containsKey(r.assetId))
          .map((r) => PhotoResult(assetMap[r.assetId]!, r.analysis)),
    );
    
    final finalUniqueIds = <String>{};
    _allPhotos.retainWhere((photoResult) => finalUniqueIds.add(photoResult.asset.id));
  }

  Future<List<PhotoResult>> selectPhotosToDelete({List<String> excludedIds = const []}) async {
    List<PhotoResult> candidates = _allPhotos
        .where((p) => !_seenPhotoIds.contains(p.asset.id))
        .toList();

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final selected = candidates.take(24).toList();
    _seenPhotoIds.addAll(selected.map((p) => p.asset.id));
    return selected;
  }

  Future<List<String>> deletePhotos(List<PhotoResult> photos) async {
    if (photos.isEmpty) return [];
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      developer.log("Could not get RootIsolateToken, deleting on main thread.", name: 'photo_cleaner.warning');
      final ids = photos.map((p) => p.asset.id).toList();
      return await PhotoManager.editor.deleteWithIds(ids);
    }
    final ids = photos.map((p) => p.asset.id).toList();
    return await compute(_deletePhotosInIsolate, DeleteIsolateData(rootIsolateToken, ids));
  }

  Future<StorageInfo> getStorageInfo() async {
    final double total = await _diskSpace.getTotalDiskSpace ?? 0.0;
    final double free = await _diskSpace.getFreeDiskSpace ?? 0.0;
    return StorageInfo(
      totalSpace: (total * 1024 * 1024).toInt(),
      usedSpace: ((total - free) * 1024 * 1024).toInt(),
    );
  }
}

class StorageInfo {
  final int totalSpace;
  final int usedSpace;
  StorageInfo({required this.totalSpace, required this.usedSpace});
  double get usedPercentage => totalSpace > 0 ? (usedSpace / totalSpace) * 100 : 0;
  String get usedSpaceGB => (usedSpace / 1073741824).toStringAsFixed(1);
  String get totalSpaceGB => (totalSpace / 1073741824).toStringAsFixed(0);
}
