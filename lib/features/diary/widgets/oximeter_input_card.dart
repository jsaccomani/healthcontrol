import 'package:flutter/material.dart';

/// Card para Registro da Saturação de Oxigênio (SpO2).
class OximeterInputCard extends StatelessWidget {
  final TextEditingController spo2Ctrl;

  const OximeterInputCard({
    super.key,
    required this.spo2Ctrl,
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
              Text('🩸', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('3. Oxímetro de Dedo (SpO2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Saturação de oxigênio medida no dedo da criança (%):',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: spo2Ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              suffixText: '%',
              hintText: '98',
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      ),
    );
  }
}
