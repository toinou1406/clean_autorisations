
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector;

  FaceDetectionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  Future<bool> hasFaces(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      print('Error detecting faces: $e');
      return false;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
