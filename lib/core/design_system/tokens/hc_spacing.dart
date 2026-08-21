import 'package:flutter/material.dart';

/// Design Tokens: Grade de Espaçamentos Padronizada do Health Control.
/// Escala consistente: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40
class HCSpacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // Aliases de compatibilidade
  static const double xxs = space4;
  static const double xs = space4;
  static const double sm = space8;
  static const double md = space12;
  static const double lg = space16;
  static const double xl = space20;
  static const double xxl = space24;
  static const double xxxl = space32;

  // Insets comuns
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: space16, vertical: space12);
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);
  static const EdgeInsets paddingCardCompact = EdgeInsets.all(space12);
  static const EdgeInsets paddingCompact = EdgeInsets.all(space8);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: space20, vertical: space12);
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(horizontal: space8, vertical: space4);
}

/// Design Tokens: Raios de Borda Padronizados (Border Radius).
/// Escala consistente: 8 / 12 / 16 / 20 / 24 / pill
class HCRadii {
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double pill = 999.0;

  // Aliases
  static const double xs = 4.0;
  static const double sm = r8;
  static const double md = r12;
  static const double lg = r16;
  static const double xl = r20;
  static const double xxl = r24;

  static BorderRadius get radiusSm => BorderRadius.circular(r8);
  static BorderRadius get radiusMd => BorderRadius.circular(r12);
  static BorderRadius get radiusLg => BorderRadius.circular(r16);
  static BorderRadius get radiusXl => BorderRadius.circular(r20);
  static BorderRadius get radiusXxl => BorderRadius.circular(r24);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);
}

/// Design Tokens: Sombras Sutis, Limpas e Acessíveis.
class HCShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
