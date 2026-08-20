import 'package:flutter/material.dart';
import 'hc_colors.dart';

/// Design Tokens: Tipografia Clínica, Acolhedora e com Máxima Legibilidade.
/// Escala: Display / Heading / Title / Body / Body Small / Label / Caption
class HCTypography {
  // 1. Display (Grandes títulos de destaque)
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: HCColors.neutral900,
    height: 1.2,
  );

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

  // 2. Heading (Títulos de tela e seções principais)
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: HCColors.neutral900,
    height: 1.3,
  );

  // 3. Title / SubHeading (Títulos de cards e subtítulos)
  static const TextStyle title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    color: HCColors.neutral900,
    height: 1.35,
  );

  static const TextStyle subHeading = title;

  // 4. Body (Texto corrido e parágrafos)
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    color: HCColors.neutral700,
    height: 1.45,
  );

  static const TextStyle bodyLarge = body;

  // 5. Body Small (Descrições secundárias e instruções)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    color: HCColors.neutral600,
    height: 1.4,
  );

  static const TextStyle bodyMedium = bodySmall;

  // 6. Label (Rótulos de campos, botões e tabs)
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: HCColors.neutral700,
    height: 1.3,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: HCColors.neutral700,
    letterSpacing: 0.2,
  );

  // 7. Caption / Badge (Metadados, notas de rodapé e tags)
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: HCColors.neutral500,
    height: 1.3,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
  );

  // 8. Métricas Clínicas (PFE, SpO2, Frequência Respiratória com números tabulares)
  static const TextStyle clinicalValueLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
    color: HCColors.neutral900,
  );

  static const TextStyle clinicalValueMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
    color: HCColors.neutral900,
  );
}
