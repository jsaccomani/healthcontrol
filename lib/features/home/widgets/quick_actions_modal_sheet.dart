import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Modal Bottom Sheet de Ações Rápidas (Registro com Menor Carga Cognitiva).
class QuickActionsModalSheet extends StatefulWidget {
  final PatientProfile profile;
  final String? initialAction;
  final VoidCallback onEntrySaved;

  const QuickActionsModalSheet({
    super.key,
    required this.profile,
    this.initialAction,
    required this.onEntrySaved,
  });

  static Future<void> show({
    required BuildContext context,
    required PatientProfile profile,
    String? initialAction,
    required VoidCallback onEntrySaved,
  }) {
    final theme = context.hcTheme;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: QuickActionsModalSheet(
          profile: profile,
          initialAction: initialAction,
          onEntrySaved: onEntrySaved,
        ),
      ),
    );
  }

  @override
  State<QuickActionsModalSheet> createState() => _QuickActionsModalSheetState();
}

class _QuickActionsModalSheetState extends State<QuickActionsModalSheet> {
  final HealthStorageService _storageService = HealthStorageService();

  late String _currentView; // 'MENU', 'MEDICATION', 'PEAK_FLOW', 'SYMPTOMS', 'SPO2', 'NOTE'
  bool _isLoading = false;

  // Prescrições ativas
  List<PrescriptionRecord> _prescriptions = [];
  final List<MedicationUsage> _selectedMeds = [];
  bool _mouthRinseDone = true;

  // Peak Flow
  final TextEditingController _b1Ctrl = TextEditingController();
  final TextEditingController _b2Ctrl = TextEditingController();
  final TextEditingController _b3Ctrl = TextEditingController();
  int? _calcBest;
  int? _calcVariance;
  bool _hasVarianceAlert = false;

  // Sintomas
  final List<String> _selectedSymptoms = [];
  final List<String> _commonSymptoms = [
    'Sem sintomas aparentes',
    'Tosse seca',
    'Tosse com secreção',
    'Chiado / Ruído no peito',
    'Falta de ar / Cansaço',
    'Acordou à noite com tosse',
    'Dificuldade para falar frases longas',
    'Febre / Resfriado',
  ];

  // SpO2
  final TextEditingController _spo2Ctrl = TextEditingController(text: '98');

  // Observações
  final TextEditingController _noteCtrl = TextEditingController();

