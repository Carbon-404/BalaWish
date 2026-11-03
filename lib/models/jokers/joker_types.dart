import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/cards/suit.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/poker/score_context.dart';

import 'joker.dart';

// Types d'effets réutilisables : un nouveau joker est en général une nouvelle
// instance de l'un d'eux dans JokerCatalog. Un effet inédit = une nouvelle classe ici

// +multi à chaque main jouée
class FlatMultJoker extends Joker {
  FlatMultJoker({
    required super.name,
    required this.mult,
    super.rarity = JokerRarity.common,
  }) : super(description: '+$mult multi');

  final int mult;

  @override
  void onHandScored(ScoreContext context) {
    context.mult += mult;
  }
}

// Bonus de jetons et/ou de multi quand la main jouée fait partie de [hands]
class HandTypeJoker extends Joker {
  HandTypeJoker({
    required super.name,
    required super.description,
    required this.hands,
    this.chips = 0,
    this.mult = 0,
    super.rarity = JokerRarity.common,
  });

  final Set<PokerHand> hands;
  final int chips;
  final int mult;

  @override
  void onHandScored(ScoreContext context) {
    if (!hands.contains(context.result.hand)) return;
    context.chips += chips;
    context.mult += mult;
  }
}

// +multi pour chaque carte de l'enseigne [suit] qui marque
class SuitJoker extends Joker {
  SuitJoker({
    required super.name,
    required this.suit,
    required this.mult,
    super.rarity = JokerRarity.common,
  }) : super(description: '+$mult multi par carte ${suit.symbol} qui marque');

  final Suit suit;
  final int mult;

  @override
  void onCardScored(ScoreContext context, PlayingCard card) {
    if (card.suit == suit) context.mult += mult;
  }
}

// Multiplie le multi : à placer après les jokers qui l'augmentent
class TimesMultJoker extends Joker {
  TimesMultJoker({
    required super.name,
    required this.factor,
    super.rarity = JokerRarity.rare,
  }) : super(description: '×$factor multi');

  final int factor;

  @override
  void onHandScored(ScoreContext context) {
    context.mult *= factor;
  }
}

// Pièces supplémentaires à chaque manche gagnée
class EconomyJoker extends Joker {
  EconomyJoker({
    required super.name,
    required this.coins,
    super.rarity = JokerRarity.common,
  }) : super(
         description: '+$coins pièce${coins > 1 ? 's' : ''} en fin de manche',
       );

  final int coins;

  @override
  int get roundEndCoins => coins;
}
