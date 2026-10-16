import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GameThemeId { casino, neon, minimal }

final themeNotifier = ValueNotifier<GameThemeId>(GameThemeId.casino);

@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.background,
    required this.panel,
    required this.panelBorder,
    required this.chips,
    required this.mult,
    required this.coins,
    required this.onAccent,
    required this.cardFace,
    required this.cardRed,
    required this.cardBlack,
    required this.selection,
    required this.textMuted,
    required this.rarity,
    required this.glow,
    required this.filledStyle,
  });

  /// Fond de l'écran (tapis, nuit, anthracite).
  final RadialGradient background;

  /// Fond et bordure des panneaux (tableau de bord, récompenses…).
  final Color panel;
  final Color panelBorder;

  /// Couleurs sémantiques du décompte : toujours les mêmes rôles.
  final Color chips; // jetons
  final Color mult; // multi
  final Color coins; // pièces

  /// Couleur du texte posé sur un bouton ou une case pleine.
  final Color onAccent;

  /// Cartes à jouer.
  final Color cardFace;
  final Color cardRed;
  final Color cardBlack;
  final Color selection; // contour des cartes sélectionnées

  final Color textMuted;

  /// Couleurs de cadre des jokers : commun, peu commun, rare, légendaire.
  final List<Color> rarity;

  /// Rayon du halo lumineux (0 = pas de halo, > 0 = style néon).
  final double glow;

  /// true : boutons et cases pleins. false : contours lumineux (néon).
  final bool filledStyle;

  @override
  GameColors copyWith({
    RadialGradient? background,
    Color? panel,
    Color? panelBorder,
    Color? chips,
    Color? mult,
    Color? coins,
    Color? onAccent,
    Color? cardFace,
    Color? cardRed,
    Color? cardBlack,
    Color? selection,
    Color? textMuted,
    List<Color>? rarity,
    double? glow,
    bool? filledStyle,
  }) {
    return GameColors(
      background: background ?? this.background,
      panel: panel ?? this.panel,
      panelBorder: panelBorder ?? this.panelBorder,
      chips: chips ?? this.chips,
      mult: mult ?? this.mult,
      coins: coins ?? this.coins,
      onAccent: onAccent ?? this.onAccent,
      cardFace: cardFace ?? this.cardFace,
      cardRed: cardRed ?? this.cardRed,
      cardBlack: cardBlack ?? this.cardBlack,
      selection: selection ?? this.selection,
      textMuted: textMuted ?? this.textMuted,
      rarity: rarity ?? this.rarity,
      glow: glow ?? this.glow,
      filledStyle: filledStyle ?? this.filledStyle,
    );
  }

  /// Interpolation entre deux thèmes : c'est ce qui permet à MaterialApp
  /// d'animer en douceur le changement de thème.
  @override
  GameColors lerp(ThemeExtension<GameColors>? other, double t) {
    if (other is! GameColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GameColors(
      background: RadialGradient.lerp(background, other.background, t)!,
      panel: c(panel, other.panel),
      panelBorder: c(panelBorder, other.panelBorder),
      chips: c(chips, other.chips),
      mult: c(mult, other.mult),
      coins: c(coins, other.coins),
      onAccent: c(onAccent, other.onAccent),
      cardFace: c(cardFace, other.cardFace),
      cardRed: c(cardRed, other.cardRed),
      cardBlack: c(cardBlack, other.cardBlack),
      selection: c(selection, other.selection),
      textMuted: c(textMuted, other.textMuted),
      rarity: List.generate(
        rarity.length,
        (i) => c(rarity[i], other.rarity[i]),
      ),
      glow: lerpDouble(glow, other.glow, t)!,
      filledStyle: t < 0.5 ? filledStyle : other.filledStyle,
    );
  }
}

/// Raccourci : `context.game.chips` au lieu de
/// `Theme.of(context).extension<GameColors>()!.chips`.
extension GameThemeContext on BuildContext {
  GameColors get game => Theme.of(this).extension<GameColors>()!;

  TextTheme get text => Theme.of(this).textTheme;
}

/// Fabrique les trois ThemeData du jeu.
class AppThemes {
  AppThemes._();

