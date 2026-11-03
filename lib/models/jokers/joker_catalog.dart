import 'package:balawish/models/cards/suit.dart';
import 'package:balawish/models/poker/poker_hand.dart';

import 'joker.dart';
import 'joker_types.dart';

// Tous les jokers pouvant apparaître en boutique
// Pour ajouter un joker : ajouter une entrée à la liste (type d'effet + réglages + rareté)
class JokerCatalog {
  JokerCatalog._();

  static final List<Joker> all = [
    FlatMultJoker(name: 'Joker', mult: 4),
    HandTypeJoker(
      name: 'Joker Paire',
      description: '+20 jetons si la main contient une paire',
      hands: {PokerHand.pair, PokerHand.twoPair, PokerHand.fullHouse},
      chips: 20,
    ),
    HandTypeJoker(
      name: 'Joker Brelan',
      description: '+12 multi si la main contient un brelan',
      hands: {PokerHand.threeOfAKind, PokerHand.fullHouse},
      mult: 12,
      rarity: JokerRarity.uncommon,
    ),
    HandTypeJoker(
      name: 'Joker Suite',
      description: '+8 multi si une suite est jouée',
      hands: {
        PokerHand.straight,
        PokerHand.straightFlush,
        PokerHand.royalFlush,
      },
      mult: 8,
      rarity: JokerRarity.uncommon,
    ),
    HandTypeJoker(
      name: 'Joker Couleur',
      description: '+10 multi si une couleur est jouée',
      hands: {PokerHand.flush, PokerHand.straightFlush, PokerHand.royalFlush},
      mult: 10,
      rarity: JokerRarity.uncommon,
    ),
    SuitJoker(name: 'Joker Cœur', suit: Suit.hearts, mult: 3),
    SuitJoker(name: 'Joker Carreau', suit: Suit.diamonds, mult: 3),
    SuitJoker(name: 'Joker Pique', suit: Suit.spades, mult: 3),
    SuitJoker(name: 'Joker Trèfle', suit: Suit.clubs, mult: 3),
    EconomyJoker(name: 'Joker Économe', coins: 1),
    TimesMultJoker(name: 'Joker Fou', factor: 2),
  ];
}
