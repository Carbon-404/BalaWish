import 'package:balawish/controllers/planet_controller.dart';
import 'package:balawish/controllers/purse_controller.dart';
import 'package:balawish/controllers/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:balawish/screens/menu/menu.dart';
import 'package:balawish/theme/theme.dart';

Future<void> main() async {
  // Nécessaire pour lire le stockage du téléphone avant runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    playerStats.load(),
    playerPurse.load(),
    playerPlanets.load(),
  ]);
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
