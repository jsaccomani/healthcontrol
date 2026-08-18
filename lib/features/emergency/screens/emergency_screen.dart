import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Tela de Emergência e SOS de Alta Prioridade (100% Offline, Alto Contraste).
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  PatientProfile? _profile;
  List<HealthControlEntry> _entries = [];
  List<PrescriptionRecord> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  Future<void> _loadEmergencyData() async {
    final p = await _storageService.getPatientProfile();
    final results = await Future.wait([
      _storageService.getHealthEntries(),
      _storageService.getPrescriptions(p.id),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _entries = results[0] as List<HealthControlEntry>;
      _prescriptions = results[1] as List<PrescriptionRecord>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        backgroundColor: HCColors.redMain,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;

    // Busca medicamentos de resgate da receita
    final List<PrescribedMedication> rescueMeds = [];
    for (final p in _prescriptions) {
      for (final m in p.medications) {
        if (m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue) {
          rescueMeds.add(m);
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF991B1B), // Fundo vermelho profundo de emergência
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F1D1D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🚨 FICHA DE EMERGÊNCIA MÉDICA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            children: [
            // 1. Banner para Apresentação Imediata ao Plantonista
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: HCRadii.radiusLg,
                border: Border.all(color: HCColors.redBorder, width: 2),
                boxShadow: HCShadows.floating,
              ),
              child: Column(
                children: [
                  const Text(
                    'MOSTRAR AO MÉDICO / PLANTONISTA DO PS',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paciente pediátrico em acompanhamento de Asma. Último PFE: ${latest?.peakFlowBest ?? 0} L/min • SpO2: ${latest?.spo2 ?? 0}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Protocolo de Resgate Imediato (GINA / PCDT)
            _buildEmergencyCard(
              title: 'PLANO DE RESGATE IMEDIATO NA CRISE',
              icon: Icons.medication,
              headerColor: const Color(0xFFB91C1C),
              children: [
                _buildRow('Medicação de Resgate:', rescueMeds.isNotEmpty ? rescueMeds.first.commercialName : 'Aerolin Spray (Salbutamol 100mcg)', isBold: true, highlight: true),
                _buildRow('Dose Pediátrica de Ataque:', rescueMeds.isNotEmpty ? rescueMeds.first.dosage : '2 a 4 jatos via espaçador valvulado com máscara', isBold: true),
                _buildRow('Intervalo:', 'A cada 20 minutos na primeira hora se persistir crise', isBold: false),
                _buildRow('Orientação Física:', 'Manter a criança sentada ereta. Não deitar durante a crise.', highlight: true),
                _buildRow('Sinais de Alerta Vermelho:', 'Tiragem intercostal (afundamento do peito), lábios roxos (cianose), batimento de asa de nariz ou incapacidade de falar frases completas.', highlight: true),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Dados Vitais para Cálculo de Dose Pediátrica
            _buildEmergencyCard(
              title: 'DADOS DO PACIENTE & CÁLCULO DE DOSE',
              icon: Icons.person_pin,
              children: [
                _buildRow('Nome do Paciente:', _profile!.name, isBold: true),
                _buildRow('Idade / Nascimento:', '${_profile!.ageDisplay} (${DateFormat('dd/MM/yyyy').format(_profile!.birthDate)})'),
                _buildRow('Peso Atual:', '${_profile!.weightKg} kg (Referência para dosagem)', highlight: true, isBold: true),
                _buildRow('Altura / IMC:', '${_profile!.heightCm.toStringAsFixed(0)} cm • IMC: ${_profile!.bmi.toStringAsFixed(1)} kg/m²'),
                _buildRow('Tipo Sanguíneo:', _profile!.bloodType, isBold: true),
                _buildRow('Melhor Sopro Pessoal (PFE):', '${_profile!.personalBestPef} L/min', highlight: true),
                _buildRow('Cartão SUS:', _profile!.susCardNumber.isNotEmpty ? _profile!.susCardNumber : 'Não informado'),
                _buildRow('Convênio Médico:', '${_profile!.healthInsurance} (Carteira: ${_profile!.insuranceCardNumber})'),
              ],
            ),

            const SizedBox(height: 14),

            // 4. Alergias Críticas & Comorbidades
            _buildEmergencyCard(
              title: 'ALERGIAS A MEDICAMENTOS & COMORBIDADES',
              icon: Icons.warning_amber_rounded,
              headerColor: const Color(0xFFDC2626),
              children: [
                _buildRow(
                  'Alergias a Medicamentos:',
                  _profile!.drugAllergies.isNotEmpty ? _profile!.drugAllergies.join(', ') : 'NENHUMA ALERGIA MEDICAMENTOSA RELATADA',
                  highlight: _profile!.drugAllergies.isNotEmpty,
                  isBold: true,
                ),
                _buildRow('Alergias Alimentares:', _profile!.foodAllergies.isNotEmpty ? _profile!.foodAllergies.join(', ') : 'Nenhuma'),
                _buildRow('Comorbidades:', _profile!.comorbidities.join(', ')),
                _buildRow('Internações em UTI prévias:', _profile!.hadIcuAdmission ? 'SIM (${_profile!.icuAdmissionsCount} vez(es))' : 'Não'),
                _buildRow('Intubação prévia por asma:', _profile!.intubatedPast ? 'SIM (Alto Risco de Asma Quase Fatal)' : 'Não', highlight: _profile!.intubatedPast),
              ],
            ),

            const SizedBox(height: 14),

            // 5. Contatos de Emergência dos Pais
            _buildEmergencyCard(
              title: 'TELEFONES DOS PAIS & MÉDICO RESPONSÁVEL',
              icon: Icons.phone_in_talk,
              children: [
                _buildRow('Mãe:', '${_profile!.motherName} • ${_profile!.motherPhone}', isBold: true),
                _buildRow('Pai:', '${_profile!.fatherName} • ${_profile!.fatherPhone}', isBold: true),
                _buildRow('Contato SOS Alternativo:', '${_profile!.emergencyContactName} • ${_profile!.emergencyContactPhone}'),
                _buildRow('Pneumopediatra Assistente:', '${_profile!.doctorName} • ${_profile!.doctorPhone}'),
                _buildRow('Hospital de Preferência:', _profile!.preferredHospital),
                _buildRow('Endereço Residencial:', _profile!.addressCityState.isNotEmpty ? _profile!.addressCityState : 'Não informado'),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildEmergencyCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color headerColor = const Color(0xFF1E293B),
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: HCRadii.radiusLg,
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: highlight ? const EdgeInsets.all(6) : EdgeInsets.zero,
      decoration: highlight
          ? BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFECACA)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: highlight ? const Color(0xFF991B1B) : const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold || highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? const Color(0xFF991B1B) : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
