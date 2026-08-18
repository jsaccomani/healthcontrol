import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Seletor em Chips dos Procedimentos Realizados no Momento.
class ProcedureChipSelector extends StatelessWidget {
  final bool includeMedication;
  final bool includePeakFlow;
  final bool includeSpo2;
  final bool includePhysioCpap;
  final bool includeSymptoms;
  final bool includeNotes;
  final ValueChanged<bool> onToggleMedication;
  final ValueChanged<bool> onTogglePeakFlow;
  final ValueChanged<bool> onToggleSpo2;
  final ValueChanged<bool> onTogglePhysioCpap;
  final ValueChanged<bool> onToggleSymptoms;
  final ValueChanged<bool> onToggleNotes;

  const ProcedureChipSelector({
    super.key,
    required this.includeMedication,
    required this.includePeakFlow,
    required this.includeSpo2,
    required this.includePhysioCpap,
    required this.includeSymptoms,
    required this.includeNotes,
    required this.onToggleMedication,
    required this.onTogglePeakFlow,
    required this.onToggleSpo2,
    required this.onTogglePhysioCpap,
    required this.onToggleSymptoms,
    required this.onToggleNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que foi realizado agora? (Toque para marcar/desmarcar)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildProcedureChip('💊 Remédio da Receita', includeMedication, onToggleMedication),
              _buildProcedureChip('🫁 Sopro (Peak Flow)', includePeakFlow, onTogglePeakFlow),
              _buildProcedureChip('🩸 Oxímetro (SpO2)', includeSpo2, onToggleSpo2),
              _buildProcedureChip('🫁 Fisioterapia / CPAP', includePhysioCpap, onTogglePhysioCpap),
              _buildProcedureChip('🤒 Notou Sintomas?', includeSymptoms, onToggleSymptoms),
              _buildProcedureChip('📝 Observações', includeNotes, onToggleNotes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureChip(String label, bool isSelected, ValueChanged<bool> onToggle) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppTheme.primaryTeal : const Color(0xFF334155),
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryLight,
      checkmarkColor: AppTheme.primaryTeal,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? AppTheme.primaryTeal : const Color(0xFFCBD5E1)),
      ),
      onSelected: onToggle,
    );
  }
}
