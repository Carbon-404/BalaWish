import 'package:balawish/models/cards/poker_card.dart';

// Les mains de poker de la plus faible à la plus forte avec leurs jetons et multi
enum PokerHand {
  highCard('Carte haute', 5, 1),
  pair('Paire', 10, 2),
  twoPair('Double paire', 20, 2),
  threeOfAKind('Brelan', 30, 3),
  straight('Suite', 30, 4),
  flush('Couleur', 35, 4),
  fullHouse('Main pleine', 40, 4),
  fourOfAKind('Carré', 60, 7),
  straightFlush('Quinte flush', 100, 8),
  royalFlush('Quinte flush royale', 100, 10);

  const PokerHand(this.label, this.baseChips, this.baseMult);

  final String label;
  final int baseChips;
  final int baseMult;
}


// Résultat de l'évaluation du score d'une sélection de cartes
class HandScore {
  const HandScore(this.hand, this.scoringCards);
  final PokerHand hand;

  // Cartes qui forment la main de poker dans l'ordre où elles ont été jouées
  // Les autres ne marquent pas
  final List<PokerCard> scoringCards;
}