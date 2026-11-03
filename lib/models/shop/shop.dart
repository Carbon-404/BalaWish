import 'dart:math';

import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/jokers/joker_catalog.dart';

// Offres de la boutique entre deux manches
class Shop {
  // Propose [offerCount] jokers au hasard parmi ceux que le joueur n'a pas déjà
  // (un joker n'est donc jamais détenu en double)
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
