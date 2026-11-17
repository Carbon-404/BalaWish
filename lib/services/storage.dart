import 'dart:convert';

import 'package:balawish/models/stats/stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sauvegarde des stats local, en JSON sous une clé
class StatsStorage {
  static const _key = 'stats';

  late final _prefs = SharedPreferencesAsync();

  // Stats sauvegardées, ou des stats vides (premier lancement,données illisibles)
  Future<Stat> load() async {
    final json = await _prefs.getString(_key);
    if (json == null) return Stat();
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, Object?>) return Stat.fromJson(decoded);
    } on FormatException {
      // Remet les stats vides
    }
    return Stat();
  }

  Future<void> save(Stat stats) {
    return _prefs.setString(_key, jsonEncode(stats.toJson()));
  }
}