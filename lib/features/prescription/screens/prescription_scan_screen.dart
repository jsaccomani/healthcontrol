import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Tela de Captura, Extração OCR e Gestão de Receitas Médicas.
///
/// Princípio Clínico Rigoroso:
/// - OCR é apenas EXTRAÇÃO preliminar.
/// - Nunca transforma automaticamente o resultado em prescrição ativa sem revisão humana.
/// - Fluxo: Documento -> OCR -> Dados Extraídos -> Revisão Humana -> Confirmação -> PrescriptionRecord.
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
    if (!mounted) return;
    setState(() {
      _prescriptions = list;
      _isLoading = false;
    });
  }

  // ===========================================================================
  // FLUXO DE ADIÇÃO DE RECEITA (Seletor -> Preview -> OCR -> Revisão)
  // ===========================================================================

  void _startAddPrescriptionFlow() {
    HCBottomSheet.show(
      context: context,
      title: 'Adicionar Receita',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha como deseja importar a prescrição médica para ${widget.patientName}:',
              style: HCTypography.bodySmall,
            ),
            const SizedBox(height: 16),

            // 1. Fotografar receita
            _buildSourceOptionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Fotografar Receita',
              subtitle: 'Use a câmera para capturar o documento impresso',
              onTap: () {
                Navigator.pop(context);
                _showCapturePreview(sourceType: 'camera');
              },
            ),

            const SizedBox(height: 10),

            // 2. Escolher imagem
            _buildSourceOptionTile(
              icon: Icons.photo_library_outlined,
              title: 'Escolher Imagem',
              subtitle: 'Selecione uma foto da galeria do seu dispositivo',
              onTap: () {
                Navigator.pop(context);
                _showCapturePreview(sourceType: 'gallery');
              },
            ),

            const SizedBox(height: 10),

            // 3. Importar PDF
            _buildSourceOptionTile(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Importar PDF',
              subtitle: 'Carregar arquivo digital fornecido pela clínica/hospital',
              onTap: () {
                Navigator.pop(context);
                _showCapturePreview(sourceType: 'pdf');
              },
            ),

            const SizedBox(height: 10),

            // 4. Cadastrar manualmente
            _buildSourceOptionTile(
              icon: Icons.edit_note_outlined,
              title: 'Cadastrar Manualmente',
              subtitle: 'Digite as informações da receita campo por campo',
              onTap: () {
                Navigator.pop(context);
                _openManualEntryScreen();
              },
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: context.hcTheme.borderSubtle),
            const SizedBox(height: 12),

            // Opções de demonstração rápida (amostras clínicas)
            Text(
              'OU USE UM MODELO DE TESTE:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: context.hcTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startOcrSimulation(sampleType: 'standard');
                    },
                    child: const Text('Receita Padrão', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startOcrSimulation(sampleType: 'formoterol');
                    },
                    child: const Text('Receita Formoterol', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOptionTile({
    required IconData icon,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primarySubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: theme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ETAPA 2: PREVIEW DO DOCUMENTO CAPTURADO
  // ===========================================================================

  void _showCapturePreview({required String sourceType}) {
    final theme = context.hcTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pré-visualização do Documento',
                  style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verifique se a receita médica está legível e bem enquadrada.',
                  style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                ),
                const SizedBox(height: 16),

                // Mock visual do documento capturado
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: theme.elevatedSurface,
                    borderRadius: HCRadii.radiusLg,
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sourceType == 'pdf' ? Icons.picture_as_pdf : Icons.document_scanner,
                        size: 56,
                        color: theme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sourceType == 'pdf' ? 'receita_pediatrica.pdf (1.2 MB)' : 'receita_foto_001.jpg (2.4 MB)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qualidade: Alta Definição • Iluminação Adequada',
                        style: TextStyle(fontSize: 11, color: theme.successText),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Botões de Recapturar vs Confirmar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startAddPrescriptionFlow();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Recapturar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startOcrSimulation(sampleType: 'standard');
                        },
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text(
                          'Extrair Dados com OCR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ETAPA 3: PROCESSAMENTO OCR ASSÍNCRONO COM PROGRESSO NÃO-BLOQUEANTE
  // ===========================================================================

  void _startOcrSimulation({required String sampleType}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OcrProcessingDialog(
        onCompleted: (extractedData) {
          Navigator.pop(ctx);
          if (extractedData != null) {
            _openReviewScreen(extractedData);
          } else {
            _showOcrFailureFallback();
          }
        },
        sampleType: sampleType,
      ),
    );
  }

  void _showOcrFailureFallback() {
    final theme = context.hcTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(color: theme.border),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.warning, size: 24),
            const SizedBox(width: 8),
            const Expanded(child: Text('Leitura Inconclusiva', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          'Nossa leitura automática não conseguiu interpretar esta receita com segurança clínica suficiente.',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openManualEntryScreen();
            },
            child: const Text('Preencher Manualmente'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ETAPA 4: TELA DE REVISÃO HUMANA (MANDATÓRIA ANTES DE SALVAR)
  // ===========================================================================

  void _openReviewScreen(Map<String, dynamic> rawExtracted) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PrescriptionReviewScreen(
          patientId: widget.patientId,
          patientName: widget.patientName,
          initialData: rawExtracted,
          onSavePrescription: (record) async {
            await _storageService.addPrescription(record);
            _loadPrescriptions();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescrição confirmada e ativada com sucesso!'),
                  backgroundColor: HCColors.greenMain,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _openManualEntryScreen() {
    _openReviewScreen({
      'doctorName': '',
      'doctorCrm': '',
      'clinicName': '',
      'prescriptionDate': DateTime.now(),
      'validityMonths': 6,
      'isOcrExtracted': false,
      'medications': [
        {
          'commercialName': '',
          'activeIngredient': '',
          'dosage': '1 jato',
          'frequency': '12/12h',
          'instructions': 'Usar com espaçador valvulado e máscara.',
          'category': MedicationCategory.maintenanceInhaled,
          'spacerRequired': true,
          'isContinuous': true,
          'hasLowConfidence': false,
        }
      ],
    });
  }

  // ===========================================================================
  // INTERFACE PRINCIPAL (LISTA DE PRESCRIÇÕES ATIVAS + CTA)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Prescrições & Receitas',
          style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
        ),
        actions: [
          TextButton.icon(
            onPressed: _startAddPrescriptionFlow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: HCLoadingState(message: 'Carregando receitas...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: HCResponsiveContainer(
                maxWidth: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Superior Explicativo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: HCRadii.radiusLg,
                        border: Border.all(color: theme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primarySubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.document_scanner_outlined, color: theme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Digitalização Segura de Receitas',
                                  style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Extraia os dados da receita médica com OCR e confirme os medicamentos para ativar o plano de cuidado e resgate.',
                                  style: HCTypography.caption.copyWith(color: theme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Botão Principal de Adição
                    HCPrimaryButton(
                      label: 'Adicionar Nova Receita Médica',
                      icon: Icons.camera_alt_outlined,
                      width: double.infinity,
                      onPressed: _startAddPrescriptionFlow,
                    ),

                    const SizedBox(height: 24),

                    // Título da Lista
                    Text(
                      'RECEITAS CADASTRADAS (${_prescriptions.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_prescriptions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: HCRadii.radiusLg,
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.description_outlined, size: 40, color: theme.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma receita médica cadastrada ainda.',
                              style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fotografe ou importe o PDF da receita para estruturar o plano.',
                              style: HCTypography.caption.copyWith(color: theme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._prescriptions.map((p) => _buildPrescriptionCard(p, theme)),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionRecord p, HCSemanticTheme theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Receita
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified, size: 16, color: theme.primary),
                  const SizedBox(width: 6),
                  Text(
                    p.doctorName,
                    style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.successBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.successBorder, width: 0.8),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(p.prescriptionDate),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.successText),
                ),
              ),
            ],
          ),
          if (p.doctorCrm.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              p.doctorCrm,
              style: HCTypography.caption.copyWith(color: theme.textSecondary),
            ),
          ],

          const SizedBox(height: 12),
          Divider(height: 1, color: theme.borderSubtle),
          const SizedBox(height: 12),

          // Medicamentos Prescritos
          ...p.medications.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.elevatedSurface,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(color: theme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: m.category == MedicationCategory.rescueInhaled
                            ? theme.criticalBg
                            : theme.primarySubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.category == MedicationCategory.rescueInhaled ? 'RESGATE' : 'CONTROLE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: m.category == MedicationCategory.rescueInhaled
                              ? theme.criticalText
                              : theme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.commercialName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dose: ${m.dosage} • Frequência: ${m.frequency}',
                            style: TextStyle(fontSize: 11, color: theme.textSecondary),
                          ),
                          if (m.instructions.isNotEmpty)
                            Text(
                              m.instructions,
                              style: TextStyle(fontSize: 10, color: theme.textTertiary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// =============================================================================
// DIALOG DE PROCESSAMENTO OCR ASSÍNCRONO COM PROGRESSO SUAVE
// =============================================================================

class _OcrProcessingDialog extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>?> onCompleted;
  final String sampleType;

  const _OcrProcessingDialog({
    required this.onCompleted,
    required this.sampleType,
  });

  @override
  State<_OcrProcessingDialog> createState() => _OcrProcessingDialogState();
}

class _OcrProcessingDialogState extends State<_OcrProcessingDialog> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Carregando e otimizando imagem...',
    'Segmentando linhas e identificando médico...',
    'Estruturando medicamentos e posologias...',
  ];

  @override
  void initState() {
    super.initState();
    _startSteps();
  }

  void _startSteps() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _currentStep = 1);

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _currentStep = 2);

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Retorna os dados extraídos conforme o modelo selecionado
    if (widget.sampleType == 'formoterol') {
      widget.onCompleted({
        'doctorName': 'Dra. Beatriz Menezes',
        'doctorCrm': 'CRM/SP 145.220',
        'clinicName': 'Clínica de Alergia e Imunologia Infantil',
        'prescriptionDate': DateTime.now(),
        'validityMonths': 6,
        'isOcrExtracted': true,
        'medications': [
          {
            'commercialName': 'Alenia 6/200mcg',
            'activeIngredient': 'Fumarato de Formoterol + Budesonida',
            'dosage': '1 cápsula inalatória',
            'frequency': '1x ao dia pela manhã',
            'instructions': 'Inalação oral via pó seco. Enxaguar a boca após o uso.',
            'category': MedicationCategory.maintenanceInhaled,
            'spacerRequired': false,
            'isContinuous': true,
            'hasLowConfidence': false,
          },
          {
            'commercialName': 'Berotec Spray 100mcg',
            'activeIngredient': 'Bromidrato de Fenoterol',
            'dosage': '1 a 2 jatos',
            'frequency': 'Em crise de falta de ar (Resgate)',
            'instructions': 'Com espaçador valvulado.',
            'category': MedicationCategory.rescueInhaled,
            'spacerRequired': true,
            'isContinuous': false,
            'hasLowConfidence': true, // Destaque de baixa confiança
          },
        ],
      });
    } else {
      widget.onCompleted({
        'doctorName': 'Dr. Marco Aurélio Valente',
        'doctorCrm': 'CRM/SP 129.840',
        'clinicName': 'Instituto Pediátrico de Pneumologia',
        'prescriptionDate': DateTime.now(),
        'validityMonths': 6,
        'isOcrExtracted': true,
        'medications': [
          {
            'commercialName': 'Clenil HFA 250mcg Spray',
            'activeIngredient': 'Dipropionato de Beclometasona',
            'dosage': '1 jato (puff)',
            'frequency': '12/12 horas (Manhã e Noite)',
            'instructions': 'Usar com espaçador valvulado e máscara. Bochechar água após o uso.',
            'category': MedicationCategory.maintenanceInhaled,
            'spacerRequired': true,
            'isContinuous': true,
            'hasLowConfidence': false,
          },
          {
            'commercialName': 'Aerolin Spray 100mcg',
            'activeIngredient': 'Sulfato de Salbutamol',
            'dosage': '2 a 4 jatos',
            'frequency': 'A cada 20 min em caso de crise (Resgate)',
            'instructions': 'Aplicar 1 jato por vez no espaçador, aguardar 6 respirações por jato.',
            'category': MedicationCategory.rescueInhaled,
            'spacerRequired': true,
            'isContinuous': false,
            'hasLowConfidence': false,
          },
        ],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusLg),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Extraindo Texto da Receita...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _steps[_currentStep],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TELA DE REVISÃO HUMANA (CAMPOS EDITÁVEIS + VALIDAÇÃO EXPLÍCITA)
// =============================================================================

class _PrescriptionReviewScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final Map<String, dynamic> initialData;
  final ValueChanged<PrescriptionRecord> onSavePrescription;

  const _PrescriptionReviewScreen({
    required this.patientId,
    required this.patientName,
    required this.initialData,
    required this.onSavePrescription,
  });

  @override
  State<_PrescriptionReviewScreen> createState() => _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends State<_PrescriptionReviewScreen> {
  late TextEditingController _doctorNameCtrl;
  late TextEditingController _doctorCrmCtrl;
  late TextEditingController _clinicNameCtrl;
  late DateTime _prescriptionDate;
  late int _validityMonths;
  late bool _isOcr;

  late List<Map<String, dynamic>> _medications;

  @override
  void initState() {
    super.initState();
    _doctorNameCtrl = TextEditingController(text: widget.initialData['doctorName'] as String? ?? '');
    _doctorCrmCtrl = TextEditingController(text: widget.initialData['doctorCrm'] as String? ?? '');
    _clinicNameCtrl = TextEditingController(text: widget.initialData['clinicName'] as String? ?? '');
    _prescriptionDate = widget.initialData['prescriptionDate'] as DateTime? ?? DateTime.now();
    _validityMonths = widget.initialData['validityMonths'] as int? ?? 6;
    _isOcr = widget.initialData['isOcrExtracted'] as bool? ?? false;

    final meds = widget.initialData['medications'] as List<dynamic>? ?? [];
    _medications = meds.map((m) => Map<String, dynamic>.from(m as Map)).toList();
  }

  void _addMedicationItem() {
    setState(() {
      _medications.add({
        'commercialName': '',
        'activeIngredient': '',
        'dosage': '1 jato',
        'frequency': '12/12h',
        'instructions': 'Usar com espaçador valvulado.',
        'category': MedicationCategory.maintenanceInhaled,
        'spacerRequired': true,
        'isContinuous': true,
        'hasLowConfidence': false,
      });
    });
  }

  void _removeMedicationItem(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _saveFinalPrescription() {
    if (_doctorNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome do médico prescritor.')),
      );
      return;
    }

    final List<PrescribedMedication> finalMeds = [];
    for (int i = 0; i < _medications.length; i++) {
      final m = _medications[i];
      final name = (m['commercialName'] as String).trim();
      if (name.isNotEmpty) {
        finalMeds.add(PrescribedMedication(
          id: 'med_${DateTime.now().millisecondsSinceEpoch}_$i',
          commercialName: name,
          activeIngredient: m['activeIngredient'] as String? ?? '',
          category: m['category'] as MedicationCategory? ?? MedicationCategory.maintenanceInhaled,
          dosage: m['dosage'] as String? ?? '1 jato',
          frequency: m['frequency'] as String? ?? '12/12h',
          instructions: m['instructions'] as String? ?? '',
          spacerRequired: m['spacerRequired'] as bool? ?? true,
          isContinuous: m['isContinuous'] as bool? ?? true,
        ));
      }
    }

    if (finalMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 1 medicamento válido na receita.')),
      );
      return;
    }

    final record = PrescriptionRecord(
      id: 'presc_${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      doctorName: _doctorNameCtrl.text.trim(),
      doctorCrm: _doctorCrmCtrl.text.trim(),
      clinicName: _clinicNameCtrl.text.trim(),
      prescriptionDate: _prescriptionDate,
      validityMonths: _validityMonths,
      medications: finalMeds,
    );

    widget.onSavePrescription(record);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Revisão da Prescrição Médica',
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
              // Banner de Transparência & Segurança Clínica
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isOcr ? theme.infoBg : theme.surface,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(color: _isOcr ? theme.infoBorder : theme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _isOcr ? Icons.auto_awesome : Icons.edit_note,
                      color: theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOcr ? 'Extraído da receita via OCR' : 'Cadastro Manual',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Revise todos os campos com atenção antes de salvar. A extração automática nunca substitui a conferência dos pais ou a orientação do médico assistente.',
                            style: HCTypography.caption.copyWith(color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Dados do Médico Prescritor
              Text(
                'MÉDICO PRESCRITOR & CONSULTÓRIO',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: theme.textSecondary),
              ),
              const SizedBox(height: 8),

              HCTextField(
                controller: _doctorNameCtrl,
                labelText: 'Nome do Médico Assistente *',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: HCTextField(
                      controller: _doctorCrmCtrl,
                      labelText: 'CRM / Registro',
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HCTextField(
                      controller: _clinicNameCtrl,
                      labelText: 'Clínica / Hospital',
                      prefixIcon: Icons.local_hospital_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Medicamentos Prescritos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MEDICAMENTOS PRESCRITOS (${_medications.length})',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: theme.textSecondary),
                  ),
                  TextButton.icon(
                    onPressed: _addMedicationItem,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._medications.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                final isLowConfidence = m['hasLowConfidence'] as bool? ?? false;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: HCRadii.radiusMd,
                    border: Border.all(
                      color: isLowConfidence ? theme.warning : theme.border,
                      width: isLowConfidence ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Item #${idx + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                              ),
                              if (isLowConfidence) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.warningBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: theme.warningBorder, width: 0.8),
                                  ),
                                  child: Text(
                                    'Baixa confiança - confira',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.warningText),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_medications.length > 1)
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: theme.critical),
                              onPressed: () => _removeMedicationItem(idx),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        initialValue: m['commercialName'] as String,
                        decoration: const InputDecoration(
                          labelText: 'Nome Comercial do Medicamento *',
                          hintText: 'Ex: Clenil HFA 250mcg / Aerolin 100mcg',
                        ),
                        onChanged: (val) => m['commercialName'] = val,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: m['dosage'] as String,
                              decoration: const InputDecoration(
                                labelText: 'Dose (ex: 1 jato / 2 puffs)',
                              ),
                              onChanged: (val) => m['dosage'] = val,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: m['frequency'] as String,
                              decoration: const InputDecoration(
                                labelText: 'Frequência (ex: 12/12h)',
                              ),
                              onChanged: (val) => m['frequency'] = val,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        initialValue: m['instructions'] as String,
                        decoration: const InputDecoration(
                          labelText: 'Instruções de Uso / Dispositivo',
                          hintText: 'Ex: Espaçador valvulado com máscara, enxaguar a boca',
                        ),
                        onChanged: (val) => m['instructions'] = val,
                      ),
                      const SizedBox(height: 10),

                      // Categoria (Manutenção vs Resgate)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<MedicationCategory>(
                              initialValue: m['category'] as MedicationCategory,
                              decoration: const InputDecoration(labelText: 'Finalidade Clínica'),
                              items: const [
                                DropdownMenuItem(
                                  value: MedicationCategory.maintenanceInhaled,
                                  child: Text('Controle Diário (Manutenção)'),
                                ),
                                DropdownMenuItem(
                                  value: MedicationCategory.rescueInhaled,
                                  child: Text('Resgate em Crise (Alívio)'),
                                ),
                                DropdownMenuItem(
                                  value: MedicationCategory.antileukotrieneOral,
                                  child: Text('Antileucotrieno Oral'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => m['category'] = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Botão de Confirmação Final com Origem Explícita
              HCPrimaryButton(
                label: 'Confirmar e Salvar Prescrição',
                icon: Icons.check_circle_outline,
                width: double.infinity,
                onPressed: _saveFinalPrescription,
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Ao confirmar, você valida que os medicamentos acima conferem com a receita física.',
                  textAlign: TextAlign.center,
                  style: HCTypography.caption.copyWith(color: theme.textTertiary),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
