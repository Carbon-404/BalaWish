import 'hand_evaluator.dart';
import 'poker_hand.dart';

// Détail du score d'une main jouée
class ScoreBreakdown {
  const ScoreBreakdown(this.result, this.chips, this.mult);

  final HandResult result;
  final int chips;
  final int mult;

  PokerHand get hand => result.hand;

  int get total => chips * mult;
}

// Compte les points d'une main dans l'ordre
class ScoreCalculator {
  ScoreCalculator._();

  static ScoreBreakdown score(HandResult result) {
    // d'abord les jetons et multi de base du type de main
    var chips = result.hand.baseChips;
    final mult = result.hand.baseMult;

    // ensuite les cartes qui forment la main de gauche à droite
    for (final card in result.scoringCards) {
      chips += card.chips;
    }

    // TODO
    // enfin les effets des jokers de gauche à droite

    return ScoreBreakdown(result, chips, mult);
  }
}
