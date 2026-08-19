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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? HCColors.darkSurfaceElevated : HCColors.neutral100,
          foregroundColor: isDark ? HCColors.darkTextPrimary : HCColors.neutral800,
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
              Icon(icon, size: 18, color: isDark ? HCColors.darkTextSecondary : HCColors.neutral700),
              const SizedBox(width: HCSpacing.sm),
            ],
            Text(
              label,
              style: HCTypography.button.copyWith(
                color: isDark ? HCColors.darkTextPrimary : HCColors.neutral800,
              ),
            ),
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
    this.label = 'SOS Emergência',
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF350A0A) : HCColors.redLight,
        foregroundColor: HCColors.redMain,
        elevation: 0,
        side: BorderSide(
          color: isDark ? const Color(0xFF991B1B) : HCColors.redBorder,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.emergency, size: 18, color: HCColors.redMain),
      label: Text(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? HCColors.primary300 : HCColors.primary600,
          side: BorderSide(
            color: isDark ? HCColors.darkBorder : HCColors.primary200,
          ),
          backgroundColor: isDark ? HCColors.darkSurface : HCColors.primary50,
          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isDark ? HCColors.primary300 : HCColors.primary600),
              const SizedBox(width: HCSpacing.xs),
            ],
            Text(
              label,
              style: HCTypography.labelBold.copyWith(
                color: isDark ? HCColors.primary300 : HCColors.primary600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
