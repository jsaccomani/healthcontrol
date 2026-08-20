import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Card de Métrica Clínica (Pico de Fluxo, SpO2, Frequência Respiratória).
class HCMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color? statusColor;
  final String? comparisonText;
  final VoidCallback? onTap;

  const HCMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.statusColor,
    this.comparisonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final color = statusColor ?? theme.primary;

    Widget card = Container(
      padding: HCSpacing.paddingCardCompact,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
        boxShadow: theme.isDark ? null : HCShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: HCTypography.label.copyWith(color: theme.textSecondary),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: HCSpacing.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: HCTypography.clinicalValueLarge.copyWith(color: color),
              ),
              const SizedBox(width: HCSpacing.space4),
              Text(
                unit,
                style: HCTypography.label.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
          if (comparisonText != null) ...[
            const SizedBox(height: HCSpacing.space4),
            Text(
              comparisonText!,
              style: HCTypography.caption.copyWith(color: theme.textMuted),
            ),
          ],
        ],
      ),
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

/// Métrica Horizontal Compacta (Para exibição em linha ou cabeçalhos).
class HCMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;
  final IconData? icon;

  const HCMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final color = valueColor ?? theme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: HCSpacing.space4),
          ],
          Text(
            '$label: ',
            style: HCTypography.caption.copyWith(color: theme.textTertiary),
          ),
          Text(
            value,
            style: HCTypography.label.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          if (unit != null) ...[
            const SizedBox(width: 2),
            Text(
              unit!,
              style: HCTypography.caption.copyWith(color: theme.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
