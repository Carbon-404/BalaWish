import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/planets/hand_levels.dart';

import 'hand_evaluator.dart';
import 'poker_hand.dart';
import 'score_context.dart';

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

  /// [isDebuffed] désigne les cartes neutralisées par un boss : elles ne
  /// rapportent pas de jetons et ne déclenchent pas les jokers
  /// [levels] contient les niveaux des mains gagnés avec les planètes
  static ScoreBreakdown score(
    HandResult result, [
    List<Joker> jokers = const [],
    bool Function(PlayingCard card)? isDebuffed,
    HandLevels? levels,
  ]) {
    // jetons et multi du type de main, à son niveau actuel
    final context = ScoreContext(result, levels ?? HandLevels());

    // les cartes qui forment la main de gauche à droite avec les effets de joker liés à chaque carte
    for (final card in result.scoringCards) {
      if (isDebuffed?.call(card) ?? false) continue;
      context.chips += card.chips;
      for (final joker in jokers) {
        joker.onCardScored(context, card);
      }
    }

    // les effets des jokers dans l'ordre
    for (final joker in jokers) {
      joker.onHandScored(context);
    }

    return ScoreBreakdown(result, context.chips, context.mult);
  }
}
