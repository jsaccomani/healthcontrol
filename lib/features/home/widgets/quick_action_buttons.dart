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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    backgroundColor: HCColors.primary500,
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
                    backgroundColor: isDark ? const Color(0xFF350A0A) : HCColors.redLight,
                    foregroundColor: HCColors.redMain,
                    side: BorderSide(
                      color: isDark ? const Color(0xFF991B1B) : HCColors.redBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onSosPressed,
                  icon: const Icon(Icons.emergency, size: 18, color: HCColors.redMain),
                  label: const Text(
                    'Crise',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusMd,
        side: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
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
                color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? HCColors.darkTextPrimary : HCColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
