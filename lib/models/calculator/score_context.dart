import 'package:balawish/models/calculator/hand_score.dart';

// Jetons et multi en cours de calcul, modifiés successivement par les jokers
class ScoreContext {
  ScoreContext(this.result)
      : value = result.hand.baseChips,
        mult = result.hand.baseMult;

  final HandScore result;
  int value;
  int mult;
}