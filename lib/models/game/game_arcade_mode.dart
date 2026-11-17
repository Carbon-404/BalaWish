import 'dart:math';

import 'package:balawish/models/enemy/enemy.dart';

import 'game.dart';

// Mode arcade : la partie ne s'arrête qu'à la défaite
// Les premières manches sont celles du mode histoire, puis les ennemis
// reviennent dans le même ordre (cycles), avec une blinde qui augmente à chaque manche
class GameArcadeMode extends Game {
  GameArcadeMode({super.random});

  // Après le premier cycle, chaque manche demande 25 % de points en plus
  static const blindGrowth = 1.25;

  // Les blindes calculées sont arrondies à ce pas, pour rester lisibles
  static const blindRounding = 50;

  static int get _enemyCount => Enemy.values.length;

  @override
  int? get roundLimit => null;

  @override
  bool get isFinalRound => false;

  // Cycle en cours : 1 pendant les manches du mode histoire, puis 2, 3…
  int get cycle => cycleOf(roundNumber);

  static int cycleOf(int number) => (number - 1) ~/ _enemyCount + 1;

  @override
  Enemy enemyFor(int number) => Enemy.forRound((number - 1) % _enemyCount + 1)!;

  // Premier cycle : la blinde de l'ennemi (comme en histoire)
  // Ensuite : la blinde du dernier ennemi, augmentée de [blindGrowth] par manche
  @override
  int blindFor(int number) {
    if (number <= _enemyCount) return enemyFor(number).score;
    final finalBlind = enemyFor(_enemyCount).score;
    final blind = finalBlind * pow(blindGrowth, number - _enemyCount);
    return (blind / blindRounding).round() * blindRounding;
  }
}
