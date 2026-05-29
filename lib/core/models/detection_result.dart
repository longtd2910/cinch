import 'package:photo_manager/photo_manager.dart';

class DetectionResult {
  final AssetEntity asset;
  final double confidence;
  final String? thumbnailPath;

  DetectionResult({
    required this.asset,
    required this.confidence,
    this.thumbnailPath,
  });
}
