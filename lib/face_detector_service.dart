
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceDetectorService {
  static final FaceDetectorService _instance = FaceDetectorService._internal();
  factory FaceDetectorService() => _instance;
  FaceDetectorService._internal();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Future<bool> hasFaces(String imagePath) async {
    try {
      // Decode image to ensure it's in a format the detector can handle.
      final imageBytes = await File(imagePath).readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return false;

      // The ML Kit plugin works best with InputImage from a file path.
      final inputImage = InputImage.fromFilePath(imagePath);

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      // Log the error appropriately
      developer.log('Error detecting faces', name: 'face_detector.error', error: e);
      return false; // Assume no faces if an error occurs
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
