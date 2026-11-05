import 'package:balawish/models/cards/deck.dart';
import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_cards.dart';

void main() {
  group('Deck', () {
    test('contient 52 cartes', () {
      expect(Deck.standard().remaining, 52);
    });

    test('ne pioche que les cartes restantes', () {
      final deck = Deck.fromCards(cards('2H 3H'));
      expect(deck.draw(5), hasLength(2));
      expect(deck.isEmpty, isTrue);
    });
  });

  group('Round', () {
    // 7 premières cartes en main, les suivantes restent dans la pioche.
    Round roundWith(String notation, {int blind = 300, int hands = 4}) {
      return Round(
        blind: blind,
        deck: Deck.fromCards(cards(notation)),
        enemy: Enemy.maliciousToken,
        handsLeft: hands,
      );
    }

    test('pioche 7 cartes, triées par rang décroissant', () {
      final round = roundWith('2H 3H 4H 5H 6H 7H 8H 9H 10H');
      expect(round.hand.map((c) => c.toString()), [
        '8♥',
        '7♥',
        '6♥',
        '5♥',
        '4♥',
        '3♥',
        '2♥',
      ]);
      expect(round.cardsInDeck, 2);
    });

    test('limite la sélection à 5 cartes', () {
      final round = roundWith('2H 3S 4H 5S 6H 8S 9H');
      for (final card in round.hand) {
        round.toggleSelection(card);
      }
      expect(round.selected, hasLength(5));
    });

    test('jouer ajoute le score, consomme une main et repioche', () {
      final round = roundWith('KH KS 2C 4D 6H 8S 10C JD QH');
      round.toggleSelection(round.hand.firstWhere((c) => c.toString() == 'K♥'));
      round.toggleSelection(round.hand.firstWhere((c) => c.toString() == 'K♠'));

      final score = round.play();

      expect(score.total, 60);
      expect(round.score, 60);
      expect(round.handsLeft, 3);
      expect(round.hand, hasLength(7));
      expect(round.isPlaying, isTrue);
    });

    test('défausser consomme une défausse et repioche', () {
      final round = roundWith('2H 3S 4H 5S 6H 8S 9H 10D');
      round.toggleSelection(round.hand.first);
      round.discard();

      expect(round.discardsLeft, Round.defaultDiscards - 1);
      expect(round.hand, hasLength(7));
      expect(round.score, 0);
    });

    test('plus de défausse possible quand le compteur est à 0', () {
      final round = Round(
        blind: 300,
        deck: Deck.standard(),
        enemy: Enemy.maliciousToken,
        discardsLeft: 0,
      );
      round.toggleSelection(round.hand.first);
      expect(round.canPlay, isTrue);
      expect(round.canDiscard, isFalse);
    });

    test('est gagnée dès que la blinde est atteinte', () {
      final round = roundWith('KH KS 2C 4D 6H 8S 10C', blind: 50);
      round.toggleSelection(round.hand[0]);
      round.toggleSelection(round.hand[1]);
      round.play();

      expect(round.status, RoundStatus.won);
      expect(round.handsLeft, 3);
    });

    test('est perdue quand il ne reste plus de main', () {
      final round = roundWith('2H 3S 4H 5S 6H 8S 9H 10D', hands: 1);
      round.toggleSelection(round.hand.first);
      round.play();

      expect(round.status, RoundStatus.lost);
    });
  });

  group('GameRun', () {
    test('+1 main chaque fois que la blinde double, plafonné à 8', () {
      expect(GameRun.handsFor(200), 4);
      expect(GameRun.handsFor(799), 4);
      expect(GameRun.handsFor(1200), 6);
      expect(GameRun.handsFor(1600), 6);
      expect(GameRun.handsFor(1601), 7);
      expect(GameRun.handsFor(4999), 7);
      expect(GameRun.handsFor(5000), 8);
      expect(GameRun.handsFor(1000000), 8);
    });

    test('chaque manche reçoit le nombre de mains de sa blinde', () {
      final run = GameRun();
      expect(run.currentRound.handsLeft, 4);

      // Manches 1 et 2 gagnées : la manche 3 (blinde 800) a 6 mains.
      for (var i = 0; i < 2; i++) {
        run.currentRound.status = RoundStatus.won;
        run.openShop();
        run.nextRound();
      }
      expect(run.currentRound.blind, 800);
      expect(run.currentRound.handsLeft, 6);
    });

    test("la blinde est le score de l'ennemi de la manche", () {
      expect(GameRun.blindFor(1), 300);
      expect(GameRun.blindFor(2), 450);
      expect(GameRun.blindFor(3), 800);
      expect(GameRun.blindFor(4), 1200);
    });

    test('gagner une manche rapporte 3 pièces + 1 par main non jouée', () {
      final run = GameRun();
      run.currentRound
        ..score = run.currentRound.blind
        ..status = RoundStatus.won
        ..handsLeft = 2;

      run.openShop();
      expect(run.coins, 5);

      run.nextRound();
      expect(run.roundNumber, 2);
      expect(run.currentRound.blind, 450);
    });

    test('pas de boutique sans victoire, pas de manche suivante sans boutique', () {
      expect(() => GameRun().openShop(), throwsStateError);
      expect(() => GameRun().nextRound(), throwsStateError);
    });
  });
}
