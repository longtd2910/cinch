import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinch/theme/obsidian_tokens.dart';

Color _c(String hex) {
  final v = hex.replaceFirst('#', '');
  return Color(0xFF000000 | int.parse(v, radix: 16));
}

class AppTheme {
  AppTheme._();

  static ColorScheme get colorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: _c('#ffffff'),
        onPrimary: _c('#283500'),
        primaryContainer: _c('#c3f400'),
        onPrimaryContainer: _c('#556d00'),
        secondary: _c('#c8c6c5'),
        onSecondary: _c('#313030'),
        secondaryContainer: _c('#474746'),
        onSecondaryContainer: _c('#b7b5b4'),
        tertiary: _c('#ffffff'),
        onTertiary: _c('#303032'),
        tertiaryContainer: _c('#e4e2e4'),
        onTertiaryContainer: _c('#656466'),
        error: _c('#ffb4ab'),
        onError: _c('#690005'),
        errorContainer: _c('#93000a'),
        onErrorContainer: _c('#ffdad6'),
        surface: _c('#131313'),
        onSurface: _c('#e2e2e2'),
        onSurfaceVariant: _c('#c4c9ac'),
        outline: _c('#8e9379'),
        outlineVariant: _c('#444933'),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: _c('#e2e2e2'),
        onInverseSurface: _c('#303030'),
        inversePrimary: _c('#506600'),
        surfaceTint: _c('#abd600'),
        surfaceDim: _c('#131313'),
        surfaceBright: _c('#393939'),
        surfaceContainerLowest: _c('#0e0e0e'),
        surfaceContainerLow: _c('#1b1b1b'),
        surfaceContainer: _c('#1f1f1f'),
        surfaceContainerHigh: _c('#2a2a2a'),
        surfaceContainerHighest: _c('#353535'),
        primaryFixed: _c('#c3f400'),
        primaryFixedDim: _c('#abd600'),
        onPrimaryFixed: _c('#161e00'),
        onPrimaryFixedVariant: _c('#3c4d00'),
        secondaryFixed: _c('#e5e2e1'),
        secondaryFixedDim: _c('#c8c6c5'),
        onSecondaryFixed: _c('#1c1b1b'),
        onSecondaryFixedVariant: _c('#474746'),
        tertiaryFixed: _c('#e4e2e4'),
        tertiaryFixedDim: _c('#c8c6c8'),
        onTertiaryFixed: _c('#1b1b1d'),
        onTertiaryFixedVariant: _c('#474649'),
      );

  static TextTheme textTheme(ColorScheme cs) {
    final displayLetter = -0.04 * 48;
    final headlineLgLetter = -0.02 * 32;
    final labelMdLetter = 0.05 * 14;
    final base = GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: Brightness.dark, useMaterial3: true).textTheme,
    ).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );
    return base.copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: displayLetter,
        color: cs.onSurface,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: headlineLgLetter,
        color: cs.onSurface,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: cs.onSurface,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: cs.onSurface,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: cs.onSurface,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: labelMdLetter,
        color: cs.onSurface,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: cs.onSurface,
      ),
    );
  }

  static ThemeData get obsidian {
    final cs = colorScheme;
    final tt = textTheme(cs);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: _c('#131313'),
      canvasColor: _c('#131313'),
      textTheme: tt,
      primaryTextTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianRadii.obsidian.md),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        extendedTextStyle: tt.labelLarge,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ObsidianRadii.obsidian.normal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ObsidianRadii.obsidian.normal),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ObsidianRadii.obsidian.normal),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
      extensions: const [
        ObsidianSpacing.obsidian,
        ObsidianRadii.obsidian,
      ],
    );
  }
}
