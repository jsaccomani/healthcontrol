import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';
import 'hc_button.dart';

/// Modal de Diálogo Padronizado do Health Control.
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusLg),
      backgroundColor: HCColors.surfaceWhite,
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? HCColors.primary500, size: 20),
            const SizedBox(width: HCSpacing.sm),
          ],
          Expanded(child: Text(title, style: HCTypography.subHeading)),
        ],
      ),
      content: content,
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(cancelLabel, style: HCTypography.labelBold.copyWith(color: HCColors.neutral600)),
          ),
        if (onConfirm != null)
          HCPrimaryButton(label: confirmLabel, onPressed: onConfirm),
      ],
    );
  }
}
