import 'package:flutter/material.dart';
import '../../crisis/screens/crisis_screen.dart';

/// Redirecionador retrocompatível para a nova CrisisScreen (Modo Crise com Isolamento Estrito de Paciente).
class EmergencyScreen extends StatelessWidget {
  final String? patientId;

  const EmergencyScreen({
    super.key,
    this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return CrisisScreen(
      patientId: patientId ?? 'arthur_saccomani_01',
    );
  }
}
