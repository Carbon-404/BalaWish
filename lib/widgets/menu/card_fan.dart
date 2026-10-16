import 'dart:math' as math;

import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

/// Une carte de l'éventail : son rang ('A', 'K', '10'…) et son enseigne.
class FanCard {
  const FanCard(this.rank, this.suit);

  final String rank;
  final String suit; // '♠', '♥', '♦' ou '♣'

  bool get isRed => suit == '♥' || suit == '♦';
}

/// Éventail de cartes de la page d'accueil.
///
/// Les cartes s'écartent autour d'un pivot situé sous la main, comme si on
/// les tenait. Si [animate] est vrai, l'éventail « respire » doucement
/// (il s'ouvre, se referme et se balance légèrement).
class CardFan extends StatefulWidget {
  const CardFan({
    super.key,
    this.cards = const [
      FanCard('10', '♠'),
      FanCard('J', '♥'),
      FanCard('Q', '♦'),
      FanCard('K', '♣'),
      FanCard('A', '♥'),
    ],
    this.cardWidth = 96,
    this.spreadAngle = 12,
    this.overlap = 0.55,
    this.animate = true,
  });

  final List<FanCard> cards;

  /// Largeur d'une carte ; la hauteur en découle (ratio 1,45).
  final double cardWidth;

  /// Angle en degrés entre deux cartes voisines.
  final double spreadAngle;

  /// Part de la largeur d'une carte recouverte par la suivante (0 à 1).
  final double overlap;

  /// Active l'animation de respiration.
  final bool animate;

  @override
  State<CardFan> createState() => _CardFanState();
}

class _CardFanState extends State<CardFan> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final Animation<double> _wave = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CardFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.cards.length;
    final cardHeight = widget.cardWidth * 1.45;
    final step = widget.cardWidth * (1 - widget.overlap); // décalage horizontal
    final middle = (count - 1) / 2;
    final dropPerCard = widget.cardWidth * 0.15; // les cartes des bords descendent
    final maxDrop = middle * dropPerCard;

    return SizedBox(
      // Marges pour que les cartes inclinées ne soient pas coupées.
      width: widget.cardWidth * 1.6 + step * (count - 1),
      height: cardHeight + maxDrop + widget.cardWidth * 0.4,
      child: AnimatedBuilder(
        animation: _wave,
        builder: (context, _) {
          final t = _wave.value; // 0 → 1 → 0
          final breathe = 1 + 0.15 * t; // l'éventail s'ouvre de 15 %
          final sway = (t - 0.5) * 0.05; // léger balancement (radians)

          return Transform.rotate(
            angle: sway,
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Ordre de gauche à droite : la carte de droite est dessinée au-dessus.
                for (var i = 0; i < count; i++)
                  _placeCard(
                    card: widget.cards[i],
                    position: i - middle, // négatif à gauche, positif à droite
                    step: step,
                    breathe: breathe,
                    dropPerCard: dropPerCard,
                    maxDrop: maxDrop,
                    cardHeight: cardHeight,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Positionne et incline une carte selon sa place dans l'éventail.
  Widget _placeCard({
    required FanCard card,
    required double position,
    required double step,
    required double breathe,
    required double dropPerCard,
    required double maxDrop,
    required double cardHeight,
  }) {
    final angle = position * widget.spreadAngle * breathe * math.pi / 180;
    final drop = position.abs() * dropPerCard;

    return Transform.translate(
      offset: Offset(position * step * breathe, drop - maxDrop),
      child: Transform.rotate(
        angle: angle,
        // Pivot sous la carte : donne l'effet « tenu en main ».
        alignment: const Alignment(0, 1.4),
        child: _BigCardFace(card: card, width: widget.cardWidth, height: cardHeight),
      ),
    );
  }
}

/// Face d'une grande carte : rang et enseigne en haut à gauche, enseigne au
/// centre, et le coin opposé retourné. Les couleurs viennent du thème.
class _BigCardFace extends StatelessWidget {
  const _BigCardFace({required this.card, required this.width, required this.height});

  final FanCard card;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final ink = card.isRed ? game.cardRed : game.cardBlack;
    final isNeon = game.glow > 0;

    final corner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(card.rank,
            style: TextStyle(color: ink, fontSize: width * 0.2, fontWeight: FontWeight.w700, height: 1)),
        Text(card.suit, style: TextStyle(color: ink, fontSize: width * 0.16, height: 1.1)),
      ],
    );

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(width * 0.08),
      decoration: BoxDecoration(
        color: game.cardFace,
        borderRadius: BorderRadius.circular(width * 0.1),
        border: isNeon ? Border.all(color: ink, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isNeon ? ink.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.4),
            blurRadius: isNeon ? game.glow : 18,
            offset: isNeon ? Offset.zero : const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(alignment: Alignment.topLeft, child: corner),
          Center(child: Text(card.suit, style: TextStyle(color: ink, fontSize: width * 0.46))),
          Align(alignment: Alignment.bottomRight, child: RotatedBox(quarterTurns: 2, child: corner)),
        ],
      ),
    );
  }
}
