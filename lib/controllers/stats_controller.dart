import 'dart:async';

import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/stats/player_stats.dart';
import 'package:balawish/services/stats_storage.dart';
import 'package:flutter/foundation.dart';

// Statistiques du joueur partagées par toute l'application, chargées au démarrage
final playerStats = StatsController(StatsStorage());

// Met à jour les statistiques, les sauvegarde aussitôt et prévient l'écran
// des statistiques
class StatsController extends ChangeNotifier {
  StatsController(this._storage);

  final StatsStorage _storage;
  PlayerStats _stats = PlayerStats();

  PlayerStats get stats => _stats;

  Future<void> load() async {
    _stats = await _storage.load();
    notifyListeners();
  }

  void recordHand(PokerHand hand) {
    _stats.recordHand(hand);
    _save();
  }

  void recordGame({required int score, required int round}) {
    _stats.recordGame(score: score, round: round);
    _save();
  }

  // Sauvegarde en arrière-plan : le jeu n'attend pas l'écriture sur le disque
  void _save() {
    notifyListeners();
    unawaited(_storage.save(_stats));
  }
}
