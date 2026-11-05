import 'package:balawish/models/cards/playing_card.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Face d'une carte de la main.
// La/les cartes sélectionnées sont mises en avant
class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    required this.width,
    this.selected = false,
    this.onTap,
    this.debuffed = false,
  });

  final PlayingCard card;
  final double width;
  final bool selected;
  final VoidCallback? onTap;

  // Carte neutralisée par un boss : elle ne marquera pas
  final bool debuffed;

  static const heightRatio = 1.45;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final ink = card.suit.isRed ? game.cardRed : game.cardBlack;
    final isNeon = game.glow > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: debuffed ? 0.5 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedSlide(
          offset: Offset(0, selected ? -0.18 : 0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: width,
            height: width * heightRatio,
            padding: EdgeInsets.all(width * 0.08),
            decoration: BoxDecoration(
              color: game.cardFace,
              borderRadius: BorderRadius.circular(width * 0.12),
              border: selected
                  ? Border.all(color: game.selection, width: 2.5)
                  : isNeon
                  ? Border.all(color: ink, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isNeon
                      ? ink.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.35),
                  blurRadius: isNeon ? game.glow / 2 : 6,
                  offset: isNeon ? Offset.zero : const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    card.rank.label,
                    style: TextStyle(
                      color: ink,
                      fontSize: width * 0.3,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.5),
                  child: Text(
                    card.suit.symbol,
                    style: TextStyle(color: ink, fontSize: width * 0.5),
                  ),
                ),
                if (debuffed)
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.block,
                      size: width * 0.28,
                      color: game.mult,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
