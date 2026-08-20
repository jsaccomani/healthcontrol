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
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: HCTypography.label.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: HCSpacing.space4),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign,
          readOnly: readOnly,
          maxLines: maxLines,
          onChanged: onChanged,
          style: HCTypography.body.copyWith(color: theme.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            suffixText: suffixUnit,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: theme.textMuted)
                : null,
            filled: true,
            fillColor: theme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.critical),
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de Seleção Padronizado (Dropdown / Select).
class HCSelectField<T> extends StatelessWidget {
  final String? labelText;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const HCSelectField({
    super.key,
    this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: HCTypography.label.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: HCSpacing.space4),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: theme.surface,
          style: HCTypography.body.copyWith(color: theme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: theme.textMuted)
                : null,
            filled: true,
            fillColor: theme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: HCRadii.radiusMd,
              borderSide: BorderSide(color: theme.primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
