import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Contexto e Seleção da Criança para o Cuidador.
/// Apresenta dados essenciais: Nome, Idade, Peso, Status e Ação "Acompanhar".
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = profile.name.trim().isNotEmpty
        ? profile.name.trim().substring(0, 1).toUpperCase()
        : 'C';

    return Material(
      color: isDark ? HCColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: HCRadii.radiusLg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar com Inicial (Visual Clínico Calmo)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? HCColors.primary900.withAlpha(80) : HCColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? HCColors.primary700 : HCColors.primary200,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? HCColors.primary300 : HCColors.primary600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informações da Criança
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? HCColors.darkText : HCColors.neutral900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.hasCarePlan) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark ? HCColors.greenMain.withAlpha(40) : HCColors.greenLight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? HCColors.greenMain : HCColors.greenBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'Plano Ativo',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDark ? HCColors.greenBorder : HCColors.greenText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.ageDisplay}${profile.weightKg > 0 ? " • ${profile.weightKg} kg" : ""}${profile.personalBestPef > 0 ? " • PFE: ${profile.personalBestPef} L/min" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (profile.healthInsurance.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.healthInsurance,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? HCColors.darkTextMuted : HCColors.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Ação "Acompanhar"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? HCColors.darkSurfaceElevated : HCColors.primary50,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(
                    color: isDark ? HCColors.darkBorder : HCColors.primary100,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acompanhar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? HCColors.primary300 : HCColors.primary700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: isDark ? HCColors.primary300 : HCColors.primary700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
