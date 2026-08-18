import 'package:flutter/material.dart';

/// Card para Registro de Fisioterapia Respiratória ou CPAP.
class PhysioInputCard extends StatelessWidget {
  final String selectedDevice;
  final List<String> availableDevices;
  final TextEditingController durationCtrl;
  final ValueChanged<String?> onDeviceChanged;

  const PhysioInputCard({
    super.key,
    required this.selectedDevice,
    required this.availableDevices,
    required this.durationCtrl,
    required this.onDeviceChanged,
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
            children: const [
              Text('🫁', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('4. Fisioterapia / Exercício Respiratório', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedDevice,
            decoration: const InputDecoration(labelText: 'Aparelho / Exercício Utilizado'),
            items: availableDevices
                .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: onDeviceChanged,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duração da Sessão (minutos)',
              hintText: 'ex: 10',
            ),
          ),
        ],
      ),
    );
  }
}