  static ThemeData build(GameThemeId id) {
    switch (id) {
      case GameThemeId.casino:
        return _make(
          bodyFont: 'Space Grotesk',
          displayFont: 'Abril Fatface',
          scheme: const ColorScheme.dark(
            primary: Color(0xFF2E6FD6),
            secondary: Color(0xFFF2C94C),
            surface: Color(0xFF124A30),
            onSurface: Color(0xFFF4EFE2),
          ),
          game: const GameColors(
            background: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.1,
              colors: [Color(0xFF1F6B45), Color(0xFF124A30), Color(0xFF0A2C1C)],
            ),
            panel: Color(0x52000000),
            panelBorder: Color(0x59F2C94C),
            chips: Color(0xFF2E6FD6),
            mult: Color(0xFFC23B30),
            coins: Color(0xFFF2C94C),
            onAccent: Colors.white,
            cardFace: Color(0xFFFBF8F0),
            cardRed: Color(0xFFC23B30),
            cardBlack: Color(0xFF1A1A1A),
            selection: Color(0xFFF2C94C),
            textMuted: Color(0xFFCFC6AD),
            rarity: [
              Color(0xFF9AA3AD),
              Color(0xFF4C8DFF),
              Color(0xFFA66CFF),
              Color(0xFFF2C94C),
            ],
            glow: 0,
            filledStyle: true,
          ),
        );

      case GameThemeId.neon:
        return _make(
          bodyFont: 'Chakra Petch',
          displayFont: 'Orbitron',
          scheme: const ColorScheme.dark(
            primary: Color(0xFF33E1FF),
            secondary: Color(0xFFFF3D8B),
            surface: Color(0xFF17142E),
            onSurface: Color(0xFFE9E6FF),
          ),
          game: const GameColors(
            background: RadialGradient(
              radius: 1.1,
              colors: [Color(0xFF0E0B1F), Color(0xFF0E0B1F), Color(0xFF0E0B1F)],
            ),
            panel: Color(0xFF17142E),
            panelBorder: Color(0xFF3A3366),
            chips: Color(0xFF33E1FF),
            mult: Color(0xFFFF3D8B),
            coins: Color(0xFFFFE14D),
            onAccent: Color(0xFF0E0B1F),
            cardFace: Color(0xFF17142E),
            cardRed: Color(0xFFFF3D8B),
            cardBlack: Color(0xFF33E1FF),
            selection: Colors.white,
            textMuted: Color(0xFFA79CFF),
            rarity: [
              Color(0xFF9AA3AD),
              Color(0xFF33E1FF),
              Color(0xFFB86BFF),
              Color(0xFFFFE14D),
            ],
            glow: 14,
            filledStyle: false,
          ),
        );

      case GameThemeId.minimal:
        return _make(
          bodyFont: 'DM Sans',
          displayFont: 'DM Mono',
          scheme: const ColorScheme.dark(
            primary: Color(0xFFECECEC),
            secondary: Color(0xFFE8A33D),
            surface: Color(0xFF2B2D31),
            onSurface: Color(0xFFECECEC),
          ),
          game: const GameColors(
            background: RadialGradient(
              radius: 1.1,
              colors: [Color(0xFF1E1F22), Color(0xFF1E1F22), Color(0xFF1E1F22)],
            ),
            panel: Color(0xFF2B2D31),
            panelBorder: Color(0xFF34363B),
            chips: Color(0xFF6AA8FF),
            mult: Color(0xFFFF8173),
            coins: Color(0xFFE8A33D),
            onAccent: Color(0xFF1E1F22),
            cardFace: Color(0xFFFAFAFA),
            cardRed: Color(0xFFC8372D),
            cardBlack: Color(0xFF1E1F22),
            selection: Color(0xFFE8A33D),
            textMuted: Color(0xFF9A9CA3),
            rarity: [
              Color(0xFF9A9CA3),
              Color(0xFF6AA8FF),
              Color(0xFFB08CFF),
              Color(0xFFE8A33D),
            ],
            glow: 0,
            filledStyle: true,
          ),
        );
    }
  }

  /// Assemble un ThemeData à partir d'une palette et de deux polices :
  /// une pour le texte courant, une pour les gros chiffres et titres.
  static ThemeData _make({
    required ColorScheme scheme,
    required GameColors game,
    required String bodyFont,
    required String displayFont,
  }) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final body = GoogleFonts.getTextTheme(
      bodyFont,
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final display = GoogleFonts.getFont(displayFont);

    return base.copyWith(
      // Le fond est dessiné par GameBackground (dégradé), pas par le Scaffold.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: body.copyWith(
        displayMedium: body.displayMedium?.merge(display), // score principal
        headlineMedium: body.headlineMedium?.merge(display), // jetons / multi
        headlineSmall: body.headlineSmall?.merge(display), // nom de la main
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: game.filledStyle
            ? game.chips
            : game.chips.withValues(alpha: 0.12),
        foregroundColor: game.filledStyle ? game.onAccent : game.chips,
        elevation: game.filledStyle ? 4 : 0,
        highlightElevation: game.filledStyle ? 8 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: game.filledStyle
              ? BorderSide.none
              : BorderSide(color: game.chips, width: 2),
        ),
      ),
      extensions: [game],
    );
  }
}
