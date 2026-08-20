import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Botões de Ações Rápidas da Home.
/// Ação Primária dominante ("Registrar") acompanhada de atalhos diretos e acesso seguro a Crise.
class QuickActionButtons extends StatelessWidget {
  final VoidCallback onRegister;
  final ValueChanged<String> onDirectAction;
  final VoidCallback onSosPressed;

  const QuickActionButtons({
    super.key,
    required this.onRegister,
    required this.onDirectAction,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha Principal: "Registrar" (Dominante) + "Crise" (SOS Secundário)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onRegister,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Registrar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.criticalBg,
                    foregroundColor: theme.critical,
                    side: BorderSide(
                      color: theme.criticalBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onSosPressed,
                  icon: Icon(Icons.emergency, size: 18, color: theme.critical),
                  label: Text(
                    'Crise',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.critical),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Atalhos Rápidos Secundários em 1 Toque
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSecondaryActionChip(
                context: context,
                icon: Icons.medication_outlined,
                label: 'Medicação',
                onTap: () => onDirectAction('MEDICATION'),
              ),
              const SizedBox(width: 8),
              _buildSecondaryActionChip(
                context: context,
                icon: Icons.air,
                label: 'Pico de fluxo',
                onTap: () => onDirectAction('PEAK_FLOW'),
              ),
              const SizedBox(width: 8),
              _buildSecondaryActionChip(
                context: context,
                icon: Icons.sick_outlined,
                label: 'Sintoma',
                onTap: () => onDirectAction('SYMPTOMS'),
              ),
              const SizedBox(width: 8),
              _buildSecondaryActionChip(
                context: context,
                icon: Icons.monitor_heart_outlined,
                label: 'SpO2',
                onTap: () => onDirectAction('SPO2'),
              ),
              const SizedBox(width: 8),
              _buildSecondaryActionChip(
                context: context,
                icon: Icons.edit_note,
                label: 'Nota',
                onTap: () => onDirectAction('NOTE'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = context.hcTheme;

    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusMd,
        side: BorderSide(color: theme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: HCRadii.radiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
