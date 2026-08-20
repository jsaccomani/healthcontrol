import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';
import 'hc_button.dart';

/// Modal de Diálogo Padronizado do Health Control com Suporte Total ao Tema.
class HCDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final Color? iconColor;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;

  const HCDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.confirmLabel = 'Confirmar',
    this.onConfirm,
    this.cancelLabel = 'Fechar',
    this.onCancel,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    IconData? icon,
    Color? iconColor,
    String confirmLabel = 'Confirmar',
    VoidCallback? onConfirm,
    String cancelLabel = 'Fechar',
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => HCDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(color: theme.border),
      ),
      backgroundColor: theme.surface,
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? theme.primary, size: 20),
            const SizedBox(width: HCSpacing.space8),
          ],
          Expanded(
            child: Text(
              title,
              style: HCTypography.title.copyWith(color: theme.textPrimary),
            ),
          ),
        ],
      ),
      content: content,
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(
              cancelLabel,
              style: HCTypography.label.copyWith(color: theme.textSecondary),
            ),
          ),
        if (onConfirm != null)
          HCPrimaryButton(label: confirmLabel, onPressed: onConfirm),
      ],
    );
  }
}

/// Diálogo de Confirmação Rápida (Ações Críticas ou Irreversíveis).
class HCConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  const HCConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Continuar',
    this.cancelLabel = 'Cancelar',
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Continuar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => HCConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(color: theme.border),
      ),
      backgroundColor: theme.surface,
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? theme.critical : theme.primary,
              size: 22,
            ),
            const SizedBox(width: HCSpacing.space8),
          ],
          Expanded(
            child: Text(
              title,
              style: HCTypography.title.copyWith(color: theme.textPrimary),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: HCTypography.label.copyWith(color: theme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? theme.critical : theme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: HCTypography.button.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Modal Bottom Sheet Padronizado (Handle superior, borda suave e tema adaptativo).
class HCBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    final theme = context.hcTheme;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      builder: (ctx) => Material(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle superior de arrasto
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(height: HCSpacing.space16),
                  Text(
                    title,
                    style: HCTypography.heading.copyWith(color: theme.textPrimary),
                  ),
                ],
                const SizedBox(height: HCSpacing.space16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
