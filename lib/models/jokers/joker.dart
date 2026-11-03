import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/poker/score_context.dart';

// Rareté d'un joker : fixe ses prix et la couleur de son cadre (GameColors.rarity)
// Pour changer les prix d'une catégorie, il suffit de modifier les valeurs ici
enum JokerRarity {
  common(price: 4, sellPrice: 2),
  uncommon(price: 6, sellPrice: 3),
  rare(price: 8, sellPrice: 4),
  legendary(price: 12, sellPrice: 6);

  const JokerRarity({required this.price, required this.sellPrice});

  final int price;
  final int sellPrice;
}

// Effet permanent acheté en boutique
// Chaque type de joker ne redéfinit que les déclencheurs qui le concernent
abstract class Joker {
  Joker({required this.name, required this.description, required this.rarity});

  final String name;
  final String description;
  final JokerRarity rarity;

  int get price => rarity.price;

  int get sellPrice => rarity.sellPrice;

  // Quand une carte de la main marque des points (étape 2 du décompte)
  void onCardScored(ScoreContext context, PlayingCard card) {}

  // Après les cartes, de gauche à droite (étape 3 du décompte)
  void onHandScored(ScoreContext context) {}

  // Pièces bonus à chaque manche gagnée
  int get roundEndCoins => 0;
}
