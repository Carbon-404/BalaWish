import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/shop/shop.dart';

import 'round.dart';

// Une partie complète
class GameRun {
  GameRun({Random? random}) : _random = random {
    currentRound = _createRound();
  }

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
    return Enemy.values.where((r) => r.order == number).first.score;
  }

  /// Image de l'ennemi en fonction du round
  static Enemy enemyFor(int number) {
    return Enemy.values.where((r) => r.order == number).first;
  }

  /// Nombre de mains accordées pour battre [blind]
  static int handsFor(int blind) {
    if(blind < 800) return 4;
    if(blind <= 1600) return 6;
    if(blind < 5000) return 7;
    return 8;
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
      enemy: enemyFor(roundNumber),
      handsLeft: handsFor(blind),
      jokers: List.unmodifiable(_jokers),
    );
  }
}
