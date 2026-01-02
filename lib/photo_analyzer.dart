
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';

//##############################################################################
//# SCORE WEIGHTS
// Weights determine the importance of each metric in the final score.
// Higher weight = more importance. This makes the algorithm tunable.
//##############################################################################
const double _weightScreenshot = 500.0; // Is it a screenshot?
const double _weightBlur = 150.0;       // How blurry is the image?
const double _weightLuminance = 120.0;  // How dark or overexposed is it?
const double _weightComplexity = 80.0;   // How simple/uninteresting is it?

/// Represents the analysis results for a single photo.
///
/// This class holds the raw metrics calculated from the image and is responsible
/// for calculating a `finalScore` that determines how likely a photo is
/// a good candidate for deletion.
class PhotoAnalysisResult {
  final String md5Hash;
  final String pHash;
  final double blurScore;
  final double luminanceScore;
  final double entropyScore;
  final double edgeDensityScore;
  final bool isFromScreenshotAlbum;
  double finalScore = 0.0;

  PhotoAnalysisResult({
    required this.md5Hash,
    required this.pHash,
    required this.blurScore,
    required this.luminanceScore,
    required this.entropyScore,
    required this.edgeDensityScore,
    required this.isFromScreenshotAlbum,
  }) {
    finalScore = _calculateFinalScore();
  }

  /// Calculates the final score based on normalized and weighted metrics.
  ///
  /// This new algorithm is more readable and easier to tune than the previous
  /// series of if-statements. It normalizes each metric to a 0-1 scale
  /// and applies a weight.
  double _calculateFinalScore() {
    // 1. Screenshot Score (very high impact)
    final double screenshotScore = isFromScreenshotAlbum ? 1.0 : 0.0;

    // 2. Blur Score (high impact)
    final double normalizedBlurScore = _normalize(blurScore, 80.0, 300.0, invert: true);

    // 3. Luminance Score (high impact for extremes)
    final double darkScore = _normalize(luminanceScore, 50.0, 100.0, invert: true);
    final double brightScore = _normalize(luminanceScore, 220.0, 180.0);
    final double normalizedLuminanceScore = math.max(darkScore, brightScore);
    
    // 4. Complexity Score (medium impact)
    final double lowEntropyScore = _normalize(entropyScore, 4.0, 6.0, invert: true);
    final double lowEdgeScore = _normalize(edgeDensityScore, 0.05, 0.1, invert: true);
    final double complexityScore = math.min(lowEntropyScore, lowEdgeScore);

    // 5. Weighted Sum
    final double totalScore = (screenshotScore * _weightScreenshot) +
                              (normalizedBlurScore * _weightBlur) +
                              (normalizedLuminanceScore * _weightLuminance) +
                              (complexityScore * _weightComplexity);
    
    if (kDebugMode) {
      developer.log(
          "Photo [${md5Hash.substring(0, 6)}...]: Final Score = ${totalScore.toStringAsFixed(2)} \n"
          "  - Blur: ${normalizedBlurScore.toStringAsFixed(2)} (raw: ${blurScore.toStringAsFixed(2)})\n"
          "  - Lum: ${normalizedLuminanceScore.toStringAsFixed(2)} (raw: ${luminanceScore.toStringAsFixed(2)})\n"
          "  - Cmplx: ${complexityScore.toStringAsFixed(2)} (entr: ${entropyScore.toStringAsFixed(2)}, edge: ${edgeDensityScore.toStringAsFixed(2)})\n"
          "  - isSS: $isFromScreenshotAlbum",
          name: 'photo_analyzer.score',
        );
    }
    
    return totalScore;
  }

  /// Helper function to normalize a value to a 0.0-1.0 range.
  double _normalize(double value, double low, double high, {bool invert = false}) {
    if (invert) {
      if (value >= high) return 0.0;
      if (value <= low) return 1.0;
      return (high - value) / (high - low);
    } else {
      if (value <= low) return 0.0;
      if (value >= high) return 1.0;
      return (value - low) / (high - low);
    }
  }
}

