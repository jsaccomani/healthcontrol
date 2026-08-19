import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';
import '../widgets/procedure_chip_selector.dart';
import '../widgets/prescribed_meds_checklist.dart';
import '../widgets/peak_flow_input_card.dart';
import '../widgets/oximeter_input_card.dart';
import '../widgets/physio_input_card.dart';
import '../widgets/symptoms_selector_card.dart';
import '../widgets/author_and_notes_card.dart';

class NewEntryScreen extends StatefulWidget {
  final String? patientId;
  const NewEntryScreen({super.key, this.patientId});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final HealthStorageService _storageService = HealthStorageService();

  List<PatientProfile> _allProfiles = [];
  PatientProfile? _profile;
  List<PrescribedMedication> _childPrescribedMeds = [];
  bool _isLoading = true;

  String _author = 'Mãe';
  final List<String> _availableAuthors = ['Mãe', 'Pai', 'Avó / Avô', 'Babá / Cuidador', 'Próprio Paciente'];

  // Chaves Modulares
  bool _includeMedication = true;
  bool _includePeakFlow = false;
  bool _includeSpo2 = false;
  bool _includePhysioCpap = false;
  bool _includeSymptoms = false;
  bool _includeNotes = false;

  // Controladores
  final TextEditingController _blow1Ctrl = TextEditingController();
  final TextEditingController _blow2Ctrl = TextEditingController();
  final TextEditingController _blow3Ctrl = TextEditingController();
  final TextEditingController _spo2Ctrl = TextEditingController(text: '98');
  final TextEditingController _notesCtrl = TextEditingController();

  // Fisioterapia / CPAP
  String _selectedPhysioDevice = 'Voldyne 2500 (Espirometria)';
  final TextEditingController _physioDurationCtrl = TextEditingController(text: '10');
  final List<String> _physioDevices = [
    'Voldyne 2500 (Espirometria)',
    'Shaker / Respibar (Oscilação Oral)',
    'CPAP Pediátrico (Pressão Positiva)',
    'Inalação com Soro / Berotec',
    'Máscara PEP / Flutter',
    'Exercícios de Expansão Torácica',
  ];

  bool _mouthRinseDone = true;
  final List<String> _selectedSymptoms = [];
  final List<MedicationUsage> _selectedMedications = [];

  final List<String> _commonSymptoms = [
    'Sem sintomas aparentes',
    'Tosse seca leve',
    'Tosse com secreção / carregada',
    'Chiado no peito (sibilo)',
    'Cansaço aos esforços',
    'Falta de ar ao deitar',
    'Respiração rápida / ofegante',
  ];

  int? _calculatedBest;
  int? _calculatedVariance;
  bool _hasVarianceError = false;
  int _personalBestPef = 300;

  @override
  void initState() {
    super.initState();
    _loadPatientAndPrescriptions(targetId: widget.patientId);
  }

