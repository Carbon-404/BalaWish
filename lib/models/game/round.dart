import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/cards/poker_card.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/calculator/hand_calculator.dart';
import 'package:balawish/models/calculator/score_calculator.dart';
import 'package:balawish/models/enemy/enemy.dart';


// Status d'une manche
enum RoundStatus { playing, won, lost }

class Round {
  static const handSize = 7;
  static const defaultHands = 4;
  static const defaultDiscards = 3;

  /// Nombre de défausses accordées face à [enemy]
  static int discardsFor(Enemy enemy) =>
      enemy.effect == BossEffect.singleDiscardDoubleReward
          ? 1
          : defaultDiscards;

  final int blind;
  final List<Joker> jokers; // Jokers actifs pendant la manche (sans celui désactivé par le boss)
  final Joker? disabledJoker; // Joker désactivé par le boss pour cette manche
  final Deck _deck;
  final Random _random;
  final Enemy enemy;
  final List<PokerCard> _hand = [];
  final List<PokerCard> _selected = [];

  int handsLeft;
  int discardsLeft;
  int score = 0;
  RoundStatus status = RoundStatus.playing;
  Family? forbiddenFamily; // Famille interdite pour la main en cours (Baron Roulette)
  ScoreBreakdown? lastScore; // Score de la dernière main jouée, pour l'affichage


  Round({
    required this.blind,
    required Deck deck,
    required this.enemy,
    this.handsLeft = defaultHands,
    int? discardsLeft,
    List<Joker> jokers = const [],
    Random? random,
  }) : _deck = deck,
        _random = random ?? Random(),
        discardsLeft = discardsLeft ?? discardsFor(enemy),
        disabledJoker = enemy.effect == BossEffect.disableFirstJoker
            ? jokers.firstOrNull
            : null,
        jokers = enemy.effect == BossEffect.disableFirstJoker
            ? List.unmodifiable(jokers.skip(1))
            : List.unmodifiable(jokers) {
    _rollForbiddenFamily();
    _refillHand();
  }



  // Cartes en main, triées par rang décroissant
  List<PokerCard> get hand => List.unmodifiable(_hand);

  // Cartes sélectionnées, dans l'ordre de la main (de gauche à droite)
  List<PokerCard> get selected => _hand.where(_selected.contains).toList();

  int get cardsInDeck => _deck.getRemaining();
  bool get isPlaying => status == RoundStatus.playing;
  bool get canPlay => isPlaying && _selected.isNotEmpty;
  bool get canDiscard => canPlay && discardsLeft > 0;
  bool isSelected(PokerCard card) => _selected.contains(card);

  /// true si [card] est neutralisée par le boss : elle peut être jouée et
  /// compte pour former la main, mais ne marque pas
  bool isDebuffed(PokerCard card) {
    return switch (enemy.effect) {
      BossEffect.spadesDisabled => card.family == Family.spades,
      BossEffect.randomFamilyDisabled => card.family == forbiddenFamily,
      _ => false,
    };
  }

  /// Sélectionne ou désélectionne [card]
  /// Retourne false si rien n'a changé (manche terminée, carte absente de la main, ou déjà 5 cartes choisies)
  bool toggleSelection(PokerCard card) {
    if (!isPlaying || !_hand.contains(card)) return false;
    if (_selected.remove(card)) return true;
    if (_selected.length >= HandCalculator.maxCards) return false;
    _selected.add(card);
    return true;
  }

  ScoreBreakdown _scoreOf(List<PokerCard> cards) {
    return ScoreCalculator.score(
      HandCalculator.evaluate(cards),
      jokers,
      isDebuffed
    );
  }

  // Joue les cartes sélectionnées et ajoute les points au score
  ScoreBreakdown play() {
    if (!canPlay) throw StateError('Aucune carte jouable.');

    final breakdown = _scoreOf(selected);
    score += breakdown.getTotalScore();
    handsLeft--;
    lastScore = breakdown;
    _removeSelectedFromHand();

    if (score >= blind) {
      status = RoundStatus.won;
    } else if (handsLeft == 0) {
      status = RoundStatus.lost;
    } else {
      _rollForbiddenFamily();
      _refillHand();
      // Plus de carte en main ni dans la pioche -> impossible de continuer
      if (_hand.isEmpty) status = RoundStatus.lost;
    }
    return breakdown;
  }

  // Défausse les cartes sélectionnées et en repioche autant
  void discard() {
    if (!canDiscard) throw StateError('Défausse impossible.');

    discardsLeft--;
    _removeSelectedFromHand();
    _refillHand();
  }

  void _removeSelectedFromHand() {
    _hand.removeWhere(_selected.contains);
    _selected.clear();
  }

  // Tire une nouvelle enseigne interdite au début de chaque main
  void _rollForbiddenFamily() {
    if (enemy.effect != BossEffect.randomFamilyDisabled) return;
    forbiddenFamily = Family.values[_random.nextInt(Family.values.length)];
  }

  /// Complète la main jusqu'à [handSize] cartes (s'il en reste assez dans la pioche)
  void _refillHand() {
    _hand.addAll(_deck.getXCards(handSize - _hand.length));
    _hand.sort((a, b) {
      final byRank = b.rank.order.compareTo(a.rank.order);
      return byRank != 0 ? byRank : a.family.index.compareTo(b.family.index);
    });
  }
}