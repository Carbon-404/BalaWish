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
          child: Padding(
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
                    onPressed: () =>
                    {
                      print("play")
                    },
                    label: Text(
                      'JOUER',
                      style: context.text.headlineMedium?.copyWith(
                        color: game.onAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FloatingButton(
                    onPressed: () =>
                    {
                      print("shop")
                    },
                    label: Text(
                      'Boutique',
                      style: context.text.headlineSmall?.copyWith(
                        color: game.onAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FloatingButton(
                    onPressed: () =>
                    {
                      print("stats")
                    },
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
        ),
      ),
    );
  }
}
