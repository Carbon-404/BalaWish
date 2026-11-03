// Les quatre enseignes d'un jeu de 52 cartes.
enum Suit {
  clubs('♣', isRed: false),
  diamonds('♦', isRed: true),
  hearts('♥', isRed: true),
  spades('♠', isRed: false);

  const Suit(this.symbol, {required this.isRed});

  final String symbol;
  final bool isRed;
}
