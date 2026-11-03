import 'rank.dart';
import 'suit.dart';

// Une carte de base
class PlayingCard {
  PlayingCard(this.rank, this.suit);

  final Rank rank;
  final Suit suit;

  // Jetons rapportés par la carte quand elle fait partie de la main jouée
  int get chips => rank.chips;

  @override
  String toString() => '${rank.label}${suit.symbol}';
}
