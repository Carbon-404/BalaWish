import 'package:balawish/screens/settings/settings.dart';
import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/menu/card_fan.dart';
import 'package:balawish/widgets/generic/floating_button.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:flutter/material.dart';

import '../board/history_mode_board.dart';

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
                          MaterialPageRoute(builder: (_) => const HistoryModeBoard()),
                        ),
                        label: Text(
                          'Mode Histoire',
                          style: context.text.headlineMedium?.copyWith(
                            color: game.onAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FloatingButton(
                        onPressed: () => {},
                        label: Text(
                          'Mode Arcade',
                          style: context.text.headlineMedium?.copyWith(
                            color: game.onAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FloatingButton(
                        onPressed: () => {},
                        label: Text(
                          'Stats',
                          style: context.text.headlineSmall?.copyWith(
                            color: game.onAccent,
                          ),
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
