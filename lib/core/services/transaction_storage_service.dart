import 'package:cinch/core/models/transaction.dart';
import 'package:hive_ce/hive.dart';

class TransactionStorageService {
  static const boxName = 'transactions';

  final Box<Map> _box;

  TransactionStorageService(this._box);

  Future<int> add(Transaction transaction) {
    return _box.add(transaction.toJson());
  }

  Future<void> update(int key, Transaction transaction) {
    return _box.put(key, transaction.toJson());
  }

  Future<void> delete(int key) {
    return _box.delete(key);
  }

  Future<int> clear() {
    return _box.clear();
  }

  List<Transaction> loadAll() {
    return _box.values
        .map((raw) => Transaction.fromJson(Map<String, dynamic>.from(raw)))
        .where((t) => t.deletedAt == null)
        .toList();
  }
}
