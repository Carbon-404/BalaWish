import 'dart:convert';

import 'package:balawish/controllers/game_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/stats/player_stats.dart';
import 'package:balawish/services/purse_storage.dart';
import 'package:balawish/services/stats_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Remplace le stockage du téléphone par une simple variable
class _MemoryStorage implements StatsStorage {
  PlayerStats? saved;

  @override
  Future<PlayerStats> load() async => saved ?? PlayerStats();

  @override
  Future<void> save(PlayerStats stats) async => saved = stats;
}

// Bourse sans stockage : ces tests ne vérifient que les statistiques
class _NoPurseStorage implements PurseStorage {
  @override
  Future<int> load() async => 0;

  @override
  Future<void> save(int coins) async {}
}

PurseController _noPurse() => PurseController(_NoPurseStorage());

void main() {
  group('PlayerStats', () {
    test('compte chaque type de main jouée', () {
      final stats = PlayerStats()
        ..recordHand(PokerHand.pair)
        ..recordHand(PokerHand.pair)
        ..recordHand(PokerHand.flush);

      expect(stats.handsPlayedOf(PokerHand.pair), 2);
      expect(stats.handsPlayedOf(PokerHand.flush), 1);
      expect(stats.handsPlayedOf(PokerHand.straight), 0);
      expect(stats.totalHandsPlayed, 3);
    });

    test('garde le meilleur et le pire score et la manche max', () {
      final stats = PlayerStats()
        ..recordGame(score: 500, round: 2)
        ..recordGame(score: 1200, round: 4)
        ..recordGame(score: 300, round: 3);

      expect(stats.gamesPlayed, 3);
      expect(stats.bestScore, 1200);
      expect(stats.worstScore, 300);
      expect(stats.maxRound, 4);
    });

    test('pas de score avant la première partie', () {
      final stats = PlayerStats();
      expect(stats.bestScore, isNull);
      expect(stats.worstScore, isNull);
    });

    test('se retrouve identique après un passage en JSON', () {
      final stats = PlayerStats()
        ..recordHand(PokerHand.twoPair)
        ..recordGame(score: 800, round: 3);

      final restored = PlayerStats.fromJson(
        jsonDecode(jsonEncode(stats.toJson())) as Map<String, Object?>,
      );

      expect(restored.handsPlayedOf(PokerHand.twoPair), 1);
      expect(restored.gamesPlayed, 1);
      expect(restored.bestScore, 800);
      expect(restored.worstScore, 800);
      expect(restored.maxRound, 3);
    });

    test('ignore les données inconnues ou invalides', () {
      final restored = PlayerStats.fromJson({
        'handsPlayed': {'pair': 4, 'unknownHand': 2, 'flush': 'abc'},
        'gamesPlayed': 'oops',
      });

      expect(restored.handsPlayedOf(PokerHand.pair), 4);
      expect(restored.totalHandsPlayed, 4);
      expect(restored.gamesPlayed, 0);
    });
  });

  group('Statistiques pendant une partie', () {
    late _MemoryStorage storage;
    late StatsController stats;

    setUp(() {
      storage = _MemoryStorage();
      stats = StatsController(storage);
    });

    void playFirstCard(GameController controller) {
      controller.toggleSelection(controller.round.hand.first);
      controller.play();
    }

    test('chaque main jouée est comptée et sauvegardée', () {
      final controller = GameController(stats: stats, purse: _noPurse());
      playFirstCard(controller);

      expect(stats.stats.totalHandsPlayed, 1);
      expect(storage.saved?.totalHandsPlayed, 1);
    });

    test('quitter après avoir joué compte une partie', () {
      final controller = GameController(stats: stats, purse: _noPurse());
      playFirstCard(controller);
      final score = controller.run.totalScore;

      controller.dispose();

      expect(stats.stats.gamesPlayed, 1);
      expect(stats.stats.bestScore, score);
      expect(stats.stats.maxRound, 1);
    });

    test("quitter sans avoir joué ne compte pas de partie", () {
      GameController(stats: stats, purse: _noPurse()).dispose();
      expect(stats.stats.gamesPlayed, 0);
    });

    test('une partie perdue est comptée une seule fois', () {
      final controller = GameController(stats: stats, purse: _noPurse());
      while (!controller.run.isOver) {
        playFirstCard(controller);
      }
      controller.restart();
      controller.dispose();

      expect(stats.stats.gamesPlayed, 1);
    });

    test('les statistiques sont rechargées au lancement suivant', () async {
      final controller = GameController(stats: stats, purse: _noPurse());
      playFirstCard(controller);
      controller.dispose();

      final relaunched = StatsController(storage);
      await relaunched.load();

      expect(relaunched.stats.gamesPlayed, 1);
      expect(relaunched.stats.totalHandsPlayed, 1);
    });
  });

  test('le score de la partie cumule toutes les manches', () {
    final run = GameRun();
    run.currentRound
      ..score = 400
      ..status = RoundStatus.won;
    run.openShop();
    run.nextRound();
    run.currentRound.score = 150;

    expect(run.totalScore, 550);
  });
}
