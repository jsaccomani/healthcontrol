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
    final theme = context.hcTheme;

    return Center(
      child: Padding(
        padding: HCSpacing.paddingCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.primary, strokeWidth: 2.5),
            const SizedBox(height: HCSpacing.space16),
            Text(
              message,
              style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
            ),
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
    final theme = context.hcTheme;

    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCard * 1.5,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.textMuted,
            size: 40,
          ),
          const SizedBox(height: HCSpacing.space12),
          Text(
            title,
            style: HCTypography.title.copyWith(color: theme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HCSpacing.space4),
          Text(
            message,
            style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: HCSpacing.space16),
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
    final theme = context.hcTheme;

    return Container(
      width: double.infinity,
      padding: HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: theme.criticalBg,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.criticalBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.critical, size: 36),
          const SizedBox(height: HCSpacing.space8),
          Text(
            title,
            style: HCTypography.title.copyWith(color: theme.criticalText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HCSpacing.space4),
          Text(
            message,
            style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: HCSpacing.space12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.critical,
                side: BorderSide(color: theme.criticalBorder),
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
