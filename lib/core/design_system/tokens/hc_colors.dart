import 'package:flutter/material.dart';

/// Design Tokens: Cores Clínicas, Neutras e Semânticas do Health Control.
class HCColors {
  // ---------------------------------------------------------------------------
  // 1. Marca & Primárias (Teal Respiratório Clínico)
  // ---------------------------------------------------------------------------
  static const Color primary50 = Color(0xFFF0FDFA);
  static const Color primary100 = Color(0xFFCCFBF1);
  static const Color primary200 = Color(0xFF99F6E4);
  static const Color primary300 = Color(0xFF5EEAD4);
  static const Color primary400 = Color(0xFF2DD4BF);
  static const Color primary500 = Color(0xFF0D9488); // Principal
  static const Color primary600 = Color(0xFF0F766E);
  static const Color primary700 = Color(0xFF115E59);
  static const Color primary800 = Color(0xFF134E4A);
  static const Color primary900 = Color(0xFF042F2E);

  // ---------------------------------------------------------------------------
  // 2. Neutros (Slate / Escala de Cinzas com Alto Contraste)
  // ---------------------------------------------------------------------------
  static const Color neutral50 = Color(0xFFF8FAFC);  // Background padrão
  static const Color neutral100 = Color(0xFFF1F5F9); // Containers leves / chips
  static const Color neutral200 = Color(0xFFE2E8F0); // Bordas e divisores
  static const Color neutral300 = Color(0xFFCBD5E1); // Bordas de inputs inativos
  static const Color neutral400 = Color(0xFF94A3B8); // Ícones e textos terciários
  static const Color neutral500 = Color(0xFF64748B); // Textos secundários
  static const Color neutral600 = Color(0xFF475569); // Textos informativos
  static const Color neutral700 = Color(0xFF334155); // Subtítulos
  static const Color neutral800 = Color(0xFF1E293B); // Títulos secundários
  static const Color neutral900 = Color(0xFF0F172A); // Títulos principais (Preto ardósia)

  // ---------------------------------------------------------------------------
  // 3. Semântica Clínica Oficial (GINA / PCDT / AMIB / SUS)
  // ---------------------------------------------------------------------------
  
  // Zona Verde: Asma Controlada / Seguro (>= 80% PFE ou SpO2 >= 95%)
  static const Color greenMain = Color(0xFF059669);
  static const Color greenLight = Color(0xFFF0FDF4);
  static const Color greenBorder = Color(0xFFBBF7D0);
  static const Color greenText = Color(0xFF166534);

  // Zona Amarela: Início de Crise / Alerta / LME a vencer (50% a 79% PFE ou SpO2 92-94%)
  static const Color yellowMain = Color(0xFFD97706);
  static const Color yellowLight = Color(0xFFFEFCE8);
  static const Color yellowBorder = Color(0xFFFEF08A);
  static const Color yellowText = Color(0xFF854D0E);

  // Zona Vermelha: Emergência / Crise Severa / Exame Vencido (< 50% PFE ou SpO2 < 92%)
  static const Color redMain = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);
  static const Color redText = Color(0xFF991B1B);

  // Azul: Informativo / Medicações Contínuas
  static const Color blueMain = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFBFDBFE);
  static const Color blueText = Color(0xFF1E40AF);

  // Roxo: Fisioterapia Respiratória / CPAP / Reabilitação
  static const Color purpleMain = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFFAF5FF);
  static const Color purpleBorder = Color(0xFFE9D5FF);
  static const Color purpleText = Color(0xFF6B21A8);

  // ---------------------------------------------------------------------------
  // 4. Superfícies & Temas (Light & Dark)
  // ---------------------------------------------------------------------------
  static const Color surfaceWhite = Colors.white;
  static const Color background = neutral50;
  static const Color overlayDark = Color(0x660F172A);

  // Superfícies do Modo Escuro (Nocturnal Healthcare)
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkBg = darkBackground;
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF23304B);
  static const Color darkBorderSubtle = Color(0xFF1B2438);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkText = darkTextPrimary;
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
}

/// Helper semântico que resolve cores de tema automaticamente a partir do contexto.
class HCSemanticTheme {
  final bool isDark;

  const HCSemanticTheme(this.isDark);

  Color get background => isDark ? HCColors.darkBackground : HCColors.neutral50;
  Color get surface => isDark ? HCColors.darkSurface : Colors.white;
  Color get elevatedSurface => isDark ? HCColors.darkSurfaceElevated : HCColors.neutral100;
  Color get border => isDark ? HCColors.darkBorder : HCColors.neutral200;
  Color get borderSubtle => isDark ? HCColors.darkBorderSubtle : HCColors.neutral100;
  
  Color get textPrimary => isDark ? HCColors.darkTextPrimary : HCColors.neutral900;
  Color get textSecondary => isDark ? HCColors.darkTextSecondary : HCColors.neutral700;
  Color get textTertiary => isDark ? HCColors.darkTextMuted : HCColors.neutral500;
  Color get textMuted => isDark ? HCColors.darkTextMuted : HCColors.neutral400;

  Color get primary => isDark ? HCColors.primary400 : HCColors.primary500;
  Color get primarySubtle => isDark ? HCColors.primary900.withAlpha(90) : HCColors.primary50;
  Color get primaryBorder => isDark ? HCColors.primary700 : HCColors.primary200;

  // Semânticos de Alerta
  Color get success => HCColors.greenMain;
  Color get successBg => isDark ? const Color(0xFF06281E) : HCColors.greenLight;
  Color get successBorder => isDark ? const Color(0xFF0F5132) : HCColors.greenBorder;
  Color get successText => isDark ? HCColors.greenBorder : HCColors.greenText;

  Color get warning => HCColors.yellowMain;
  Color get warningBg => isDark ? const Color(0xFF2E1A03) : HCColors.yellowLight;
  Color get warningBorder => isDark ? const Color(0xFF78350F) : HCColors.yellowBorder;
  Color get warningText => isDark ? const Color(0xFFFCD34D) : HCColors.yellowText;

  Color get critical => HCColors.redMain;
  Color get criticalBg => isDark ? const Color(0xFF2C0B0B) : HCColors.redLight;
  Color get criticalBorder => isDark ? const Color(0xFF7F1D1D) : HCColors.redBorder;
  Color get criticalText => isDark ? const Color(0xFFFCA5A5) : HCColors.redText;

  Color get info => HCColors.blueMain;
  Color get infoBg => isDark ? const Color(0xFF172554) : HCColors.blueLight;
  Color get infoBorder => isDark ? const Color(0xFF1E40AF) : HCColors.blueBorder;
  Color get infoText => isDark ? HCColors.blueBorder : HCColors.blueText;
}

extension HCSemanticThemeExtension on BuildContext {
  HCSemanticTheme get hcTheme {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return HCSemanticTheme(isDark);
  }
}
