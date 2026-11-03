import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/cards/rank.dart';

import 'poker_hand.dart';

// Résultat de l'évaluation du score d'une sélection de cartes
class HandResult {
  const HandResult(this.hand, this.scoringCards);

  final PokerHand hand;

  // Cartes qui forment la main de poker dans l'ordre où elles ont été jouées
  // Les autres ne marquent pas
  final List<PlayingCard> scoringCards;
}

// Détermine la meilleure main de poker formée par 1 à 5 cartes
class HandEvaluator {
  HandEvaluator._();

  static const maxCards = 5;

  static HandResult evaluate(List<PlayingCard> cards) {
    if (cards.isEmpty || cards.length > maxCards) {
      throw ArgumentError('Il faut entre 1 et $maxCards cartes.');
    }

    final isFlush = _isFlush(cards);
    final isStraight = _isStraight(cards);

    if (isFlush && isStraight) {
      final isRoyal = cards.every((c) => c.rank.order >= Rank.ten.order);
      return HandResult(
        isRoyal ? PokerHand.royalFlush : PokerHand.straightFlush,
        cards,
      );
    }

    final groups = _groupByRank(cards);
    final biggest = groups.first.length;
    final second = groups.length > 1 ? groups[1].length : 0;

    if (biggest == 4) {
      return _result(PokerHand.fourOfAKind, cards, groups.first);
    }
    if (biggest == 3 && second == 2) {
      return HandResult(PokerHand.fullHouse, cards);
    }
    if (isFlush) return HandResult(PokerHand.flush, cards);
    if (isStraight) return HandResult(PokerHand.straight, cards);
    if (biggest == 3) {
      return _result(PokerHand.threeOfAKind, cards, groups.first);
    }
    if (biggest == 2 && second == 2) {
      return _result(PokerHand.twoPair, cards, [...groups[0], ...groups[1]]);
    }
    if (biggest == 2) return _result(PokerHand.pair, cards, groups.first);

    // Carte haute le premier groupe contient la carte de rang le plus élevé
    return _result(PokerHand.highCard, cards, groups.first);
  }

  /// Garde les cartes de [scoring] dans l'ordre de jeu de [played].
  static HandResult _result(
    PokerHand hand,
    List<PlayingCard> played,
    List<PlayingCard> scoring,
  ) {
    return HandResult(hand, played.where(scoring.contains).toList());
  }

  // Regroupe les cartes par rang
  // Les groupes sont triés du plus grand au plus petit et du rang le plus haut au plus bas
  static List<List<PlayingCard>> _groupByRank(List<PlayingCard> cards) {
    final byRank = <Rank, List<PlayingCard>>{};
    for (final card in cards) {
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }
    return byRank.values.toList()..sort((a, b) {
      final bySize = b.length.compareTo(a.length);
      if (bySize != 0) return bySize;
      return b.first.rank.order.compareTo(a.first.rank.order);
    });
  }

  static bool _isFlush(List<PlayingCard> cards) {
    return cards.length == maxCards &&
        cards.every((c) => c.suit == cards.first.suit);
  }

  // Cinq rangs consécutifs
  // L'as peut être en haut (10-J-Q-K-A) ou en bas (A-2-3-4-5)
  static bool _isStraight(List<PlayingCard> cards) {
    if (cards.length != maxCards) return false;

    final orders = cards.map((c) => c.rank.order).toSet();
    if (orders.length != maxCards) return false;

    final sorted = orders.toList()..sort();
    if (sorted.last - sorted.first == maxCards - 1) return true;

    const aceLow = {2, 3, 4, 5, 14};
    return orders.containsAll(aceLow);
  }
}