  @override
  void dispose() {
    _blow1Ctrl.dispose();
    _blow2Ctrl.dispose();
    _blow3Ctrl.dispose();
    _spo2Ctrl.dispose();
    _notesCtrl.dispose();
    _physioDurationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatientAndPrescriptions({String? targetId}) async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final profile = await _storageService.getPatientProfile(patientId: targetId);
    final prescriptions = await _storageService.getPrescriptions(profile.id);

    final List<PrescribedMedication> allMeds = [];
    for (final p in prescriptions) {
      allMeds.addAll(p.medications);
    }

    if (allMeds.isEmpty) {
      allMeds.addAll([
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

    if (!mounted) return;
    setState(() {
      _allProfiles = profiles;
      _profile = profile;
      _childPrescribedMeds = allMeds;
      _personalBestPef = profile.personalBestPef;
      _isLoading = false;
    });
  }

  void _switchChild(PatientProfile target) {
    _loadPatientAndPrescriptions(targetId: target.id);
  }

  void _openChildSelectorSheet() {
    HCChildSelectorSheet.show(
      context: context,
      profiles: _allProfiles,
      selectedProfileId: _profile!.id,
      onSelect: _switchChild,
      onAddNew: () async {
        final created = await HCAddChildDialog.show(
          context: context,
          onChildCreated: (c) {},
        );
        if (created != null) _switchChild(created);
      },
    );
  }

  void _recalculatePeakFlow() {
    final b1 = int.tryParse(_blow1Ctrl.text.trim());
    final b2 = int.tryParse(_blow2Ctrl.text.trim());
    final b3 = int.tryParse(_blow3Ctrl.text.trim());

    final blows = [if (b1 != null) b1, if (b2 != null) b2, if (b3 != null) b3];
    if (blows.isEmpty) {
      setState(() {
        _calculatedBest = null;
        _calculatedVariance = null;
        _hasVarianceError = false;
      });
      return;
    }

    final best = blows.reduce((a, b) => a > b ? a : b);
    final min = blows.reduce((a, b) => a < b ? a : b);
    final variance = best - min;

    setState(() {
      _calculatedBest = best;
      _calculatedVariance = variance;
      _hasVarianceError = blows.length >= 2 && variance > 20;
    });
  }

  void _toggleMedication(PrescribedMedication med) {
    setState(() {
      final idx = _selectedMedications.indexWhere((m) => m.name == med.commercialName);
      if (idx >= 0) {
        _selectedMedications.removeAt(idx);
      } else {
        _selectedMedications.add(
          MedicationUsage(
            name: med.commercialName,
            dosage: med.dosage,
            type: med.category == MedicationCategory.rescueInhaled ? MedicationType.rescue : MedicationType.maintenance,
          ),
        );
      }
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _saveEntry() async {
    if (_profile == null) return;
    final List<int> attempts = [];
    if (_includePeakFlow) {
      final b1 = int.tryParse(_blow1Ctrl.text.trim());
      final b2 = int.tryParse(_blow2Ctrl.text.trim());
      final b3 = int.tryParse(_blow3Ctrl.text.trim());
      if (b1 != null) attempts.add(b1);
      if (b2 != null) attempts.add(b2);
      if (b3 != null) attempts.add(b3);
    }

    final spo2Val = _includeSpo2 ? (int.tryParse(_spo2Ctrl.text.trim()) ?? 98) : 98;

    PhysioSessionRecord? physioRecord;
    if (_includePhysioCpap) {
      final dur = int.tryParse(_physioDurationCtrl.text.trim()) ?? 10;
      physioRecord = PhysioSessionRecord(
        deviceName: _selectedPhysioDevice,
        durationMinutes: dur,
        preSpo2: spo2Val,
        postSpo2: spo2Val,
        amibApproved: true,
      );
    }

    await _storageService.addHealthControlEntry(
      targetPatientId: _profile!.id,
      authorName: _author,
      authorRole: 'Cuidador Principal',
      peakFlowAttempts: attempts,
      spo2: spo2Val,
      symptoms: _includeSymptoms && _selectedSymptoms.isNotEmpty ? _selectedSymptoms : ['Sem sintomas aparentes'],
      medications: _includeMedication ? _selectedMedications : [],
      mouthRinseCompleted: _mouthRinseDone,
      notes: _includeNotes && _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : '',
      physiotherapy: physioRecord,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anotação de saúde gravada com sucesso! ✅'),
        backgroundColor: Color(0xFF059669),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Nova Anotação de Saúde', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            children: [
            // Identificação do Paciente Selecionado
            HCChildContextBadge(
              profile: _profile!,
              onSwitchTap: _openChildSelectorSheet,
            ),
            const SizedBox(height: 14),

            // Seletor Modular de Procedimentos
            ProcedureChipSelector(
              includeMedication: _includeMedication,
              includePeakFlow: _includePeakFlow,
              includeSpo2: _includeSpo2,
              includePhysioCpap: _includePhysioCpap,
              includeSymptoms: _includeSymptoms,
              includeNotes: _includeNotes,
              onToggleMedication: (v) => setState(() => _includeMedication = v),
              onTogglePeakFlow: (v) => setState(() => _includePeakFlow = v),
              onToggleSpo2: (v) => setState(() => _includeSpo2 = v),
              onTogglePhysioCpap: (v) => setState(() => _includePhysioCpap = v),
              onToggleSymptoms: (v) => setState(() => _includeSymptoms = v),
              onToggleNotes: (v) => setState(() => _includeNotes = v),
            ),

            const SizedBox(height: 12),

            // 1. Remédios da Receita
            if (_includeMedication) ...[
              PrescribedMedsChecklist(
                prescribedMeds: _childPrescribedMeds,
                selectedMedications: _selectedMedications,
                mouthRinseDone: _mouthRinseDone,
                onToggleMedication: _toggleMedication,
                onToggleMouthRinse: (v) => setState(() => _mouthRinseDone = v),
              ),
              const SizedBox(height: 12),
            ],

            // 2. Sopro (Peak Flow)
            if (_includePeakFlow) ...[
              PeakFlowInputCard(
                blow1Ctrl: _blow1Ctrl,
                blow2Ctrl: _blow2Ctrl,
                blow3Ctrl: _blow3Ctrl,
                calculatedBest: _calculatedBest,
                calculatedVariance: _calculatedVariance,
                hasVarianceError: _hasVarianceError,
                personalBestPef: _personalBestPef,
                onRecalculate: _recalculatePeakFlow,
              ),
              const SizedBox(height: 12),
            ],

            // 3. Oxímetro (SpO2)
            if (_includeSpo2) ...[
              OximeterInputCard(spo2Ctrl: _spo2Ctrl),
              const SizedBox(height: 12),
            ],

            // 4. Fisioterapia / CPAP
            if (_includePhysioCpap) ...[
              PhysioInputCard(
                selectedDevice: _selectedPhysioDevice,
                availableDevices: _physioDevices,
                durationCtrl: _physioDurationCtrl,
                onDeviceChanged: (v) {
                  if (v != null) setState(() => _selectedPhysioDevice = v);
                },
              ),
              const SizedBox(height: 12),
            ],

            // 5. Sintomas
            if (_includeSymptoms) ...[
              SymptomsSelectorCard(
                commonSymptoms: _commonSymptoms,
                selectedSymptoms: _selectedSymptoms,
                onToggleSymptom: _toggleSymptom,
              ),
              const SizedBox(height: 12),
            ],

            // 6. Autor & Observações
            AuthorAndNotesCard(
              selectedAuthor: _author,
              availableAuthors: _availableAuthors,
              notesCtrl: _notesCtrl,
              includeNotes: _includeNotes,
              onAuthorChanged: (v) {
                if (v != null) setState(() => _author = v);
              },
            ),

            const SizedBox(height: 20),

            // Botão Principal de Gravação
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saveEntry,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Gravar Anotação de Saúde 💾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
