import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Ações de Escalada e Emergência (QUANDO ESCALAR?).
/// Inclui: SAMU 192, Ligar para o Médico Assistente e GPS Hospital de Referência.
/// Dispostas de forma limpa e acessível, sem competir visualmente com o plano de resgate.
class CrisisEmergencyActions extends StatelessWidget {
  final VoidCallback onCallSamu;
  final VoidCallback? onCallDoctor;
  final VoidCallback onOpenHospitalGps;

  const CrisisEmergencyActions({
    super.key,
    required this.onCallSamu,
    this.onCallDoctor,
    required this.onOpenHospitalGps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SE PERSISTIR O DESCONFORTO OU EM CASO DE PIORA (ESCALADA):',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Ligar 192 (SAMU Emergência)
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HCColors.redMain,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: onCallSamu,
                  icon: const Icon(Icons.phone_in_talk, size: 18),
                  label: const Text(
                    'Ligar 192 (SAMU)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Ligar Médico Assistente (se houver)
            if (onCallDoctor != null) ...[
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textPrimary,
                      side: BorderSide(color: theme.border),
                      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    ),
                    onPressed: onCallDoctor,
                    icon: Icon(Icons.call, color: theme.primary, size: 18),
                    label: const Text(
                      'Ligar Médico',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // GPS Hospital de Referência
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textPrimary,
                    side: BorderSide(color: theme.border),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                  ),
                  onPressed: onOpenHospitalGps,
                  icon: Icon(Icons.local_hospital_outlined, color: theme.primary, size: 18),
                  label: const Text(
                    'Pronto-Socorro',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
