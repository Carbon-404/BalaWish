import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/game/game.dart';
import 'package:balawish/models/game/game_arcade_mode.dart';
import 'package:balawish/models/game/game_story_mode.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/stats/stats.dart';
import 'package:flutter_test/flutter_test.dart';

// Simule une manche gagnée puis passe à la suivante (via la boutique)
void winRound(Game run) {
  run.currentRound.status = RoundStatus.won;
  run.openShop();
  run.nextRound();
}

void main() {
  group('Mode histoire', () {
    test('se termine par une victoire contre le dernier ennemi', () {
      final run = GameStoryMode();
      for (var i = 1; i < GameStoryMode.roundCount; i++) {
        winRound(run);
      }
      expect(run.isFinalRound, isTrue);
      expect(run.enemy, Enemy.theHouse);

      run.currentRound.status = RoundStatus.won;
      expect(run.isVictory, isTrue);
      expect(run.isOver, isTrue);
      expect(run.openShop, throwsStateError);
    });
  });

  group('Mode arcade', () {
    final arcade = GameArcadeMode();

    test('le premier cycle reprend les blindes du mode histoire', () {
      for (final enemy in Enemy.values) {
        expect(arcade.enemyFor(enemy.order), enemy);
        expect(arcade.blindFor(enemy.order), enemy.score);
      }
    });

    test('les ennemis reviennent dans le même ordre après le dernier', () {
      final count = Enemy.values.length;
      expect(arcade.enemyFor(count + 1), Enemy.maliciousToken);
      expect(arcade.enemyFor(2 * count), Enemy.theHouse);
      expect(GameArcadeMode.cycleOf(count), 1);
      expect(GameArcadeMode.cycleOf(count + 1), 2);
    });

    test('la blinde augmente à chaque manche après le premier cycle', () {
      final count = Enemy.values.length;
      var previous = arcade.blindFor(count);
      for (var n = count + 1; n <= count + 20; n++) {
        final blind = arcade.blindFor(n);
        expect(blind, greaterThan(previous));
        expect(blind % GameArcadeMode.blindRounding, 0);
        previous = blind;
      }
    });

    test('ne se termine jamais par une victoire', () {
      final run = GameArcadeMode();
      for (var i = 0; i < 2 * Enemy.values.length; i++) {
        winRound(run);
      }
      expect(run.roundNumber, 2 * Enemy.values.length + 1);
      expect(run.roundLimit, isNull);

      run.currentRound.status = RoundStatus.won;
      expect(run.isVictory, isFalse);
      expect(run.isOver, isFalse);
    });

    test('la partie s\'arrête à la défaite', () {
      final run = GameArcadeMode();
      run.currentRound.status = RoundStatus.lost;
      expect(run.isOver, isTrue);
    });
  });

  group('Statistiques par mode', () {
    test('le record arcade est séparé de la manche max en histoire', () {
      final stats = Stat()
        ..recordGame(score: 900, round: 5, mode: GameMode.story)
        ..recordGame(score: 40000, round: 14, mode: GameMode.arcade);

      expect(stats.maxRound, 5);
      expect(stats.maxArcadeRound, 14);
      expect(stats.gamesPlayed, 2);
    });

    test('le record arcade est conservé après un passage en JSON', () {
      final stats = Stat()
        ..recordGame(score: 100, round: 12, mode: GameMode.arcade);
      expect(Stat.fromJson(stats.toJson()).maxArcadeRound, 12);
    });
  });
}
