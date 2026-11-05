import 'package:balawish/models/enemy/enemy.dart';
import 'package:balawish/models/game/round.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Ennemi de la manche : portrait, nom et effet du boss
// L'image prend toute la place disponible, un appui affiche sa description
class EnemyView extends StatelessWidget {
  const EnemyView({super.key, required this.round});

  final Round round;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final enemy = round.enemy;

    return GestureDetector(
      onTap: () => showEnemyDetails(context, enemy),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              enemy.imagePath(themeNotifier.value.name),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  enemy.name,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (enemy.isBoss) ...[
                const SizedBox(width: 8),
                const BossBadge(),
              ],
            ],
          ),
          if (enemy.isBoss)
            Text(
              _effectText(round),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: game.mult),
            ),
        ],
      ),
    );
  }

  // Effet du boss, complété par l'état actuel de la manche
  static String _effectText(Round round) {
    final suit = round.forbiddenSuit;
    if (round.enemy.effect == BossEffect.randomSuitDebuffed && suit != null) {
      return 'Couleur interdite pour cette main : ${suit.symbol}';
    }
    final joker = round.disabledJoker;
    if (joker != null) {
      return '${round.enemy.effectDescription} (${joker.name})';
    }
    return round.enemy.effectDescription;
  }
}

// Étiquette « BOSS »
class BossBadge extends StatelessWidget {
  const BossBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: game.filledStyle ? game.mult : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: game.filledStyle ? null : Border.all(color: game.mult),
      ),
      child: Text(
        'BOSS',
        style: context.text.labelSmall?.copyWith(
          color: game.filledStyle ? game.onAccent : game.mult,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Fiche de l'ennemi : portrait, description et effet
Future<void> showEnemyDetails(BuildContext context, Enemy enemy) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final game = context.game;
      return AlertDialog(
        title: Row(
          children: [
            Flexible(child: Text(enemy.name)),
            if (enemy.isBoss) ...[const SizedBox(width: 8), const BossBadge()],
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                enemy.imagePath(themeNotifier.value.name),
                height: 140,
              ),
              const SizedBox(height: 12),
              Text(enemy.description, style: context.text.bodyMedium),
              const SizedBox(height: 12),
              Text(
                'Blinde : ${enemy.score}',
                style: context.text.titleSmall?.copyWith(color: game.chips),
              ),
              if (enemy.isBoss) ...[
                const SizedBox(height: 4),
                Text(
                  enemy.effectDescription,
                  textAlign: TextAlign.center,
                  style: context.text.titleSmall?.copyWith(color: game.mult),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    },
  );
}
