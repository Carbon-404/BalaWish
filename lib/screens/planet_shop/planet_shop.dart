import 'package:balawish/controllers/planet_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/models/planets/planet.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:balawish/widgets/planets/planet_view.dart';
import 'package:flutter/material.dart';

// Boutique du menu : les planètes s'achètent avec la bourse et améliorent
// pour toujours les mains de poker, dans toutes les parties suivantes
class PlanetShopScreen extends StatelessWidget {
  const PlanetShopScreen({super.key});

  static const _columns = 2;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    // Planètes de la plus forte main à la plus faible
    final planets = Planet.values.reversed.toList();

    return Background(
      child: ListenableBuilder(
        listenable: Listenable.merge([playerPurse, playerPlanets]),
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('Boutique', style: context.text.headlineSmall),
            actions: [
              Icon(Icons.savings, color: game.coins),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${playerPurse.coins}',
                  style: context.text.titleMedium?.copyWith(
                    color: game.coins,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Chaque planète améliore pour toujours les jetons et le '
                  'multi de départ d\'une main de poker.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: game.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < planets.length; i += _columns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // Les cartes d'une même ligne prennent la hauteur de la plus grande
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final planet in planets.skip(i).take(_columns))
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: _buildCard(context, planet),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Planet planet) {
    final levels = playerPlanets.levels;
    return PlanetView(
      planet: planet,
      level: playerPlanets.levelOf(planet),
      chips: levels.chipsFor(planet.hand),
      mult: levels.multFor(planet.hand),
      price: playerPlanets.priceOf(planet),
      onBuy: playerPlanets.canBuy(planet) ? () => _buy(context, planet) : null,
    );
  }

  void _buy(BuildContext context, Planet planet) {
    if (!playerPlanets.buy(planet)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${planet.name} : ${planet.hand.label} passe au niveau '
            '${playerPlanets.levelOf(planet)} !',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
