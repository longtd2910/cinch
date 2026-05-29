import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/detection_result.dart';
import 'package:cinch/core/services/transaction_classifier.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

class DetectionState {
  final List<DetectionResult> results;
  final int totalPhotos;
  final int processedPhotos;
  final bool isComplete;

  DetectionState({
    required this.results,
    required this.totalPhotos,
    required this.processedPhotos,
    this.isComplete = false,
  });

  DetectionState copyWith({
    List<DetectionResult>? results,
    int? totalPhotos,
    int? processedPhotos,
    bool? isComplete,
  }) {
    return DetectionState(
      results: results ?? this.results,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      processedPhotos: processedPhotos ?? this.processedPhotos,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class DetectionProvider extends ChangeNotifier {
  final TransactionClassifier _classifier;

  UIState<DetectionState> _state = Initial();
  UIState<DetectionState> get state => _state;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isInitialized = false;

  List<AssetEntity> _pendingPhotos = [];
  final List<DetectionResult> _results = [];
  final Set<String> _processedIds = {};
  final Set<String> _dismissedIds = {};
  int _totalPhotos = 0;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  DetectionProvider(this._classifier);

  Future<void> startOrResume() async {
    if (_isRunning && !_isPaused) return;

    if (_isPaused) {
      _isPaused = false;
      _continueScanning();
      return;
    }

    _isRunning = true;
    _isPaused = false;

    _state = Loading(DetectionState(
      results: List.unmodifiable(_results),
      totalPhotos: 0,
      processedPhotos: _processedIds.length,
    ));
    notifyListeners();

    try {
      if (!_isInitialized) {
        await _classifier.init();
        _isInitialized = true;
      }

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        _state = Error('Photo access denied');
        _isRunning = false;
        notifyListeners();
        return;
      }

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

      final List<AssetEntity> allPhotos = [];
      for (final album in albums) {
        final count = await album.assetCountAsync;
        if (count == 0) continue;
        final assets = await album.getAssetListRange(start: 0, end: count);
        allPhotos.addAll(assets);
      }

      final seen = <String>{};
      final uniquePhotos = allPhotos.where((a) => seen.add(a.id)).toList();

      _pendingPhotos = uniquePhotos
          .where((a) => !_processedIds.contains(a.id))
          .toList();
      _totalPhotos = uniquePhotos.length;

      if (_pendingPhotos.isEmpty) {
        _state = Success(DetectionState(
          results: List.unmodifiable(_results),
          totalPhotos: _totalPhotos,
          processedPhotos: _processedIds.length,
          isComplete: true,
        ));
        _isRunning = false;
        notifyListeners();
        return;
      }

      _state = Loading(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
      ));
      notifyListeners();

      await _continueScanning();
    } catch (e) {
      _state = Error('Detection failed: $e');
      _isRunning = false;
      notifyListeners();
    }
  }

  Future<void> _continueScanning() async {
    while (_pendingPhotos.isNotEmpty && !_isPaused) {
      final asset = _pendingPhotos.removeAt(0);
      if (_processedIds.contains(asset.id)) continue;

      try {
        final file = await asset.file;
        if (file == null) {
          _processedIds.add(asset.id);
          continue;
        }

        final bytes = await file.readAsBytes();
        final image = img.decodeImage(Uint8List.fromList(bytes));
        if (image == null) {
          _processedIds.add(asset.id);
          continue;
        }

        final result = await _classifier.classify(image);
        _processedIds.add(asset.id);

        if (result['is_transaction'] == true) {
          _results.add(DetectionResult(
            asset: asset,
            confidence: result['confidence'] as double,
          ));
        }
      } catch (_) {
        _processedIds.add(asset.id);
      }

      _state = Loading(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
      ));
      notifyListeners();
    }

    if (!_isPaused) {
      _state = Success(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
        isComplete: true,
      ));
      _isRunning = false;
      notifyListeners();
    }
  }

  void pause() {
    if (_isRunning && !_isPaused) {
      _isPaused = true;
    }
  }

  Future<void> scanForDate(DateTime date) async {
    _isRunning = true;
    _isPaused = false;
    _results.clear();
    _processedIds.clear();
    _pendingPhotos = [];
    _totalPhotos = 0;

    _state = Loading(DetectionState(
      results: [],
      totalPhotos: 0,
      processedPhotos: 0,
    ));
    notifyListeners();

    try {
      if (!_isInitialized) {
        await _classifier.init();
        _isInitialized = true;
      }

      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        _state = Error('Photo access denied');
        _isRunning = false;
        notifyListeners();
        return;
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      final filterOption = FilterOptionGroup(
        createTimeCond: DateTimeCond(min: startOfDay, max: endOfDay),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      );

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: filterOption,
      );

      final List<AssetEntity> allPhotos = [];
      for (final album in albums) {
        final count = await album.assetCountAsync;
        if (count == 0) continue;
        final assets = await album.getAssetListRange(start: 0, end: count);
        allPhotos.addAll(assets);
      }

      final seen = <String>{};
      _pendingPhotos = allPhotos.where((a) => seen.add(a.id)).toList();
      _totalPhotos = _pendingPhotos.length;

      if (_pendingPhotos.isEmpty) {
        _state = Success(DetectionState(
          results: [],
          totalPhotos: 0,
          processedPhotos: 0,
          isComplete: true,
        ));
        _isRunning = false;
        notifyListeners();
        return;
      }

      _state = Loading(DetectionState(
        results: [],
        totalPhotos: _totalPhotos,
        processedPhotos: 0,
      ));
      notifyListeners();

      await _continueScanning();
    } catch (e) {
      _state = Error('Detection failed: $e');
      _isRunning = false;
      notifyListeners();
    }
  }

  void dismissResult(int index) {
    if (index < 0 || index >= _results.length) return;
    final removed = _results.removeAt(index);
    _dismissedIds.add(removed.asset.id);

    if (_state is Loading<DetectionState>) {
      _state = Loading(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
      ));
    } else if (_state is Success<DetectionState>) {
      _state = Success(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
        isComplete: true,
      ));
    }
    notifyListeners();
  }

  void removeResult(int index) {
    if (index < 0 || index >= _results.length) return;
    _results.removeAt(index);

    if (_state is Loading<DetectionState>) {
      _state = Loading(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
      ));
    } else if (_state is Success<DetectionState>) {
      _state = Success(DetectionState(
        results: List.unmodifiable(_results),
        totalPhotos: _totalPhotos,
        processedPhotos: _processedIds.length,
        isComplete: true,
      ));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _classifier.dispose();
    }
    super.dispose();
  }
}
