import 'package:flutter/material.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';
import 'hc_button.dart';

/// Estado de Carregamento Acolhedor (Loading State).
class HCLoadingState extends StatelessWidget {
  final String message;

  const HCLoadingState({
    super.key,
    this.message = 'Carregando dados de saúde...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: HCSpacing.paddingCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: HCColors.primary500, strokeWidth: 2.5),
            const SizedBox(height: HCSpacing.md),
            Text(message, style: HCTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Estado Vazio Padronizado (Empty State com CTA opcional).
class HCEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const HCEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCard * 1.5,
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDark ? HCColors.darkTextMuted : HCColors.neutral400,
            size: 40,
          ),
          const SizedBox(height: HCSpacing.sm),
          Text(
            title,
            style: HCTypography.subHeading.copyWith(
              color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HCSpacing.xs),
          Text(
            message,
            style: HCTypography.bodySmall.copyWith(
              color: isDark ? HCColors.darkTextSecondary : HCColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: HCSpacing.md),
            HCPrimaryButton(label: actionLabel!, onPressed: onActionPressed),
          ],
        ],
      ),
    );
  }
}

/// Estado de Erro / Falha (Error State com Ação de Tentar Novamente).
class HCErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const HCErrorState({
    super.key,
    this.title = 'Ops, algo não saiu como esperado',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: HCColors.redLight,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: HCColors.redBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: HCColors.redMain, size: 36),
          const SizedBox(height: HCSpacing.sm),
          Text(title, style: HCTypography.subHeading.copyWith(color: HCColors.redText)),
          const SizedBox(height: HCSpacing.xs),
          Text(message, style: HCTypography.bodySmall.copyWith(color: HCColors.redText), textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: HCSpacing.md),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: HCColors.redMain,
                side: const BorderSide(color: HCColors.redBorder),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ],
      ),
    );
  }
}
