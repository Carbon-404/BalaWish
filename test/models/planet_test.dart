import 'dart:convert';

import 'package:balawish/controllers/game_controller.dart';
import 'package:balawish/controllers/planet_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/planets/hand_levels.dart';
import 'package:balawish/models/planets/planet.dart';
import 'package:balawish/models/poker/hand_evaluator.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/poker/score_calculator.dart';
import 'package:balawish/models/stats/player_stats.dart';
import 'package:balawish/services/planet_storage.dart';
import 'package:balawish/services/purse_storage.dart';
import 'package:balawish/services/stats_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_cards.dart';

// Remplacent le stockage du téléphone par de simples variables
class _MemoryPlanetStorage implements PlanetStorage {
  HandLevels? saved;

  @override
  Future<HandLevels> load() async => saved?.copy() ?? HandLevels();

  @override
  Future<void> save(HandLevels levels) async => saved = levels.copy();
}

class _MemoryPurseStorage implements PurseStorage {
  @override
  Future<int> load() async => 0;

  @override
  Future<void> save(int coins) async {}
}

class _MemoryStatsStorage implements StatsStorage {
  @override
  Future<PlayerStats> load() async => PlayerStats();

  @override
  Future<void> save(PlayerStats stats) async {}
}

void main() {
  test('chaque main de poker a exactement une planète', () {
    for (final hand in PokerHand.values) {
      expect(Planet.values.where((p) => p.hand == hand), hasLength(1));
    }
  });

  test('le prix augmente à chaque niveau', () {
    expect(Planet.priceFor(1), Planet.basePrice);
    expect(Planet.priceFor(2), Planet.basePrice + Planet.priceStep);
    expect(Planet.priceFor(3), Planet.basePrice + 2 * Planet.priceStep);
  });

  group('HandLevels', () {
    test('au niveau 1, une main garde ses valeurs de base', () {
      final levels = HandLevels();
      expect(levels.levelOf(PokerHand.pair), 1);
      expect(levels.chipsFor(PokerHand.pair), PokerHand.pair.baseChips);
      expect(levels.multFor(PokerHand.pair), PokerHand.pair.baseMult);
    });

    test('chaque niveau ajoute les bonus de la planète', () {
      final levels = HandLevels()
        ..upgrade(PokerHand.pair)
        ..upgrade(PokerHand.pair);

      // Paire : 10 × 2, Mercure : +15 jetons, +1 multi par niveau
      expect(levels.levelOf(PokerHand.pair), 3);
      expect(levels.chipsFor(PokerHand.pair), 10 + 2 * 15);
      expect(levels.multFor(PokerHand.pair), 2 + 2 * 1);
      expect(levels.levelOf(PokerHand.flush), 1);
    });

    test('se retrouve identique après un passage en JSON', () {
      final levels = HandLevels()..upgrade(PokerHand.flush);
      final restored = HandLevels.fromJson(
        jsonDecode(jsonEncode(levels.toJson())) as Map<String, Object?>,
      );
      expect(restored.levelOf(PokerHand.flush), 2);
    });

    test('ignore les données invalides', () {
      final restored = HandLevels.fromJson({
        'pair': 3,
        'flush': 'abc',
        'straight': 0,
        'unknownHand': 5,
      });
      expect(restored.levelOf(PokerHand.pair), 3);
      expect(restored.levelOf(PokerHand.flush), 1);
      expect(restored.levelOf(PokerHand.straight), 1);
    });
  });

  test('le score part des valeurs de la main à son niveau', () {
    final levels = HandLevels()..upgrade(PokerHand.pair);
    final result = HandEvaluator.evaluate(cards('KH KS'));

    final score = ScoreCalculator.score(result, const [], null, levels);

    // (10 + 15 + 10 + 10) × (2 + 1)
    expect(score.chips, 45);
    expect(score.mult, 3);
  });

  group('Achat de planètes', () {
    late _MemoryPlanetStorage storage;
    late PurseController purse;
    late PlanetController planets;

    setUp(() {
      storage = _MemoryPlanetStorage();
      purse = PurseController(_MemoryPurseStorage())..deposit(20);
      planets = PlanetController(storage, purse);
    });

    test('acheter paie avec la bourse et monte la main d\'un niveau', () {
      final price = planets.priceOf(Planet.mercury);

      expect(planets.buy(Planet.mercury), isTrue);

      expect(purse.coins, 20 - price);
      expect(planets.levelOf(Planet.mercury), 2);
      expect(storage.saved?.levelOf(PokerHand.pair), 2);
    });

    test('impossible sans assez de pièces dans la bourse', () {
      purse.spend(purse.coins);

      expect(planets.canBuy(Planet.mercury), isFalse);
      expect(planets.buy(Planet.mercury), isFalse);
      expect(planets.levelOf(Planet.mercury), 1);
    });

    test('les niveaux sont rechargés au lancement suivant', () async {
      planets.buy(Planet.jupiter);

      final relaunched = PlanetController(storage, purse);
      await relaunched.load();

      expect(relaunched.levelOf(Planet.jupiter), 2);
    });

    test('une nouvelle partie utilise les niveaux achetés', () {
      planets.buy(Planet.mercury);
      final controller = GameController(
        stats: StatsController(_MemoryStatsStorage()),
        purse: purse,
        planets: planets,
      );

      expect(controller.round.handLevels.levelOf(PokerHand.pair), 2);

      // Un achat pendant la partie ne change pas la partie en cours
      planets.buy(Planet.mercury);
      expect(controller.round.handLevels.levelOf(PokerHand.pair), 2);
    });
  });
}
