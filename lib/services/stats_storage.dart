import 'dart:convert';

import 'package:balawish/models/stats/player_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sauvegarde des statistiques sur le téléphone, en JSON sous une seule clé
// Les données sont conservées quand l'application est fermée puis relancée
class StatsStorage {
  static const _key = 'player_stats';

  // Ouvert à la première utilisation seulement
  late final _prefs = SharedPreferencesAsync();

  // Statistiques sauvegardées, ou des statistiques vides (premier lancement,
  // données illisibles)
  Future<PlayerStats> load() async {
    final json = await _prefs.getString(_key);
    if (json == null) return PlayerStats();
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, Object?>) return PlayerStats.fromJson(decoded);
    } on FormatException {
      // JSON illisible : on repart de statistiques vides
    }
    return PlayerStats();
  }

  Future<void> save(PlayerStats stats) {
    return _prefs.setString(_key, jsonEncode(stats.toJson()));
  }
}
