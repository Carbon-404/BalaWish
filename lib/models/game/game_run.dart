import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/planets/hand_levels.dart';
import 'package:balawish/models/shop/shop.dart';

import 'round.dart';

// Une partie complète
class GameRun {
  GameRun({Random? random, HandLevels? handLevels})
    : _random = random,
      handLevels = handLevels ?? HandLevels() {
    currentRound = _createRound();
  }

  // Pièces gagnées par manche (augmente avec les main non utilisées)
  static const baseReward = 3;

  // Nombre max de jokers détenus
  static const maxJokers = 5;

  // En cas de défaite (ou d'abandon), seule une partie des pièces va dans la bourse
  static const lossCoinsDivisor = 2;

  final Random? _random;
  final List<Joker> _jokers = [];

  // Niveaux des mains de poker (planètes achetées), fixes pendant la partie
  final HandLevels handLevels;

  // Numéro de la manche en cours.
  int roundNumber = 1;
  int coins = 0;
  late Round currentRound;

  // Score cumulé des manches déjà terminées
  int _previousRoundsScore = 0;

  // Score de la partie : total de toutes les manches jouées
  int get totalScore => _previousRoundsScore + currentRound.score;

  // Boutique ouverte entre deux manches
  Shop? shop;

  List<Joker> get jokers => List.unmodifiable(_jokers);

  bool get isInShop => shop != null;

  // Nombre de manches d'une partie : une par ennemi, La Maison en dernier
  static int get roundCount => Enemy.values.length;

  Enemy get enemy => currentRound.enemy;

  // Dernière manche de la partie (le boss final)
  bool get isFinalRound => roundNumber >= roundCount;

  // Partie gagnée : le boss final est battu
  bool get isVictory => isFinalRound && currentRound.status == RoundStatus.won;

  // Partie terminée, gagnée ou perdue
  bool get isOver => currentRound.status == RoundStatus.lost || isVictory;

  // Pièces versées dans la bourse du joueur à la fin de la partie :
  // toutes en cas de victoire, la moitié (arrondie à l'inférieur) sinon
  int get coinsForPurse => isVictory ? coins : coins ~/ lossCoinsDivisor;

  /// Blinde de la manche [number] : le score de son ennemi
  static int blindFor(int number) => enemyFor(number).score;

  /// Ennemi affronté à la manche [number]
  static Enemy enemyFor(int number) {
    final enemy = Enemy.forRound(number);
    if (enemy == null) {
      throw RangeError.range(
        number,
        1,
        roundCount,
        'number',
        'Manche inexistante',
      );
    }
    return enemy;
  }

  /// Nombre de mains accordées pour battre [blind]
  static int handsFor(int blind) {
    if (blind < 800) return 4;
    if (blind <= 1600) return 6;
    if (blind < 5000) return 7;
    return 8;
  }

  // Pièces bonus des jokers
  int get jokerCoins => _jokers.fold(0, (sum, j) => sum + j.roundEndCoins);

  // Multiplicateur de récompense du boss (Le Banquier double les pièces)
  int get rewardMultiplier =>
      enemy.effect == BossEffect.singleDiscardDoubleReward ? 2 : 1;

  // Pièces que rapporte la manche
  int get roundReward =>
      (baseReward + currentRound.handsLeft + jokerCoins) * rewardMultiplier;

  // Défausse la sélection
  void discard() {
    currentRound.discard();
  }

  // Enregistre la récompense de la manche gagnée et ouvre la boutique
  void openShop() {
    if (currentRound.status != RoundStatus.won || isInShop) {
      throw StateError("La manche en cours n'est pas gagnée.");
    }
    if (isFinalRound) throw StateError('La partie est terminée.');
    coins += roundReward;
    shop = Shop(owned: _jokers, random: _random);
  }

  bool canBuy(int offerIndex) {
    final offer = shop?.offers[offerIndex];
    return offer != null && coins >= offer.price && _jokers.length < maxJokers;
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
    _previousRoundsScore += currentRound.score;
    roundNumber++;
    currentRound = _createRound();
  }

  // Reset la pioche pour chaque début de manche
  Round _createRound() {
    final enemy = enemyFor(roundNumber);
    return Round(
      blind: enemy.score,
      deck: Deck.standard(_random),
      enemy: enemy,
      handsLeft: handsFor(enemy.score),
      jokers: _jokers,
      handLevels: handLevels,
      random: _random,
    );
  }
}
