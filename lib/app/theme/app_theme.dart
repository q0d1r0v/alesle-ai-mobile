import 'package:flutter/material.dart';

/// Design tokens from the Alesle design system v3 ("Calm. Clear. Glass.",
/// alesle-ai-pages/Alesle AI — Mobile MVP.html).
abstract final class AlesleColors {
  static const Color ink = Color(0xFF15151D);
  static const Color canvas = Color(0xFFF4F4F8);
  static const Color text2 = Color(0xFF5A5B6B);
  static const Color capsuleGrey = Color(0xFFEEEEF2);
  static const Color hairline = Color(0xFFE2E2E8);
  static const Color violet = Color(0xFF6B4ED0);
  static const Color violetLight = Color(0xFFA089F0);
  static const Color violetGlow = Color(0xFF8568DB);
  static const Color doneTop = Color(0xFF4ED184);
  static const Color doneBottom = Color(0xFF1E8F4E);
  static const Color notDoneTop = Color(0xFFFFB25C);
  static const Color notDoneBottom = Color(0xFFD9730F);
  static const Color danger = Color(0xFFC62828);

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[violetLight, violet],
  );
  static const LinearGradient doneGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[doneTop, doneBottom],
  );
  static const LinearGradient notDoneGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[notDoneTop, notDoneBottom],
  );
}

/// Radii of the design system: cards 26, sheets 34, capsules fully round.
abstract final class AlesleRadii {
  static const double card = 26;
  static const double sheet = 34;
  static const double capsule = 999;
}

/// Soft shadows of the design system's cards.
abstract final class AlesleShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Color(0x0A15151D), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F15151D), blurRadius: 32, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> capsule = <BoxShadow>[
    BoxShadow(color: Color(0x2E15151D), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

ThemeData buildTheme() {
  const ColorScheme scheme = ColorScheme.light(
    primary: AlesleColors.ink,
    onPrimary: Colors.white,
    secondary: AlesleColors.violet,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: AlesleColors.ink,
    onSurfaceVariant: AlesleColors.text2,
    surfaceContainerHighest: AlesleColors.capsuleGrey,
    outlineVariant: AlesleColors.hairline,
    error: AlesleColors.danger,
  );
  // Type scale: large title 34/41 bold −3 %, body 17, captions 15.
  const TextTheme text = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      height: 41 / 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    headlineSmall: TextStyle(
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      height: 22 / 17,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 17, height: 24 / 17),
    bodyMedium: TextStyle(fontSize: 15, height: 21 / 15),
    bodySmall: TextStyle(fontSize: 13, height: 18 / 13),
    labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Geist',
    textTheme: text.apply(
      bodyColor: AlesleColors.ink,
      displayColor: AlesleColors.ink,
    ),
    scaffoldBackgroundColor: AlesleColors.canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AlesleColors.ink,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlesleRadii.card),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AlesleColors.canvas,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
