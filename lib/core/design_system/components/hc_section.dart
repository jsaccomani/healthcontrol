import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Cabeçalho de Seção Padronizado (Título, Ícone, Contador e Ação Opcional).
class HCSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? counterText;
  final Widget? trailingAction;

  const HCSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.counterText,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HCSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: HCColors.primary600),
                const SizedBox(width: HCSpacing.xs),
              ],
              Text(title, style: HCTypography.subHeading),
              if (counterText != null) ...[
                const SizedBox(width: HCSpacing.sm),
                Container(
                  padding: HCSpacing.paddingBadge,
                  decoration: BoxDecoration(
                    color: HCColors.neutral100,
                    borderRadius: HCRadii.radiusMd,
                  ),
                  child: Text(
                    counterText!,
                    style: HCTypography.badge.copyWith(color: HCColors.neutral600),
                  ),
                ),
              ],
            ],
          ),
          if (trailingAction != null) trailingAction!,
        ],
      ),
    );
  }
}
