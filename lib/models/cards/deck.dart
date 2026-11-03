import 'dart:math';

import 'playing_card.dart';
import 'rank.dart';
import 'suit.dart';

// La pioche
class Deck {

  // Paquet classique de 52 cartes, mélangé
  /// [random] permet d'obtenir un mélange (reproductible pour les tests)
  Deck.standard([Random? random])
    : _cards = [
        for (final suit in Suit.values)
          for (final rank in Rank.values) PlayingCard(rank, suit),
      ] {
    _cards.shuffle(random);
  }

  Deck.fromCards(Iterable<PlayingCard> cards) : _cards = List.of(cards);

  final List<PlayingCard> _cards;

  int get remaining => _cards.length;

  bool get isEmpty => _cards.isEmpty;

  /// Pioche [count] cartes, ou seulement celles qui restent s'il n'y en a pas assez
  List<PlayingCard> draw(int count) {
    final drawnCount = min(count, _cards.length);
    final drawn = _cards.sublist(0, drawnCount);
    _cards.removeRange(0, drawnCount);
    return drawn;
  }
}
