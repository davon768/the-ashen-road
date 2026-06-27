import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'game_state.dart';

class SaveService {
  static const String _saveFileName = 'ashen_road_save.json';

  Future<File> get _saveFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_saveFileName');
  }

  Future<void> save(GameState state) async {
    final file = await _saveFile;
    final json = jsonEncode(state.toJson());
    await file.writeAsString(json);
  }

  Future<GameState?> load() async {
    try {
      final file = await _saveFile;
      if (!await file.exists()) return null;
      final json = await file.readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      return GameState.fromJson(data);
    } catch (_) {
      // Corrupted or incompatible save — start fresh
      return null;
    }
  }

  Future<void> deleteSave() async {
    final file = await _saveFile;
    if (await file.exists()) await file.delete();
  }

  Future<bool> hasSave() async {
    final file = await _saveFile;
    return file.exists();
  }
}
