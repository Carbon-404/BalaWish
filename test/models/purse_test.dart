import 'package:balawish/controllers/game_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/stats/player_stats.dart';
import 'package:balawish/services/purse_storage.dart';
import 'package:balawish/services/stats_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Remplace le stockage du téléphone par une simple variable
class _MemoryPurseStorage implements PurseStorage {
  int saved = 0;

  @override
  Future<int> load() async => saved;

  @override
  Future<void> save(int coins) async => saved = coins;
}

class _MemoryStatsStorage implements StatsStorage {
  @override
  Future<PlayerStats> load() async => PlayerStats();

  @override
  Future<void> save(PlayerStats stats) async {}
}

void main() {
  group('PurseController', () {
    test('ajoute les pièces et les sauvegarde', () {
      final storage = _MemoryPurseStorage();
      final purse = PurseController(storage)
        ..deposit(4)
        ..deposit(3);

      expect(purse.coins, 7);
      expect(storage.saved, 7);
    });

    test('ignore les dépôts nuls', () {
      final purse = PurseController(_MemoryPurseStorage())..deposit(0);
      expect(purse.coins, 0);
    });

    test('retrouve la bourse au lancement suivant', () async {
      final storage = _MemoryPurseStorage();
      PurseController(storage).deposit(12);

      final relaunched = PurseController(storage);
      await relaunched.load();

      expect(relaunched.coins, 12);
    });
  });

  group('Pièces versées en fin de partie', () {
    test('la moitié des pièces en cas de défaite, arrondie en dessous', () {
      final run = GameRun()..coins = 11;
      run.currentRound.status = RoundStatus.lost;
      expect(run.coinsForPurse, 5);
    });

    test('toutes les pièces en cas de victoire', () {
      final run = GameRun()
        ..coins = 11
        ..roundNumber = GameRun.roundCount;
      run.currentRound.status = RoundStatus.won;
      expect(run.coinsForPurse, 11);
    });
  });

  group('Bourse pendant une partie', () {
    late _MemoryPurseStorage storage;
    late PurseController purse;

    setUp(() {
      storage = _MemoryPurseStorage();
      purse = PurseController(storage);
    });

    GameController newGame() => GameController(
      stats: StatsController(_MemoryStatsStorage()),
      purse: purse,
    );

    void playFirstCard(GameController controller) {
      controller.toggleSelection(controller.round.hand.first);
      controller.play();
    }

    test('une partie perdue verse la moitié de ses pièces, une seule fois', () {
      final controller = newGame();
      controller.run.coins = 10;
      while (!controller.run.isOver) {
        playFirstCard(controller);
      }
      controller.restart();
      controller.dispose();

      expect(purse.coins, 5);
      expect(storage.saved, 5);
    });

    test('abandonner en cours de partie compte comme une défaite', () {
      final controller = newGame();
      playFirstCard(controller);
      controller.run.coins = 9;

      controller.dispose();

      expect(purse.coins, 4);
    });

    test('chaque nouvelle partie repart de 0 pièce', () {
      final controller = newGame();
      controller.run.coins = 10;
      playFirstCard(controller);
      controller.restart();

      expect(controller.run.coins, 0);
      expect(purse.coins, 5);
    });
  });
}
