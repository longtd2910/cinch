import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/services/image_storage_service.dart';
import 'package:cinch/core/services/location_storage_service.dart';
import 'package:cinch/core/services/money_source_storage_service.dart';
import 'package:cinch/core/services/tag_storage_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/core/utils/date_time_format.dart';
import 'package:cinch/core/utils/exif_date.dart';
import 'package:cinch/core/utils/money_format.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionScreenState {
  final String? imagePath;

  AddTransactionScreenState({required this.imagePath});
}

class AddTransactionScreenProvider extends ChangeNotifier {
  static const fieldAmount = 'amount';
  static const fieldLocation = 'location';
  static const fieldMoneySource = 'moneySource';
  static const fieldTag = 'tag';

  final amountTextController = TextEditingController();
  final noteTextController = TextEditingController();

  final LocationStorageService _locationStorage;
  final MoneySourceStorageService _moneySourceStorage;
  final TagStorageService _tagStorage;
  final TransactionStorageService _transactionStorage;

  final List<String> _locationOptions = [];
  List<String> get locationOptions => List.unmodifiable(_locationOptions);

  String? _selectedLocation;
  String? get selectedLocation => _selectedLocation;

  final List<String> _moneySourceOptions = [];
  List<String> get moneySourceOptions =>
      List.unmodifiable(_moneySourceOptions);

  String? _selectedMoneySource;
  String? get selectedMoneySource => _selectedMoneySource;

  final List<String> _tagOptions = [];
  List<String> get tagOptions => List.unmodifiable(_tagOptions);

  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  bool _isIncome = false;
  bool get isIncome => _isIncome;

  DateTime? _selectedTime;
  DateTime? get selectedTime => _selectedTime;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  final Set<String> _invalidFields = <String>{};
  Set<String> get invalidFields => Set.unmodifiable(_invalidFields);
  bool isFieldInvalid(String field) => _invalidFields.contains(field);

  int _errorTick = 0;
  int get errorTick => _errorTick;

  Future<void> setLocation(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final added = !_locationOptions.contains(t);
    if (added) {
      _locationOptions.add(t);
    }
    _selectedLocation = t;
    _invalidFields.remove(fieldLocation);
    notifyListeners();
    if (added) {
      await _locationStorage.save(_locationOptions);
    }
  }

  Future<void> setMoneySource(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final added = !_moneySourceOptions.contains(t);
    if (added) {
      _moneySourceOptions.add(t);
    }
    _selectedMoneySource = t;
    _invalidFields.remove(fieldMoneySource);
    notifyListeners();
    if (added) {
      await _moneySourceStorage.save(_moneySourceOptions);
    }
  }

  Future<void> setTag(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final added = !_tagOptions.contains(t);
    if (added) {
      _tagOptions.add(t);
    }
    _selectedTag = t;
    _invalidFields.remove(fieldTag);
    notifyListeners();
    if (added) {
      await _tagStorage.save(_tagOptions);
    }
  }

  void setIsIncome(bool value) {
    if (_isIncome == value) return;
    _isIncome = value;
    notifyListeners();
  }

  void setSelectedTime(DateTime? value) {
    if (_selectedTime == value) return;
    _selectedTime = value;
    notifyListeners();
  }

  UIState<AddTransactionScreenState> _state = Initial();
  UIState<AddTransactionScreenState> get state => _state;

  final AddTransactionScreenState initialScreenState;

  AddTransactionScreenProvider({
    required this.initialScreenState,
    required LocationStorageService locationStorage,
    required MoneySourceStorageService moneySourceStorage,
    required TagStorageService tagStorage,
    required TransactionStorageService transactionStorage,
    DateTime? initialTime,
  })  : _locationStorage = locationStorage,
        _moneySourceStorage = moneySourceStorage,
        _tagStorage = tagStorage,
        _transactionStorage = transactionStorage,
        _selectedTime = initialTime {
    _state = Success(initialScreenState);
    amountTextController.addListener(_onAmountChanged);
    _loadLocations();
    _loadMoneySources();
    _loadTags();
  }

  void _onAmountChanged() {
    if (!_invalidFields.contains(fieldAmount)) return;
    final amount = parseMoneyFromCommas(amountTextController.text);
    if (amount > 0) {
      _invalidFields.remove(fieldAmount);
      notifyListeners();
    }
  }

  Future<void> _loadLocations() async {
    final stored = await _locationStorage.load();
    _locationOptions
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> _loadMoneySources() async {
    final stored = await _moneySourceStorage.load();
    _moneySourceOptions
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> _loadTags() async {
    final stored = await _tagStorage.load();
    _tagOptions
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> setImagePath(XFile image, BuildContext context) async {
    final imageStorage = ImageStorageService();
    final bytes = await image.readAsBytes();
    final imagePath = await imageStorage.saveBytes(
      bytes,
      '${yymmddHHmmss(DateTime.now())}.jpeg',
    );
    final capturedAt = await readImageDateTimeFromBytes(bytes);
    if (capturedAt != null) {
      _selectedTime = capturedAt;
    }
    _state = Success(AddTransactionScreenState(imagePath: imagePath));
    notifyListeners();
  }

  Set<String> _validate(int amount) {
    final missing = <String>{};
    if (amount <= 0) missing.add(fieldAmount);
    if (_selectedLocation == null) missing.add(fieldLocation);
    if (_selectedMoneySource == null) missing.add(fieldMoneySource);
    if (_selectedTag == null) missing.add(fieldTag);
    return missing;
  }

  Future<bool> submit() async {
    if (_isSubmitting) return false;

    final amount = parseMoneyFromCommas(amountTextController.text);
    final missing = _validate(amount);
    _invalidFields
      ..clear()
      ..addAll(missing);
    if (_invalidFields.isNotEmpty) {
      _errorTick++;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final currentState = _state is Success<AddTransactionScreenState>
          ? (_state as Success<AddTransactionScreenState>).data
          : initialScreenState;
      final now = DateTime.now();
      final transaction = Transaction(
        time: _selectedTime ?? now,
        amount: amount,
        tags: [_selectedTag!],
        note: noteTextController.text.trim(),
        location: _selectedLocation!,
        type: _isIncome,
        source: _selectedMoneySource!,
        imageUrl: currentState.imagePath ?? '',
        createdAt: now,
        updatedAt: now,
      );
      await _transactionStorage.add(transaction);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    amountTextController.removeListener(_onAmountChanged);
    amountTextController.dispose();
    noteTextController.dispose();
    super.dispose();
  }
}
