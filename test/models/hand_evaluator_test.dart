import 'package:balawish/models/poker/hand_evaluator.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/poker/score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_cards.dart';

void main() {
  PokerHand handOf(String notation) =>
      HandEvaluator.evaluate(cards(notation)).hand;

  List<String> scoringOf(String notation) => HandEvaluator.evaluate(
    cards(notation),
  ).scoringCards.map((c) => c.toString()).toList();

  group('HandEvaluator détecte', () {
    test('la carte haute', () {
      expect(handOf('7H QS 10C 2D JH'), PokerHand.highCard);
      expect(scoringOf('7H QS 10C 2D JH'), ['Q♠']);
    });

    test('la paire, sans compter les autres cartes', () {
      expect(handOf('5H 5S 9C 3D QH'), PokerHand.pair);
      expect(scoringOf('5H 5S 9C 3D QH'), ['5♥', '5♠']);
    });

    test('la double paire', () {
      expect(handOf('5H 5S 10C 10D KH'), PokerHand.twoPair);
      expect(scoringOf('5H 5S 10C 10D KH'), ['5♥', '5♠', '10♣', '10♦']);
    });

    test('le brelan', () {
      expect(handOf('7H 7S 7D 2C JH'), PokerHand.threeOfAKind);
    });

    test('la suite, y compris avec l\'as en haut ou en bas', () {
      expect(handOf('3H 4S 5D 6C 7H'), PokerHand.straight);
      expect(handOf('10H JS QD KC AH'), PokerHand.straight);
      expect(handOf('AH 2S 3D 4C 5H'), PokerHand.straight);
    });

    test("pas de suite qui fait le tour (Q-K-A-2-3)", () {
      expect(handOf('QH KS AD 2C 3H'), PokerHand.highCard);
    });

    test('la couleur', () {
      expect(handOf('2H QH JH KH 5H'), PokerHand.flush);
    });

    test('la main pleine', () {
      expect(handOf('5H 5S 7C 7D 7H'), PokerHand.fullHouse);
    });

    test('le carré, sans la 5e carte', () {
      expect(handOf('3H 3S 3D 3C JH'), PokerHand.fourOfAKind);
      expect(scoringOf('3H 3S 3D 3C JH'), hasLength(4));
    });

    test('la quinte flush, y compris A-2-3-4-5', () {
      expect(handOf('6C 7C 8C 9C 10C'), PokerHand.straightFlush);
      expect(handOf('AD 2D 3D 4D 5D'), PokerHand.straightFlush);
    });

    test('la quinte flush royale', () {
      expect(handOf('10D JD QD KD AD'), PokerHand.royalFlush);
    });

    test('les mains à moins de 5 cartes', () {
      expect(handOf('KH'), PokerHand.highCard);
      expect(handOf('KH KS'), PokerHand.pair);
      expect(handOf('9H 9S 9C 9D'), PokerHand.fourOfAKind);
      expect(handOf('2H 3H 4H 5H'), PokerHand.highCard);
    });
  });

  test('HandEvaluator refuse 0 ou plus de 5 cartes', () {
    expect(() => HandEvaluator.evaluate([]), throwsArgumentError);
    expect(
      () => HandEvaluator.evaluate(cards('2H 3H 4H 5H 6H 7H')),
      throwsArgumentError,
    );
  });

  group('ScoreCalculator', () {
    test('paire de rois : (10 + 10 + 10) × 2', () {
      final score = ScoreCalculator.score(
        HandEvaluator.evaluate(cards('KH KS 2C')),
      );
      expect(score.chips, 30);
      expect(score.mult, 2);
      expect(score.total, 60);
    });

    test("carte haute à l'as : (5 + 11) × 1", () {
      final score = ScoreCalculator.score(
        HandEvaluator.evaluate(cards('AH 7S 3C')),
      );
      expect(score.total, 16);
    });
  });
}
