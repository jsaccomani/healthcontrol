import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/storage/health_storage_service.dart';

class PhysioScreen extends StatefulWidget {
  final String? patientId;
  const PhysioScreen({super.key, this.patientId});

  @override
  State<PhysioScreen> createState() => _PhysioScreenState();
}

class _PhysioScreenState extends State<PhysioScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  PatientProfile? _profile;
  bool _isLoading = true;

  final TextEditingController _spo2Ctrl = TextEditingController(text: '97');
  final TextEditingController _respRateCtrl = TextEditingController(text: '22');

  String _selectedDevice = 'Voldyne 2500 (Espirometria a Volume)';
  final List<String> _devices = [
    'Voldyne 2500 (Espirometria a Volume)',
    'Shaker / Acapella (OPEP - Higiene Brônquica)',
    'Respiron Infantil (Incentivo a Fluxo)',
    'POWERbreathe Medic (Treino Muscular TMI)',
    'EPAP / Pressão Positiva Expiratória',
  ];

  AmibSafetyResult? _safetyCheck;
  bool _isTimerRunning = false;
  int _timerSeconds = 0;
  Timer? _timer;
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _storageService.getPatientProfile(patientId: widget.patientId);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _isLoading = false;
    });
  }

  void _runSafetyScreening() {
    final spo2 = int.tryParse(_spo2Ctrl.text.trim());
    final fr = int.tryParse(_respRateCtrl.text.trim());

    if (spo2 == null || fr == null) {
      setState(() => _safetyCheck = const AmibSafetyResult(
        isClearedForTherapy: false,
        safetyViolations: ['Informe a SpO2 e a Frequência Respiratória reais para realizar a triagem de segurança.'],
      ));
      return;
    }

    final check = AmibSafetyScreener.screenVitals(
      spo2Percent: spo2,
      fio2Decimal: 0.21,
      peepCmH2O: 5,
      respiratoryRateRpm: fr,
      targetLevel: AmibMobilizationLevel.level3,
    );

    setState(() => _safetyCheck = check);
  }

  void _startTimer() {
    _runSafetyScreening();
    if (_safetyCheck?.isClearedForTherapy != true) return;

    setState(() {
      _isTimerRunning = true;
      _timerSeconds = 0;
      _breathCount = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _timerSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spo2Ctrl.dispose();
    _respRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: HCLoadingState(message: 'Carregando módulo de fisioterapia...')),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Fisioterapia & Reabilitação',
          style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identificação do Paciente Selecionado
              HCChildContextBadge(
                profile: _profile!,
                showSwitchAction: false,
              ),
              const SizedBox(height: 14),

              // Banner AMIB
              const HCInfoCard(
                title: 'Protocolo de Segurança AMIB',
                message: 'Critérios oficiais da Associação de Medicina Intensiva Brasileira para segurança de exercícios respiratórios.',
                icon: Icons.shield_outlined,
              ),

              const SizedBox(height: 16),

              // Triagem de Segurança Pré-Exercício
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: HCRadii.radiusLg,
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Sinais Vitais Pré-Fisioterapia:',
                      style: HCTypography.title.copyWith(fontSize: 13, color: theme.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _spo2Ctrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: theme.textPrimary),
                            decoration: const InputDecoration(labelText: 'SpO2 Atual (%)', hintText: 'ex: 97'),
                            onChanged: (_) => _runSafetyScreening(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _respRateCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: theme.textPrimary),
                            decoration: const InputDecoration(labelText: 'Freq. Resp. (irpm)', hintText: 'ex: 22'),
                            onChanged: (_) => _runSafetyScreening(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDevice,
                      dropdownColor: theme.surface,
                      decoration: const InputDecoration(labelText: 'Aparelho Utilizado:'),
                      items: _devices
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDevice = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    HCPrimaryButton(
                      label: 'Verificar Critérios de Segurança AMIB',
                      icon: Icons.verified_user_outlined,
                      width: double.infinity,
                      onPressed: _runSafetyScreening,
                    ),
                  ],
                ),
              ),

              if (_safetyCheck != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _safetyCheck!.isClearedForTherapy ? theme.successBg : theme.criticalBg,
                    borderRadius: HCRadii.radiusLg,
                    border: Border.all(
                      color: _safetyCheck!.isClearedForTherapy ? theme.successBorder : theme.criticalBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _safetyCheck!.isClearedForTherapy ? Icons.check_circle : Icons.warning,
                            color: _safetyCheck!.isClearedForTherapy ? theme.success : theme.critical,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _safetyCheck!.isClearedForTherapy ? 'LIBERADO PARA FISIOTERAPIA' : 'CONTRAINDICADO NO MOMENTO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _safetyCheck!.isClearedForTherapy ? theme.successText : theme.criticalText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _safetyCheck!.isClearedForTherapy
                            ? 'Todos os parâmetros estão dentro dos limites seguros da AMIB.'
                            : _safetyCheck!.safetyViolations.join(' • '),
                        style: TextStyle(fontSize: 12, color: theme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Cronômetro da Sessão
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: HCRadii.radiusLg,
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Cronômetro do Exercício Respiratório',
                      style: HCTypography.title.copyWith(fontSize: 13, color: theme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                      style: HCTypography.clinicalValueLarge.copyWith(fontSize: 36, color: theme.primary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTimerRunning ? theme.critical : theme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(_isTimerRunning ? 'Pausar' : 'Iniciar Exercício'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _breathCount++);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.border),
                            shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                          ),
                          icon: Icon(Icons.add, color: theme.textPrimary),
                          label: Text('Respiração ($_breathCount)', style: TextStyle(color: theme.textPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
