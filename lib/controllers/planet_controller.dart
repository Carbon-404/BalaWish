import 'dart:async';

import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/models/planets/hand_levels.dart';
import 'package:balawish/models/planets/planet.dart';
import 'package:balawish/services/planet_storage.dart';
import 'package:flutter/foundation.dart';

// Niveaux des mains partagés par toute l'application, chargés au démarrage
final playerPlanets = PlanetController(PlanetStorage(), playerPurse);

// Achat des planètes avec les pièces de la bourse, et niveaux des mains qui
// en découlent (conservés d'une partie à l'autre)
class PlanetController extends ChangeNotifier {
  PlanetController(this._storage, this._purse);

  final PlanetStorage _storage;
  final PurseController _purse;
  HandLevels _levels = HandLevels();

  HandLevels get levels => _levels;

  Future<void> load() async {
    _levels = await _storage.load();
    notifyListeners();
  }

  int levelOf(Planet planet) => _levels.levelOf(planet.hand);

  // Prix du prochain niveau de [planet]
  int priceOf(Planet planet) => Planet.priceFor(levelOf(planet));

  bool canBuy(Planet planet) => _purse.canSpend(priceOf(planet));

  // Paie la planète avec la bourse et monte sa main d'un niveau
  // Renvoie false si la bourse ne contient pas assez de pièces
  bool buy(Planet planet) {
    if (!_purse.spend(priceOf(planet))) return false;
    _levels.upgrade(planet.hand);
    notifyListeners();
    unawaited(_storage.save(_levels));
    return true;
  }
}
