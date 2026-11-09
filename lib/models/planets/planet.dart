import 'package:balawish/models/poker/poker_hand.dart';

// Cartes planètes : chacune améliore pour toujours une main de poker
// Chaque niveau acheté ajoute [chips] jetons et [mult] multi à la main
enum Planet {
  pluto('Pluton', PokerHand.highCard, chips: 10, mult: 1),
  mercury('Mercure', PokerHand.pair, chips: 15, mult: 1),
  venus('Vénus', PokerHand.twoPair, chips: 20, mult: 1),
  earth('Terre', PokerHand.threeOfAKind, chips: 20, mult: 2),
  mars('Mars', PokerHand.straight, chips: 30, mult: 3),
  jupiter('Jupiter', PokerHand.flush, chips: 15, mult: 2),
  saturn('Saturne', PokerHand.fullHouse, chips: 25, mult: 2),
  uranus('Uranus', PokerHand.fourOfAKind, chips: 30, mult: 3),
  neptune('Neptune', PokerHand.straightFlush, chips: 40, mult: 4),
  sun('Soleil', PokerHand.royalFlush, chips: 50, mult: 5);

  const Planet(this.name, this.hand, {required this.chips, required this.mult});

  final String name;
  final PokerHand hand;
  final int chips;
  final int mult;

  // Prix d'une planète : il augmente à chaque niveau déjà acheté
  // Pour changer les prix, il suffit de modifier ces deux valeurs
  static const basePrice = 5;
  static const priceStep = 5;

  /// Prix pour passer une main du niveau [level] au niveau suivant
  static int priceFor(int level) => basePrice + priceStep * (level - 1);

  /// Planète qui améliore [hand]
  static Planet of(PokerHand hand) => values.firstWhere((p) => p.hand == hand);
}
