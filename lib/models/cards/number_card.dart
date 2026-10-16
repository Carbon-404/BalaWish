import 'card.dart';

class NumberCard extends Card {
  int value;

  NumberCard(Color color, this.value): super("$value - $color", color, "");
}