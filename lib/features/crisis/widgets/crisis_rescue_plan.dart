import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card do Plano de Resgate Médico Prescrito (Área Visual Dominante).
/// Responde imediatamente: "O QUE FAZER?"
/// Exibe EXATAMENTE a prescrição cadastrada sem reinterpretação, alteração de dose ou sugestão não-médica.
class CrisisRescuePlan extends StatelessWidget {
  final List<Map<String, dynamic>> validRescuePlans;
  final void Function({
    required String prescriptionId,
    required String medicationName,
    required String dosage,
    String administeredBy,
  }) onAdministerDose;

  const CrisisRescuePlan({
    super.key,
    required this.validRescuePlans,
    required this.onAdministerDose,
  });

  void _showConfirmationDialog(
    BuildContext context, {
    required PrescriptionRecord presc,
    required PrescribedMedication med,
  }) {
    final theme = context.hcTheme;
    String selectedCaregiver = 'Cuidador';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusLg,
            side: BorderSide(color: theme.border),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HCColors.redMain.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle_outline, color: HCColors.redMain, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirmar Administração',
                  style: HCTypography.heading.copyWith(
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você confirma que administrou a seguinte dose de resgate agora?',
                style: HCTypography.bodySmall.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.elevatedSurface,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.commercialName,
                      style: HCTypography.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dose: ${med.dosage}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                      ),
                    ),
                    if (med.instructions.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Instrução: ${med.instructions}',
                        style: HCTypography.caption.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Quem administrou a medicação?',
                style: HCTypography.label.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['Mãe', 'Pai', 'Cuidador', 'Familiar'].map((role) {
                  final isSelected = selectedCaregiver == role;
                  return ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    selectedColor: theme.primarySubtle,
                    backgroundColor: theme.surface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.primary : theme.textPrimary,
                    ),
                    side: BorderSide(
                      color: isSelected ? theme.primary : theme.border,
                    ),
                    onSelected: (val) {
                      if (val) setDialogState(() => selectedCaregiver = role);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HCColors.redMain,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                onAdministerDose(
                  prescriptionId: presc.id,
                  medicationName: med.commercialName,
                  dosage: med.dosage,
                  administeredBy: selectedCaregiver,
                );
              },
              child: const Text(
                'Confirmar e Iniciar Timer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validRescuePlans.map((item) {
        final PrescriptionRecord presc = item['prescription'] as PrescriptionRecord;
        final PrescribedMedication med = item['medication'] as PrescribedMedication;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.criticalBg,
            borderRadius: HCRadii.radiusLg,
            border: Border.all(
              color: theme.criticalBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho de Área Dominante: PLANO DE RESGATE
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HCColors.redMain.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.medication_liquid_outlined,
                      color: HCColors.redMain,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PLANO DE RESGATE PRESCRITO',
                      style: TextStyle(
                        color: theme.criticalText,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nome do Medicamento
              Text(
                med.commercialName,
                style: HCTypography.title.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              if (med.activeIngredient.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  med.activeIngredient,
                  style: HCTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bloco de Detalhes da Posologia Exata Prescrita
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(
                    color: theme.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dose
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dose: ',
                          style: HCTypography.label.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            med.dosage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Via
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Via: ',
                          style: HCTypography.label.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            med.category == MedicationCategory.rescueInhaled
                                ? 'Inalatória (Inalação oral)'
                                : 'Oral',
                            style: HCTypography.bodySmall.copyWith(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Frequência / Instrução
                    if (med.frequency.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frequência: ',
                            style: HCTypography.label.copyWith(
                              color: theme.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              med.frequency,
                              style: HCTypography.bodySmall.copyWith(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Dispositivo / Espaçador
                    if (med.spacerRequired || med.instructions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispositivo: ',
                            style: HCTypography.label.copyWith(
                              color: theme.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              med.spacerRequired
                                  ? 'Utilizar com espaçador valvulado${med.instructions.isNotEmpty ? " • ${med.instructions}" : ""}'
                                  : med.instructions,
                              style: HCTypography.bodySmall.copyWith(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Origem Médica (Prescrito por Dr. X, CRM, Data)
              Row(
                children: [
                  Icon(
                    presc.verificationStatus == PrescriptionVerificationStatus.verified
                        ? Icons.verified
                        : Icons.assignment_outlined,
                    size: 14,
                    color: presc.verificationStatus == PrescriptionVerificationStatus.verified
                        ? theme.success
                        : theme.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Prescrito por: ${presc.doctorName}${presc.doctorCrm.isNotEmpty ? " (${presc.doctorCrm})" : ""} em ${DateFormat('dd/MM/yyyy').format(presc.prescriptionDate)}',
                      style: HCTypography.caption.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              HCPrescriptionVerificationBadge(prescription: presc),

              const SizedBox(height: 14),

              // CTA Principal Dominante: "Registrar medicação administrada"
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
                  onPressed: () => _showConfirmationDialog(
                    context,
                    presc: presc,
                    med: med,
                  ),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    'Registrar Medicação Administrada',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
