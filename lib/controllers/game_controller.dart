import 'dart:math';

import 'package:balawish/controllers/planet_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:flutter/foundation.dart';

/// Fait le lien entre la partie (logique pure) et l'interface : chaque action
/// modifie le modèle puis prévient les widgets qui l'écoutent.
class GameController extends ChangeNotifier {
  GameController({
    Random? random,
    StatsController? stats,
    PurseController? purse,
    PlanetController? planets,
  }) : _random = random,
       _stats = stats ?? playerStats,
       _purse = purse ?? playerPurse,
       _planets = planets ?? playerPlanets;

  final Random? _random;
  final StatsController _stats;
  final PurseController _purse;
  final PlanetController _planets;
  late GameRun run = _newRun();

  // Une partie ne compte dans les statistiques qu'à partir de la 1re main jouée
  bool _hasPlayedHand = false;

  // La partie en cours est déjà enregistrée dans les statistiques
  bool _isRecorded = false;

  Round get round => run.currentRound;

  void toggleSelection(PlayingCard card) {
    if (round.toggleSelection(card)) notifyListeners();
  }

  void play() {
    if (!round.canPlay) return;
    final score = round.play();
    _hasPlayedHand = true;
    _stats.recordHand(score.hand);
    if (run.isOver) _recordGame();
    notifyListeners();
  }

  void discard() {
    if (!round.canDiscard) return;
    run.discard();
    notifyListeners();
  }

  void openShop() {
    run.openShop();
    notifyListeners();
  }

  void buyJoker(int offerIndex) {
    if (!run.canBuy(offerIndex)) return;
    run.buyJoker(offerIndex);
    notifyListeners();
  }

  void sellJoker(int index) {
    run.sellJoker(index);
    notifyListeners();
  }

  void moveJoker(int from, int to) {
    run.moveJoker(from, to);
    notifyListeners();
  }

  void nextRound() {
    run.nextRound();
    notifyListeners();
  }

  void restart() {
    _recordGame();
    run = _newRun();
    _hasPlayedHand = false;
    _isRecorded = false;
    notifyListeners();
  }

  // Quitter le plateau en cours de partie compte comme une partie jouée (et perdue)
  @override
  void dispose() {
    _recordGame();
    super.dispose();
  }

  // Nouvelle partie avec les niveaux de mains actuels (copiés : un achat de
  // planète ne change pas une partie déjà lancée)
  GameRun _newRun() =>
      GameRun(random: _random, handLevels: _planets.levels.copy());

  // Enregistre la partie en cours (terminée ou abandonnée), une seule fois :
  // statistiques, et pièces versées dans la bourse
  void _recordGame() {
    if (_isRecorded || !_hasPlayedHand) return;
    _isRecorded = true;
    _stats.recordGame(score: run.totalScore, round: run.roundNumber);
    _purse.deposit(run.coinsForPurse);
  }
}
