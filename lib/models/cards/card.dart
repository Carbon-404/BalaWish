enum Color { club, diamond, heart, spade }

abstract class Card {
  String name;
  Color color;
  String spritePath;

  Card(this.name, this.color, this.spritePath);

  void toPrint(){
    print("$name\n");
  }
}