import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'photo_cleaner_service.dart'; // To get PhotoResult

class FullScreenImageView extends StatefulWidget {
  final List<PhotoResult> photos;
  final int initialIndex;
  final Set<String> ignoredPhotos;
  final Function(String) onToggleKeep;

  const FullScreenImageView({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.ignoredPhotos,
    required this.onToggleKeep,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;
  final ValueNotifier<bool> _isZoomed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _isZoomed.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Reset zoom state when changing page
    _isZoomed.value = false;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPhotoId = widget.photos[_currentIndex].asset.id;
    final isKept = widget.ignoredPhotos.contains(currentPhotoId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // If the user swipes down and the image is not zoomed, pop the route.
          if (!_isZoomed.value && (details.primaryVelocity ?? 0) > 250) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.photos.length,
              builder: (context, index) {
                final asset = widget.photos[index].asset;
                return PhotoViewGalleryPageOptions.customChild(
                  child: PhotoPage(
                    key: ValueKey(asset.id),
                    asset: asset,
                    isZoomedNotifier: _isZoomed,
                  ),
                  heroAttributes: PhotoViewHeroAttributes(tag: asset.id),
                );
              },
              onPageChanged: _onPageChanged,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              scrollPhysics: const BouncingScrollPhysics(),
              loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
            ),
            // App Bar on top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withAlpha(102), // Corrected deprecated withOpacity
                child: SafeArea(
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      '${_currentIndex + 1} of ${widget.photos.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                  ),
                ),
              ),
            ),
            // Floating Action Button
            Positioned(
              bottom: 30,
              left: 20,
              child: FloatingActionButton.extended(
                backgroundColor: isKept ? Colors.green : Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // This setState only rebuilds the FAB and AppBar, not the gallery pages
                  setState(() {
                    widget.onToggleKeep(currentPhotoId);
                  });
                },
                icon: Icon(
                  isKept ? Icons.check_circle : Icons.do_not_disturb_on,
                  color: Colors.white,
                ),
                label: Text(
                  isKept ? 'Kept' : 'Keep',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A stateful widget to manage loading and displaying a single photo.
// This prevents reloading when the parent widget rebuilds.
class PhotoPage extends StatefulWidget {
  final AssetEntity asset;
  final ValueNotifier<bool> isZoomedNotifier;

  const PhotoPage({
    super.key,
    required this.asset,
    required this.isZoomedNotifier,
  });

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  File? _file;
  Uint8List? _thumbnailData;
  dynamic _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // First, load the thumbnail for a fast preview.
      final thumb = await widget.asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
      if (mounted) {
        setState(() => _thumbnailData = thumb);
      }

      // Then, load the full-resolution file.
      final file = await widget.asset.file;
      if (mounted) {
        setState(() => _file = file);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _loadError.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    // If the full file is available, show it.
    if (_file != null) {
      return PhotoView(
        imageProvider: FileImage(_file!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.5,
        scaleStateChangedCallback: (state) {
          widget.isZoomedNotifier.value = state != PhotoViewScaleState.initial;
        },
        loadingBuilder: (context, event) {
          // While the full image is decoding, we can still show the thumbnail
          // if it's available. This creates a smoother experience.
          if (_thumbnailData != null) {
            return PhotoView(imageProvider: MemoryImage(_thumbnailData!));
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // If only the thumbnail is available, show it.
    if (_thumbnailData != null) {
      return PhotoView(
        imageProvider: MemoryImage(_thumbnailData!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.5,
      );
    }

    // While everything is loading.
    return const Center(child: CircularProgressIndicator());
  }
}