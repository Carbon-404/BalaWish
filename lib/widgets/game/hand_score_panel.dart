import 'package:balawish/models/game/round.dart';
import 'package:balawish/models/poker/hand_evaluator.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Main créée avec la sélection jetons et multi, ou le résultat de la dernière main (par défaut)
class HandScorePanel extends StatelessWidget {
  const HandScorePanel({super.key, required this.round});

  final Round round;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final selected = round.selected;
    final last = round.lastScore;

    String title;
    String chips = '-';
    String mult = '-';
    String? total;

    if (selected.isNotEmpty) {
      final hand = HandEvaluator.evaluate(selected).hand;
      title = hand.label;
      chips = '${hand.baseChips}';
      mult = '${hand.baseMult}';
    } else if (last != null) {
      title = last.hand.label;
      chips = '${last.chips}';
      mult = '${last.mult}';
      total = '+${last.total}';
    } else {
      title = "Sélectionnez jusqu'à 5 cartes";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: game.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: game.panelBorder),
      ),
      child: Column(
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ValueBox(value: chips, color: game.chips),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('×', style: context.text.headlineMedium),
              ),
              _ValueBox(value: mult, color: game.mult),
            ],
          ),
          if (total != null) ...[
            const SizedBox(height: 8),
            Text(
              total,
              style: context.text.titleLarge?.copyWith(color: game.coins),
            ),
          ],
        ],
      ),
    );
  }
}

// Case pleine avec les jetons ou le multi.
class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.value, required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: game.filledStyle ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: game.filledStyle ? null : Border.all(color: color, width: 2),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: context.text.headlineMedium?.copyWith(
          color: game.filledStyle ? game.onAccent : color,
        ),
      ),
    );
  }
}
