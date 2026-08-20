import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Topo / Banner de Identificação Estrita da Criança no Modo Crise.
/// Apresenta o contexto clínico trancado (sem seletor de troca).
class CrisisHeader extends StatelessWidget {
  final PatientProfile profile;

  const CrisisHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF240A0A) : const Color(0xFFFEF2F2),
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          width: 1.5,
        ),
        boxShadow: HCShadows.card,
      ),
      child: Row(
        children: [
          // Badge Crise com Ícone
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HCColors.redMain,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Identidade e Dados Vitais da Criança
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
                        'CRISE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        profile.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          color: isDark ? Colors.white : HCColors.neutral900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${profile.ageDisplay}${profile.weightKg > 0 ? " • Peso: ${profile.weightKg} kg" : ""}${profile.personalBestPef > 0 ? " • Recorde PFE: ${profile.personalBestPef} L/min" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFFCA5A5) : HCColors.neutral700,
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
