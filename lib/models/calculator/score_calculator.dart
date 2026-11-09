import 'package:balawish/models/cards/poker_card.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/calculator/hand_score.dart';
import 'package:balawish/models/calculator/score_context.dart';

// Détail du score d'une main jouée
class ScoreBreakdown {

  final HandScore result;
  final int value;
  final int mult;


  const ScoreBreakdown(this.result, this.value, this.mult);

  PokerHand getHand() {
    return result.hand;
  }
  
  int getTotalScore() {
    return value * mult;
  }
}

// Compte les points d'une main dans l'ordre
class ScoreCalculator {
  ScoreCalculator._();

  /// [isDebuffed] désigne les cartes neutralisées par un boss : elles ne
  /// rapportent pas de jetons et ne déclenchent pas les jokers
  /// [levels] contient les niveaux des mains gagnés avec les planètes
  static ScoreBreakdown score(
      HandScore result, [
        List<Joker> jokers = const [],
        bool Function(PokerCard card)? isDebuffed,
      ]) {
    // jetons et multi de base du type de main
    final context = ScoreContext(result);

    // les cartes qui forment la main de gauche à droite avec les effets de joker liés à chaque carte
    for (final card in result.scoringCards) {
      if (isDebuffed?.call(card) ?? false) continue;
      context.value += card.value;
      for (final joker in jokers) {
        joker.onCardScored(context, card);
      }
    }

    // les effets des jokers dans l'ordre
    for (final joker in jokers) {
      joker.onHandScored(context);
    }

    return ScoreBreakdown(result, context.value, context.mult);
  }
}