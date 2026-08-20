import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Segurança quando NÃO HÁ plano de resgate cadastrado.
/// Princípio Clínico: O sistema não inventa medicamentos ou posologias na ausência de prescrição.
class CrisisNoPlanCard extends StatelessWidget {
  final VoidCallback onCallSamu;
  final VoidCallback? onCallDoctor;
  final VoidCallback onOpenEmergencySummary;

  const CrisisNoPlanCard({
    super.key,
    required this.onCallSamu,
    this.onCallDoctor,
    required this.onOpenEmergencySummary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1E0B) : const Color(0xFFFEFCE8),
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDE047),
          width: 1.5,
        ),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'NENHUM PLANO DE RESGATE CADASTRADO',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Este aplicativo não possui uma orientação médica registrada para esta criança.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : HCColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por segurança clínica, o aplicativo não recomenda medicamentos ou doses sem prescrição. Em caso de falta de ar, chiado ou cansaço, acione o serviço de urgência imediatamente.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Botão 192 com Saliência Máxima
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HCColors.redMain,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                elevation: 0,
              ),
              onPressed: onCallSamu,
              icon: const Icon(Icons.phone_in_talk, size: 22),
              label: const Text(
                'Ligar 192 (SAMU Emergência)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Ações Secundárias Seguras
          Row(
            children: [
              if (onCallDoctor != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? HCColors.primary300 : HCColors.primary700,
                      side: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral300),
                      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    ),
                    onPressed: onCallDoctor,
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text(
                      'Contatar Médico',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : HCColors.neutral800,
                    side: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral300),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                  ),
                  onPressed: onOpenEmergencySummary,
                  icon: const Icon(Icons.medical_information_outlined, size: 16),
                  label: const Text(
                    'Ver Ficha Médica',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
