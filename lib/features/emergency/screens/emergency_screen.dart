import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:clinical_core/clinical_core.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  PatientProfile? _profile;
  List<HealthControlEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  Future<void> _loadEmergencyData() async {
    final p = await _storageService.getPatientProfile();
    final e = await _storageService.getHealthEntries();
    setState(() {
      _profile = p;
      _entries = e;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        backgroundColor: AppTheme.zoneRed,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFB91C1C), // Vermelho emergência
      appBar: AppBar(
        backgroundColor: const Color(0xFF991B1B),
        foregroundColor: Colors.white,
        title: const Text(
          '🚨 FICHA DE EMERGÊNCIA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner de Alerta para o Médico
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text(
                    'MOSTRAR AO MÉDICO / PLANTONISTA DO PS',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Paciente pediátrico em acompanhamento de Asma Grave.',
                    style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Card Dados Vitais Imediatos
            _buildEmergencyCard(
              title: 'IDENTIFICAÇÃO & DADOS DO PACIENTE',
              icon: Icons.person,
              children: [
                _buildRow('Nome Completo:', _profile!.name, isBold: true),
                _buildRow('Idade / Nascimento:', '${_profile!.ageDisplay} (${DateFormat('dd/MM/yyyy').format(_profile!.birthDate)})'),
                _buildRow('Peso Atual:', '${_profile!.weightKg} kg (Calculador de Dose Pediátrica)', highlight: true),
                _buildRow('Altura:', '${_profile!.heightCm.toStringAsFixed(0)} cm • IMC: ${_profile!.bmi.toStringAsFixed(1)} kg/m²'),
                _buildRow('Tipo Sanguíneo:', _profile!.bloodType),
                _buildRow('Cartão SUS:', _profile!.susCardNumber.isNotEmpty ? _profile!.susCardNumber : 'Não informado'),
                _buildRow('Convênio:', '${_profile!.healthInsurance} (${_profile!.insuranceCardNumber})'),
              ],
            ),

            const SizedBox(height: 12),

            // Card Alergias & Comorbidades
            _buildEmergencyCard(
              title: 'ALERGIAS & COMORBIDADES DA CRIANÇA',
              icon: Icons.warning_amber_rounded,
              children: [
                _buildRow(
                  'Alergias a Remédios:',
                  _profile!.drugAllergies.isNotEmpty ? _profile!.drugAllergies.join(', ') : 'Nenhuma relatada',
                  highlight: _profile!.drugAllergies.isNotEmpty,
                ),
                _buildRow('Alergias Ambientais:', _profile!.environmentalAllergies.join(', ')),
                _buildRow('Comorbidades:', _profile!.comorbidities.join(', ')),
              ],
            ),

            const SizedBox(height: 12),

            // Card Último Estado Clínico
            _buildEmergencyCard(
              title: 'ÚLTIMO REGISTRO CLÍNICO HOJE',
              icon: Icons.history,
              children: [
                if (latest != null) ...[
                  _buildRow('Horário do Registro:', DateFormat('dd/MM/yyyy HH:mm').format(latest.timestamp)),
                  _buildRow('Saturação SpO2:', '${latest.spo2}%', highlight: latest.spo2 < 92),
                  _buildRow('Pico de Fluxo (PFE):', '${latest.peakFlowBest} L/min (Melhor Pessoal: ${_profile!.personalBestPef} L/min)'),
                  if (latest.symptoms.isNotEmpty)
                    _buildRow('Sintomas Notados:', latest.symptoms.join(', ')),
                  if (latest.notes.isNotEmpty)
                    _buildRow('Observações dos Pais:', latest.notes),
                ] else
                  const Text('Nenhum registro nas últimas horas.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),

            const SizedBox(height: 12),

            // Card Medicações & Resgate
            _buildEmergencyCard(
              title: 'PLANO DE RESGATE & MEDICAÇÕES USADAS',
              icon: Icons.medication,
              children: [
                _buildRow('Broncodilatador de Resgate:', 'Aerolin / Salbutamol Spray 100mcg (com espaçador)'),
                _buildRow('Uso Contínuo:', _profile!.continuousMedications.isNotEmpty ? _profile!.continuousMedications.join(', ') : 'Clenil HFA 250mcg'),
                _buildRow('Biomarcadores:', 'IgE: ${_profile!.igeLevel.toStringAsFixed(0)} UI/mL • Eosinófilos: ${_profile!.eosinophilsCount} cél/µL'),
              ],
            ),

            const SizedBox(height: 12),

            // Contatos de Emergência
            _buildEmergencyCard(
              title: 'CONTATOS DE EMERGÊNCIA & MÉDICO',
              icon: Icons.phone,
              children: [
                _buildRow('Mãe (${_profile!.motherName.isNotEmpty ? _profile!.motherName : "Mãe"}):', _profile!.motherPhone.isNotEmpty ? _profile!.motherPhone : '(11) 98765-4321'),
                if (_profile!.fatherName.isNotEmpty || _profile!.fatherPhone.isNotEmpty)
                  _buildRow('Pai (${_profile!.fatherName}):', _profile!.fatherPhone),
                if (_profile!.doctorName.isNotEmpty)
                  _buildRow('Médico Assistente:', '${_profile!.doctorName} (${_profile!.doctorPhone})'),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB91C1C), size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Divider(height: 14, color: Color(0xFFE2E8F0)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: highlight ? const Color(0xFFB91C1C) : const Color(0xFF0F172A),
                fontWeight: isBold || highlight ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
