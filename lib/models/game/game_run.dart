import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/shop/shop.dart';

import 'round.dart';

// Une partie complète
class GameRun {
  GameRun({Random? random}) : _random = random {
    currentRound = _createRound();
  }

  static const startingBlind = 200;
  static const blindGrowth = 1.5;

  // Mains de la première manche
  static const baseHands = 4;

  // Mains max par manche
  static const maxHands = 8;

  // Pièces gagnées par manche (augmente avec les main non utilisées)
  static const baseReward = 3;

  // Nombre max de jokers détenus
  static const maxJokers = 5;

  final Random? _random;
  final List<Joker> _jokers = [];

  // Numéro de la manche en cours.
  int roundNumber = 1;
  int coins = 0;
  late Round currentRound;

  // Boutique ouverte entre deux manches
  Shop? shop;

  List<Joker> get jokers => List.unmodifiable(_jokers);

  bool get isInShop => shop != null;

  bool get isOver => currentRound.status == RoundStatus.lost;

  /// Blinde de la manche [number] : 200, 300, 450, 675…
  static int blindFor(int number) {
    return (startingBlind * pow(blindGrowth, number - 1)).round();
  }

  /// Nombre de mains accordées pour battre [blind] : 4, puis +1 qand la blinde double (plafonné à [maxHands])
  static int handsFor(int blind) {
    var hands = baseHands;
    for (var threshold = startingBlind * 2;
    threshold <= blind && hands < maxHands;
    threshold *= 2) {
      hands++;
    }
    return hands;
  }

  // Pièces bonus des jokers
  int get jokerCoins => _jokers.fold(0, (sum, j) => sum + j.roundEndCoins);

  // Pièces que rapporte la manche
  int get roundReward => baseReward + currentRound.handsLeft + jokerCoins;

  // Enregistre la récompense de la manche gagnée et ouvre la boutique
  void openShop() {
    if (currentRound.status != RoundStatus.won || isInShop) {
      throw StateError("La manche en cours n'est pas gagnée.");
    }
    coins += roundReward;
    shop = Shop(owned: _jokers, random: _random);
  }

  bool canBuy(int offerIndex) {
    final offer = shop?.offers[offerIndex];
    return offer != null &&
        coins >= offer.price &&
        _jokers.length < maxJokers;
  }

  void buyJoker(int offerIndex) {
    if (!canBuy(offerIndex)) throw StateError('Achat impossible.');
    final joker = shop!.offers[offerIndex]!;
    coins -= joker.price;
    _jokers.add(joker);
    shop!.offers[offerIndex] = null;
  }

  void sellJoker(int index) {
    coins += _jokers.removeAt(index).sellPrice;
  }

  // Déplace un joker l'ordre est celui du calcul des effets
  void moveJoker(int from, int to) {
    _jokers.insert(to, _jokers.removeAt(from));
  }

  // Ferme la boutique et lance la manche suivante
  void nextRound() {
    if (!isInShop) throw StateError("La boutique n'est pas ouverte.");
    shop = null;
    roundNumber++;
    currentRound = _createRound();
  }

  // Reset la piche pour chaque début de manche
  Round _createRound() {
    final blind = blindFor(roundNumber);
    return Round(
      blind: blind,
      deck: Deck.standard(_random),
      handsLeft: handsFor(blind),
      jokers: List.unmodifiable(_jokers),
    );
  }
}
