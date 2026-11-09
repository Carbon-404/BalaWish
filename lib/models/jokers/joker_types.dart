import 'package:balawish/models/cards/poker_card.dart';
import 'package:balawish/models/calculator/hand_score.dart';
import 'package:balawish/models/calculator/score_context.dart';
import 'package:balawish/models/jokers/joker.dart';

// Types d'effets réutilisables :
// nouveau joker -> nouvelle instance dans JokerList
// nouvel effet -> nouvelle classe ici

// +multi à chaque main jouée
class FlatMultJoker extends Joker {
  final int mult;

  FlatMultJoker({
    required super.name,
    required this.mult,
    super.rarity = JokerRarity.common,
  }) : super(description: '+$mult multi');

  @override
  void onHandScored(ScoreContext context) {
    context.mult += mult;
  }
}

// Bonus de jetons et/ou de multi quand la main jouée fait partie de [hands]
class HandTypeJoker extends Joker {
  final Set<PokerHand> hands;
  final int value;
  final int mult;

  HandTypeJoker({
    required super.name,
    required super.description,
    required this.hands,
    this.value = 0,
    this.mult = 0,
    super.rarity = JokerRarity.common,
  });

  @override
  void onHandScored(ScoreContext context) {
    if (!hands.contains(context.result.hand)) return;
    context.value += value;
    context.mult += mult;
  }
}

// +multi pour chaque carte de la fammille qui marque
class FamilyJoker extends Joker {
  final Family family;
  final int mult;

  FamilyJoker({
    required super.name,
    required this.family,
    required this.mult,
    super.rarity = JokerRarity.common,
  }) : super(description: '+$mult multi par carte ${family.symbol} qui marque');

  @override
  void onCardScored(ScoreContext context, PokerCard card) {
    if (card.family == family) context.mult += mult;
  }
}

// Multiplie le multi : à placer après les jokers qui l'augmentent
class TimesMultJoker extends Joker {
  final int factor;
 
  TimesMultJoker({
    required super.name,
    required this.factor,
    super.rarity = JokerRarity.rare,
  }) : super(description: '×$factor multi');

  @override
  void onHandScored(ScoreContext context) {
    context.mult *= factor;
  }
}

// Pièces supplémentaires à chaque manche gagnée
class EconomyJoker extends Joker {
  final int coins;

  EconomyJoker({
    required super.name,
    required this.coins,
    super.rarity = JokerRarity.common,
  }) : super(
    description: '+$coins pièce${coins > 1 ? 's' : ''} en fin de manche',
  );

  @override
  int get roundEndCoins => coins;
}