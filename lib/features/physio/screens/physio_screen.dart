import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';

class PhysioScreen extends StatefulWidget {
  const PhysioScreen({super.key});

  @override
  State<PhysioScreen> createState() => _PhysioScreenState();
}

class _PhysioScreenState extends State<PhysioScreen> {
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

  void _runSafetyScreening() {
    final spo2 = int.tryParse(_spo2Ctrl.text.trim()) ?? 97;
    final fr = int.tryParse(_respRateCtrl.text.trim()) ?? 22;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fisioterapia & Reabilitação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner AMIB
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HCColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HCColors.primary200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.primaryTeal, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Protocolo com Travas de Segurança da AMIB (Associação de Medicina Intensiva Brasileira).',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Triagem de Segurança Pré-Exercício
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Sinais Vitais Pré-Fisioterapia:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _spo2Ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'SpO2 Atual (%)', hintText: 'ex: 97'),
                            onChanged: (_) => _runSafetyScreening(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _respRateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Freq. Resp. (irpm)', hintText: 'ex: 22'),
                            onChanged: (_) => _runSafetyScreening(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDevice,
                      decoration: const InputDecoration(labelText: 'Aparelho Utilizado:'),
                      items: _devices.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDevice = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _runSafetyScreening,
                      child: const Text('Verificar Critérios de Segurança AMIB'),
                    ),
                  ],
                ),
              ),

              if (_safetyCheck != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _safetyCheck!.isClearedForTherapy ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _safetyCheck!.isClearedForTherapy ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _safetyCheck!.isClearedForTherapy ? Icons.check_circle : Icons.warning,
                            color: _safetyCheck!.isClearedForTherapy ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _safetyCheck!.isClearedForTherapy ? 'LIBERADO PARA FISIOTERAPIA' : 'CONTRAINDICADO NO MOMENTO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _safetyCheck!.isClearedForTherapy ? const Color(0xFF065F46) : const Color(0xFF991B1B),
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
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Text('Cronômetro do Exercício Respiratório', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Text(
                      '${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTimerRunning ? const Color(0xFFEF4444) : AppTheme.primaryTeal,
                          ),
                          icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(_isTimerRunning ? 'Pausar' : 'Iniciar Exercício'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _breathCount++);
                          },
                          icon: const Icon(Icons.add),
                          label: Text('Respiração ($_breathCount)'),
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
