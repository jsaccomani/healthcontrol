import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Campo de Texto Padronizado do Health Control com Suporte a Rótulo, Unidade e Erro.
class HCTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? suffixUnit;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const HCTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixUnit,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: HCTypography.labelBold.copyWith(
              color: isDark ? HCColors.darkTextSecondary : HCColors.neutral700,
            ),
          ),
          const SizedBox(height: HCSpacing.xs),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          style: HCTypography.bodyLarge.copyWith(
            color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            suffixText: suffixUnit,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: isDark ? HCColors.darkTextMuted : HCColors.neutral500)
                : null,
            filled: true,
            fillColor: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: const BorderSide(color: HCColors.primary500, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: const BorderSide(color: HCColors.redMain),
            ),
          ),
        ),
      ],
    );
  }
}
