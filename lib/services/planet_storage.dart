import 'dart:convert';

import 'package:balawish/models/planets/hand_levels.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sauvegarde sur le téléphone des niveaux de mains obtenus avec les planètes
class PlanetStorage {
  static const _key = 'hand_levels';

  // Ouvert à la première utilisation seulement
  late final _prefs = SharedPreferencesAsync();

  // Niveaux sauvegardés, ou tous au niveau de départ (premier lancement,
  // données illisibles)
  Future<HandLevels> load() async {
    final json = await _prefs.getString(_key);
    if (json == null) return HandLevels();
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, Object?>) return HandLevels.fromJson(decoded);
    } on FormatException {
      // JSON illisible : on repart des niveaux de départ
    }
    return HandLevels();
  }

  Future<void> save(HandLevels levels) {
    return _prefs.setString(_key, jsonEncode(levels.toJson()));
  }
}
