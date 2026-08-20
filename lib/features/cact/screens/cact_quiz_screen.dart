import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
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
    final theme = context.hcTheme;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: HCLoadingState(message: 'Carregando questionário c-ACT...')),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Teste de Controle (c-ACT)',
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
              // Identificação da Criança Avaliada
              HCChildContextBadge(
                profile: _profile!,
                showSwitchAction: false,
              ),
              const SizedBox(height: 14),

              // Banner Explicativo
              const HCInfoCard(
                title: 'Questionário Validado c-ACT (GINA / SBPT)',
                message: 'Para crianças de 4 a 11 anos. Responda junto com seu filho para avaliar o controle clínico mensal da asma.',
                icon: Icons.assignment_outlined,
              ),

              const SizedBox(height: 16),

              // Parte 1: Para a Criança Responder
              Text(
                'Parte 1: Para a Criança Responder (Percepção do Paciente)',
                style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
              ),
              const SizedBox(height: 8),

              _buildChildQuestion(
                title: '1. Como você sente sua asma hoje?',
                options: const ['Muito ruim (0 pts)', 'Ruim (1 pt)', 'Boa (2 pts)', 'Muito boa (3 pts)'],
                currentValue: _q1,
                onChanged: (v) => setState(() => _q1 = v),
              ),

              _buildChildQuestion(
                title: '2. Sua asma atrapalha você de correr ou brincar?',
                options: const ['Atrapalha muito (0 pts)', 'Às vezes atrapalha (1 pt)', 'Atrapalha pouco (2 pts)', 'Não atrapalha nada (3 pts)'],
                currentValue: _q2,
                onChanged: (v) => setState(() => _q2 = v),
              ),

              _buildChildQuestion(
                title: '3. Você tosse por causa da sua asma?',
                options: const ['Tosso muito (0 pts)', 'Tosso às vezes (1 pt)', 'Tosso pouco (2 pts)', 'Não tosso nunca (3 pts)'],
                currentValue: _q3,
                onChanged: (v) => setState(() => _q3 = v),
              ),

              _buildChildQuestion(
                title: '4. Você acorda à noite tossindo ou chiando?',
                options: const ['Muitas noites (0 pts)', 'Algumas noites (1 pt)', 'Raramente (2 pts)', 'Nunca acordo (3 pts)'],
                currentValue: _q4,
                onChanged: (v) => setState(() => _q4 = v),
              ),

              const SizedBox(height: 14),

              // Parte 2: Para os Pais Responderem
              Text(
                'Parte 2: Para os Pais Responderem (Últimas 4 semanas)',
                style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
              ),
              const SizedBox(height: 8),

              _buildParentQuestion(
                title: '5. Nos últimos 28 dias, em quantos dias a criança teve sintomas de asma durante o dia?',
                options: const ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
                currentValue: _q5,
                onChanged: (v) => setState(() => _q5 = v),
              ),

              _buildParentQuestion(
                title: '6. Quantos dias a criança chiou o peito durante o dia?',
                options: const ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
                currentValue: _q6,
                onChanged: (v) => setState(() => _q6 = v),
              ),

              _buildParentQuestion(
                title: '7. Quantos dias a criança acordou durante a noite por causa da asma?',
                options: const ['Todos os dias (0)', '3 a 4 dias/sem (1)', '1 a 2 dias/sem (2)', 'Menos de 1 dia/sem (3)', 'Nenhum dia (4)'],
                currentValue: _q7,
                onChanged: (v) => setState(() => _q7 = v),
              ),

              const SizedBox(height: 16),

              // Botão Calcular Escore
              HCPrimaryButton(
                label: 'Calcular Escore c-ACT',
                icon: Icons.calculate_outlined,
                width: double.infinity,
                onPressed: _calculateScore,
              ),

              if (_result != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _result!.isControlled ? theme.successBg : theme.warningBg,
                    borderRadius: HCRadii.radiusLg,
                    border: Border.all(
                      color: _result!.isControlled ? theme.successBorder : theme.warningBorder,
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
                              color: _result!.isControlled ? theme.successText : theme.warningText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _result!.isControlled ? theme.success : theme.warning,
                              borderRadius: HCRadii.radiusSm,
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
                        style: TextStyle(fontSize: 13, color: theme.textPrimary),
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
    final theme = context.hcTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HCTypography.title.copyWith(fontSize: 13, color: theme.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(options.length, (idx) {
              final isSel = currentValue == idx;
              return ChoiceChip(
                label: Text(
                  options[idx],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSel ? theme.primary : theme.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSel,
                selectedColor: theme.primarySubtle,
                backgroundColor: theme.elevatedSurface,
                side: BorderSide(color: isSel ? theme.primary : theme.border),
                onSelected: (sel) {
                  if (sel) onChanged(idx);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildParentQuestion({
    required String title,
    required List<String> options,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    final theme = context.hcTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HCTypography.title.copyWith(fontSize: 13, color: theme.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(options.length, (idx) {
              final isSel = currentValue == idx;
              return ChoiceChip(
                label: Text(
                  options[idx],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSel ? theme.primary : theme.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSel,
                selectedColor: theme.primarySubtle,
                backgroundColor: theme.elevatedSurface,
                side: BorderSide(color: isSel ? theme.primary : theme.border),
                onSelected: (sel) {
                  if (sel) onChanged(idx);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
