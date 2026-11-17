import 'dart:math';

import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/cards/poker_card.dart';
import 'package:balawish/models/game/game.dart';
import 'package:balawish/models/game/game_arcade_mode.dart';
import 'package:balawish/models/game/game_story_mode.dart';
import 'package:balawish/models/game/round.dart';
import 'package:flutter/foundation.dart';

/// Fait le lien entre la partie (logique pure) et l'interface : chaque action
/// modifie le modèle puis prévient les widgets qui l'écoutent.
class GameController extends ChangeNotifier {
  GameController({
    this.mode = GameMode.story,
    Random? random,
    StatsController? stats,
  }) : _random = random,
       _stats = stats ?? playerStats;

  final GameMode mode;
  final Random? _random;
  final StatsController _stats;
  late Game run = _newRun();

  // Une partie ne compte dans les statistiques qu'à partir de la 1re main jouée
  bool _hasPlayedHand = false;
  bool _isSaved = false;

  Round get round => run.currentRound;

  void toggleSelection(PokerCard card) {
    if (round.toggleSelection(card)) notifyListeners();
  }

  void play() {
    if (!round.canPlay) return;
    final score = round.play();
    _hasPlayedHand = true;
    _stats.recordHand(score.getHand());
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

  // Relance une partie du même mode
  void restart() {
    _recordGame();
    run = _newRun();
    _hasPlayedHand = false;
    _isSaved = false;
    notifyListeners();
  }

  // Quitter le plateau en cours de partie compte comme une partie jouée (et perdue)
  @override
  void dispose() {
    _recordGame();
    super.dispose();
  }

  Game _newRun() => switch (mode) {
    GameMode.story => GameStoryMode(random: _random),
    GameMode.arcade => GameArcadeMode(random: _random),
  };

  // Enregistre la partie en cours (terminée ou abandonnée) dans les
  // statistiques, une seule fois
  void _recordGame() {
    if (_isSaved || !_hasPlayedHand) return;
    _isSaved = true;
    _stats.recordGame(
      score: run.totalScore,
      round: run.roundNumber,
      mode: mode,
    );
  }
}