  // Autoria do registro
  late String _author;
  late List<String> _authors;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialAction ?? 'MENU';
    _initAuthors();
    _loadPrescriptions();
  }

  void _initAuthors() {
    final p = widget.profile;
    final List<String> authorsList = [];
    for (final g in p.legalGuardians) {
      if (g.fullName.isNotEmpty && !authorsList.contains(g.fullName)) {
        authorsList.add('${g.fullName} (${g.displayRelationship})');
      }
    }
    for (final c in p.caregivers) {
      if (c.fullName.isNotEmpty && !authorsList.contains(c.fullName)) {
        authorsList.add('${c.fullName} (${c.displayRelationship})');
      }
    }
    if (authorsList.isEmpty) {
      authorsList.addAll(['Mãe', 'Pai', 'Cuidador(a)', 'Babá', 'Escola']);
    }
    _authors = authorsList;
    _author = _authors.first;
  }

  Future<void> _loadPrescriptions() async {
    final list = await _storageService.getPrescriptions(widget.profile.id);
    if (!mounted) return;
    setState(() {
      _prescriptions = list;
    });
  }

  ActionZoneType? _calcZone;

  void _recalcPeakFlow() {
    final b1 = int.tryParse(_b1Ctrl.text.trim()) ?? 0;
    final b2 = int.tryParse(_b2Ctrl.text.trim()) ?? 0;
    final b3 = int.tryParse(_b3Ctrl.text.trim()) ?? 0;

    final attempts = [b1, b2, b3].where((v) => v > 0).toList();
    if (attempts.isEmpty) {
      setState(() {
        _calcBest = null;
        _calcVariance = null;
        _hasVarianceAlert = false;
        _calcZone = null;
      });
      return;
    }

    final best = attempts.reduce((a, b) => a > b ? a : b);
    final min = attempts.reduce((a, b) => a < b ? a : b);
    final variance = attempts.length > 1 ? best - min : 0;
    final alert = attempts.length > 1 && variance > 20;

    ActionZoneType? zone;
    if (widget.profile.personalBestPef > 0) {
      final evaluation = ActionZoneEvaluator.evaluate(currentPef: best, personalBestPef: widget.profile.personalBestPef);
      zone = evaluation.zone;
    } else {
      zone = null;
    }

    setState(() {
      _calcBest = best;
      _calcVariance = variance;
      _hasVarianceAlert = alert;
      _calcZone = zone;
    });
  }

  Future<void> _saveQuickEntry({
    List<MedicationUsage>? medications,
    bool mouthRinse = true,
    List<int>? peakFlowAttempts,
    List<String>? symptoms,
    int? spo2,
    String notes = '',
  }) async {
    setState(() => _isLoading = true);

    await _storageService.addHealthControlEntry(
      targetPatientId: widget.profile.id,
      authorName: _author,
      authorRole: _author == 'Mãe' || _author == 'Pai' ? 'Cuidador Principal' : 'Responsável',
      peakFlowAttempts: peakFlowAttempts ?? [],
      spo2: spo2,
      symptoms: symptoms != null && symptoms.isNotEmpty ? symptoms : ['Sem sintomas aparentes'],
      medications: medications ?? [],
      mouthRinseCompleted: mouthRinse,
      notes: notes,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onEntrySaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro de saúde salvo com sucesso!'),
          backgroundColor: HCColors.greenMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrasto
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Cabeçalho de Contexto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_currentView != 'MENU')
                        IconButton(
                          icon: Icon(Icons.arrow_back, size: 20, color: theme.textPrimary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _currentView = 'MENU'),
                        ),
                      if (_currentView != 'MENU') const SizedBox(width: 8),
                      Text(
                        _getTitleForView(),
                        style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Paciente: ${widget.profile.name}',
                style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Corpo Dinâmico conforme _currentView
              if (_currentView == 'MENU') _buildMenuView(),
              if (_currentView == 'MEDICATION') _buildMedicationView(),
              if (_currentView == 'PEAK_FLOW') _buildPeakFlowView(),
              if (_currentView == 'SYMPTOMS') _buildSymptomsView(),
              if (_currentView == 'SPO2') _buildSpo2View(),
              if (_currentView == 'NOTE') _buildNoteView(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleForView() {
    switch (_currentView) {
      case 'MEDICATION':
        return 'Registrar Medicação';
      case 'PEAK_FLOW':
        return 'Registrar Sopro (Peak Flow)';
      case 'SYMPTOMS':
        return 'Registrar Sintomas';
      case 'SPO2':
        return 'Registrar Saturação (SpO2)';
      case 'NOTE':
        return 'Adicionar Observação';
      default:
        return 'Registrar Ação Rápida';
    }
  }

  Widget _buildMenuView() {
    final theme = context.hcTheme;

    return Column(
      children: [
        _buildActionTile(
          icon: Icons.medication_outlined,
          color: theme.primary,
          bgColor: theme.primarySubtle,
          title: 'Medicação (Rotina ou Resgate)',
          subtitle: 'Checklist das bombinhas e remédios prescritos',
          onTap: () => setState(() => _currentView = 'MEDICATION'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.air,
          color: theme.info,
          bgColor: theme.infoBg,
          title: 'Pico de Fluxo (Peak Flow)',
          subtitle: 'Registro dos 3 sopros e cálculo de variabilidade',
          onTap: () => setState(() => _currentView = 'PEAK_FLOW'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.sick_outlined,
          color: theme.warning,
          bgColor: theme.warningBg,
          title: 'Sintomas e Chiado no Peito',
          subtitle: 'Tosse, cansaço, ruídos respiratórios ou indisposição',
          onTap: () => setState(() => _currentView = 'SYMPTOMS'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.monitor_heart_outlined,
          color: theme.success,
          bgColor: theme.successBg,
          title: 'Saturação de Oxigênio (SpO2)',
          subtitle: 'Leitura rápida do oxímetro de pulso',
          onTap: () => setState(() => _currentView = 'SPO2'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.edit_note,
          color: theme.textSecondary,
          bgColor: theme.elevatedSurface,
          title: 'Observação Livre',
          subtitle: 'Anotar recados da escola, clima ou rotina',
          onTap: () => setState(() => _currentView = 'NOTE'),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = context.hcTheme;

    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusMd,
        side: BorderSide(color: theme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: HCRadii.radiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: HCRadii.radiusMd,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-View: Medicação ---
  Widget _buildMedicationView() {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione os medicamentos administrados agora:',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 12),
        if (_prescriptions.isEmpty || _prescriptions.expand((p) => p.medications).isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.elevatedSurface,
              borderRadius: HCRadii.radiusMd,
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nenhuma receita cadastrada ainda. Você pode registrar uma medicação livre ou escanear uma receita.',
                    style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else
          ..._prescriptions.expand((p) => p.medications).map((med) {
            final isSel = _selectedMeds.any((m) => m.name == med.commercialName);
            final isRescue = med.category == MedicationCategory.rescueInhaled;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSel ? theme.primarySubtle : theme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: HCRadii.radiusMd,
                  side: BorderSide(
                    color: isSel ? theme.primary : theme.border,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isSel,
                  activeColor: theme.primary,
                  title: Text(
                    med.commercialName,
                    style: HCTypography.title.copyWith(fontSize: 13, color: theme.textPrimary),
                  ),
                  subtitle: Text(
                    '${isRescue ? "Resgate" : "Manutenção"} • Dose: ${med.dosage}',
                    style: HCTypography.bodySmall.copyWith(
                      color: isRescue ? theme.warningText : theme.textSecondary,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedMeds.add(
                          MedicationUsage(
                            name: med.commercialName,
                            dosage: med.dosage,
                            type: isRescue ? MedicationType.rescue : MedicationType.maintenance,
                          ),
                        );
                      } else {
                        _selectedMeds.removeWhere((m) => m.name == med.commercialName);
                      }
                    });
                  },
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.elevatedSurface,
            borderRadius: HCRadii.radiusMd,
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _mouthRinseDone,
                activeColor: theme.primary,
                onChanged: (v) => setState(() => _mouthRinseDone = v ?? true),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bochecho com água ou escovação realizada',
                      style: HCTypography.labelBold.copyWith(fontSize: 12, color: theme.textPrimary),
                    ),
                    Text(
                      'Prevenção de sapinho e rouquidão pós-corticoide',
                      style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Registro de Medicação',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: _selectedMeds.isEmpty
              ? null
              : () => _saveQuickEntry(
                    medications: _selectedMeds,
                    mouthRinse: _mouthRinseDone,
                  ),
        ),
      ],
    );
  }

  // --- Sub-View: Peak Flow ---
  Widget _buildPeakFlowView() {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registre os 3 sopros consecutivos no aparelho de Peak Flow:',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _b1Ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: '1º Sopro', hintText: 'L/min'),
                onChanged: (_) => _recalcPeakFlow(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _b2Ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: '2º Sopro', hintText: 'L/min'),
                onChanged: (_) => _recalcPeakFlow(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _b3Ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: '3º Sopro', hintText: 'L/min'),
                onChanged: (_) => _recalcPeakFlow(),
              ),
            ),
          ],
        ),
        if (_calcBest != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _calcZone == ActionZoneType.red
                  ? theme.criticalBg
                  : (_calcZone == ActionZoneType.yellow || _hasVarianceAlert
                      ? theme.warningBg
                      : (_calcZone == ActionZoneType.green ? theme.successBg : theme.elevatedSurface)),
              borderRadius: HCRadii.radiusMd,
              border: Border.all(
                color: _calcZone == ActionZoneType.red
                    ? theme.criticalBorder
                    : (_calcZone == ActionZoneType.yellow || _hasVarianceAlert
                        ? theme.warningBorder
                        : (_calcZone == ActionZoneType.green ? theme.successBorder : theme.border)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _calcZone == ActionZoneType.red
                      ? Icons.emergency
                      : (_hasVarianceAlert || _calcZone == ActionZoneType.yellow
                          ? Icons.warning_amber_rounded
                          : (_calcZone == ActionZoneType.green ? Icons.check_circle_outline : Icons.info_outline)),
                  color: _calcZone == ActionZoneType.red
                      ? theme.critical
                      : (_hasVarianceAlert || _calcZone == ActionZoneType.yellow
                          ? theme.warning
                          : (_calcZone == ActionZoneType.green ? theme.success : theme.textSecondary)),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Melhor Sopro: $_calcBest L/min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _calcZone == ActionZoneType.red
                                  ? theme.criticalText
                                  : (_hasVarianceAlert || _calcZone == ActionZoneType.yellow
                                      ? theme.warningText
                                      : (_calcZone == ActionZoneType.green ? theme.successText : theme.textPrimary)),
                            ),
                          ),
                          if (_calcZone != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _calcZone == ActionZoneType.red
                                    ? HCColors.redMain
                                    : (_calcZone == ActionZoneType.yellow ? HCColors.yellowMain : HCColors.greenMain),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _calcZone == ActionZoneType.green
                                    ? 'ZONA VERDE'
                                    : (_calcZone == ActionZoneType.yellow ? 'ZONA AMARELA' : 'ZONA VERMELHA'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _calcZone == null
                            ? (_hasVarianceAlert
                                ? 'Variação de $_calcVariance L/min entre sopros (> 20 L/min). Sem PFE de referência cadastrado — não é possível calcular a zona. Cadastre o melhor PFE pessoal no perfil para habilitar esta avaliação.'
                                : 'Sem PFE de referência cadastrado — não é possível calcular a zona. Cadastre o melhor PFE pessoal no perfil para habilitar esta avaliação.')
                            : (_hasVarianceAlert
                                ? 'Variação de $_calcVariance L/min entre sopros (> 20 L/min). Verifique a vedação da boca e repita se necessário.'
                                : 'Técnica consistente (variância: $_calcVariance L/min). Siga o plano de ação médica correspondente.'),
                        style: TextStyle(fontSize: 11, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Registro de Peak Flow',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: _calcBest == null
              ? null
              : () {
                  final list = [
                    int.tryParse(_b1Ctrl.text.trim()) ?? 0,
                    int.tryParse(_b2Ctrl.text.trim()) ?? 0,
                    int.tryParse(_b3Ctrl.text.trim()) ?? 0,
                  ].where((v) => v > 0).toList();
                  _saveQuickEntry(peakFlowAttempts: list);
                },
        ),
      ],
    );
  }

  // --- Sub-View: Sintomas ---
  Widget _buildSymptomsView() {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione os sintomas observados na criança hoje:',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSymptoms.map((symptom) {
            final isSel = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(
                symptom,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? theme.primary : theme.textPrimary,
                ),
              ),
              selected: isSel,
              selectedColor: theme.primarySubtle,
              backgroundColor: theme.elevatedSurface,
              side: BorderSide(color: isSel ? theme.primary : theme.border),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (symptom == 'Sem sintomas aparentes') {
                      _selectedSymptoms.clear();
                    } else {
                      _selectedSymptoms.remove('Sem sintomas aparentes');
                    }
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Registro de Sintomas',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: _selectedSymptoms.isEmpty
              ? null
              : () => _saveQuickEntry(symptoms: _selectedSymptoms),
        ),
      ],
    );
  }

  // --- Sub-View: SpO2 ---
  Widget _buildSpo2View() {
    final theme = context.hcTheme;
    final val = int.tryParse(_spo2Ctrl.text.trim());
    final isCritical = val != null && val < 92;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informe a Saturação de Oxigênio (SpO2) medida no oxímetro:',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _spo2Ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: theme.textPrimary,
          ),
          decoration: const InputDecoration(
            labelText: 'Saturação de Oxigênio (%)',
            suffixText: '%',
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (val != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCritical ? theme.criticalBg : theme.successBg,
              borderRadius: HCRadii.radiusMd,
              border: Border.all(color: isCritical ? theme.criticalBorder : theme.successBorder),
            ),
            child: Row(
              children: [
                Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: isCritical ? theme.critical : theme.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCritical
                        ? 'Atenção: Saturação abaixo de 92% indica hipoxemia. Avalie resgate ou atendimento de emergência.'
                        : 'Saturação adequada (≥ 95%).',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCritical ? theme.criticalText : theme.successText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Saturação de Oxigênio',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: val == null ? null : () => _saveQuickEntry(spo2: val),
        ),
      ],
    );
  }

  // --- Sub-View: Observação ---
  Widget _buildNoteView() {
    final theme = context.hcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escreva qualquer relato relevante sobre a saúde do seu filho hoje:',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          maxLines: 4,
          style: TextStyle(color: theme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Ex: Teve contato com fumaça na casa da avó. Não tossiu durante a noite.',
          ),
        ),
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Observação',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: () => _saveQuickEntry(notes: _noteCtrl.text.trim()),
        ),
      ],
    );
  }

  Widget _buildAuthorSelector() {
    final theme = context.hcTheme;

    return Row(
      children: [
        Text(
          'Quem está anotando:',
          style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _author,
            isDense: true,
            dropdownColor: theme.surface,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _authors
                .map((a) => DropdownMenuItem(
                      value: a,
                      child: Text(a, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _author = v);
            },
          ),
        ),
      ],
    );
  }
}
