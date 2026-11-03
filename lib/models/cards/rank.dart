/// Rang d'une carte, du 2 à l'as
///
/// [order] est utilisé pour comparer les cartes et pour détecter les suites :
/// l'as vaut 14 mais il peut aussi compter comme 1 dans la suite A-2-3-4-5
/// [chips] est le nombre de jetons rapporté quand la carte marque des points.
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

  const Rank(this.order, this.label, this.chips);

  final int order;
  final String label;
  final int chips;
}
