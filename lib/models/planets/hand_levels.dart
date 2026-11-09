import 'package:balawish/models/poker/poker_hand.dart';

import 'planet.dart';

// Niveau de chaque main de poker, augmenté par les planètes achetées
// Au niveau 1 (de départ), une main a ses jetons et multi de base (annexe A)
class HandLevels {
  HandLevels([Map<PokerHand, int>? levels]) : _levels = {...?levels};

  static const baseLevel = 1;

  final Map<PokerHand, int> _levels;

  int levelOf(PokerHand hand) => _levels[hand] ?? baseLevel;

  // Jetons et multi de départ de [hand] : la base plus les bonus des planètes
  int chipsFor(PokerHand hand) =>
      hand.baseChips + Planet.of(hand).chips * _bonusLevels(hand);

  int multFor(PokerHand hand) =>
      hand.baseMult + Planet.of(hand).mult * _bonusLevels(hand);

  void upgrade(PokerHand hand) {
    _levels[hand] = levelOf(hand) + 1;
  }

  // Copie indépendante : une partie garde les niveaux de son lancement
  HandLevels copy() => HandLevels(_levels);

  int _bonusLevels(PokerHand hand) => levelOf(hand) - baseLevel;

  // Les mains sont enregistrées par leur nom (comme dans PlayerStats)
  Map<String, Object?> toJson() => {
    for (final entry in _levels.entries) entry.key.name: entry.value,
  };

  // Les valeurs absentes ou invalides sont ignorées
  factory HandLevels.fromJson(Map<String, Object?> json) {
    return HandLevels({
      for (final hand in PokerHand.values)
        if (json[hand.name] case final int level when level >= baseLevel)
          hand: level,
    });
  }
}
