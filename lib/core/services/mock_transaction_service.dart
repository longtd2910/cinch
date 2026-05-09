import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/services/image_storage_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';

class MockTransactionService {
  static const _minTransactionsPerDay = 5;
  static const _maxTransactionsPerDay = 10;
  static const _exampleImageUrls = [
    'https://picsum.photos/id/1060/480/640',
    'https://picsum.photos/id/1080/480/640',
    'https://picsum.photos/id/292/480/640',
    'https://picsum.photos/id/431/480/640',
    'https://picsum.photos/id/488/480/640',
  ];

  final TransactionStorageService _transactionStorage;
  final ImageStorageService _imageStorage;
  final Random _random;
  final List<String> _mockImagePaths = [];

  MockTransactionService(
    this._transactionStorage,
    this._imageStorage, {
    Random? random,
  }) : _random = random ?? Random();

  Future<int> createForEmptyPastDays(int days, {DateTime? now}) async {
    if (days <= 0) return 0;

    final today = _dateOnly(now ?? DateTime.now());
    final occupiedDates = _transactionStorage
        .loadAll()
        .map((transaction) => _dateKey(transaction.time))
        .toSet();

    final missingDates = <DateTime>[];
    for (var offset = 1; offset <= days; offset++) {
      final date = today.subtract(Duration(days: offset));
      if (!occupiedDates.contains(_dateKey(date))) {
        missingDates.add(date);
      }
    }
    if (missingDates.isEmpty) return 0;

    final imagePaths = await _loadMockImagePaths();

    var createdCount = 0;
    for (final date in missingDates) {
      final transactionsForDay =
          _minTransactionsPerDay +
          _random.nextInt(_maxTransactionsPerDay - _minTransactionsPerDay + 1);

      for (var index = 0; index < transactionsForDay; index++) {
        final imagePath = imagePaths[_random.nextInt(imagePaths.length)];
        await _transactionStorage.add(_createMockTransaction(date, imagePath));
        createdCount++;
      }
      occupiedDates.add(_dateKey(date));
    }

    return createdCount;
  }

  Future<List<String>> _loadMockImagePaths() async {
    if (_mockImagePaths.isNotEmpty) return _mockImagePaths;

    for (var index = 0; index < _exampleImageUrls.length; index++) {
      final bytes = await _downloadBytes(_exampleImageUrls[index]);
      final path = await _imageStorage.saveBytes(
        bytes,
        'mock_transaction_${index + 1}.jpg',
      );
      _mockImagePaths.add(path);
    }

    return _mockImagePaths;
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to download mock image',
          uri: Uri.parse(url),
        );
      }

      final chunks = <int>[];
      await for (final chunk in response) {
        chunks.addAll(chunk);
      }
      return Uint8List.fromList(chunks);
    } finally {
      client.close(force: true);
    }
  }

  Transaction _createMockTransaction(DateTime date, String imagePath) {
    final time = date.add(
      Duration(hours: 8 + _random.nextInt(12), minutes: _random.nextInt(60)),
    );
    final createdAt = DateTime.now();

    return Transaction(
      time: time,
      amount: 10000 + _random.nextInt(190000),
      imageUrl: imagePath,
      tags: const ['Mock'],
      note: 'Mock transaction',
      location: 'Mock location',
      type: false,
      source: 'Mock source',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _dateKey(DateTime value) {
    final date = _dateOnly(value);
    return '${date.year}-${date.month}-${date.day}';
  }
}
