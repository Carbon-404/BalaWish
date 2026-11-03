import 'package:balawish/theme/theme.dart';
import 'package:balawish/widgets/generic/background.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return Background(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Paramètres', style: context.text.headlineSmall),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'THÈME',
                style: context.text.labelLarge?.copyWith(
                  color: game.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<GameThemeId>(
                valueListenable: themeNotifier,
                builder: (context, current, _) => Column(
                  children: [
                    for (final id in GameThemeId.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ThemeTile(
                          id: id,
                          selected: id == current,
                          onTap: () => themeNotifier.value = id,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une option de thème : son nom et un aperçu de ses couleurs.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final GameThemeId id;
  final bool selected;
  final VoidCallback onTap;

  static const _names = {
    GameThemeId.casino: 'Casino',
    GameThemeId.neon: 'Néon',
    GameThemeId.minimal: 'Minimal',
  };

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    // Couleurs du thème représenté, pas du thème actuel.
    final preview = AppThemes.build(id).extension<GameColors>()!;

    return Material(
      color: game.panel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? game.selection : game.panelBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  gradient: preview.background,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(_names[id]!, style: context.text.titleMedium),
              ),
              for (final color in [preview.chips, preview.mult, preview.coins])
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 12),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? game.selection : game.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
