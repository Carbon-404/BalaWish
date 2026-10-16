import 'package:flutter/material.dart';
import 'package:balawish/screens/menu/menu.dart';
import 'package:balawish/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameThemeId>(
      valueListenable: themeNotifier,
      builder: (context, themeId, _) => MaterialApp(
        title: 'BalaWish',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.build(themeId),
        themeAnimationDuration: const Duration(milliseconds: 400),
        home: const Menu(),
      ),
    );
  }
}

