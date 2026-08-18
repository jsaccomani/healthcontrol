import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Card para Registro dos 3 Sopros de Pico de Fluxo (Peak Flow - CFF) e Detecção de Variância.
class PeakFlowInputCard extends StatelessWidget {
  final TextEditingController blow1Ctrl;
  final TextEditingController blow2Ctrl;
  final TextEditingController blow3Ctrl;
  final int? calculatedBest;
  final int? calculatedVariance;
  final bool hasVarianceError;
  final VoidCallback onRecalculate;

  const PeakFlowInputCard({
    super.key,
    required this.blow1Ctrl,
    required this.blow2Ctrl,
    required this.blow3Ctrl,
    required this.calculatedBest,
    required this.calculatedVariance,
    required this.hasVarianceError,
    required this.onRecalculate,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('🫁', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text('2. Sopro da Criança (Peak Flow)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                ],
              ),
              if (calculatedBest != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(6)),
                  child: Text('Melhor: $calculatedBest L/min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppTheme.primaryTeal)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Peça para a criança soprar com força 3 vezes no aparelhinho:',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _buildBlowField('1º Sopro', blow1Ctrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildBlowField('2º Sopro', blow2Ctrl)),
              const SizedBox(width: 8),
              Expanded(child: _buildBlowField('3º Sopro', blow3Ctrl)),
            ],
          ),

          if (hasVarianceError && calculatedVariance != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Atenção: Os sopros variaram $calculatedVariance L/min (diferença maior que 20 L/min). Pode ter ocorrido tosse ou bocal mal vedado.',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlowField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'L/min',
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          onChanged: (_) => onRecalculate(),
        ),
      ],
    );
  }
}
