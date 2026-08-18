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
  // 4. Superfícies
  // ---------------------------------------------------------------------------
  static const Color surfaceWhite = Colors.white;
  static const Color background = neutral50;
  static const Color overlayDark = Color(0x660F172A);
}
