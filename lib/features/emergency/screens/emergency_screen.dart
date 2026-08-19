import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Modo Crise / Emergência Médica (100% Offline, Alta Operacionalidade, Baixa Carga Cognitiva).
class EmergencyScreen extends StatefulWidget {
  final String? patientId;
  const EmergencyScreen({super.key, this.patientId});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  List<PatientProfile> _allProfiles = [];
  PatientProfile? _profile;
  List<HealthControlEntry> _entries = [];
  List<PrescriptionRecord> _prescriptions = [];
  bool _isLoading = true;

  // Temporizador de Reavaliação Pós-Resgate (20 minutos)
  Timer? _reassessmentTimer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  DateTime? _lastRescueTime;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData(targetId: widget.patientId);
  }

  @override
  void dispose() {
    _reassessmentTimer?.cancel();
    super.dispose();
  }

  void _startReassessmentTimer() {
    _reassessmentTimer?.cancel();
    setState(() {
      _secondsRemaining = 20 * 60; // 20 minutos
      _isTimerRunning = true;
      _lastRescueTime = DateTime.now();
    });

    _reassessmentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isTimerRunning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tempo de reavaliação atingido (20 min). Verifique o sopro e a respiração da criança.'),
            backgroundColor: HCColors.redMain,
            duration: Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadEmergencyData({String? targetId}) async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final p = await _storageService.getPatientProfile(patientId: targetId);
    final results = await Future.wait([
      _storageService.getHealthEntries(patientId: p.id),
      _storageService.getPrescriptions(p.id),
    ]);
    if (!mounted) return;
    setState(() {
      _allProfiles = profiles;
      _profile = p;
      _entries = results[0] as List<HealthControlEntry>;
      _prescriptions = results[1] as List<PrescriptionRecord>;
      _isLoading = false;
    });
  }

  void _switchEmergencyChild(PatientProfile target) {
    _loadEmergencyData(targetId: target.id);
  }

  Future<void> _recordQuickRescueDose(String rescueMedName, String dosage) async {
    if (_profile == null) return;
    
    await _storageService.addHealthControlEntry(
      targetPatientId: _profile!.id,
      authorName: 'Cuidador (Modo Crise)',
      authorRole: 'Cuidador Principal',
      peakFlowAttempts: [],
      spo2: _entries.isNotEmpty ? _entries.first.spo2 : 95,
      symptoms: ['Crise de Falta de Ar / Resgate Aplicado'],
      medications: [
        MedicationUsage(
          name: rescueMedName,
          dosage: dosage,
          type: MedicationType.rescue,
        ),
      ],
      mouthRinseCompleted: false,
      notes: 'Dose de resgate de emergência aplicada via Modo Crise.',
    );

    _startReassessmentTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dose de resgate ($rescueMedName) registrada. Cronômetro de 20 min iniciado!'),
          backgroundColor: HCColors.greenMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadEmergencyData(targetId: _profile!.id);
    }
  }

  Future<void> _callSamu() async {
    final uri = Uri.parse('tel:192');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openHospitalGps(String hospital) async {
    final query = hospital.isNotEmpty ? hospital : 'Pronto Socorro Infantil mais proximo';
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF7F1D1D),
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

    final primaryRescueName = rescueMeds.isNotEmpty ? rescueMeds.first.commercialName : 'Aerolin Spray (Salbutamol 100mcg)';
    final primaryRescueDose = rescueMeds.isNotEmpty ? rescueMeds.first.dosage : '2 a 4 jatos com espaçador valvulado';

    return Scaffold(
      backgroundColor: const Color(0xFF7F1D1D), // Vermelho emergência profundo e contido
      appBar: AppBar(
        backgroundColor: const Color(0xFF450A0A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'MODO CRISE DE ASMA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            children: [
              // Seletor de Crianças Multi-filho
              if (_allProfiles.length > 1) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: HCRadii.radiusMd,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Criança em Crise:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _allProfiles.map((p) {
                              final isSel = p.id == _profile!.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    p.name.split(' ').first,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      color: isSel ? const Color(0xFF7F1D1D) : Colors.black87,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: Colors.white,
                                  backgroundColor: Colors.white70,
                                  onSelected: (sel) {
                                    if (sel) _switchEmergencyChild(p);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 1. Banner Principal de Identificação da Criança
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: HCRadii.radiusLg,
                  boxShadow: HCShadows.floating,
                ),
                child: Column(
                  children: [
                    Text(
                      _profile!.name.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_profile!.ageDisplay} • Peso Atual: ${_profile!.weightKg} kg • Recorde PFE: ${_profile!.personalBestPef} L/min',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (latest != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Última Medição: PFE ${latest.peakFlowBest} L/min • SpO2: ${latest.spo2}% (${DateFormat('HH:mm').format(latest.timestamp)})',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 2. Card de Resgate Imediato & Botão 1-Tap
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: HCRadii.radiusLg,
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medication, color: Color(0xFFB91C1C), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'PLANO DE RESGATE PRESCRIÇÃO MÉDICA',
                          style: TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      primaryRescueName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dose: $primaryRescueDose (sempre com espaçador valvulado)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                          elevation: 0,
                        ),
                        onPressed: () => _recordQuickRescueDose(primaryRescueName, primaryRescueDose),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Registrar Dose Aplicada Agora',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Temporizador de Reavaliação Pós-Resgate (20 minutos)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: HCRadii.radiusLg,
                  boxShadow: HCShadows.card,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined, color: Color(0xFF0F766E), size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Reavaliação Pós-Resgate (20 min)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F766E)),
                            ),
                          ],
                        ),
                        if (!_isTimerRunning)
                          TextButton(
                            onPressed: _startReassessmentTimer,
                            child: const Text('Iniciar Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_isTimerRunning) ...[
                      Text(
                        _formatTimer(_secondsRemaining),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: Color(0xFF0F766E),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (20 * 60 - _secondsRemaining) / (20 * 60),
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dose dada às ${DateFormat('HH:mm').format(_lastRescueTime ?? DateTime.now())}. Ao zerar, meça o sopro e observe o esforço respiratório.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ] else ...[
                      const Text(
                        'Recomenda-se aguardar 20 minutos após a bombinha de resgate para verificar se o sopro voltou para a Zona Verde ou se necessita ir ao Pronto-Socorro.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. Botões Rápidos de Ação: Ligar 192 & GPS Pronto-Socorro
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                          elevation: 0,
                        ),
                        onPressed: _callSamu,
                        icon: const Icon(Icons.phone, color: Color(0xFFDC2626), size: 20),
                        label: const Text(
                          'Ligar 192 (SAMU)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                          elevation: 0,
                        ),
                        onPressed: () => _openHospitalGps(_profile!.preferredHospital),
                        icon: const Icon(Icons.directions_car, color: Color(0xFF0F766E), size: 20),
                        label: const Text(
                          'GPS Pronto-Socorro',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Ficha Médica para o Plantonista do PS
              _buildEmergencyCard(
                title: 'ALERGIAS & ANTECEDENTES CRÍTICOS',
                icon: Icons.warning_amber_rounded,
                headerColor: const Color(0xFF991B1B),
                children: [
                  _buildRow(
                    'Alergias Medicamentosas:',
                    _profile!.drugAllergies.isNotEmpty ? _profile!.drugAllergies.join(', ') : 'NENHUMA RELATADA',
                    highlight: _profile!.drugAllergies.isNotEmpty,
                    isBold: true,
                  ),
                  _buildRow('Internação prévia em UTI:', _profile!.hadIcuAdmission ? 'SIM (${_profile!.icuAdmissionsCount} vez(es))' : 'Não'),
                  _buildRow('Intubação prévia por asma:', _profile!.intubatedPast ? 'SIM (Alto Risco)' : 'Não', highlight: _profile!.intubatedPast),
                  _buildRow('Tipo Sanguíneo:', _profile!.bloodType, isBold: true),
                  _buildRow('Cartão SUS:', _profile!.susCardNumber.isNotEmpty ? _profile!.susCardNumber : 'Não informado'),
                  _buildRow('Convênio:', '${_profile!.healthInsurance} (Carteira: ${_profile!.insuranceCardNumber})'),
                ],
              ),

              const SizedBox(height: 12),

              // 6. Telefones dos Responsáveis
              _buildEmergencyCard(
                title: 'CONTATOS DOS PAIS & MÉDICO',
                icon: Icons.contact_phone_outlined,
                children: [
                  _buildRow('Mãe:', '${_profile!.motherName} • ${_profile!.motherPhone}', isBold: true),
                  _buildRow('Pai:', '${_profile!.fatherName} • ${_profile!.fatherPhone}', isBold: true),
                  _buildRow('Médico Assistente:', '${_profile!.doctorName} • ${_profile!.doctorPhone}'),
                  _buildRow('Hospital Preferencial:', _profile!.preferredHospital),
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

