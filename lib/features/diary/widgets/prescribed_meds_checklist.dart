import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';

/// Checklist com as medicações da receita médica da criança e controle de bochecho.
class PrescribedMedsChecklist extends StatelessWidget {
  final List<PrescribedMedication> prescribedMeds;
  final List<MedicationUsage> selectedMedications;
  final bool mouthRinseDone;
  final ValueChanged<PrescribedMedication> onToggleMedication;
  final ValueChanged<bool> onToggleMouthRinse;

  const PrescribedMedsChecklist({
    super.key,
    required this.prescribedMeds,
    required this.selectedMedications,
    required this.mouthRinseDone,
    required this.onToggleMedication,
    required this.onToggleMouthRinse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medication_outlined, color: AppTheme.primaryTeal, size: 18),
              SizedBox(width: 6),
              Text(
                '1. Medicações Prescritas pelo Médico',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Marque apenas o que foi administrado neste horário:',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          ...prescribedMeds.map((med) {
            final isChecked = selectedMedications.any((m) => m.name == med.commercialName);
            final isRescue = med.category == MedicationCategory.rescueInhaled;
            final isSteroid = med.category == MedicationCategory.maintenanceInhaled;

            return Material(
              color: isChecked ? (isRescue ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4)) : const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isChecked ? (isRescue ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)) : const Color(0xFFE2E8F0),
                ),
              ),
              child: CheckboxListTile(
                value: isChecked,
                activeColor: isRescue ? const Color(0xFFDC2626) : AppTheme.primaryTeal,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        med.commercialName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isRescue ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isRescue ? 'Resgate' : 'Manutenção',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isRescue ? const Color(0xFFDC2626) : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Dose: ${med.dosage} (${med.frequency})${isSteroid ? ' • Bochecho obrigatório' : ''}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                onChanged: (_) => onToggleMedication(med),
              ),
            );
          }),

          const SizedBox(height: 6),

          // Alerta e Confirmação de Bochecho
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_outlined, color: AppTheme.primaryTeal, size: 18),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Bochecho com água ou escovação feita após a bombinha?',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                  ),
                ),
                Switch(
                  value: mouthRinseDone,
                  activeThumbColor: AppTheme.primaryTeal,
                  onChanged: onToggleMouthRinse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
