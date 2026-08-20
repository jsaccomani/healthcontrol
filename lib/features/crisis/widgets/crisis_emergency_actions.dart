import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Botões de Emergência Imediata (Nível 1 — Imediato).
/// Garante acesso 1-tap ao SAMU 192 e rotas de GPS para o Pronto-Socorro.
class CrisisEmergencyActions extends StatelessWidget {
  final VoidCallback onCallSamu;
  final VoidCallback onOpenHospitalGps;

  const CrisisEmergencyActions({
    super.key,
    required this.onCallSamu,
    required this.onOpenHospitalGps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Ligar 192
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HCColors.redMain,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                elevation: 0,
              ),
              onPressed: onCallSamu,
              icon: const Icon(Icons.phone_in_talk, size: 20),
              label: const Text(
                'Ligar 192 (SAMU)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // GPS Hospital
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : HCColors.neutral800,
                side: BorderSide(
                  color: isDark ? HCColors.darkBorder : HCColors.neutral300,
                ),
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
              ),
              onPressed: onOpenHospitalGps,
              icon: const Icon(Icons.directions_car, color: HCColors.primary500, size: 20),
              label: const Text(
                'GPS Pronto-Socorro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
