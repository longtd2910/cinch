import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:workmanager/workmanager.dart';

class ScanScheduleService extends ChangeNotifier {
  static const boxName = 'scan_schedule';
  static const taskName = 'daily_photo_scan';
  static const taskUniqueName = 'com.cinch.dailyPhotoScan';

  static const _keyEnabled = 'enabled';
  static const _keyHour = 'hour';
  static const _keyMinute = 'minute';

  static const _defaultHour = 22;
  static const _defaultMinute = 0;

  final Box _box;

  ScanScheduleService(this._box);

  bool get enabled => _box.get(_keyEnabled, defaultValue: false) as bool;
  int get hour => _box.get(_keyHour, defaultValue: _defaultHour) as int;
  int get minute => _box.get(_keyMinute, defaultValue: _defaultMinute) as int;
  TimeOfDay get scheduledTime => TimeOfDay(hour: hour, minute: minute);

  Future<void> setEnabled(bool value) async {
    await _box.put(_keyEnabled, value);
    if (value) {
      await _registerTask();
    } else {
      await _cancelTask();
    }
    notifyListeners();
  }

  Future<void> setTime(TimeOfDay time) async {
    await _box.put(_keyHour, time.hour);
    await _box.put(_keyMinute, time.minute);
    if (enabled) {
      await _registerTask();
    }
    notifyListeners();
  }

  Duration _initialDelay() {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.difference(now);
  }

  Future<void> _registerTask() async {
    await Workmanager().cancelByUniqueName(taskUniqueName);
    await Workmanager().registerPeriodicTask(
      taskUniqueName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _initialDelay(),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
    );
  }

  Future<void> _cancelTask() async {
    await Workmanager().cancelByUniqueName(taskUniqueName);
  }

  Future<void> rescheduleIfEnabled() async {
    if (enabled) {
      await _registerTask();
    }
  }
}
