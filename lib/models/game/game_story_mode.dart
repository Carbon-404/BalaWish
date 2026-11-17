import 'package:balawish/models/enemy/enemy.dart';

import 'game.dart';

// Mode histoire : les ennemis du casino affrontés une seule fois, dans l'ordre
// La partie est gagnée quand La Maison (dernier ennemi) est battue
class GameStoryMode extends Game {
  GameStoryMode({super.random});

  // Nombre de manches d'une partie : une par ennemi, La Maison en dernier
  static int get roundCount => Enemy.values.length;

  @override
  int? get roundLimit => roundCount;

  @override
  bool get isFinalRound => roundNumber >= roundCount;

  /// Blinde de la manche [number] : le score de son ennemi
  @override
  int blindFor(int number) => enemyFor(number).score;

  @override
  Enemy enemyFor(int number) {
    final enemy = Enemy.forRound(number);
    if (enemy == null) {
      throw RangeError.range(
        number,
        1,
        roundCount,
        'number',
        'Round not found',
      );
    }
    return enemy;
  }
}
