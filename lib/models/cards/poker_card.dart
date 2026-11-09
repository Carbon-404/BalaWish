// Familles d'un jeu de 52 cartes
enum Family {
  clubs('♣', isRed: false),
  diamonds('♦', isRed: true),
  hearts('♥', isRed: true),
  spades('♠', isRed: false);

  const Family(this.symbol, {required this.isRed});

  final String symbol;
  final bool isRed;
}

// Rangs et valeurs des cartes d'd'un jeu de 52 cartes
enum Rank {
  two(2, '2', 2),
  three(3, '3', 3),
  four(4, '4', 4),
  five(5, '5', 5),
  six(6, '6', 6),
  seven(7, '7', 7),
  eight(8, '8', 8),
  nine(9, '9', 9),
  ten(10, '10', 10),
  jack(11, 'J', 10),
  queen(12, 'Q', 10),
  king(13, 'K', 10),
  ace(14, 'A', 11);

  const Rank(this.order, this.label, this.value);

  final int order;
  final String label;
  final int value;
}

class PokerCard {
  PokerCard(this.rank, this.family);

  final Rank rank;
  final Family family;

  // Jetons rapportés par la carte quand elle est jouée
  int get value => rank.value;

  @override
  String toString() => '${rank.label}${family.symbol}';
}