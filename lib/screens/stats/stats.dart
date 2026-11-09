import 'package:balawish/controllers/stats_controller.dart';
import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/poker/poker_hand.dart';
import 'package:balawish/models/stats/player_stats.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:flutter/material.dart';

// Statistiques cumulées du joueur, sauvegardées entre deux lancements
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Background(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Statistiques', style: context.text.headlineSmall),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: playerStats,
            builder: (context, _) {
              final stats = playerStats.stats;
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      _StatTile(
                        label: 'Parties jouées',
                        value: '${stats.gamesPlayed}',
                        color: game.chips,
                      ),
                      const SizedBox(width: 8),
                      _StatTile(
                        label: 'Manche max',
                        value: '${stats.maxRound} / ${GameRun.roundCount}',
                        color: game.coins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatTile(
                        label: 'Meilleur score',
                        value: _scoreText(stats.bestScore),
                        color: game.chips,
                      ),
                      const SizedBox(width: 8),
                      _StatTile(
                        label: 'Pire score',
                        value: _scoreText(stats.worstScore),
                        color: game.mult,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MAINS JOUÉES (${stats.totalHandsPlayed})',
                    style: context.text.labelLarge?.copyWith(
                      color: game.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HandsChart(stats: stats),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Tiret tant qu'aucune partie n'a été jouée
  static String _scoreText(int? score) => score == null ? '—' : '$score';
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: game.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: game.panelBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: context.text.labelSmall?.copyWith(color: game.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.text.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Une ligne par type de main, de la plus forte à la plus faible
// La barre est proportionnelle à la main la plus jouée
class _HandsChart extends StatelessWidget {
  const _HandsChart({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final hands = PokerHand.values.reversed;
    final mostPlayed = hands.map(stats.handsPlayedOf).fold(0, (a, b) {
      return a > b ? a : b;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: game.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: game.panelBorder),
      ),
      child: Column(
        children: [
          for (final hand in hands)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(hand.label, style: context.text.bodyMedium),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: mostPlayed == 0
                            ? 0
                            : stats.handsPlayedOf(hand) / mostPlayed,
                        minHeight: 10,
                        color: game.chips,
                        backgroundColor: game.panelBorder,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${stats.handsPlayedOf(hand)}',
                      textAlign: TextAlign.right,
                      style: context.text.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