class PhotoAnalyzer {

  Future<String> calculatePerceptualHash(img.Image resizedImage) async {
    final grayscaleImg = img.grayscale(resizedImage);
    final smallImg = img.copyResize(grayscaleImg,
        width: 8, height: 8, interpolation: img.Interpolation.average);
    double total = 0;
    for (int y = 0; y < smallImg.height; y++) {
      for (int x = 0; x < smallImg.width; x++) {
        total += smallImg.getPixel(x, y).r;
      }
    }
    final double average = total / 64.0;
    BigInt hash = BigInt.zero;
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        if (smallImg.getPixel(x, y).r >= average) {
          hash |= (BigInt.one << (y * 8 + x));
        }
      }
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  int hammingDistance(String pHash1, String pHash2) {
    if (pHash1.length != pHash2.length) return pHash1.length;
    final val1 = BigInt.parse(pHash1, radix: 16);
    final val2 = BigInt.parse(pHash2, radix: 16);
    BigInt xor = val1 ^ val2;
    int distance = 0;
    while (xor > BigInt.zero) {
      distance += (xor & BigInt.one) == BigInt.one ? 1 : 0;
      xor >>= 1;
    }
    return distance;
  }

  double _calculateLaplacianVariance(img.Image image) {
    final laplace = img.convolution(image, filter: [
      0, 1, 0,
      1, -4, 1,
      0, 1, 0,
    ]);
    final pixels = laplace.getBytes(order: img.ChannelOrder.red);
    double mean = pixels.reduce((a, b) => a + b) / pixels.length;
    double variance =
        pixels.map((p) => math.pow(p - mean, 2)).reduce((a, b) => a + b) /
            pixels.length;
    return variance;
  }

  Map<String, double> _calculateLuminanceAndEntropy(img.Image image) {
    final luminances = <int>[];
    final histogram = List<int>.filled(256, 0);
    for (final pixel in image) {
      final luminance = pixel.r.toInt();
      luminances.add(luminance);
      histogram[luminance]++;
    }
    final double meanLuminance =
        luminances.reduce((a, b) => a + b) / luminances.length;
    double entropy = 0.0;
    final int totalPixels = luminances.length;
    for (int count in histogram) {
      if (count > 0) {
        double probability = count / totalPixels;
        entropy -= probability * (math.log(probability) / math.log(2));
      }
    }
    return {'luminance': meanLuminance, 'entropy': entropy};
  }

  double _calculateEdgeDensity(img.Image image) {
    final edgeImage = img.sobel(image);
    final edgePixels = edgeImage.getBytes(order: img.ChannelOrder.red);
    int edgeCount = edgePixels.where((p) => p > 50).length;
    return edgeCount / edgePixels.length;
  }

  Future<PhotoAnalysisResult> analyze(Uint8List imageBytes,
      {bool isFromScreenshotAlbum = false}) async {

    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Could not decode image");
    }
    
    // Use a small, grayscale image for fast analysis.
    final lowResGray = img.copyResize(originalImage,
        width: 64, height: 64, interpolation: img.Interpolation.average);
    img.grayscale(lowResGray);
    
    final md5Hash = md5.convert(imageBytes).toString();
    
    // All calculations are synchronous and fast enough on the small image.
    final pHash = await calculatePerceptualHash(lowResGray);
    final blurScore = _calculateLaplacianVariance(lowResGray);
    final lumAndEntropy = _calculateLuminanceAndEntropy(lowResGray);
    final edgeScore = _calculateEdgeDensity(lowResGray);

    return PhotoAnalysisResult(
      md5Hash: md5Hash,
      pHash: pHash,
      blurScore: blurScore,
      luminanceScore: lumAndEntropy['luminance']!,
      entropyScore: lumAndEntropy['entropy']!,
      edgeDensityScore: edgeScore,
      isFromScreenshotAlbum: isFromScreenshotAlbum,
    );
  }
}
