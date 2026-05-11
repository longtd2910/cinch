import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m3e_design/m3e_design.dart';

import 'package:cinch/theme/obsidian_tokens.dart';

Color _c(String hex) {
  final v = hex.replaceFirst('#', '');
  return Color(0xFF000000 | int.parse(v, radix: 16));
}

class AppTheme {
  AppTheme._();

  static ColorScheme get colorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: _c('#C8A97E'),
    onPrimary: _c('#1E1B18'),
    primaryContainer: _c('#EAD8B7'),
    onPrimaryContainer: _c('#1E1B18'),
    secondary: _c('#8E857C'),
    onSecondary: _c('#F7F4EF'),
    secondaryContainer: _c('#F3EEE7'),
    onSecondaryContainer: _c('#1E1B18'),
    tertiary: _c('#5E9F7A'),
    onTertiary: _c('#F7F4EF'),
    tertiaryContainer: _c('#D8E9DE'),
    onTertiaryContainer: _c('#1E1B18'),
    error: _c('#B36B5E'),
    onError: _c('#F7F4EF'),
    errorContainer: _c('#EAD8B7'),
    onErrorContainer: _c('#1E1B18'),
    surface: _c('#F7F4EF'),
    onSurface: _c('#1E1B18'),
    onSurfaceVariant: _c('#8E857C'),
    outline: _c('#E4DDD4'),
    outlineVariant: _c('#E4DDD4'),
    shadow: const Color(0x0F2D2014),
    scrim: const Color(0x662D2014),
    inverseSurface: _c('#1E1B18'),
    onInverseSurface: _c('#F7F4EF'),
    inversePrimary: _c('#EAD8B7'),
    surfaceTint: _c('#C8A97E'),
    surfaceDim: _c('#ECE5DB'),
    surfaceBright: _c('#F7F4EF'),
    surfaceContainerLowest: _c('#FFFFFF'),
    surfaceContainerLow: _c('#F3EEE7'),
    surfaceContainer: _c('#ECE5DB'),
    surfaceContainerHigh: _c('#E4DDD4'),
    surfaceContainerHighest: _c('#D8D0C6'),
    primaryFixed: _c('#EAD8B7'),
    primaryFixedDim: _c('#C8A97E'),
    onPrimaryFixed: _c('#1E1B18'),
    onPrimaryFixedVariant: _c('#8E857C'),
    secondaryFixed: _c('#F3EEE7'),
    secondaryFixedDim: _c('#ECE5DB'),
    onSecondaryFixed: _c('#1E1B18'),
    onSecondaryFixedVariant: _c('#8E857C'),
    tertiaryFixed: _c('#D8E9DE'),
    tertiaryFixedDim: _c('#5E9F7A'),
    onTertiaryFixed: _c('#1E1B18'),
    onTertiaryFixedVariant: _c('#3F7358'),
  );

  static TextTheme textTheme(ColorScheme cs) {
    final displayLetter = -0.04 * 48;
    final headlineLgLetter = -0.02 * 32;
    final labelMdLetter = 0.05 * 14;
    final base = GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: Brightness.light, useMaterial3: true).textTheme,
    ).apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);
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
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
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
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(cs.primary)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        extendedTextStyle: tt.labelLarge,
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1),
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
      extensions: const [ObsidianSpacing.obsidian, ObsidianRadii.obsidian],
    );
    return withM3ETheme(base);
  }
}
