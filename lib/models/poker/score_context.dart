import 'hand_evaluator.dart';

// Jetons et multi en cours de calcul, modifiés successivement par les jokers
class ScoreContext {
  ScoreContext(this.result)
    : chips = result.hand.baseChips,
      mult = result.hand.baseMult;

  final HandResult result;
  int chips;
  int mult;
}
