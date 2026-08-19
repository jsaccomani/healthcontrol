import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';

import '../../../core/storage/health_storage_service.dart';

class CactQuizScreen extends StatefulWidget {
  final String? patientId;
  const CactQuizScreen({super.key, this.patientId});

  @override
  State<CactQuizScreen> createState() => _CactQuizScreenState();
}

class _CactQuizScreenState extends State<CactQuizScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  PatientProfile? _profile;
  bool _isLoading = true;

  // Respostas da Criança (4 perguntas, 0 a 3)
  int _q1 = 3;
  int _q2 = 2;
  int _q3 = 3;
  int _q4 = 2;

  // Respostas dos Pais (3 perguntas, 0 a 5)
  int _q5 = 4;
  int _q6 = 4;
  int _q7 = 4;

  CactScoreResult? _result;

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

  void _calculateScore() {
    final res = CactCalculator.calculate(
      childResponses: [_q1, _q2, _q3, _q4],
      parentResponses: [_q5, _q6, _q7],
    );
    setState(() => _result = res);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Controle (c-ACT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Identificação da Criança Avaliada
            HCChildContextBadge(
              profile: _profile!,
              showSwitchAction: false,
            ),
            const SizedBox(height: 14),

            // Banner Explicativo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Questionário oficial para crianças de 4 a 11 anos. Responda com seu filho para avaliar o controle mensal da asma.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF3730A3)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Parte 1: Para a Criança Responder
            const Text(
              'Parte 1: Para a Criança Responder (Percepção do Paciente)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),

            _buildChildQuestion(
              title: '1. Como você sente sua asma hoje?',
              options: ['Muito ruim (0 pts)', 'Ruim (1 pt)', 'Boa (2 pts)', 'Muito boa (3 pts)'],
              currentValue: _q1,
              onChanged: (v) => setState(() => _q1 = v),
            ),

            _buildChildQuestion(
              title: '2. Sua asma atrapalha você de correr ou brincar?',
              options: ['Atrapalha muito (0 pts)', 'Às vezes atrapalha (1 pt)', 'Atrapalha pouco (2 pts)', 'Não atrapalha nada (3 pts)'],
              currentValue: _q2,
              onChanged: (v) => setState(() => _q2 = v),
            ),

            _buildChildQuestion(
              title: '3. Você tosse por causa da sua asma?',
              options: ['Tosso muito (0 pts)', 'Tosso às vezes (1 pt)', 'Tosso pouco (2 pts)', 'Não tosso nunca (3 pts)'],
              currentValue: _q3,
              onChanged: (v) => setState(() => _q3 = v),
            ),

            _buildChildQuestion(
              title: '4. Você acorda à noite tossindo ou chiando?',
              options: ['Muitas noites (0 pts)', 'Algumas noites (1 pt)', 'Raramente (2 pts)', 'Nunca acordo (3 pts)'],
              currentValue: _q4,
              onChanged: (v) => setState(() => _q4 = v),
            ),

            const SizedBox(height: 14),

            // Parte 2: Para os Pais Responderem
            const Text(
              'Parte 2: Para os Pais Responderem (Últimas 4 semanas)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),

            _buildParentQuestion(
              title: '5. Nos últimos 28 dias, em quantos dias a criança teve sintomas de asma durante o dia?',
              options: ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
              currentValue: _q5,
              onChanged: (v) => setState(() => _q5 = v),
            ),

            _buildParentQuestion(
              title: '6. Quantos dias a criança chiou o peito durante o dia?',
              options: ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
              currentValue: _q6,
              onChanged: (v) => setState(() => _q6 = v),
            ),

            _buildParentQuestion(
              title: '7. Quantos dias a criança acordou durante a noite por causa da asma?',
              options: ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
              currentValue: _q7,
              onChanged: (v) => setState(() => _q7 = v),
            ),

            const SizedBox(height: 16),

            // Botão Calcular Escore
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateScore,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                child: const Text('Calcular Escore c-ACT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.isControlled ? AppTheme.zoneGreenBg : AppTheme.zoneYellowBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _result!.isControlled ? AppTheme.zoneGreen : AppTheme.zoneYellow,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Escore Total: ${_result!.totalScore} / 27',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _result!.isControlled ? AppTheme.zoneGreen : const Color(0xFF92400E),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _result!.isControlled ? AppTheme.zoneGreen : AppTheme.zoneYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _result!.isControlled ? 'Asma Controlada' : 'Asma Não Controlada',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!.clinicalRecommendation,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildChildQuestion({
    required String title,
    required List<String> options,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(options.length, (idx) {
                final isSel = currentValue == idx;
                return ChoiceChip(
                  label: Text(options[idx], style: const TextStyle(fontSize: 11)),
                  selected: isSel,
                  selectedColor: const Color(0xFFC7D2FE),
                  onSelected: (sel) {
                    if (sel) onChanged(idx);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentQuestion({
    required String title,
    required List<String> options,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(options.length, (idx) {
                final isSel = currentValue == idx;
                return ChoiceChip(
                  label: Text(options[idx], style: const TextStyle(fontSize: 11)),
                  selected: isSel,
                  selectedColor: const Color(0xFFC7D2FE),
                  onSelected: (sel) {
                    if (sel) onChanged(idx);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
