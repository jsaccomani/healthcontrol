import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card do Plano de Resgate Médico Prescrito (Nível 1 — Imediato).
/// Exibe estritamente os dados registrados na prescrição médica ativa, com identificação clara da origem.
class CrisisRescuePlan extends StatelessWidget {
  final List<Map<String, dynamic>> validRescuePlans;
  final void Function({
    required String prescriptionId,
    required String medicationName,
    required String dosage,
  }) onAdministerDose;

  const CrisisRescuePlan({
    super.key,
    required this.validRescuePlans,
    required this.onAdministerDose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: isDark ? const Color(0xFF2C0B0B) : const Color(0xFFFEF2F2),
            borderRadius: HCRadii.radiusLg,
            border: Border.all(
              color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
              width: 1.5,
            ),
            boxShadow: HCShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho de Origem Médica
              Row(
                children: [
                  const Icon(
                    Icons.medication_liquid_outlined,
                    color: HCColors.redMain,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PLANO DE RESGATE PRESCRITO',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFFCA5A5) : HCColors.redMain,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Nome Comercial do Medicamento
              Text(
                med.commercialName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : HCColors.neutral900,
                ),
              ),
              if (med.activeIngredient.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  med.activeIngredient,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Caixa com Detalhes da Posologia Prescrita
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFFEE2E2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dose Prescrita: ${med.dosage}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (med.frequency.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Frequência: ${med.frequency}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                        ),
                      ),
                    ],
                    if (med.instructions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Instruções: ${med.instructions}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Identificação do Médico Prescritor (Origem Explícita)
              Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 13,
                    color: isDark ? HCColors.primary300 : HCColors.primary600,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Prescrito por: ${presc.doctorName}${presc.doctorCrm.isNotEmpty ? " (${presc.doctorCrm})" : ""} em ${DateFormat('dd/MM/yyyy').format(presc.prescriptionDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Botão de Ação Primária
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
                  onPressed: () => onAdministerDose(
                    prescriptionId: presc.id,
                    medicationName: med.commercialName,
                    dosage: med.dosage,
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
