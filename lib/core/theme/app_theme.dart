import 'package:flutter/material.dart';
import '../design_system/tokens/hc_colors.dart';
import '../design_system/tokens/hc_spacing.dart';
import '../design_system/tokens/hc_typography.dart';

/// Tema visual moderno, acessível e clínico do Health Control (Material 3).
class AppTheme {
  // Cores de compatibilidade retroativa
  static const Color primaryTeal = HCColors.primary500;
  static const Color primaryDark = HCColors.primary700;
  static const Color primaryLight = HCColors.primary100;
  static const Color backgroundLight = HCColors.neutral50;
  static const Color surfaceWhite = HCColors.surfaceWhite;

  // Cores Oficiais das Zonas GINA / PCDT
  static const Color zoneGreen = HCColors.greenMain;
  static const Color zoneGreenBg = HCColors.greenLight;
  static const Color zoneYellow = HCColors.yellowMain;
  static const Color zoneYellowBg = HCColors.yellowLight;
  static const Color zoneRed = HCColors.redMain;
  static const Color zoneRedBg = HCColors.redLight;

  // Tema Claro (Calm Healthcare)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HCColors.primary500,
        brightness: Brightness.light,
        primary: HCColors.primary500,
        secondary: HCColors.primary700,
        surface: HCColors.neutral50,
      ),
      scaffoldBackgroundColor: HCColors.neutral50,
      appBarTheme: const AppBarTheme(
        backgroundColor: HCColors.surfaceWhite,
        foregroundColor: HCColors.neutral900,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: HCColors.neutral800),
        titleTextStyle: HCTypography.heading,
      ),
      cardTheme: CardThemeData(
        color: HCColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: const BorderSide(color: HCColors.neutral200, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HCColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: HCSpacing.paddingButton,
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusMd,
          ),
          textStyle: HCTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HCColors.primary700,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: HCColors.primary200),
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HCColors.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.primary500, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Tema Escuro (Nocturnal Healthcare - Conforto em emergências de madrugada)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HCColors.primary400,
        brightness: Brightness.dark,
        primary: HCColors.primary400,
        secondary: HCColors.primary300,
        surface: HCColors.darkSurface,
      ),
      scaffoldBackgroundColor: HCColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: HCColors.darkSurface,
        foregroundColor: HCColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: HCColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: HCColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: HCColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: const BorderSide(color: HCColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HCColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: HCSpacing.paddingButton,
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusMd,
          ),
          textStyle: HCTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HCColors.primary300,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: HCColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusMd,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HCColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HCRadii.radiusMd,
          borderSide: const BorderSide(color: HCColors.primary400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
