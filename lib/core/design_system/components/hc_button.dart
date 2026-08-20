import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Botão Primário Padrão do Health Control (Ação Principal da Tela).
class HCPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const HCPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
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
                const SizedBox(width: HCSpacing.space8),
              ],
              Text(label, style: HCTypography.button),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
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
  final double height;

  const HCSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.elevatedSurface,
          foregroundColor: theme.textPrimary,
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
              Icon(icon, size: 18, color: theme.textSecondary),
              const SizedBox(width: HCSpacing.space8),
            ],
            Text(
              label,
              style: HCTypography.button.copyWith(color: theme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de Emergência SOS (Ação Crítica com Alto Destaque Visual e Calma).
class HCEmergencyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double height;

  const HCEmergencyButton({
    super.key,
    this.label = 'SOS Emergência',
    required this.onPressed,
    this.fullWidth = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.criticalBg,
        foregroundColor: theme.critical,
        elevation: 0,
        side: BorderSide(
          color: theme.criticalBorder,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.emergency, size: 18, color: HCColors.redMain),
      label: Text(
        label,
        style: HCTypography.button.copyWith(color: theme.critical),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
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
  final double height;

  const HCOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.primary,
          side: BorderSide(color: theme.primaryBorder),
          backgroundColor: theme.primarySubtle,
          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: theme.primary),
              const SizedBox(width: HCSpacing.space4),
            ],
            Text(
              label,
              style: HCTypography.labelBold.copyWith(color: theme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de Ícone Padronizado com Target de Toque Mínimo de 44x44px.
class HCIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const HCIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: HCRadii.radiusMd,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: HCRadii.radiusMd,
        ),
        child: Icon(
          icon,
          size: size,
          color: color ?? theme.textSecondary,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
