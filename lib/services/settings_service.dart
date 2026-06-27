import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  static const _fileName = 'ashen_road_settings.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      final f = await _file;
      if (!await f.exists()) return {};
      return jsonDecode(await f.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final f = await _file;
    await f.writeAsString(jsonEncode(data));
  }

  Future<String?> getReplicateApiKey() async {
    final data = await _read();
    return data['replicateApiKey'] as String?;
  }

  Future<void> setReplicateApiKey(String key) async {
    final data = await _read();
    data['replicateApiKey'] = key;
    await _write(data);
  }
}
