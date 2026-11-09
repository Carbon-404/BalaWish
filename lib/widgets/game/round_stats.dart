import 'package:balawish/models/game/game_story_mode.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Affichage top du gameboard : blinde, score, mains / défausses restantes et pièces.
class RoundStats extends StatelessWidget {
  const RoundStats({super.key, required this.run});

  final GameStoryMode run;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final round = run.currentRound;

    return Column(
      children: [
        Row(
          children: [
            _StatBox(
              label: 'Blinde',
              value: '${round.blind}',
              color: game.mult,
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: 'Score',
              value: '${round.score}',
              color: game.chips,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatBox(
              label: 'Mains',
              value: '${round.handsLeft}',
              color: game.chips,
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: 'Défausses',
              value: '${round.discardsLeft}',
              color: game.mult,
            ),
            const SizedBox(width: 8),
            _StatBox(label: 'Pièces', value: '${run.coins}', color: game.coins),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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