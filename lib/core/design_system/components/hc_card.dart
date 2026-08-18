import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';

/// Card Padrão do Health Control (Borda sutil, fundo branco e raio consistente).
class HCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? width;

  const HCCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      padding: padding ?? HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: backgroundColor ?? HCColors.surfaceWhite,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: borderColor ?? HCColors.neutral200, width: 1.0),
        boxShadow: HCShadows.subtle,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: HCRadii.radiusLg,
        child: card,
      );
    }

    return card;
  }
}
