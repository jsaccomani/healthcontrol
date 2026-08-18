import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Badge / Tag Semântico com Alto Contraste (Ícone + Texto + Cor).
class HCStatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const HCStatusBadge({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HCSpacing.paddingBadge,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: HCRadii.radiusSm,
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: HCSpacing.xs),
          ],
          Text(
            label,
            style: HCTypography.badge.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Badge Específico para as Zonas de Ação GINA / PCDT (Verde, Amarela, Vermelha).
class HCActionZoneBadge extends StatelessWidget {
  final ActionZoneType zone;

  const HCActionZoneBadge({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    final (bg, text, border, label, icon) = switch (zone) {
      ActionZoneType.green => (
          HCColors.greenLight,
          HCColors.greenText,
          HCColors.greenBorder,
          'Zona Verde (Normal)',
          Icons.check_circle_outline,
        ),
      ActionZoneType.yellow => (
          HCColors.yellowLight,
          HCColors.yellowText,
          HCColors.yellowBorder,
          'Zona Amarela (Alerta)',
          Icons.warning_amber_rounded,
        ),
      ActionZoneType.red => (
          HCColors.redLight,
          HCColors.redText,
          HCColors.redBorder,
          'Zona Vermelha (Perigo)',
          Icons.emergency_outlined,
        ),
    };

    return HCStatusBadge(
      label: label,
      icon: icon,
      backgroundColor: bg,
      textColor: text,
      borderColor: border,
    );
  }
}
