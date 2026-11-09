import 'dart:async';

import 'package:balawish/services/purse_storage.dart';
import 'package:flutter/foundation.dart';

// Bourse du joueur partagée par toute l'application, chargée au démarrage
final playerPurse = PurseController(PurseStorage());

// Bourse globale : les pièces gardées d'une partie à l'autre, contrairement
// aux pièces d'une partie qui repartent toujours de 0
class PurseController extends ChangeNotifier {
  PurseController(this._storage);

  final PurseStorage _storage;
  int _coins = 0;

  int get coins => _coins;

  Future<void> load() async {
    _coins = await _storage.load();
    notifyListeners();
  }

  bool canSpend(int amount) => amount <= _coins;

  void deposit(int amount) {
    if (amount <= 0) return;
    _coins += amount;
    _save();
  }

  // Retire [amount] pièces si la bourse en contient assez, sinon ne fait rien
  bool spend(int amount) {
    if (!canSpend(amount)) return false;
    _coins -= amount;
    _save();
    return true;
  }

  // Sauvegarde en arrière-plan : le jeu n'attend pas l'écriture sur le disque
  void _save() {
    notifyListeners();
    unawaited(_storage.save(_coins));
  }
}
