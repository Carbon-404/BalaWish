import 'package:shared_preferences/shared_preferences.dart';

// Sauvegarde sur le téléphone des pièces de la bourse du joueur
class PurseStorage {
  static const _key = 'purse_coins';

  // Ouvert à la première utilisation seulement
  late final _prefs = SharedPreferencesAsync();

  // 0 au premier lancement
  Future<int> load() async => await _prefs.getInt(_key) ?? 0;

  Future<void> save(int coins) => _prefs.setInt(_key, coins);
}
