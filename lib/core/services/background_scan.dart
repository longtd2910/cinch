import 'dart:typed_data';

import 'package:cinch/core/services/scan_schedule_service.dart';
import 'package:cinch/core/services/transaction_classifier.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void backgroundScanCallback() {
  Workmanager().executeTask((task, inputData) async {
    if (task != ScanScheduleService.taskName &&
        task != Workmanager.iOSBackgroundTask) {
      return true;
    }

    try {
      await Hive.initFlutter();
      final resultsBox = await Hive.openBox<Map>('scan_results');

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) return true;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final filterOption = FilterOptionGroup(
        createTimeCond: DateTimeCond(min: startOfDay, max: now),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      );

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: filterOption,
      );

      final List<AssetEntity> photos = [];
      for (final album in albums) {
        final count = await album.assetCountAsync;
        if (count == 0) continue;
        final assets = await album.getAssetListRange(start: 0, end: count);
        photos.addAll(assets);
      }

      final seen = <String>{};
      final uniquePhotos = photos.where((a) => seen.add(a.id)).toList();

      if (uniquePhotos.isEmpty) return true;

      final classifier = TransactionClassifier();
      await classifier.init();

      final detections = <Map<String, dynamic>>[];

      for (final asset in uniquePhotos) {
        try {
          final file = await asset.file;
          if (file == null) continue;
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(Uint8List.fromList(bytes));
          if (image == null) continue;

          final result = await classifier.classify(image);
          if (result['is_transaction'] == true) {
            detections.add({
              'assetId': asset.id,
              'confidence': result['confidence'],
              'timestamp': now.toIso8601String(),
            });
          }
        } catch (_) {}
      }

      classifier.dispose();

      if (detections.isNotEmpty) {
        await resultsBox.put(
          now.toIso8601String().split('T').first,
          {
            'date': now.toIso8601String(),
            'count': detections.length,
            'detections': detections,
          },
        );
      }

      await resultsBox.close();
    } catch (_) {}

    return true;
  });
}
