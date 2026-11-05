import 'dart:math';

import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/cards/suit.dart';
import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/models/jokers/joker_types.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_cards.dart';

void main() {
  Round roundAgainst(
    Enemy enemy,
    String notation, {
    List<Joker> jokers = const [],
    Random? random,
  }) {
    return Round(
      blind: 100000,
      deck: Deck.fromCards(cards(notation)),
      enemy: enemy,
      jokers: jokers,
      random: random,
    );
  }

  PlayingCard cardOf(Round round, String label) =>
      round.hand.firstWhere((c) => c.toString() == label);

  // Gagne la manche en cours puis passe à la suivante
  void winRound(GameRun run) {
    run.currentRound.status = RoundStatus.won;
    run.openShop();
    run.nextRound();
  }

  group('Enemy', () {
    test('un ennemi par manche, dans l\'ordre', () {
      for (var i = 0; i < Enemy.values.length; i++) {
        expect(Enemy.forRound(i + 1), Enemy.values[i]);
      }
      expect(Enemy.forRound(0), isNull);
      expect(Enemy.forRound(Enemy.values.length + 1), isNull);
    });

    test('les boss sont les ennemis avec un effet', () {
      expect(Enemy.maliciousToken.isBoss, isFalse);
      expect(Enemy.spikeQueen.isBoss, isTrue);
      for (final boss in Enemy.values.where((e) => e.isBoss)) {
        expect(boss.effectDescription, isNotEmpty);
      }
    });

    test('blindFor refuse une manche hors de la partie', () {
      expect(() => GameRun.blindFor(GameRun.roundCount + 1), throwsRangeError);
    });
  });

  group('Effets des boss', () {
    test('Dame de Pique : les ♠ ne marquent pas', () {
      final round = roundAgainst(Enemy.spikeQueen, 'KH KS 2C 4D 6H 8S 10C');
      expect(round.isDebuffed(cardOf(round, 'K♠')), isTrue);
      expect(round.isDebuffed(cardOf(round, 'K♥')), isFalse);

      round.toggleSelection(cardOf(round, 'K♥'));
      round.toggleSelection(cardOf(round, 'K♠'));
      // La paire compte, mais seul le K♥ rapporte ses jetons : (10 + 10) × 2
      expect(round.play().total, 40);
    });

    test('Dame de Pique : une carte ♠ ne déclenche pas les jokers', () {
      final round = roundAgainst(
        Enemy.spikeQueen,
        'AS 2C 4D 6H 8S 10C JD',
        jokers: [SuitJoker(name: 'Pique', suit: Suit.spades, mult: 3)],
      );
      round.toggleSelection(cardOf(round, 'A♠'));
      final score = round.play();
      // Carte haute de base : 5 jetons × 1, ni les 11 jetons de l'as ni le +3 multi
      expect(score.chips, 5);
      expect(score.mult, 1);
    });

    test('Baron Roulette : une couleur interdite tirée à chaque main', () {
      final round = roundAgainst(
        Enemy.baronRoulette,
        '2H 3H 4H 5H 6H 7H 8H 9H 10H JH QH KH AH 2S 3S',
        random: Random(1),
      );
      final suit = round.forbiddenSuit;
      expect(suit, isNotNull);
      for (final card in round.hand) {
        expect(round.isDebuffed(card), card.suit == suit);
      }

      // Une nouvelle enseigne est tirée après chaque main jouée
      final seen = {suit};
      for (var i = 0; i < 3 && round.isPlaying; i++) {
        round.toggleSelection(round.hand.first);
        round.play();
        seen.add(round.forbiddenSuit);
      }
      expect(seen.length, greaterThan(1));
    });

    test('les ennemis sans effet ne neutralisent rien', () {
      final round = roundAgainst(Enemy.twinDices, 'KH KS 2C 4D 6H 8S 10C');
      expect(round.hand.any(round.isDebuffed), isFalse);
      expect(round.forbiddenSuit, isNull);
      expect(round.discardsLeft, Round.defaultDiscards);
    });

    test('La Maison : désactive le joker le plus à gauche', () {
      final first = FlatMultJoker(name: '+4', mult: 4);
      final second = FlatMultJoker(name: '+1', mult: 1);
      final round = roundAgainst(
        Enemy.theHouse,
        'KH KS 2C 4D 6H 8S 10C',
        jokers: [first, second],
      );
      expect(round.disabledJoker, first);
      expect(round.jokers, [second]);

      round.toggleSelection(cardOf(round, 'K♥'));
      round.toggleSelection(cardOf(round, 'K♠'));
      // (10 + 10 + 10) × (2 + 1)
      expect(round.play().total, 90);
    });

    test('La Maison sans joker ne plante pas', () {
      final round = roundAgainst(Enemy.theHouse, 'KH KS 2C 4D 6H 8S 10C');
      expect(round.disabledJoker, isNull);
      expect(round.jokers, isEmpty);
    });

    test('Le Banquier : une seule défausse et récompense doublée', () {
      final run = GameRun();
      while (run.enemy != Enemy.theBanker) {
        winRound(run);
      }
      expect(run.currentRound.discardsLeft, 1);

      run.coins = 0;
      run.currentRound
        ..status = RoundStatus.won
        ..handsLeft = 2;
      run.openShop();
      expect(run.coins, (GameRun.baseReward + 2) * 2);
    });

    test('Valet Tricheur : chaque défausse coûte une pièce', () {
      final run = GameRun();
      while (run.enemy != Enemy.cheatingValet) {
        winRound(run);
      }
      run.coins = 1;
      final round = run.currentRound;

      round.toggleSelection(round.hand.first);
      run.discard();
      expect(run.coins, 0);
      expect(round.discardsLeft, Round.defaultDiscards - 1);

      // Pas de dette : le solde reste à 0
      round.toggleSelection(round.hand.first);
      run.discard();
      expect(run.coins, 0);
    });

    test('les défausses sont gratuites face aux autres ennemis', () {
      final run = GameRun()..coins = 5;
      run.currentRound.toggleSelection(run.currentRound.hand.first);
      run.discard();
      expect(run.coins, 5);
    });
  });

  group('Fin de partie', () {
    test('battre La Maison gagne la partie, sans boutique', () {
      final run = GameRun();
      for (var i = 1; i < GameRun.roundCount; i++) {
        expect(run.isFinalRound, isFalse);
        winRound(run);
      }
      expect(run.enemy, Enemy.theHouse);
      expect(run.isFinalRound, isTrue);
      expect(run.isOver, isFalse);

      run.currentRound.status = RoundStatus.won;
      expect(run.isVictory, isTrue);
      expect(run.isOver, isTrue);
      expect(run.openShop, throwsStateError);
    });

    test('perdre une manche termine la partie sans victoire', () {
      final run = GameRun();
      run.currentRound.status = RoundStatus.lost;
      expect(run.isOver, isTrue);
      expect(run.isVictory, isFalse);
    });
  });
}
