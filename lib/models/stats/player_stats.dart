import 'dart:math';

import 'package:balawish/models/poker/poker_hand.dart';

// Statistiques du joueur, cumulées sur toutes ses parties
class PlayerStats {
  PlayerStats({
    Map<PokerHand, int>? handsPlayed,
    this.gamesPlayed = 0,
    this.bestScore,
    this.worstScore,
    this.maxRound = 0,
  }) : handsPlayed = handsPlayed ?? {};

  // Nombre de mains jouées pour chaque type de main de poker
  final Map<PokerHand, int> handsPlayed;

  int gamesPlayed;

  // Score total d'une partie (toutes manches confondues), null avant la 1re partie
  int? bestScore;
  int? worstScore;

  // Manche la plus avancée atteinte
  int maxRound;

  int handsPlayedOf(PokerHand hand) => handsPlayed[hand] ?? 0;

  int get totalHandsPlayed => handsPlayed.values.fold(0, (sum, n) => sum + n);

  void recordHand(PokerHand hand) {
    handsPlayed[hand] = handsPlayedOf(hand) + 1;
  }

  // Enregistre une partie terminée (ou abandonnée) avec son score et sa manche atteinte
  void recordGame({required int score, required int round}) {
    gamesPlayed++;
    bestScore = max(bestScore ?? score, score);
    worstScore = min(worstScore ?? score, score);
    maxRound = max(maxRound, round);
  }

  // Les mains sont enregistrées par leur nom (et non leur index) : réordonner
  // ou ajouter des valeurs à PokerHand ne fausse pas les données déjà sauvegardées
  Map<String, Object?> toJson() => {
    'handsPlayed': {
      for (final entry in handsPlayed.entries) entry.key.name: entry.value,
    },
    'gamesPlayed': gamesPlayed,
    'bestScore': bestScore,
    'worstScore': worstScore,
    'maxRound': maxRound,
  };

  // Les valeurs absentes ou invalides sont ignorées (données d'une ancienne version)
  factory PlayerStats.fromJson(Map<String, Object?> json) {
    final savedHands = json['handsPlayed'];
    return PlayerStats(
      handsPlayed: {
        if (savedHands is Map)
          for (final hand in PokerHand.values)
            if (savedHands[hand.name] case final int count) hand: count,
      },
      gamesPlayed: _intOr(json['gamesPlayed'], 0),
      bestScore: json['bestScore'] is int ? json['bestScore'] as int : null,
      worstScore: json['worstScore'] is int ? json['worstScore'] as int : null,
      maxRound: _intOr(json['maxRound'], 0),
    );
  }

  static int _intOr(Object? value, int fallback) =>
      value is int ? value : fallback;
}
