import 'package:balawish/theme/theme.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key, this.icon, required this.onPressed, this.label, this.tooltip});

  final Icon? icon;
  final VoidCallback? onPressed;
  final Widget? label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final game = context.game;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (game.glow > 0)
            BoxShadow(color: game.chips.withValues(alpha: 0.55), blurRadius: game.glow),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        label: label?? const Text(""),
        icon: icon,
      ),
    );
  }
}