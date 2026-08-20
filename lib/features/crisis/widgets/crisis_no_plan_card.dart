import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Segurança quando NÃO HÁ plano de resgate cadastrado.
/// Princípio de Segurança Clínica: O aplicativo não inventa nem sugere medicamentos sem prescrição médica válida.
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
    final theme = context.hcTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.warningBg,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: theme.warningBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PLANO DE RESGATE NÃO CADASTRADO',
                  style: TextStyle(
                    color: theme.warningText,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Não existe um plano de resgate cadastrado para esta criança.',
            style: HCTypography.title.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Em uma emergência, procure atendimento médico imediatamente.',
            style: HCTypography.bodySmall.copyWith(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Por segurança clínica estrita, este aplicativo não sugere medicamentos ou dosagens sem prévia prescrição cadastrada.',
            style: HCTypography.caption.copyWith(
              color: theme.textTertiary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Botão 192 SAMU em Destaque Absoluto
          SizedBox(
            width: double.infinity,
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
                'Ligar 192 (SAMU Emergência)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Ações Secundárias Seguras
          Row(
            children: [
              if (onCallDoctor != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textPrimary,
                      side: BorderSide(color: theme.border),
                      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    ),
                    onPressed: onCallDoctor,
                    icon: Icon(Icons.call, color: theme.primary, size: 16),
                    label: const Text(
                      'Ligar Médico',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textPrimary,
                    side: BorderSide(color: theme.border),
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                  ),
                  onPressed: onOpenEmergencySummary,
                  icon: const Icon(Icons.medical_information_outlined, size: 16),
                  label: const Text(
                    'Ver Ficha Clínica',
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
