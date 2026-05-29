import 'dart:typed_data';

import 'package:cinch/core/models/detection_result.dart';
import 'package:cinch/core/services/transaction_classifier.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class PhotoScannerService {
  final TransactionClassifier _classifier;

  PhotoScannerService(this._classifier);

  Future<List<AssetEntity>> getPhotosForDate(DateTime date) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final filterOption = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: startOfDay, max: endOfDay),
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) return [];

    final List<AssetEntity> allPhotos = [];
    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count == 0) continue;
      final assets = await album.getAssetListRange(start: 0, end: count);
      allPhotos.addAll(assets);
    }

    final seen = <String>{};
    return allPhotos.where((a) => seen.add(a.id)).toList();
  }

  Future<List<DetectionResult>> scanPhotos(
    List<AssetEntity> photos, {
    void Function(int processed, int total)? onProgress,
  }) async {
    final results = <DetectionResult>[];

    for (int i = 0; i < photos.length; i++) {
      final asset = photos[i];
      try {
        final file = await asset.file;
        if (file == null) continue;

        final bytes = await file.readAsBytes();
        final image = img.decodeImage(Uint8List.fromList(bytes));
        if (image == null) continue;

        final result = await _classifier.classify(image);

        if (result['is_transaction'] == true) {
          results.add(DetectionResult(
            asset: asset,
            confidence: result['confidence'] as double,
          ));
        }
      } catch (_) {}

      onProgress?.call(i + 1, photos.length);
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }
}
