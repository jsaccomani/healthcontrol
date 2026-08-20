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

/// Tela de Modo Crise (Foco Estrito no Paciente, Divulgação Progressiva em 3 Níveis).
/// - Nível 1: Identidade, Resgate Prescrito, Timer e SAMU 192 (visível sem scroll).
/// - Nível 2: Resumo Clínico para Plantonista (expansível).
/// - Nível 3: Histórico Recente (carregado sob demanda).
///
/// Regra de Segurança Clínica: Não inventa posologias nem medicamentos na ausência de prescrição.
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

  Future<void> _recordRescueMedication({
    required String prescriptionId,
    required String medicationName,
    required String dosage,
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

    await _crisisAlertService.notifyMedicationAdministered(updatedEvent, _profile!);

    setState(() {
      _activeCrisisEvent = updatedEvent;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dose de resgate ($medicationName) registrada! Cronômetro de 20 min iniciado.'),
          backgroundColor: HCColors.greenMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Future<void> _resolveCrisis() async {
    if (_activeCrisisEvent != null && _profile != null) {
      await _crisisAlertService.notifyCrisisResolved(_activeCrisisEvent!, _profile!);
    }
    if (mounted) {
      Navigator.of(context).pop();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: isDark ? HCColors.darkBg : HCColors.neutral50,
        body: const Center(child: CircularProgressIndicator(color: HCColors.primary500)),
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // Preserva o estado de auditoria ao sair
      },
      child: Scaffold(
        backgroundColor: isDark ? HCColors.darkBg : const Color(0xFFFAF6F6),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF3B0B0B) : HCColors.redMain,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Sair do Modo Crise',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Row(
            children: [
              Icon(Icons.emergency, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'MODO CRISE DE ASMA',
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
              onPressed: _resolveCrisis,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: const Text(
                'Finalizar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HCResponsiveContainer(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Identificação Estrita da Criança (Contexto Trancado)
                CrisisHeader(profile: _profile!),

                const SizedBox(height: 14),

                // 2. Nível 1: Plano de Resgate Médico Prescrito OU Aviso Clínico Seguro de Ausência
                if (hasRescuePlan)
                  CrisisRescuePlan(
                    validRescuePlans: validRescuePlans,
                    onAdministerDose: _recordRescueMedication,
                  )
                else
                  CrisisNoPlanCard(
                    onCallSamu: _callSamu,
                    onCallDoctor: docPhone.isNotEmpty ? () => _callPhone(docPhone) : null,
                    onOpenEmergencySummary: () {},
                  ),

                const SizedBox(height: 14),

                // 3. Nível 1: Temporizador Persistente de Reavaliação (20 min)
                CrisisReassessmentTimer(
                  reassessmentAt: _activeCrisisEvent?.reassessmentAt,
                  onStartManualTimer: _startManualTimer,
                ),

                const SizedBox(height: 14),

                // 4. Nível 1: Ações de Emergência Imediata (192 SAMU & GPS)
                CrisisEmergencyActions(
                  onCallSamu: _callSamu,
                  onOpenHospitalGps: () => _openHospitalGps(_profile!.preferredHospital),
                ),

                const SizedBox(height: 14),

                // 5. Nível 2: Resumo Clínico Estruturado para o Plantonista (Expansível)
                CrisisClinicalSummary(
                  profile: _profile!,
                  onCallPhone: _callPhone,
                ),

                const SizedBox(height: 14),

                // 6. Nível 3: Histórico Clínico sob Demanda
                CrisisHistory(patientId: _profile!.id),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
