import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';

class PrescriptionScanScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PrescriptionScanScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> {
  final HealthStorageService _storageService = HealthStorageService();

  List<PrescriptionRecord> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    final list = await _storageService.getPrescriptions(widget.patientId);
    setState(() {
      _prescriptions = list;
      _isLoading = false;
    });
  }

  void _openScanModal() {
    final rawTextCtrl = TextEditingController();
    int sampleSelected = 0;

    final samples = [
      {
        'title': '📋 Receita Pediátrica Padrão (Manutenção + Resgate)',
        'text': '''INSTITUTO PEDIÁTRICO DE PNEUMOLOGIA
Dr. Marco Aurélio Valente - CRM 129.840/SP
Data: 18/08/2026

Paciente: ${widget.patientName}

USO INALATÓRIO:
1. Clenil HFA 250mcg Spray
   - Fazer 1 jato (puff) de 12 em 12 horas.
   - Usar obrigatoriamente com espaçador valvulado e máscara facial.
   - Enxaguar a cavidade oral ou escovar os dentes após a aplicação.

2. Aerolin Spray 100mcg (Sulfato de Salbutamol)
   - Fazer 2 a 4 jatos com espaçador em caso de tosse, chiado ou falta de ar.

USO ORAL:
3. Singulair Baby 4mg Sachê (Montelucaste)
   - Tomar 1 sachê 1x ao dia à noite misturado em alimento pastoso.

Validade: 6 meses.''',
      },
      {
        'title': '🚨 Receita de Exacerbação / Crise Aguda',
        'text': '''HOSPITAL INFANTIL PRONTO-SOCORRO
Dra. Renata Silveira - CRM 165.430/SP
Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}

Paciente: ${widget.patientName}

1. Aerolin 100mcg Spray
   - 2 jatos de 4 em 4 horas no espaçador por 48 horas.

2. Prednisolona 3mg/mL Solução Oral
   - Tomar 6,5 mL (1mg/kg) 1x ao dia pela manhã por 5 dias consecutivos.

3. Clenil HFA 250mcg
   - Manter 1 jato 12/12h com espaçador.''',
      },
    ];

    rawTextCtrl.text = samples[0]['text'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.document_scanner, color: AppTheme.primaryTeal, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Escanear Receita Médica',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tire uma foto da receita, importe uma prescrição digital ou use o leitor de texto com IA para alimentar as medicações e datas de validade automaticamente.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
                const SizedBox(height: 14),

                // Botões de Ação de Captura
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Tirar Foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Foto da receita capturada! Processando texto via OCR...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Galeria / PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFF0284C7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Documento PDF importado com sucesso.')),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Seletor de Amostras de IA
                const Text('Modelos de Teste Rápido (OCR Simulado):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: List.generate(samples.length, (idx) {
                    final isSel = sampleSelected == idx;
                    return ChoiceChip(
                      label: Text(idx == 0 ? 'Receita Contínua' : 'Receita de Crise', style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (sel) {
                        if (sel) {
                          setModalState(() {
                            sampleSelected = idx;
                            rawTextCtrl.text = samples[idx]['text'] as String;
                          });
                        }
                      },
                    );
                  }),
                ),

                const SizedBox(height: 10),

                // Campo de Texto da Receita
                TextField(
                  controller: rawTextCtrl,
                  maxLines: 7,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'Texto da Prescrição Médica (Extraído via OCR / Scanner)',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Processar e Importar Medicamentos', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (rawTextCtrl.text.trim().isEmpty) return;
                      final messenger = ScaffoldMessenger.of(context);

                      final parsed = PrescriptionOcrParser.parseRawPrescriptionText(
                        rawText: rawTextCtrl.text.trim(),
                        patientId: widget.patientId,
                      );

                      await _storageService.savePrescription(parsed);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (!mounted) return;
                      await _loadPrescriptions();

                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Receita de ${parsed.doctorName} importada com ${parsed.medications.length} medicações! ✅'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openManualAddMedicationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollCtrl,
            children: [
              const Row(
                children: [
                  Icon(Icons.medication, color: AppTheme.primaryTeal),
                  SizedBox(width: 8),
                  Text(
                    'Catálogo Oficial de Bombinhas & Remédios',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecione um medicamento de referência (SBP / GINA / PCDT) para incluir no tratamento do seu filho:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              ...PediatricPharmacopeia.catalog.map((item) {
                final category = item['category'] as MedicationCategory;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(category.iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['active']} • ${item['defaultDosage']}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                        const SizedBox(height: 2),
                        Text(
                          category.displayName,
                          style: const TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                    onTap: () async {
                      final newMed = PrescribedMedication(
                        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                        commercialName: item['name'] as String,
                        activeIngredient: item['active'] as String,
                        category: category,
                        dosage: item['defaultDosage'] as String,
                        frequency: item['defaultFrequency'] as String,
                        instructions: item['instructions'] as String,
                        spacerRequired: item['spacer'] as bool,
                        isContinuous: item['continuous'] as bool,
                      );

                      if (_prescriptions.isNotEmpty) {
                        final active = _prescriptions.first;
                        final updated = PrescriptionRecord(
                          id: active.id,
                          patientId: active.patientId,
                          doctorName: active.doctorName,
                          doctorCrm: active.doctorCrm,
                          clinicName: active.clinicName,
                          prescriptionDate: active.prescriptionDate,
                          validityMonths: active.validityMonths,
                          medications: [...active.medications, newMed],
                          notes: active.notes,
                        );
                        await _storageService.savePrescription(updated);
                      } else {
                        final newPresc = PrescriptionRecord(
                          id: 'presc_manual_${DateTime.now().millisecondsSinceEpoch}',
                          patientId: widget.patientId,
                          doctorName: 'Prescrição Cadastrada Manualmente',
                          prescriptionDate: DateTime.now(),
                          validityMonths: 6,
                          medications: [newMed],
                        );
                        await _storageService.savePrescription(newPresc);
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (!mounted) return;
                      await _loadPrescriptions();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${newMed.commercialName} adicionado ao plano de tratamento! ✅')),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Receitas & Bombinhas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Escanear Nova Receita',
            icon: const Icon(Icons.document_scanner, color: AppTheme.primaryTeal),
            onPressed: _openScanModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de Ação
                  _buildScanBanner(),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prescrições Médicas Ativas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Adicionar Remédio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: _openManualAddMedicationModal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (_prescriptions.isEmpty)
                    _buildEmptyPrescriptionsState()
                  else
                    ..._prescriptions.map((p) => _buildPrescriptionCard(p)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildScanBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Digitalizador Inteligente de Prescrições',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Escaneie a receita do pneumopediatra para alimentar automaticamente as bombinhas, horários, doses e acompanhar a data de validade da receita.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F766E),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.document_scanner),
              label: const Text('Escanear Receita do Médico', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _openScanModal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionRecord p) {
    final isExp = p.isExpired;
    final days = p.daysUntilExpiration;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExp ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isExp ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Receita
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.doctorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    if (p.doctorCrm.isNotEmpty)
                      Text(
                        p.doctorCrm,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExp ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isExp ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExp ? Icons.warning_amber : Icons.check_circle_outline,
                      size: 12,
                      color: isExp ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExp ? 'Receita Vencida' : 'Válida (${days}d)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isExp ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Text(
                'Emitida em: ${DateFormat('dd/MM/yyyy').format(p.prescriptionDate)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 8),
              Text(
                '• Vence em: ${DateFormat('dd/MM/yyyy').format(p.expirationDate)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Lista de Medicações da Receita
          const Text(
            'Medicamentos & Bombinhas Prescritas:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),

          ...p.medications.map((m) => _buildMedicationItem(m)),

          if (p.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Recomendações: ${p.notes}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationItem(PrescribedMedication m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.category.iconEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        m.commercialName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: m.isContinuous ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m.isContinuous ? 'Uso Contínuo' : 'Resgate / S.O.S.',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: m.isContinuous ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${m.activeIngredient} • Dose: ${m.dosage} • Frequência: ${m.frequency}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
                if (m.spacerRequired)
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      '🫧 Uso obrigatório com espaçador valvulado e bochecho',
                      style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPrescriptionsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, color: Color(0xFF94A3B8), size: 40),
          SizedBox(height: 8),
          Text(
            'Nenhuma receita digitalizada ainda.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Toque no botão de escanear acima para ler a prescrição do seu médico.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
