import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/devotional.dart';

class SavedStore {
  static const _key = 'vozdafe.saved.v1';

  Future<List<Devotional>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final items = <Devotional>[];
    for (final item in raw) {
      try {
        final json = jsonDecode(item);
        if (json is Map<String, dynamic>) {
          items.add(Devotional.fromJson(json));
        }
      } catch (_) {
        // Skip a corrupted entry but preserve all other favorites.
      }
    }
    return items;
  }

  Future<void> save(List<Devotional> items) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setStringList(
      _key,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
    if (!success) throw StateError('Não foi possível salvar neste dispositivo.');
  }
}
