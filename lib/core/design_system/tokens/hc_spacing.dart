import 'package:flutter/material.dart';

/// Design Tokens: Grade de Espaçamentos, Paddings e Gaps.
class HCSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Insets comuns
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets paddingCard = EdgeInsets.all(14.0);
  static const EdgeInsets paddingCompact = EdgeInsets.all(8.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0);
}

/// Design Tokens: Raios de Borda (Border Radius).
class HCRadii {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 999.0;

  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);
}

/// Design Tokens: Sombras Sutis e Acessíveis.
class HCShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x05000000),
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

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
