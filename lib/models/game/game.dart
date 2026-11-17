import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/shop/shop.dart';

import 'round.dart';

// Modes de jeu proposés depuis le menu
enum GameMode { story, arcade }

// Une partie complète, commune à tous les modes : manches, pièces, jokers et boutique
// Chaque mode choisit ses ennemis, ses blindes et quand la partie s'arrête
abstract class Game {
  Game({Random? random}) : _random = random {
    currentRound = _createRound();
  }

  static const baseReward =
      3; // Pièces gagnées par manche (augmente avec les mains non utilisées)
  static const maxJokers = 5; // Nombre max de jokers détenus

  final Random? _random;
  final List<Joker> _jokers = [];

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

  /// Ennemi affronté à la manche [number]
  Enemy enemyFor(int number);

  /// Blinde de la manche [number]
  int blindFor(int number);

  /// Nombre total de manches, null si la partie ne finit jamais (arcade)
  int? get roundLimit;

  // Dernière manche de la partie (le boss final), toujours false en arcade
  bool get isFinalRound;

  Enemy get enemy => currentRound.enemy;
  bool get isVictory =>
      isFinalRound &&
      currentRound.status ==
          RoundStatus.won; // Partie gagnée : le boss final est battu
  bool get isOver =>
      currentRound.status == RoundStatus.lost ||
      isVictory; // Partie terminée, gagnée ou perdue

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
    final blind = blindFor(roundNumber);
    return Round(
      blind: blind,
      deck: Deck.standard(_random),
      enemy: enemyFor(roundNumber),
      handsLeft: handsFor(blind),
      jokers: _jokers,
      random: _random,
    );
  }
}
