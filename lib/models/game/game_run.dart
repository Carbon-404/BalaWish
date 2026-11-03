import 'dart:math';

import 'package:balawish/models/cards/deck.dart';

import 'round.dart';

// Une partie complète
class GameRun {
  GameRun({Random? random}) : _random = random {
    currentRound = _createRound();
  }

  static const startingBlind = 200;
  static const blindGrowth = 1.5;

  // Mains de la première manche
  static const baseHands = 4;

  // Mains max par manche
  static const maxHands = 8;

  // Pièces gagnées par manche (augmente avec les main non utilisées)
  static const baseReward = 3;

  final Random? _random;

  // Numéro de la manche en cours.
  int roundNumber = 1;
  int coins = 0;
  late Round currentRound;

  bool get isOver => currentRound.status == RoundStatus.lost;

  /// Blinde de la manche [number] : 200, 300, 450, 675…
  static int blindFor(int number) {
    return (startingBlind * pow(blindGrowth, number - 1)).round();
  }

  /// Nombre de mains accordées pour battre [blind] : 4, puis +1 qand la blinde double (plafonné à [maxHands])
  static int handsFor(int blind) {
    var hands = baseHands;
    for (var threshold = startingBlind * 2;
    threshold <= blind && hands < maxHands;
    threshold *= 2) {
      hands++;
    }
    return hands;
  }

  // Pièces que rapporte la manche en cours si elle gagnée
  int get roundReward => baseReward + currentRound.handsLeft;

  // Enregistre la récompense et lance le round suivant
  void nextRound() {
    if (currentRound.status != RoundStatus.won) {
      throw StateError("La manche en cours n'est pas gagnée.");
    }
    coins += roundReward;
    roundNumber++;
    currentRound = _createRound();
  }

  // Reset la piche pour chaque début de manche
  Round _createRound() {
    final blind = blindFor(roundNumber);
    return Round(
      blind: blind,
      deck: Deck.standard(_random),
      handsLeft: handsFor(blind),
    );
  }
}
