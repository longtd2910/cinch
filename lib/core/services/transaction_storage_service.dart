import 'package:cinch/core/models/transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class TransactionStorageService extends ChangeNotifier {
  static const boxName = 'transactions';

  final Box<Map> _box;

  int _dataRevision = 0;
  int get dataRevision => _dataRevision;

  TransactionStorageService(this._box);

  void _afterWrite() {
    _dataRevision++;
    notifyListeners();
  }

  Future<int> add(Transaction transaction) async {
    final key = await _box.add(transaction.toJson());
    _afterWrite();
    return key;
  }

  Future<void> update(int key, Transaction transaction) async {
    await _box.put(key, transaction.toJson());
    _afterWrite();
  }

  Future<void> delete(int key) async {
    await _box.delete(key);
    _afterWrite();
  }

  Future<int> clear() async {
    final n = await _box.clear();
    _afterWrite();
    return n;
  }

  List<Transaction> loadAll() {
    return _box.values
        .map((raw) => Transaction.fromJson(Map<String, dynamic>.from(raw)))
        .where((t) => t.deletedAt == null)
        .toList();
  }
}
