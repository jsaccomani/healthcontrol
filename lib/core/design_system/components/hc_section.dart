import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Cabeçalho de Seção Padronizado (Título, Ícone, Subtítulo, Contador e Ação Opcional).
class HCSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? counterText;
  final Widget? trailingAction;

  const HCSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.counterText,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HCSpacing.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: theme.primary),
                      const SizedBox(width: HCSpacing.space8),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: HCTypography.title.copyWith(color: theme.textPrimary),
                      ),
                    ),
                    if (counterText != null) ...[
                      const SizedBox(width: HCSpacing.space8),
                      Container(
                        padding: HCSpacing.paddingBadge,
                        decoration: BoxDecoration(
                          color: theme.elevatedSurface,
                          borderRadius: HCRadii.radiusMd,
                          border: Border.all(color: theme.border),
                        ),
                        child: Text(
                          counterText!,
                          style: HCTypography.badge.copyWith(color: theme.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (trailingAction != null) trailingAction!,
        ],
      ),
    );
  }
}

/// Seção Padronizada (Agrupamento com Header e Conteúdo).
class HCSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HCSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: HCSpacing.space20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HCSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            trailingAction: trailing,
          ),
          const SizedBox(height: HCSpacing.space8),
          child,
        ],
      ),
    );
  }
}
