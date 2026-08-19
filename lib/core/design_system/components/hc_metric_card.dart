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
  final Color statusColor;
  final String? comparisonText;

  const HCMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.statusColor = HCColors.primary500,
    this.comparisonText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
        ),
        boxShadow: isDark ? null : HCShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: HCTypography.bodySmall.copyWith(
                  color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
                ),
              ),
              Icon(icon, color: statusColor, size: 18),
            ],
          ),
          const SizedBox(height: HCSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: HCTypography.clinicalValueLarge.copyWith(color: statusColor),
              ),
              const SizedBox(width: HCSpacing.xs),
              Text(
                unit,
                style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (comparisonText != null) ...[
            const SizedBox(height: HCSpacing.xs),
            Text(
              comparisonText!,
              style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
            ),
          ],
        ],
      ),
    );
  }
}
