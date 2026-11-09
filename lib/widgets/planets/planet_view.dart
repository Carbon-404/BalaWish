import 'package:balawish/models/planets/planet.dart';
import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

// Couleur propre à chaque planète, identique dans tous les thèmes
extension PlanetColor on Planet {
  Color get color => switch (this) {
    Planet.pluto => const Color(0xFFB8A99A),
    Planet.mercury => const Color(0xFF9E9E9E),
    Planet.venus => const Color(0xFFE8C07D),
    Planet.earth => const Color(0xFF3D8BD9),
    Planet.mars => const Color(0xFFD9573D),
    Planet.jupiter => const Color(0xFFD9A066),
    Planet.saturn => const Color(0xFFE3C878),
    Planet.uranus => const Color(0xFF7FD6E0),
    Planet.neptune => const Color(0xFF3F5FD9),
    Planet.sun => const Color(0xFFFFB300),
  };
}

// Carte planète de la boutique : la planète, la main qu'elle améliore, son
// niveau actuel avec ses jetons × multi, le gain par niveau et le bouton d'achat
class PlanetView extends StatelessWidget {
  const PlanetView({
    super.key,
    required this.planet,
    required this.level,
    required this.chips,
    required this.mult,
    required this.price,
    required this.onBuy,
  });

  final Planet planet;
  final int level;

  // Jetons et multi de la main au niveau actuel
  final int chips;
  final int mult;

  final int price;

  // null si la bourse ne contient pas assez de pièces
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    final color = planet.color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: game.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          if (game.glow > 0)
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: game.glow / 2,
            ),
        ],
      ),
      // Le bouton reste en bas quand la carte est étirée en hauteur
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              _PlanetDrawing(planet: planet),
              const SizedBox(height: 8),
              Text(
                planet.name,
                style: context.text.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${planet.hand.label} · Niv. $level',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: game.textMuted),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$chips',
                      style: TextStyle(color: game.chips),
                    ),
                    const TextSpan(text: ' × '),
                    TextSpan(
                      text: '$mult',
                      style: TextStyle(color: game.mult),
                    ),
                  ],
                ),
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+${planet.chips} jetons, +${planet.mult} multi',
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onBuy,
            icon: const Icon(Icons.savings, size: 18),
            label: Text('$price'),
          ),
        ],
      ),
    );
  }
}

// Planète dessinée : une sphère éclairée en haut à gauche, avec un anneau
// pour Saturne
class _PlanetDrawing extends StatelessWidget {
  const _PlanetDrawing({required this.planet});

  final Planet planet;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    final color = planet.color;
    final sphere = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Color.lerp(color, Colors.white, 0.55)!,
            color,
            Color.lerp(color, Colors.black, 0.5)!,
          ],
          stops: const [0, 0.5, 1],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 14),
        ],
      ),
    );

    if (planet != Planet.saturn) return sphere;

    return SizedBox(
      width: _size * 1.6,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          sphere,
          Transform.rotate(
            angle: -0.35,
            child: Container(
              width: _size * 1.6,
              height: _size * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(_size, 12)),
                border: Border.all(
                  color: Color.lerp(color, Colors.white, 0.3)!,
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
