import 'package:flutter/material.dart';
import 'package:balawish/theme/theme.dart';

class Background extends StatelessWidget {
  const Background({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.game.background),
      child: child,
    );
  }
}