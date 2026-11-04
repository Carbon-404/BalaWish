import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/poker/hand_evaluator.dart';
import 'package:balawish/models/poker/score_calculator.dart';
import 'package:balawish/models/enemy/enemy.dart';

enum RoundStatus { playing, won, lost }

/// Une manche battre la [blind] en un nombre limité de mains
///
/// La manche est gagnée dès que le score atteint la blinde,
/// et perdue si les mains (ou les cartes) tombe à 0 avant d'avoir battu la blinde
class Round {
  Round({
    required this.blind,
    required Deck deck,
    required this.enemy,
    this.handsLeft = defaultHands,
    this.discardsLeft = defaultDiscards,
    this.jokers = const [],
  }) : _deck = deck {
    _refillHand();
  }

  static const handSize = 7;
  static const defaultHands = 4;
  static const defaultDiscards = 3;

  final int blind;

  // Jokers actifs pendant la manche
  final List<Joker> jokers;

  final Deck _deck;
  final Enemy enemy;
  final List<PlayingCard> _hand = [];
  final List<PlayingCard> _selected = [];

  int handsLeft;
  int discardsLeft;
  int score = 0;
  RoundStatus status = RoundStatus.playing;

  // Score de la dernière main jouée, pour l'affichage
  ScoreBreakdown? lastScore;

  // Cartes en main, triées par rang décroissant
  List<PlayingCard> get hand => List.unmodifiable(_hand);

  // Cartes sélectionnées, dans l'ordre de la main (de gauche à droite)
  List<PlayingCard> get selected => _hand.where(_selected.contains).toList();

  int get cardsInDeck => _deck.remaining;

  bool get isPlaying => status == RoundStatus.playing;

  bool get canPlay => isPlaying && _selected.isNotEmpty;

  bool get canDiscard => canPlay && discardsLeft > 0;

  bool isSelected(PlayingCard card) => _selected.contains(card);

  /// Sélectionne ou désélectionne [card]
  /// Retourne false si rien n'a changé (manche terminée, carte absente de la main, ou déjà 5 cartes choisies)
  bool toggleSelection(PlayingCard card) {
    if (!isPlaying || !_hand.contains(card)) return false;
    if (_selected.remove(card)) return true;
    if (_selected.length >= HandEvaluator.maxCards) return false;
    _selected.add(card);
    return true;
  }

  // Joue les cartes sélectionnées et ajoute les points au score
  ScoreBreakdown play() {
    if (!canPlay) throw StateError('Aucune carte jouable.');

    final played = selected;
    final breakdown = ScoreCalculator.score(
      HandEvaluator.evaluate(played),
      jokers,
    );
    score += breakdown.total;
    handsLeft--;
    lastScore = breakdown;
    _removeSelectedFromHand();

    if (score >= blind) {
      status = RoundStatus.won;
    } else if (handsLeft == 0) {
      status = RoundStatus.lost;
    } else {
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

  /// Complète la main jusqu'à [handSize] cartes (s'il en reste assez dans la pioche)
  void _refillHand() {
    _hand.addAll(_deck.draw(handSize - _hand.length));
    _hand.sort((a, b) {
      final byRank = b.rank.order.compareTo(a.rank.order);
      return byRank != 0 ? byRank : a.suit.index.compareTo(b.suit.index);
    });
  }
}
