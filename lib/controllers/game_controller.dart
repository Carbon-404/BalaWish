import 'dart:math';

import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:flutter/foundation.dart';

/// Fait le lien entre la partie (logique pure) et l'interface : chaque action
/// modifie le modèle puis prévient les widgets qui l'écoutent.
class GameController extends ChangeNotifier {
  GameController({Random? random})
    : _random = random,
      run = GameRun(random: random);

  final Random? _random;
  GameRun run;

  Round get round => run.currentRound;

  void toggleSelection(PlayingCard card) {
    if (round.toggleSelection(card)) notifyListeners();
  }

  void play() {
    if (!round.canPlay) return;
    round.play();
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
    run = GameRun(random: _random);
    notifyListeners();
  }
}
