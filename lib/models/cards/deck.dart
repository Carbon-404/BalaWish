import 'dart:math';

import 'poker_card.dart';

// La pioche
class Deck {

  final List<PokerCard> _cards;

  // Paquet classique de 52 cartes, mélangé
  /// [random] permet d'obtenir un mélange (reproductible pour les tests)
  Deck.standard([Random? random]): _cards = [
    for (final family in Family.values)
      for (final rank in Rank.values) PokerCard(rank, family),
  ] {
    _cards.shuffle(random);
  }

  Deck.fromCards(Iterable<PokerCard> cards) : _cards = List.of(cards);

  // Getters

  /// Pioche [count] cartes, ou seulement celles qui restent s'il n'y en a pas assez
  List<PokerCard> getXCards(int count) {
    final toPick = min(count, _cards.length);
    final picked = _cards.sublist(0, toPick);
    _cards.removeRange(0, toPick);
    return picked;
  }

  // Retourne le nombre de cartes restantes dans la pioche
  int getRemaining(){
    return _cards.length;
  }

  // Retourne vrai si le paquet de carte est vide, faux sinon
  bool getIsEmpty() {
    return _cards.isEmpty;
  }
}