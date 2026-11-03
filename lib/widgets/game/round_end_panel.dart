import 'package:balawish/models/game/game_run.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Modale de fin de manche.
class RoundEndPanel extends StatelessWidget {
  const RoundEndPanel({
    super.key,
    required this.run,
    required this.onOpenShop,
    required this.onRestart,
    required this.onQuit,
  });

  final GameRun run;
  final VoidCallback onOpenShop;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final round = run.currentRound;
    final won = round.status == RoundStatus.won;

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: game.panelBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                won ? 'Blinde battue !' : 'Partie terminée',
                style: context.text.headlineSmall?.copyWith(
                  color: won ? game.coins : game.mult,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score : ${round.score} / ${round.blind}',
                style: context.text.titleMedium,
              ),
              const SizedBox(height: 8),
              if (won)...[
                Text(
                '+${run.roundReward} pièces\n'
                '${GameRun.baseReward} de base + ${round.handsLeft} '
                  'pour les mains non jouées'
                  '${run.jokerCoins > 0 ? ' + ${run.jokerCoins} des jokers' : ''}',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(color: game.coins),
                ),
                const SizedBox(height: 12),
                _NextRoundPreview(roundNumber: run.roundNumber + 1)
              ]
              else
                Text(
                  'Vous avez atteint la manche ${run.roundNumber}.',
                  style: context.text.bodyMedium?.copyWith(
                    color: game.textMuted,
                  ),
                ),
              const SizedBox(height: 24),
              if (won)
                FilledButton(
                  onPressed: onOpenShop,
                  child: const Text('Boutique'),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: onQuit,
                      child: const Text('Menu'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onRestart,
                      child: const Text('Rejouer'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Affiche la blinde et le nombre de mains de la manche suivante
class _NextRoundPreview extends StatelessWidget {
  const _NextRoundPreview({required this.roundNumber});

  final int roundNumber;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final blind = GameRun.blindFor(roundNumber);
    final hands = GameRun.handsFor(blind);
    final previousHands = GameRun.handsFor(GameRun.blindFor(roundNumber - 1));

    return Column(
      children: [
        Text(
          'Prochaine manche : $blind — $hands mains',
          style: context.text.bodyMedium?.copyWith(color: game.textMuted),
        ),
        if (hands > previousHands)
          Text(
            '+1 main !',
            style: context.text.titleMedium?.copyWith(color: game.chips),
          ),
      ],
    );
  }
}
