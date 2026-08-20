import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Contexto e Seleção da Criança para o Cuidador.
/// Apresenta dados essenciais: Nome, Idade, Peso e Status Clínico Relevante (se existir).
/// Ao tocar: abre a Home individual da criança.
class ChildContextCard extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onSelect;

  const ChildContextCard({
    super.key,
    required this.profile,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final initial = profile.name.trim().isNotEmpty
        ? profile.name.trim().substring(0, 1).toUpperCase()
        : 'C';

    // Status clínico relevante (somente se existir)
    final clinicalStatus = profile.hasCarePlan
        ? 'Asma controlada'
        : (profile.drugAllergies.isNotEmpty
            ? 'Alerta de Alergia'
            : (profile.specialConditions.isNotEmpty
                ? profile.specialConditions.first.name
                : null));

    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: theme.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: HCRadii.radiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Avatar com Inicial (Visual Clínico Calmo)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primarySubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryBorder,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informações da Criança (Nome, Idade • Peso, Status se existir)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: HCTypography.heading.copyWith(
                        fontSize: 16,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.ageDisplay}${profile.weightKg > 0 ? " • ${profile.weightKg.toString().replaceAll('.', ',')} kg" : ""}',
                      style: HCTypography.bodySmall.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (clinicalStatus != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.successBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.successBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          clinicalStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.successText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Indicador sutil de navegação
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.elevatedSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
