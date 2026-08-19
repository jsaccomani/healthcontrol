import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Bottom Sheet Modular de Ações Rápidas (< 10 segundos).
/// Permite ao cuidador registrar medicações, sopro, sintomas ou saturação sem fricção.
class HCQuickActionsModalSheet extends StatefulWidget {
  final PatientProfile profile;
  final VoidCallback onEntrySaved;
  final String initialView;

  const HCQuickActionsModalSheet({
    super.key,
    required this.profile,
    required this.onEntrySaved,
    this.initialView = 'MENU',
  });

  static Future<void> show({
    required BuildContext context,
    required PatientProfile profile,
    required VoidCallback onEntrySaved,
    String initialView = 'MENU',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => HCQuickActionsModalSheet(
        profile: profile,
        onEntrySaved: onEntrySaved,
        initialView: initialView,
      ),
    );
  }

  @override
  State<HCQuickActionsModalSheet> createState() => _HCQuickActionsModalSheetState();
}

class _HCQuickActionsModalSheetState extends State<HCQuickActionsModalSheet> {
  final HealthStorageService _storageService = HealthStorageService();

  late String _currentView;
  bool _isLoading = false;

  // Medicações
  List<PrescribedMedication> _prescriptions = [];
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
    'Tosse seca leve',
    'Tosse carregada',
    'Chiado no peito (sibilo)',
    'Cansaço aos esforços',
    'Falta de ar ao deitar',
    'Respiração acelerada',
  ];

  // SpO2
  final TextEditingController _spo2Ctrl = TextEditingController(text: '98');

  // Observações
  final TextEditingController _noteCtrl = TextEditingController();
  String _author = 'Mãe';
  final List<String> _authors = ['Mãe', 'Pai', 'Avó / Avô', 'Babá / Cuidador', 'Próprio Paciente'];

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _b1Ctrl.dispose();
    _b2Ctrl.dispose();
    _b3Ctrl.dispose();
    _spo2Ctrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    final list = await _storageService.getPrescriptions(widget.profile.id);
    final List<PrescribedMedication> all = [];
    for (final p in list) {
      all.addAll(p.medications);
    }
    if (all.isEmpty) {
      all.addAll([
        const PrescribedMedication(
          id: 'def_1',
          commercialName: 'Clenil HFA 250mcg Spray',
          activeIngredient: 'Beclometasona',
          category: MedicationCategory.maintenanceInhaled,
          dosage: '1 jato',
          frequency: '12/12h',
        ),
        const PrescribedMedication(
          id: 'def_2',
          commercialName: 'Aerolin Spray 100mcg',
          activeIngredient: 'Salbutamol',
          category: MedicationCategory.rescueInhaled,
          dosage: '2 jatos',
          frequency: 'Resgate',
        ),
      ]);
    }
    if (mounted) {
      setState(() => _prescriptions = all);
    }
  }

  void _recalcPeakFlow() {
    final v1 = int.tryParse(_b1Ctrl.text.trim());
    final v2 = int.tryParse(_b2Ctrl.text.trim());
    final v3 = int.tryParse(_b3Ctrl.text.trim());
    final list = [if (v1 != null) v1, if (v2 != null) v2, if (v3 != null) v3];

    if (list.isEmpty) {
      setState(() {
        _calcBest = null;
        _calcVariance = null;
        _hasVarianceAlert = false;
      });
      return;
    }

    final maxVal = list.reduce((a, b) => a > b ? a : b);
    final minVal = list.reduce((a, b) => a < b ? a : b);
    final variance = maxVal - minVal;

    setState(() {
      _calcBest = maxVal;
      _calcVariance = variance;
      _hasVarianceAlert = list.length >= 2 && variance > 20;
    });
  }

  Future<void> _saveQuickEntry({
    List<int> peakFlowAttempts = const [],
    int? spo2,
    List<String> symptoms = const [],
    List<MedicationUsage> medications = const [],
    bool mouthRinse = true,
    String notes = '',
  }) async {
    setState(() => _isLoading = true);

    await _storageService.addHealthControlEntry(
      targetPatientId: widget.profile.id,
      authorName: _author,
      authorRole: 'Cuidador Principal',
      peakFlowAttempts: peakFlowAttempts,
      spo2: spo2 ?? 98,
      symptoms: symptoms.isNotEmpty ? symptoms : ['Sem sintomas aparentes'],
      medications: medications,
      mouthRinseCompleted: mouthRinse,
      notes: notes,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onEntrySaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro salvo com sucesso!'),
          backgroundColor: HCColors.greenMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    color: HCColors.neutral300,
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
                          icon: const Icon(Icons.arrow_back, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _currentView = 'MENU'),
                        ),
                      if (_currentView != 'MENU') const SizedBox(width: 8),
                      Text(
                        _getTitleForView(),
                        style: HCTypography.heading.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: HCColors.neutral400),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Paciente: ${widget.profile.name}',
                style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
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
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.medication_outlined,
          color: HCColors.primary600,
          bgColor: HCColors.primary50,
          title: 'Medicação (Rotina ou Resgate)',
          subtitle: 'Checklist das bombinhas e remédios prescritos',
          onTap: () => setState(() => _currentView = 'MEDICATION'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.air,
          color: HCColors.blueMain,
          bgColor: HCColors.blueLight,
          title: 'Pico de Fluxo (Peak Flow)',
          subtitle: 'Registro dos 3 sopros e cálculo de variabilidade',
          onTap: () => setState(() => _currentView = 'PEAK_FLOW'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.sick_outlined,
          color: HCColors.yellowMain,
          bgColor: HCColors.yellowLight,
          title: 'Sintomas e Chiado no Peito',
          subtitle: 'Tosse, cansaço, ruídos respiratórios ou indisposição',
          onTap: () => setState(() => _currentView = 'SYMPTOMS'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.monitor_heart_outlined,
          color: HCColors.greenMain,
          bgColor: HCColors.greenLight,
          title: 'Saturação de Oxigênio (SpO2)',
          subtitle: 'Leitura rápida do oxímetro de pulso',
          onTap: () => setState(() => _currentView = 'SPO2'),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.edit_note,
          color: HCColors.neutral700,
          bgColor: HCColors.neutral100,
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
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusMd,
        side: const BorderSide(color: HCColors.neutral200),
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
                      style: HCTypography.subHeading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: HCColors.neutral400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-View: Medicação ---
  Widget _buildMedicationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione os medicamentos administrados agora:',
          style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
        ),
        const SizedBox(height: 12),
        ..._prescriptions.map((med) {
          final isSel = _selectedMeds.any((m) => m.name == med.commercialName);
          final isRescue = med.category == MedicationCategory.rescueInhaled;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isSel ? HCColors.primary50 : Colors.white,
              borderRadius: HCRadii.radiusMd,
              shape: RoundedRectangleBorder(
                borderRadius: HCRadii.radiusMd,
                side: BorderSide(
                  color: isSel ? HCColors.primary500 : HCColors.neutral200,
                  width: isSel ? 1.5 : 1,
                ),
              ),
              child: CheckboxListTile(
              value: isSel,
              activeColor: HCColors.primary500,
              title: Text(
                med.commercialName,
                style: HCTypography.subHeading.copyWith(fontSize: 13),
              ),
              subtitle: Text(
                '${isRescue ? "Resgate" : "Manutenção"} • Dose: ${med.dosage}',
                style: HCTypography.bodySmall.copyWith(
                  color: isRescue ? HCColors.yellowText : HCColors.neutral600,
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
            color: HCColors.neutral50,
            borderRadius: HCRadii.radiusMd,
            border: Border.all(color: HCColors.neutral200),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _mouthRinseDone,
                activeColor: HCColors.primary500,
                onChanged: (v) => setState(() => _mouthRinseDone = v ?? true),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bochecho com água ou escovação realizada',
                      style: HCTypography.labelBold.copyWith(fontSize: 12),
                    ),
                    Text(
                      'Prevenção de sapinho e rouquidão pós-corticoide',
                      style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registre os 3 sopros consecutivos no aparelho de Peak Flow:',
          style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
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
              color: _hasVarianceAlert ? HCColors.yellowLight : HCColors.greenLight,
              borderRadius: HCRadii.radiusMd,
              border: Border.all(
                color: _hasVarianceAlert ? HCColors.yellowBorder : HCColors.greenBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _hasVarianceAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: _hasVarianceAlert ? HCColors.yellowMain : HCColors.greenMain,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Melhor Sopro: $_calcBest L/min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _hasVarianceAlert ? HCColors.yellowText : HCColors.greenText,
                        ),
                      ),
                      Text(
                        _hasVarianceAlert
                            ? 'Variação de $_calcVariance L/min entre sopros (> 20 L/min). Verifique a vedação da boca.'
                            : 'Técnica consistente (variância: $_calcVariance L/min).',
                        style: const TextStyle(fontSize: 11, color: HCColors.neutral700),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione os sintomas observados na criança hoje:',
          style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSymptoms.map((symptom) {
            final isSel = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
              selected: isSel,
              selectedColor: HCColors.primary100,
              backgroundColor: HCColors.neutral100,
              side: BorderSide(color: isSel ? HCColors.primary500 : HCColors.neutral200),
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
    final val = int.tryParse(_spo2Ctrl.text.trim()) ?? 98;
    final isCritical = val < 92;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informe a Saturação de Oxigênio (SpO2) medida no oxímetro:',
          style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _spo2Ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
          decoration: const InputDecoration(
            labelText: 'Saturação de Oxigênio (%)',
            suffixText: '%',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCritical ? HCColors.redLight : HCColors.greenLight,
            borderRadius: HCRadii.radiusMd,
            border: Border.all(color: isCritical ? HCColors.redBorder : HCColors.greenBorder),
          ),
          child: Row(
            children: [
              Icon(
                isCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isCritical ? HCColors.redMain : HCColors.greenMain,
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
                    color: isCritical ? HCColors.redText : HCColors.greenText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAuthorSelector(),
        const SizedBox(height: 16),
        HCPrimaryButton(
          label: _isLoading ? 'Salvando...' : 'Salvar Saturação de Oxigênio',
          icon: Icons.check,
          isLoading: _isLoading,
          width: double.infinity,
          onPressed: () => _saveQuickEntry(spo2: val),
        ),
      ],
    );
  }

  // --- Sub-View: Observação ---
  Widget _buildNoteView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escreva qualquer relato relevante sobre a saúde do seu filho hoje:',
          style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          maxLines: 4,
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
    return Row(
      children: [
        Text(
          'Quem está anotando:',
          style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _author,
            isDense: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _authors
                .map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 12))))
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
