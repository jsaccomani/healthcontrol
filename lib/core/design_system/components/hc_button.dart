import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Botão Primário Padrão do Health Control (Ação Principal).
class HCPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const HCPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: HCSpacing.sm),
              ],
              Text(label, style: HCTypography.button),
            ],
          );

    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HCColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
          padding: HCSpacing.paddingButton,
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

/// Botão Secundário (Ações Complementares ou Neutras).
class HCSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const HCSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HCColors.neutral100,
          foregroundColor: HCColors.neutral800,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
          padding: HCSpacing.paddingButton,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: HCColors.neutral700),
              const SizedBox(width: HCSpacing.sm),
            ],
            Text(label, style: HCTypography.button.copyWith(color: HCColors.neutral800)),
          ],
        ),
      ),
    );
  }
}

/// Botão de Emergência SOS (Ação Crítica com Alto Destaque Visual).
class HCEmergencyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;

  const HCEmergencyButton({
    super.key,
    this.label = '🚨 SOS Emergência',
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: HCColors.redLight,
        foregroundColor: HCColors.redMain,
        elevation: 0,
        side: const BorderSide(color: HCColors.redBorder, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: HCTypography.button.copyWith(color: HCColors.redMain),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: 48, child: button);
    }
    return button;
  }
}

/// Botão Contornado (Outline).
class HCOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const HCOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: HCColors.primary600,
          side: const BorderSide(color: HCColors.primary200),
          backgroundColor: HCColors.primary50,
          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: HCColors.primary600),
              const SizedBox(width: HCSpacing.xs),
            ],
            Text(
              label,
              style: HCTypography.labelBold.copyWith(color: HCColors.primary600),
            ),
          ],
        ),
      ),
    );
  }
}
