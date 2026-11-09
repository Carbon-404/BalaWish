import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/screens/board/board.dart';
import 'package:balawish/screens/planet_shop/planet_shop.dart';
import 'package:balawish/screens/settings/settings.dart';
import 'package:balawish/screens/stats/stats.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/menu/card_fan.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:flutter/material.dart';

import '../../widgets/generic/floating_button.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Background(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'BALAWISH',
                        style: context.text.displayMedium?.copyWith(
                          color: game.coins,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const CardFan(),
                      const SizedBox(height: 24),
                      Text(
                        'Battez les blindes, collectionnez les jokers.',
                        style: context.text.bodyMedium?.copyWith(
                          color: game.textMuted,
                        ),
                      ),
                      const Spacer(),
                      FloatingButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const Board()),
                        ),
                        label: Text(
                          'JOUER',
                          style: context.text.headlineMedium?.copyWith(
                            color: game.onAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FloatingButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PlanetShopScreen(),
                          ),
                        ),
                        label: Text(
                          'Boutique',
                          style: context.text.headlineSmall?.copyWith(
                            color: game.onAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FloatingButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        ),
                        label: Text(
                          'Statistiques',
                          style: context.text.headlineSmall?.copyWith(
                            color: game.onAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bourse globale, alimentée à la fin de chaque partie
              Positioned(
                top: 20,
                left: 16,
                child: ListenableBuilder(
                  listenable: playerPurse,
                  builder: (context, _) => Row(
                    children: [
                      Icon(Icons.savings, color: game.coins),
                      const SizedBox(width: 6),
                      Text(
                        '${playerPurse.coins}',
                        style: context.text.titleMedium?.copyWith(
                          color: game.coins,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  color: game.textMuted,
                  tooltip: 'Paramètres',
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const Settings())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
