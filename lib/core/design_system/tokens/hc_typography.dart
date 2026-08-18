import 'package:flutter/material.dart';
import 'hc_colors.dart';

/// Design Tokens: Tipografia Acolhedora, Legível e com Alto Contraste Clínico.
class HCTypography {
  // Display & Títulos Grandes
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: HCColors.neutral900,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: HCColors.neutral900,
    height: 1.25,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    color: HCColors.neutral900,
    height: 1.3,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HCColors.neutral800,
    height: 1.35,
  );

  // Corpo de Texto
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: HCColors.neutral700,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: HCColors.neutral600,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: HCColors.neutral500,
    height: 1.35,
  );

  // Labels & Badges
  static const TextStyle labelBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: HCColors.neutral700,
    letterSpacing: 0.2,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
  );

  // Métricas Clínicas (PFE, SpO2)
  static const TextStyle clinicalValueLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
    color: HCColors.neutral900,
  );

  static const TextStyle clinicalValueMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
    color: HCColors.neutral900,
  );
}
