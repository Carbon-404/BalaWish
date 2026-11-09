import 'dart:math';

import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/jokers/joker_list.dart';

// Offres de la boutique entre deux manches
class Shop {
  // Propose plusieurd jokers au hasard (exclus ceux déjà achetées)
  Shop({required List<Joker> owned, Random? random})
      : offers = List<Joker?>.of(
    (JokerCatalog.all.where((j) => !owned.contains(j)).toList()
      ..shuffle(random))
        .take(offerCount),
  );

  static const offerCount = 3;

  // null quand l'offre a été achetée
  final List<Joker?> offers;
}