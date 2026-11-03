import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/cards/rank.dart';
import 'package:balawish/models/cards/suit.dart';

/// Construit des cartes à partir d'une notation courte : "AS KH 10D 2C".
/// Rang (2-10, J, Q, K, A) suivi de l'enseigne (C, D, H, S).
List<PlayingCard> cards(String notation) {
  return notation.split(' ').map(_card).toList();
}

PlayingCard _card(String code) {
  final rankLabel = code.substring(0, code.length - 1);
  final suitLetter = code[code.length - 1];
  final rank = Rank.values.firstWhere((r) => r.label == rankLabel);
  final suit = switch (suitLetter) {
    'C' => Suit.clubs,
    'D' => Suit.diamonds,
    'H' => Suit.hearts,
    'S' => Suit.spades,
    _ => throw ArgumentError('Enseigne inconnue : $suitLetter'),
  };
  return PlayingCard(rank, suit);
}
