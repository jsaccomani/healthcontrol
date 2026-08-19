import 'package:flutter/material.dart';

/// Card para Seleção de Sintomas Observados na Criança.
class SymptomsSelectorCard extends StatelessWidget {
  final List<String> commonSymptoms;
  final List<String> selectedSymptoms;
  final ValueChanged<String> onToggleSymptom;

  const SymptomsSelectorCard({
    super.key,
    required this.commonSymptoms,
    required this.selectedSymptoms,
    required this.onToggleSymptom,
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
              Icon(Icons.sick_outlined, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 6),
              Text('5. Sintomas Observados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: commonSymptoms.map((s) {
              final isSel = selectedSymptoms.contains(s);
              return FilterChip(
                label: Text(s, style: TextStyle(fontSize: 11, color: isSel ? const Color(0xFFDC2626) : const Color(0xFF334155))),
                selected: isSel,
                selectedColor: const Color(0xFFFEE2E2),
                checkmarkColor: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isSel ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
                ),
                onSelected: (_) => onToggleSymptom(s),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
