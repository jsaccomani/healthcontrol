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

  String _author = 'Mãe';
  final TextEditingController _blow1Ctrl = TextEditingController();
  final TextEditingController _blow2Ctrl = TextEditingController();
  final TextEditingController _blow3Ctrl = TextEditingController();
  final TextEditingController _spo2Ctrl = TextEditingController(text: '98');
  final TextEditingController _notesCtrl = TextEditingController();

  bool _mouthRinseDone = false;
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedTriggers = [];
  final List<MedicationUsage> _selectedMedications = [];

  final List<String> _commonSymptoms = [
    'Sem sintomas',
    'Tosse noturna',
    'Chiado no peito',
    'Cansaço aos esforços',
    'Tiragem intercostal (afundamento das costelas)',
  ];

  final List<String> _commonTriggers = [
    'Tempo seco',
    'Queda de temperatura',
    'Poeira/Mofo',
    'Exercício físico',
    'Fumaça',
  ];

  final List<MedicationUsage> _availableMedications = [
    const MedicationUsage(name: 'Clenil HFA 250mcg (Preventivo)', dosage: '1 puff', type: MedicationType.maintenance),
    const MedicationUsage(name: 'Aerolin / Salbutamol (Resgate)', dosage: '2 puffs', type: MedicationType.rescue),
    const MedicationUsage(name: 'Budesonida Spray (Preventivo)', dosage: '1 puff', type: MedicationType.maintenance),
    const MedicationUsage(name: 'Prednisolona Oral (Corticoide)', dosage: '5ml', type: MedicationType.oralSteroid),
    const MedicationUsage(name: 'Dupixent / Dupilumabe (Biológico)', dosage: '200mg', type: MedicationType.biologic),
  ];

  int? _calculatedBest;
  int? _calculatedVariance;
  bool _hasVarianceError = false;

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
    final spo2Val = int.tryParse(_spo2Ctrl.text.trim()) ?? 98;
    final b1 = int.tryParse(_blow1Ctrl.text.trim());
    final b2 = int.tryParse(_blow2Ctrl.text.trim());
    final b3 = int.tryParse(_blow3Ctrl.text.trim());

    final attempts = [if (b1 != null) b1, if (b2 != null) b2, if (b3 != null) b3];

    if (attempts.isEmpty && _selectedSymptoms.isEmpty && _selectedMedications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe ao menos os sopros do Peak Flow, sintomas ou medicações.')),
      );
      return;
    }

    final entry = await _storageService.addHealthControlEntry(
      authorName: _author,
      authorRole: _author == 'Médico' ? 'Pneumologista' : 'Cuidador Principal',
      peakFlowAttempts: attempts,
      spo2: spo2Val,
      symptoms: _selectedSymptoms,
      environmentalTriggers: _selectedTriggers,
      medications: _selectedMedications,
      mouthRinseCompleted: _mouthRinseDone,
      notes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;

    // Diálogo de confirmação com a Zona e Orientações
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              entry.peakFlowZone == ActionZoneType.green
                  ? Icons.check_circle
                  : (entry.peakFlowZone == ActionZoneType.yellow ? Icons.warning_amber : Icons.emergency),
              color: entry.peakFlowZone == ActionZoneType.green
                  ? AppTheme.zoneGreen
                  : (entry.peakFlowZone == ActionZoneType.yellow ? AppTheme.zoneYellow : AppTheme.zoneRed),
            ),
            const SizedBox(width: 8),
            Text('Lançamento ${entry.versionTag} Salvo!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pico de Fluxo Máximo: ${entry.peakFlowBest} L/min'),
            Text('Saturação SpO2: ${entry.spo2}%'),
            const SizedBox(height: 8),
            if (entry.peakFlowZone == ActionZoneType.yellow) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.zoneYellowBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.zoneYellow),
                ),
                child: const Text(
                  '⚠️ Paciente na Zona Amarela! Administre o resgate e reavalie em 20 minutos.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
            ],
            if (entry.medications.any((m) => m.type == MedicationType.maintenance) && !_mouthRinseDone) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💧 Lembre-se: Faça o bochecho ou escove os dentes da criança para evitar sapinho/candidíase.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Lançamento Diário', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quem está registrando
            _buildAuthorSelector(),

            const SizedBox(height: 16),

            // Peak Flow (Regra dos 3 Sopros CFF)
            _buildPeakFlowSection(),

            const SizedBox(height: 16),

            // Saturação SpO2
            _buildVitalsSection(),

            const SizedBox(height: 16),

            // Medicações Usadas
            _buildMedicationsSection(),

            const SizedBox(height: 16),

            // Higiene Bucal Anti-Sapinho (Mandatório)
            _buildMouthRinseSection(),

            const SizedBox(height: 16),

            // Sintomas & Gatilhos
            _buildSymptomsAndTriggersSection(),

            const SizedBox(height: 16),

            // Observações
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Observações ou queixas da criança',
                hintText: 'Ex: tossiu mais de madrugada, dormiu bem...',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveEntry,
                icon: const Icon(Icons.check),
                label: const Text('Salvar Lançamento & Gerar Versão', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(width: 8),
          const Text('Responsável pelo registro:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          DropdownButton<String>(
            value: _author,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Mãe', child: Text('Mãe')),
              DropdownMenuItem(value: 'Pai', child: Text('Pai')),
              DropdownMenuItem(value: 'Cuidador', child: Text('Cuidador/Babá')),
              DropdownMenuItem(value: 'Médico', child: Text('Médico/Fisioterapeuta')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _author = val);
            },
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.air, color: AppTheme.primaryTeal, size: 20),
              SizedBox(width: 6),
              Text(
                'Pico de Fluxo (PFE) - Regra dos 3 Sopros',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Peça para o seu filho soprar 3 vezes com força máxima no aparelho. O app selecionará o melhor valor.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _blow1Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '1º Sopro', hintText: 'ex: 210'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _blow2Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '2º Sopro', hintText: 'ex: 220'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _blow3Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '3º Sopro', hintText: 'ex: 215'),
                  onChanged: (_) => _recalculatePeakFlow(),
                ),
              ),
            ],
          ),
          if (_calculatedBest != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _hasVarianceError ? AppTheme.zoneYellowBg : AppTheme.zoneGreenBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasVarianceError ? AppTheme.zoneYellow : AppTheme.zoneGreen,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasVarianceError ? Icons.warning_amber : Icons.check_circle,
                    size: 16,
                    color: _hasVarianceError ? AppTheme.zoneYellow : AppTheme.zoneGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _hasVarianceError
                          ? 'Maior: $_calculatedBest L/min • Variação de $_calculatedVariance L/min (Sopros muito diferentes, oriente o sopro reto!)'
                          : 'Maior Sopro: $_calculatedBest L/min (Técnica consistente)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _hasVarianceError ? const Color(0xFF92400E) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_outline, color: AppTheme.primaryTeal, size: 20),
              SizedBox(width: 6),
              Text(
                'Saturação de Oxigênio (Oxímetro)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _spo2Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'SpO2 (%)', hintText: 'ex: 98'),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 2,
                child: Text(
                  'Normal em ar ambiente: ≥ 95%.\nAbaixo de 92% requer atenção médica.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medication_outlined, color: AppTheme.primaryTeal, size: 20),
              SizedBox(width: 6),
              Text(
                'Medicações Utilizadas Nesta Sessão',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableMedications.map((med) {
              final isSelected = _selectedMedications.any((m) => m.name == med.name);
              return FilterChip(
                label: Text(med.name, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: AppTheme.primaryLight,
                checkmarkColor: AppTheme.primaryTeal,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMedications.add(med);
                    } else {
                      _selectedMedications.removeWhere((m) => m.name == med.name);
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

  Widget _buildMouthRinseSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _mouthRinseDone ? AppTheme.zoneGreenBg : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _mouthRinseDone ? AppTheme.zoneGreen.withOpacity(0.5) : AppTheme.zoneYellow,
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          '💧 Higiene Bucal / Bochecho Realizado',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
        ),
        subtitle: const Text(
          'Fundamental após usar corticoide inalatório (Clenil/Budesonida) para evitar sapinho (candidíase oral) e rouquidão.',
          style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
        ),
        value: _mouthRinseDone,
        activeColor: AppTheme.zoneGreen,
        onChanged: (val) => setState(() => _mouthRinseDone = val ?? false),
      ),
    );
  }

  Widget _buildSymptomsAndTriggersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sintomas Notados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _commonSymptoms.map((s) {
              final isSel = _selectedSymptoms.contains(s);
              return FilterChip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                selected: isSel,
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
          const SizedBox(height: 12),
          const Text('Gatilhos do Ambiente:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _commonTriggers.map((t) {
              final isSel = _selectedTriggers.contains(t);
              return FilterChip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                selected: isSel,
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _selectedTriggers.add(t);
                    } else {
                      _selectedTriggers.remove(t);
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
}
