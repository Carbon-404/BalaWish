import 'package:balawish/models/cards/poker_card.dart';
import 'package:balawish/models/calculator/hand_score.dart';

// Détermine la meilleure main de poker formée par 1 à 5 cartes
class HandCalculator {
  static const maxCards = 5;

  HandCalculator._();

  static HandScore evaluate(List<PokerCard> cards) {
    if (cards.isEmpty || cards.length > maxCards) {
      throw ArgumentError('Il faut entre 1 et $maxCards cartes.');
    }

    final isFlush = _isFlush(cards);
    final isStraight = _isStraight(cards);

    if (isFlush && isStraight) {
      final isRoyal = cards.every((c) => c.rank.order >= Rank.ten.order);
      return HandScore(
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
      return HandScore(PokerHand.fullHouse, cards);
    }
    if (isFlush) return HandScore(PokerHand.flush, cards);
    if (isStraight) return HandScore(PokerHand.straight, cards);
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
  static HandScore _result(
      PokerHand hand,
      List<PokerCard> played,
      List<PokerCard> scoring,
      ) {
    return HandScore(hand, played.where(scoring.contains).toList());
  }

  // Regroupe les cartes par rang
  // Les groupes sont triés du plus grand au plus petit et du rang le plus haut au plus bas
  static List<List<PokerCard>> _groupByRank(List<PokerCard> cards) {
    final byRank = <Rank, List<PokerCard>>{};
    for (final card in cards) {
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }
    return byRank.values.toList()..sort((a, b) {
      final bySize = b.length.compareTo(a.length);
      if (bySize != 0) return bySize;
      return b.first.rank.order.compareTo(a.first.rank.order);
    });
  }

  static bool _isFlush(List<PokerCard> cards) {
    return cards.length == maxCards &&
        cards.every((c) => c.family == cards.first.family);
  }

  // Cinq rangs consécutifs
  // L'as peut être en haut (10-J-Q-K-A) ou en bas (A-2-3-4-5)
  static bool _isStraight(List<PokerCard> cards) {
    if (cards.length != maxCards) return false;

    final orders = cards.map((c) => c.rank.order).toSet();
    if (orders.length != maxCards) return false;

    final sorted = orders.toList()..sort();
    if (sorted.last - sorted.first == maxCards - 1) return true;

    const aceLow = {2, 3, 4, 5, 14};
    return orders.containsAll(aceLow);
  }
}