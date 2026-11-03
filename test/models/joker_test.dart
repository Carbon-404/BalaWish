import 'package:balawish/models/cards/suit.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/jokers/joker_types.dart';
import 'package:balawish/models/poker/hand_evaluator.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/poker/score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_cards.dart';

void main() {
  // Paire de rois : (10 + 10 + 10) × 2, le 2♥ ne marque pas
  final pairOfKings = HandEvaluator.evaluate(cards('KH KS 2H'));

  group('ScoreCalculator avec jokers', () {
    test('Joker Paire : +20 jetons', () {
      final joker = HandTypeJoker(
        name: 'Paire',
        description: '',
        hands: {PokerHand.pair},
        chips: 20,
      );
      expect(ScoreCalculator.score(pairOfKings, [joker]).chips, 50);
    });

    test("un joker de main ne s'applique pas aux autres mains", () {
      final joker = HandTypeJoker(
        name: 'Couleur',
        description: '',
        hands: {PokerHand.flush},
        mult: 10,
      );
      expect(ScoreCalculator.score(pairOfKings, [joker]).mult, 2);
    });

    test('Joker Cœur : seules les cartes qui marquent comptent', () {
      final joker = SuitJoker(name: 'Cœur', suit: Suit.hearts, mult: 3);
      expect(ScoreCalculator.score(pairOfKings, [joker]).mult, 5);
    });

    test("l'ordre des jokers compte", () {
      final plus = FlatMultJoker(name: '+4', mult: 4);
      final times = TimesMultJoker(name: '×2', factor: 2);
      expect(ScoreCalculator.score(pairOfKings, [plus, times]).mult, 12);
      expect(ScoreCalculator.score(pairOfKings, [times, plus]).mult, 8);
    });
  });

  group('Boutique', () {
    // Simule une manche gagnée puis ouvre la boutique
    void visitShop(GameRun run) {
      run.currentRound.status = RoundStatus.won;
      run.openShop();
    }

    test('ouvrir la boutique encaisse la récompense et propose 3 jokers', () {
      final run = GameRun();
      visitShop(run);
      expect(run.coins, GameRun.baseReward + run.currentRound.handsLeft);
      expect(run.shop!.offers, hasLength(3));
    });

    test('acheter retire les pièces et ajoute le joker', () {
      final run = GameRun()..coins = 20;
      visitShop(run);
      final coinsBefore = run.coins;
      final joker = run.shop!.offers[0]!;

      run.buyJoker(0);

      expect(run.jokers, [joker]);
      expect(run.coins, coinsBefore - joker.price);
      expect(run.shop!.offers[0], isNull);
    });

    test('impossible sans assez de pièces', () {
      final run = GameRun();
      visitShop(run);
      run.coins = 0;
      expect(run.canBuy(0), isFalse);
    });

    test('5 jokers maximum, jamais deux fois le même', () {
      final run = GameRun()..coins = 100;
      visitShop(run);
      for (var i = 0; i < 3; i++) {
        run.buyJoker(i);
      }
      run.nextRound();
      visitShop(run);
      expect(run.shop!.offers.any(run.jokers.contains), isFalse);
      run.buyJoker(0);
      run.buyJoker(1);

      expect(run.jokers, hasLength(GameRun.maxJokers));
      expect(run.canBuy(2), isFalse);
    });

    test('vendre rend le prix de revente', () {
      final run = GameRun()..coins = 20;
      visitShop(run);
      run.buyJoker(0);
      final coinsBefore = run.coins;
      final sellPrice = run.jokers.first.sellPrice;

      run.sellJoker(0);

      expect(run.jokers, isEmpty);
      expect(run.coins, coinsBefore + sellPrice);
    });

    test('les jokers peuvent être réordonnés', () {
      final run = GameRun()..coins = 100;
      visitShop(run);
      run.buyJoker(0);
      run.buyJoker(1);
      final [first, second] = run.jokers;

      run.moveJoker(0, 1);

      expect(run.jokers, [second, first]);
    });

    test('les jokers achetés comptent dans la manche suivante', () {
      final run = GameRun()..coins = 100;
      visitShop(run);
      run.buyJoker(0);
      run.nextRound();
      expect(run.currentRound.jokers, run.jokers);
    });
  });
}
