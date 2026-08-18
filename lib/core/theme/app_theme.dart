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

  // Tema Material 3
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HCColors.primary500,
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
          padding: HCSpacing.paddingButton,
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusMd,
          ),
          textStyle: HCTypography.button,
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
}
