import 'dart:async';

import 'package:balawish/models/calculator/hand_score.dart';
import 'package:balawish/models/game/game.dart';
import 'package:balawish/models/stats/stats.dart';
import 'package:balawish/services/storage.dart';
import 'package:flutter/foundation.dart';

// Statistiques du joueur partagées par toute l'application, chargées au démarrage
final playerStats = StatsController(StatsStorage());

// Met à jour les statistiques, les sauvegarde aussitôt et prévient l'écran
// des statistiques
class StatsController extends ChangeNotifier {
  StatsController(this._storage);

  final StatsStorage _storage;
  Stat _stats = Stat();

  Stat get stats => _stats;

  Future<void> load() async {
    _stats = await _storage.load();
    notifyListeners();
  }

  void recordHand(PokerHand hand) {
    _stats.recordHand(hand);
    _save();
  }

  void recordGame({
    required int score,
    required int round,
    required GameMode mode,
  }) {
    _stats.recordGame(score: score, round: round, mode: mode);
    _save();
  }

  // Sauvegarde en arrière-plan
  void _save() {
    notifyListeners();
    unawaited(_storage.save(_stats));
  }
}
