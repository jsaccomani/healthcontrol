import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final HealthStorageService _storageService = HealthStorageService();

  PatientProfile? _patientProfile;
  List<PrescribedMedication> _childPrescribedMeds = [];
  bool _isLoading = true;

  String _author = 'Mãe';

  // Chaves Modulares (O que o cuidador realizou agora)
  bool _includePeakFlow = false;
  bool _includeSpo2 = false;
  bool _includeMedication = true;
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

  @override
  void initState() {
    super.initState();
    _loadPatientAndPrescriptions();
  }

  Future<void> _loadPatientAndPrescriptions() async {
    setState(() => _isLoading = true);
    final profile = await _storageService.getPatientProfile();
    final prescriptions = await _storageService.getPrescriptions(profile.id);

    final List<PrescribedMedication> allMeds = [];
    for (final p in prescriptions) {
      allMeds.addAll(p.medications);
    }

    // Se não houver prescrição cadastrada, carrega sugestões padrão
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

    setState(() {
      _patientProfile = profile;
      _childPrescribedMeds = allMeds;
      _isLoading = false;
    });
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

  Future<void> _saveEntry() async {
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
      physioRecord = PhysioSessionRecord(
        deviceName: _selectedPhysioDevice,
        durationMinutes: int.tryParse(_physioDurationCtrl.text.trim()) ?? 10,
        preSpo2: spo2Val,
        postSpo2: spo2Val,
        amibApproved: true,
      );
    }

    await _storageService.addHealthControlEntry(
      authorName: _author,
      authorRole: _author == 'Médico' ? 'Pneumopediatra' : 'Cuidador Principal',
      peakFlowAttempts: attempts,
      spo2: spo2Val,
      symptoms: _includeSymptoms && _selectedSymptoms.isNotEmpty ? _selectedSymptoms : ['Sem queixas registradas'],
      medications: _includeMedication ? _selectedMedications : [],
      mouthRinseCompleted: _mouthRinseDone,
      physiotherapy: physioRecord,
      notes: _includeNotes ? _notesCtrl.text.trim() : '',
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Novo Lançamento de Saúde', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Quem está anotando
            _buildAuthorCard(),

            const SizedBox(height: 14),

            // 2. Seletor Modular: O que você realizou agora?
            _buildActionSelectionHeader(),

            const SizedBox(height: 14),

            // 3. Seção Remédios Prescritos na Receita do Filho
            if (_includeMedication) ...[
              _buildPrescribedMedicationsSection(),
              const SizedBox(height: 14),
            ],

            // 4. Seção Sopro (Peak Flow) - Opcional
            if (_includePeakFlow) ...[
              _buildPeakFlowSection(),
              const SizedBox(height: 14),
            ],

            // 5. Seção Oxímetro / Saturação (SpO2) - Opcional
            if (_includeSpo2) ...[
              _buildSpo2Section(),
              const SizedBox(height: 14),
            ],

            // 6. Seção Fisioterapia / CPAP / Inalação - Opcional
            if (_includePhysioCpap) ...[
              _buildPhysioCpapSection(),
              const SizedBox(height: 14),
            ],

            // 7. Seção Sintomas - Opcional
            if (_includeSymptoms) ...[
              _buildSymptomsSection(),
              const SizedBox(height: 14),
            ],

            // 8. Seção Observações - Opcional
            if (_includeNotes) ...[
              _buildNotesSection(),
              const SizedBox(height: 14),
            ],

            const SizedBox(height: 10),

            // Botão Salvar Lançamento
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveEntry,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Gravar Anotação de Saúde', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryLight,
                child: Text(_author == 'Pai' ? '👨' : (_author == 'Mãe' ? '👩' : '🩺')),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quem está cuidando agora?', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  Text(_author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                ],
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _author,
              items: const [
                DropdownMenuItem(value: 'Mãe', child: Text('👩 Mãe')),
                DropdownMenuItem(value: 'Pai', child: Text('👨 Pai')),
                DropdownMenuItem(value: 'Avó / Cuidador', child: Text('👵 Cuidador')),
                DropdownMenuItem(value: 'Médico', child: Text('🩺 Médico')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _author = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que você fez com ele agora? (Selecione para abrir os campos)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildToggleChip('💊 Dei Remédio / Bombinha', _includeMedication, (v) => setState(() => _includeMedication = v)),
              _buildToggleChip('💨 Sopro (Peak Flow)', _includePeakFlow, (v) => setState(() => _includePeakFlow = v)),
              _buildToggleChip('🫁 Oxímetro (SpO2)', _includeSpo2, (v) => setState(() => _includeSpo2 = v)),
              _buildToggleChip('🫁 Fisioterapia / CPAP', _includePhysioCpap, (v) => setState(() => _includePhysioCpap = v)),
              _buildToggleChip('🤒 Tossiu / Teve Sintomas', _includeSymptoms, (v) => setState(() => _includeSymptoms = v)),
              _buildToggleChip('📝 Escrever Observação', _includeNotes, (v) => setState(() => _includeNotes = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppTheme.primaryLight,
      checkmarkColor: AppTheme.primaryTeal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onSelected,
    );
  }

  Widget _buildPrescribedMedicationsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💊 Remédios da Receita do Filho',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: const Text('Receita Ativa', style: TextStyle(fontSize: 9, color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Toque na bombinha ou remédio que a criança usou neste momento:',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          ..._childPrescribedMeds.map((med) {
            final isSelected = _selectedMedications.any((m) => m.name.contains(med.commercialName));
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.3) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0)),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                value: isSelected,
                activeColor: AppTheme.primaryTeal,
                secondary: Text(med.category.iconEmoji, style: const TextStyle(fontSize: 20)),
                title: Text(
                  med.commercialName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
                subtitle: Text(
                  '${med.dosage} • ${med.frequency}${med.spacerRequired ? " • com espaçador" : ""}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedMedications.add(
                        MedicationUsage(
                          name: med.commercialName,
                          dosage: med.dosage,
                          type: med.category == MedicationCategory.rescueInhaled ? MedicationType.rescue : MedicationType.maintenance,
                        ),
                      );
                    } else {
                      _selectedMedications.removeWhere((m) => m.name.contains(med.commercialName));
                    }
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 8),

          // Lembrete de Bochecho
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _mouthRinseDone,
                  activeColor: const Color(0xFF059669),
                  onChanged: (v) => setState(() => _mouthRinseDone = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    '💧 Fez bochecho / lavou a boca com água após o spray (Previne sapinho)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakFlowSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💨 Pico de Fluxo (Sopro no Peak Flow)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Peça para a criança soprar 3 vezes com força máxima:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _blow1Ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: '1º Sopro', hintText: '210'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _blow2Ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: '2º Sopro', hintText: '220'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _blow3Ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: '3º Sopro', hintText: '220'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
            ],
          ),
          if (_calculatedBest != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hasVarianceError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hasVarianceError
                    ? '⚠️ Variação de $_calculatedVariance L/min entre os sopros. Repita para garantir a vedação da boquilha.'
                    : '✅ Melhor sopro registrado: $_calculatedBest L/min',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _hasVarianceError ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpo2Section() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🫁 Oxímetro de Dedo (Saturação SpO2)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          TextField(
            controller: _spo2Ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Saturação de Oxigênio (%)', hintText: '98'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysioCpapSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🫁 Fisioterapia Respiratória / CPAP / Inalação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPhysioDevice,
            decoration: const InputDecoration(labelText: 'Aparelho ou Exercício Realizado'),
            items: _physioDevices.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedPhysioDevice = v);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _physioDurationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duração do Exercício (minutos)', hintText: '10'),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤒 Sintomas Apresentados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _commonSymptoms.map((s) {
              final isSel = _selectedSymptoms.contains(s);
              return FilterChip(
                label: Text(s, style: const TextStyle(fontSize: 11)),
                selected: isSel,
                selectedColor: const Color(0xFFFEE2E2),
                checkmarkColor: const Color(0xFFDC2626),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _selectedSymptoms.add(s);
                    } else {
                      _selectedSymptoms.remove(s);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 Observações Adicionais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'ex: Dormiu bem, sem tosse durante a noite.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
