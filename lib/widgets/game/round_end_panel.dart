import 'package:balawish/models/game/game_story_mode.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/enemy/enemy_view.dart';
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

  final GameStoryMode run;
  final VoidCallback onOpenShop;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final round = run.currentRound;
    final enemy = round.enemy;
    final won = round.status == RoundStatus.won;
    final victory = run.isVictory;

    final String title;
    if (victory) {
      title = 'Le casino est vaincu !';
    } else if (won) {
      title = '${enemy.name} battu !';
    } else {
      title = 'Partie terminée';
    }

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
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
                  title,
                  textAlign: TextAlign.center,
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
                if (victory)
                  Text(
                    'Vous avez battu les ${GameStoryMode.roundCount} ennemis. '
                        'La Maison ne gagne pas toujours !',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(color: game.coins),
                  )
                else if (won) ...[
                  Text(
                    '+${run.roundReward} pièces\n'
                        '${GameStoryMode.baseReward} de base + ${round.handsLeft} '
                        'pour les mains non jouées'
                        '${run.jokerCoins > 0 ? ' + ${run.jokerCoins} des jokers' : ''}'
                        '${run.rewardMultiplier > 1 ? ', ×${run.rewardMultiplier} (${enemy.name})' : ''}',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(color: game.coins),
                  ),
                  const SizedBox(height: 12),
                  _NextRoundPreview(roundNumber: run.roundNumber + 1),
                ] else
                  Text(
                    '${enemy.name} vous a battu à la manche '
                        '${run.roundNumber} / ${GameStoryMode.roundCount}.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: game.textMuted,
                    ),
                  ),
                const SizedBox(height: 24),
                if (won && !victory)
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
      ),
    );
  }
}

// Affiche l'ennemi, la blinde et le nombre de mains de la manche suivante
class _NextRoundPreview extends StatelessWidget {
  const _NextRoundPreview({required this.roundNumber});

  final int roundNumber;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final enemy = GameStoryMode.enemyFor(roundNumber);
    final hands = GameStoryMode.handsFor(enemy.score);
    final previousHands = GameStoryMode.handsFor(GameStoryMode.blindFor(roundNumber - 1));

    return Column(
      children: [
        GestureDetector(
          onTap: () => showEnemyDetails(context, enemy),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Prochain ennemi : ${enemy.name}',
                  style: context.text.bodyMedium,
                ),
              ),
              if (enemy.isBoss) ...[
                const SizedBox(width: 6),
                const BossBadge(),
              ],
            ],
          ),
        ),
        if (enemy.isBoss)
          Text(
            enemy.effectDescription,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(color: game.mult),
          ),
        const SizedBox(height: 4),
        Text(
          'Blinde : ${enemy.score} — $hands mains',
          style: context.text.bodyMedium?.copyWith(color: game.textMuted),
        ),
        if (hands > previousHands)
          Text(
            '+${hands - previousHands} main${hands - previousHands > 1 ? 's' : ''} !',
            style: context.text.titleMedium?.copyWith(color: game.chips),
          ),
      ],
    );
  }
}