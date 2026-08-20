import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/crisis_alert_service.dart';
import '../widgets/crisis_header.dart';
import '../widgets/crisis_rescue_plan.dart';
import '../widgets/crisis_no_plan_card.dart';
import '../widgets/crisis_reassessment_timer.dart';
import '../widgets/crisis_emergency_actions.dart';
import '../widgets/crisis_clinical_summary.dart';
import '../widgets/crisis_history.dart';

/// Tela de Modo Crise (Modo Operacional de Emergência).
///
/// Princípio Fundamental: Redução Total de Carga Cognitiva.
/// Responde imediatamente em 2 segundos:
/// 1. QUEM? (Identidade trancada da criança)
/// 2. O QUE FAZER? (Plano de resgate médico cadastrado com posologia exata)
/// 3. QUANDO REAVALIAR? (Temporizador persistente de 20 minutos derivado de timestamp)
/// 4. QUANDO ESCALAR? (Ações de emergência SAMU 192, Médico e Pronto-Socorro)
class CrisisScreen extends StatefulWidget {
  final String patientId;

  const CrisisScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  final CrisisAlertService _crisisAlertService = LocalAuditCrisisAlertService();
  final Uuid _uuid = const Uuid();

  PatientProfile? _profile;
  List<PrescriptionRecord> _prescriptions = [];
  CrisisEvent? _activeCrisisEvent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrisisData();
  }

  Future<void> _loadCrisisData() async {
    setState(() => _isLoading = true);

    final profile = await _storageService.getPatientProfile(patientId: widget.patientId);
    final prescriptions = await _storageService.getPrescriptions(widget.patientId);
    var activeEvent = await _storageService.getActiveCrisisEvent(widget.patientId);

    // Se ainda não houver um evento de crise ativo para esta sessão, inicia um
    if (activeEvent == null) {
      final now = DateTime.now();
      final primaryCaregiver = profile.caregivers.isNotEmpty ? profile.caregivers.first : null;
      activeEvent = CrisisEvent(
        id: 'crisis_${_uuid.v4().substring(0, 8)}',
        patientId: widget.patientId,
        startedAt: now,
        startedBy: primaryCaregiver?.id ?? 'caregiver_01',
        startedByName: primaryCaregiver?.fullName ?? 'Cuidador Principal',
        startedByRole: primaryCaregiver?.accessLevel.displayName ?? 'Cuidador',
        status: 'active',
        createdAt: now,
      );
      await _crisisAlertService.notifyCrisisStarted(activeEvent, profile);
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _prescriptions = prescriptions;
      _activeCrisisEvent = activeEvent;
      _isLoading = false;
    });
  }

  int _rescueDosesCount = 0;

  Future<void> _recordRescueMedication({
    required String prescriptionId,
    required String medicationName,
    required String dosage,
    required String administeredBy,
  }) async {
    if (_profile == null || _activeCrisisEvent == null) return;

    final now = DateTime.now();
    final reassessmentTime = now.add(const Duration(minutes: 20));

    final updatedEvent = _activeCrisisEvent!.copyWith(
      rescuePlanId: prescriptionId,
      medicationAdministered: medicationName,
      doseAdministered: dosage,
      administeredAt: now,
      reassessmentAt: reassessmentTime,
    );

    // Notifica o serviço de alerta (abstração pronta para integração com Health Control Pro)
    await _crisisAlertService.notifyMedicationAdministered(updatedEvent, _profile!);

    // Grava no log de eventos clínicos
    await _storageService.addHealthControlEntry(
      targetPatientId: widget.patientId,
      authorName: administeredBy,
      authorRole: 'Cuidador',
      peakFlowAttempts: [],
      spo2: 95,
      medications: [
        MedicationUsage(
          name: medicationName,
          dosage: dosage,
          type: MedicationType.rescue,
          puffsCount: 2,
        ),
      ],
      symptoms: ['Crise de Asma em Andamento'],
      mouthRinseCompleted: true,
      notes: 'Dose de resgate administrada durante modo crise.',
    );

    setState(() {
      _activeCrisisEvent = updatedEvent;
      _rescueDosesCount++;
    });

    if (mounted) {
      if (_rescueDosesCount >= 3) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF3B0B0B),
            title: const Row(
              children: [
                Icon(Icons.emergency, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alerta de Asma Grave',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Você registrou a 3ª dose de resgate nesta crise. Conforme a diretriz médica (GINA/SBPT), se a criança mantiver chiado, tosse ou esforço respiratório, acione o SAMU 192 ou procure o Pronto-Socorro Infantil imediatamente.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HCColors.redMain,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _callSamu();
                },
                child: const Text('Ligar 192 Agora', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dose de resgate ($medicationName - $dosage) confirmada! Cronômetro de 20 min iniciado.'),
            backgroundColor: HCColors.greenMain,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _startManualTimer() async {
    if (_activeCrisisEvent != null && _profile != null) {
      final reassessmentTime = DateTime.now().add(const Duration(minutes: 20));
      final updated = _activeCrisisEvent!.copyWith(reassessmentAt: reassessmentTime);
      await _crisisAlertService.notifyCrisisReassessment(updated, _profile!);
      setState(() => _activeCrisisEvent = updated);
    }
  }

  Future<void> _showFinalizeConfirmation() async {
    final theme = context.hcTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(color: theme.border),
        ),
        title: Text(
          'Finalizar Modo Crise?',
          style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
        ),
        content: Text(
          'A crise será registrada como resolvida no histórico clínico da criança.',
          style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Continuar em Crise', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HCColors.greenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, Finalizar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (_activeCrisisEvent != null && _profile != null) {
        await _crisisAlertService.notifyCrisisResolved(_activeCrisisEvent!, _profile!);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return;
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callSamu() async {
    final uri = Uri.parse('tel:192');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openHospitalGps(String hospital) async {
    final query = hospital.isNotEmpty ? hospital : 'Pronto Socorro Infantil mais proximo';
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: HCLoadingState(message: 'Iniciando modo crise...')),
      );
    }

    // Busca medicações de resgate válidas nas prescrições médicas ativas
    final List<Map<String, dynamic>> validRescuePlans = [];
    for (final p in _prescriptions) {
      for (final m in p.medications) {
        if (m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue) {
          validRescuePlans.add({
            'prescription': p,
            'medication': m,
          });
        }
      }
    }

    final hasRescuePlan = validRescuePlans.isNotEmpty;
    final docPhone = _profile!.primaryDoctor?.primaryPhone ?? _profile!.doctorPhone;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.isDark ? const Color(0xFF3B0B0B) : HCColors.redMain,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'MODO CRISE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showFinalizeConfirmation,
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            label: const Text(
              'Finalizar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. QUEM? (Identificação Estrita e Contexto Trancado)
              CrisisHeader(profile: _profile!),

              const SizedBox(height: 14),

              // 2. O QUE FAZER? (Plano de Resgate Prescrito OU Aviso Seguro de Ausência)
              if (hasRescuePlan)
                CrisisRescuePlan(
                  validRescuePlans: validRescuePlans,
                  onAdministerDose: ({
                    required prescriptionId,
                    required medicationName,
                    required dosage,
                    administeredBy = 'Cuidador',
                  }) => _recordRescueMedication(
                    prescriptionId: prescriptionId,
                    medicationName: medicationName,
                    dosage: dosage,
                    administeredBy: administeredBy,
                  ),
                )
              else
                CrisisNoPlanCard(
                  onCallSamu: _callSamu,
                  onCallDoctor: docPhone.isNotEmpty ? () => _callPhone(docPhone) : null,
                  onOpenEmergencySummary: () {},
                ),

              const SizedBox(height: 14),

              // 3. QUANDO REAVALIAR? (Temporizador Persistente de 20 min)
              CrisisReassessmentTimer(
                reassessmentAt: _activeCrisisEvent?.reassessmentAt,
                onStartManualTimer: _startManualTimer,
              ),

              const SizedBox(height: 14),

              // 4. QUANDO ESCALAR? (Ações de Emergência Secundárias)
              CrisisEmergencyActions(
                onCallSamu: _callSamu,
                onCallDoctor: docPhone.isNotEmpty ? () => _callPhone(docPhone) : null,
                onOpenHospitalGps: () => _openHospitalGps(_profile!.preferredHospital),
              ),

              const SizedBox(height: 18),

              // 5. INFORMAÇÕES IMPORTANTES PARA ATENDIMENTO (Accordion)
              CrisisClinicalSummary(
                profile: _profile!,
                onCallPhone: _callPhone,
              ),

              const SizedBox(height: 14),

              // 6. HISTÓRICO DE CRISES RECENTES (Sob Demanda)
              CrisisHistory(patientId: _profile!.id),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
