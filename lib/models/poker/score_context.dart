import 'package:balawish/models/planets/hand_levels.dart';

import 'hand_evaluator.dart';

// Jetons et multi en cours de calcul, modifiés successivement par les jokers
// Ils partent des valeurs de la main à son niveau actuel (planètes comprises)
class ScoreContext {
  ScoreContext(this.result, HandLevels levels)
    : chips = levels.chipsFor(result.hand),
      mult = levels.multFor(result.hand);

  final HandResult result;
  int chips;
  int mult;
}
