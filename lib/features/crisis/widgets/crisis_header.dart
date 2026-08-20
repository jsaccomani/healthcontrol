import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Topo / Banner de Identificação Estrita da Criança no Modo Crise.
/// Responde imediatamente à pergunta: "QUEM?"
/// Apresenta o contexto clínico trancado (sem troca casual de paciente).
class CrisisHeader extends StatelessWidget {
  final PatientProfile profile;

  const CrisisHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.criticalBg,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: theme.criticalBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Ícone de Modo Operacional Crise
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HCColors.redMain,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Identidade e Dados Vitais da Criança (QUEM?)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HCColors.redMain,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MODO CRISE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        profile.name,
                        style: HCTypography.heading.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${profile.ageDisplay}${profile.weightKg > 0 ? " • ${profile.weightKg.toString().replaceAll('.', ',')} kg" : ""}${profile.personalBestPef > 0 ? " • PFE Base: ${profile.personalBestPef} L/min" : ""}',
                  style: HCTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
