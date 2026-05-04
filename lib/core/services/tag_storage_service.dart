import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TagStorageService {
  static const _fileName = 'tags.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<String>> load() async {
    final file = await _file();
    if (!await file.exists()) return const [];
    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<String> tags) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(tags));
  }
}
