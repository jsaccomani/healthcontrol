import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Card Padrão do Health Control (Borda sutil, superfície adaptativa e raio consistente).
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
    final theme = context.hcTheme;

    Widget card = Container(
      width: width,
      padding: padding ?? HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.surface,
        borderRadius: HCRadii.radiusXl,
        border: Border.all(color: borderColor ?? theme.border, width: 1.0),
        boxShadow: theme.isDark ? null : HCShadows.elevated,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: HCRadii.radiusXl,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Card Informativo (Destaque sutil para orientações clínicas e lembretes).
class HCInfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? accentColor;
  final Widget? trailing;

  const HCInfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.accentColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final color = accentColor ?? theme.info;

    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCardCompact,
      decoration: BoxDecoration(
        color: theme.infoBg,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(color: theme.infoBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: HCSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HCTypography.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.infoText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: HCTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Card de Alerta Clínico (Avisos de Risco, Alergias ou Situações de Atenção).
class HCAlertCard extends StatelessWidget {
  final String title;
  final String message;
  final bool isCritical;
  final Widget? action;

  const HCAlertCard({
    super.key,
    required this.title,
    required this.message,
    this.isCritical = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final bg = isCritical ? theme.criticalBg : theme.warningBg;
    final border = isCritical ? theme.criticalBorder : theme.warningBorder;
    final text = isCritical ? theme.criticalText : theme.warningText;
    final icon = isCritical ? Icons.emergency : Icons.warning_amber_rounded;

    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: HCRadii.radiusXl,
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: text, size: 20),
              const SizedBox(width: HCSpacing.space8),
              Expanded(
                child: Text(
                  title,
                  style: HCTypography.title.copyWith(color: text, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: HCSpacing.space12),
            action!,
          ],
        ],
      ),
    );
  }
}
