import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';

/// Botões de Ações Rápidas da Home: Registrar Ação, Modo Crise / SOS e Plano Médico.
class QuickActionButtons extends StatelessWidget {
  final VoidCallback onNewEntry;
  final VoidCallback onUpdatePrescription;
  final VoidCallback onSosPressed;

  const QuickActionButtons({
    super.key,
    required this.onNewEntry,
    required this.onUpdatePrescription,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onNewEntry,
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text(
                    'Registrar Ação',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    backgroundColor: HCColors.redLight,
                    foregroundColor: HCColors.redMain,
                    side: const BorderSide(color: HCColors.redBorder, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onSosPressed,
                  icon: const Icon(Icons.emergency, size: 20, color: HCColors.redMain),
                  label: const Text(
                    'Modo Crise',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: HCColors.neutral700,
              side: const BorderSide(color: HCColors.neutral200),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
            ),
            onPressed: onUpdatePrescription,
            icon: const Icon(Icons.description_outlined, size: 16, color: HCColors.neutral600),
            label: const Text(
              'Ver Plano de Ação & Receitas Médicas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
