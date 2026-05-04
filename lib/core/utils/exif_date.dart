import 'package:exif/exif.dart';

const _candidateTags = <String>[
  'EXIF DateTimeOriginal',
  'EXIF DateTimeDigitized',
  'Image DateTime',
];

Future<DateTime?> readImageDateTimeFromBytes(List<int> bytes) async {
  try {
    final tags = await readExifFromBytes(bytes);
    if (tags.isEmpty) return null;
    for (final key in _candidateTags) {
      final tag = tags[key];
      if (tag == null) continue;
      final parsed = _parseExifDate(tag.printable);
      if (parsed != null) return parsed;
    }
    return null;
  } catch (_) {
    return null;
  }
}

DateTime? _parseExifDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final parts = s.split(' ');
  if (parts.length < 2) return null;
  final dateParts = parts[0].split(':');
  final timeParts = parts[1].split(':');
  if (dateParts.length != 3 || timeParts.length < 2) return null;
  final year = int.tryParse(dateParts[0]);
  final month = int.tryParse(dateParts[1]);
  final day = int.tryParse(dateParts[2]);
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  final second = timeParts.length >= 3 ? int.tryParse(timeParts[2]) ?? 0 : 0;
  if (year == null ||
      month == null ||
      day == null ||
      hour == null ||
      minute == null) {
    return null;
  }
  if (year <= 0 || month <= 0 || day <= 0) return null;
  try {
    return DateTime(year, month, day, hour, minute, second);
  } catch (_) {
    return null;
  }
}
