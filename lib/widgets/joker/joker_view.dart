import 'package:balawish/models/jokers/joker.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Carte de joker, encadrée de la couleur de sa rareté
// En version compacte (plateau), la description s'affiche par appui long
class JokerView extends StatelessWidget {
  const JokerView({
    super.key,
    required this.joker,
    this.width = 110,
    this.compact = false,
    this.footer,
    this.disabled = false,
  });

  final Joker joker;
  final double width;
  final bool compact;
  final Widget? footer;

  // Joker neutralisé par un boss : grisé et sans effet pendant la manche
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final color = game.rarity[joker.rarity.index];

    final card = Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: game.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          if (game.glow > 0)
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: game.glow / 2,
            ),
        ],
      ),
      // Si la carte est étirée en hauteur, le pied reste collé en bas
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                joker.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style:
                (compact
                    ? context.text.labelSmall
                    : context.text.labelLarge)
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
              if (!compact) ...[
                const SizedBox(height: 6),
                Text(
                  joker.description,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall,
                ),
              ],
            ],
          ),
          if (footer != null)
            Padding(padding: const EdgeInsets.only(top: 8), child: footer),
        ],
      ),
    );

    if (disabled) {
      return Tooltip(
        message: 'Désactivé pour cette manche',
        child: Opacity(opacity: 0.35, child: card),
      );
    }
    return compact ? Tooltip(message: joker.description, child: card) : card;
  }
}