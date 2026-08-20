import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/crisis_alert_service.dart';

/// Tela de Modo Crise (Foco Exclusivo no Paciente em Crise, 100% Offline-First, Sem Troca Acidental).
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

  // Temporizador de Reavaliação Pós-Resgate
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    _loadCrisisData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCrisisData() async {
    setState(() => _isLoading = true);

    final profile = await _storageService.getPatientProfile(patientId: widget.patientId);
    final prescriptions = await _storageService.getPrescriptions(widget.patientId);
    var activeEvent = await _storageService.getActiveCrisisEvent(widget.patientId);

    // Se ainda não houver um evento de crise ativo iniciado para esta sessão, inicia um
    if (activeEvent == null) {
      final now = DateTime.now();
      activeEvent = CrisisEvent(
        id: 'crisis_${_uuid.v4().substring(0, 8)}',
        patientId: widget.patientId,
        startedAt: now,
        startedBy: profile.caregivers.isNotEmpty ? profile.caregivers.first.fullName : 'Cuidador Principal',
        startedByRole: profile.caregivers.isNotEmpty ? profile.caregivers.first.accessLevel.displayName : 'Cuidador',
        status: 'active',
        createdAt: now,
      );
      await _crisisAlertService.notifyCrisisStarted(activeEvent, profile);
    }

    // Inicializa ou restaura o temporizador baseado no timestamp persistido
    _checkAndRestoreTimer(activeEvent);

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _prescriptions = prescriptions;
      _activeCrisisEvent = activeEvent;
      _isLoading = false;
    });
  }

  void _checkAndRestoreTimer(CrisisEvent event) {
    if (event.reassessmentAt != null) {
      final diff = event.reassessmentAt!.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        _secondsRemaining = diff;
        _startTimerTicker();
      } else {
        _secondsRemaining = 0;
        _isTimerActive = false;
      }
    }
  }

  void _startTimerTicker() {
    _timer?.cancel();
    _isTimerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
        setState(() => _isTimerActive = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tempo de reavaliação atingido (20 min). Verifique o sopro e a respiração da criança.'),
            backgroundColor: HCColors.redMain,
            duration: Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
      _secondsRemaining = 20 * 60;
    });

    _startTimerTicker();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dose de resgate ($medicationName) registrada! Reavaliar em 20 minutos.'),
          backgroundColor: HCColors.greenMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // Preserva o estado de auditoria ao sair
      },
      child: Scaffold(
        backgroundColor: isDark ? HCColors.darkBg : const Color(0xFFFAF5F5),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF450A0A) : HCColors.redMain,
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
              label: const Text('Finalizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                // 1. Banner Superior de Identificação Estrita da Criança (Contexto Trancado)
                _buildLockedPatientHeader(_profile!, isDark),

                const SizedBox(height: 14),

                // 2. Card do Plano de Resgate Médico Prescrito OU Aviso Clínico Seguro de Ausência
                if (hasRescuePlan)
                  _buildActiveRescuePlanCard(validRescuePlans, isDark)
                else
                  _buildNoRescuePlanCard(isDark),

                const SizedBox(height: 14),

                // 3. Temporizador de Reavaliação Pós-Resgate (20 minutos)
                _buildReassessmentTimerCard(isDark),

                const SizedBox(height: 14),

                // 4. Ações de Emergência Imediata (192 SAMU & GPS)
                _buildEmergencyActionButtons(isDark),

                const SizedBox(height: 14),

                // 5. Telefones de Contato Direto (Médico Assistente & Responsáveis)
                _buildDirectContactsCard(isDark),

                const SizedBox(height: 14),

                // 6. Ficha Médica Resumida para o Plantonista do PS
                _buildEmergencyMedicalSummaryCard(isDark),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Banner de Identificação Estrita da Criança (Sem possibilidade de troca rápida acidental)
  Widget _buildLockedPatientHeader(PatientProfile p, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: HCColors.redMain.withAlpha(80), width: 1.5),
        boxShadow: HCShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HCColors.redMain.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: HCColors.redMain, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      p.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? HCColors.darkText : HCColors.neutral900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HCColors.redMain,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'EM CRISE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.ageDisplay} • Peso: ${p.weightKg} kg • Recorde PFE: ${p.personalBestPef} L/min',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card de Plano de Resgate Ativo (Baseado Estritamente na Receita Médica Cadastrada)
  Widget _buildActiveRescuePlanCard(List<Map<String, dynamic>> validRescuePlans, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validRescuePlans.map((item) {
        final PrescriptionRecord presc = item['prescription'] as PrescriptionRecord;
        final PrescribedMedication med = item['medication'] as PrescribedMedication;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2),
            borderRadius: HCRadii.radiusLg,
            border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA), width: 1.5),
            boxShadow: HCShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication_liquid_outlined, color: HCColors.redMain, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'PLANO DE RESGATE MÉDICO PRESCRITO',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFFCA5A5) : HCColors.redMain,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                med.commercialName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : HCColors.neutral900,
                ),
              ),
              if (med.activeIngredient.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  med.activeIngredient,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: HCRadii.radiusMd,
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFFEE2E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dose Prescrita: ${med.dosage}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Instruções: ${med.instructions.isNotEmpty ? med.instructions : "Usar com espaçador valvulado."}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prescrito por: ${presc.doctorName} (${presc.doctorCrm}) em ${DateFormat('dd/MM/yyyy').format(presc.prescriptionDate)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? HCColors.darkTextMuted : HCColors.neutral500,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HCColors.redMain,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                    elevation: 0,
                  ),
                  onPressed: () => _recordRescueMedication(
                    prescriptionId: presc.id,
                    medicationName: med.commercialName,
                    dosage: med.dosage,
                  ),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    'Registrar Administração de Resgate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Card Seguro para quando NÃO HÁ plano de resgate cadastrado (Sem fabricação de dados)
  Widget _buildNoRescuePlanCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NENHUM PLANO DE RESGATE CADASTRADO',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Esta criança não possui prescrição médica ativa de resgate cadastrada no aplicativo.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : HCColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por segurança clínica, o aplicativo não recomenda medicamentos nem doses sem prescrição. Em caso de falta de ar ou chiado, ligue para o SAMU 192 ou procure o Pronto-Socorro imediatamente.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Temporizador Persistente de Reavaliação (20 minutos pós-resgate)
  Widget _buildReassessmentTimerCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: HCColors.primary600, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Reavaliação Pós-Resgate (20 min)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? HCColors.darkText : HCColors.primary700,
                    ),
                  ),
                ],
              ),
              if (!_isTimerActive)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _secondsRemaining = 20 * 60;
                    });
                    _startTimerTicker();
                  },
                  child: const Text('Iniciar 20 min', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isTimerActive) ...[
            Center(
              child: Text(
                _formatTimer(_secondsRemaining),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: HCColors.primary600,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (20 * 60 - _secondsRemaining) / (20 * 60),
                backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(HCColors.primary500),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ao zerar, reavalie a frequência respiratória, retração intercostal e meça o Peak Flow.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: isDark ? HCColors.darkTextMuted : HCColors.neutral600),
            ),
          ] else ...[
            Text(
              'Após administrar a dose prescrita, aguarde 20 minutos e observe a resposta clínica antes de repetir a dose ou buscar atendimento de urgência.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Botões de Ação Imediata: SAMU 192 & GPS Pronto-Socorro
  Widget _buildEmergencyActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HCColors.redMain,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                elevation: 0,
              ),
              onPressed: _callSamu,
              icon: const Icon(Icons.phone_in_talk, size: 20),
              label: const Text(
                'Ligar 192 (SAMU)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : HCColors.neutral800,
                side: BorderSide(color: isDark ? HCColors.darkBorder : HCColors.neutral300),
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
              ),
              onPressed: () => _openHospitalGps(_profile!.preferredHospital),
              icon: const Icon(Icons.directions_car, color: HCColors.primary500, size: 20),
              label: const Text(
                'GPS Pronto-Socorro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Contatos Telefônicos Diretos do Médico Assistente e Responsáveis
  Widget _buildDirectContactsCard(bool isDark) {
    final doc = _profile!.primaryDoctor;
    final docPhone = doc?.primaryPhone ?? _profile!.doctorPhone;
    final docName = doc?.fullName ?? _profile!.doctorName;
    final emergency = _profile!.primaryEmergencyContact;
    final emPhone = emergency?.phone ?? _profile!.emergencyContactPhone;
    final emName = emergency?.fullName ?? _profile!.emergencyContactName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone_outlined, color: HCColors.primary500, size: 18),
              const SizedBox(width: 8),
              Text(
                'CONTATOS MÉDICOS E FAMILIARES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? HCColors.darkText : HCColors.neutral800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (docPhone.isNotEmpty) ...[
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: HCColors.primary50,
                radius: 18,
                child: Icon(Icons.local_hospital, color: HCColors.primary600, size: 18),
              ),
              title: Text(docName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(doc?.displaySpecialty ?? 'Pneumopediatra', style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: HCColors.primary600),
                onPressed: () => _callPhone(docPhone),
              ),
            ),
            const Divider(height: 8),
          ],
          if (emPhone.isNotEmpty) ...[
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEF2F2),
                radius: 18,
                child: Icon(Icons.phone, color: HCColors.redMain, size: 18),
              ),
              title: Text(emName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Contato de Emergência (${emergency?.relationship ?? "Principal"})', style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: HCColors.redMain),
                onPressed: () => _callPhone(emPhone),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Ficha Médica Resumida para o Plantonista do Pronto-Socorro
  Widget _buildEmergencyMedicalSummaryCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined, color: HCColors.neutral700, size: 18),
              const SizedBox(width: 8),
              Text(
                'RESUMO CLÍNICO PARA O PLANTONISTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? HCColors.darkText : HCColors.neutral800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Alergias Medicamentosas:',
            _profile!.drugAllergies.isNotEmpty ? _profile!.drugAllergies.join(', ') : 'Nenhuma relatada',
            isDark: isDark,
            isWarning: _profile!.drugAllergies.isNotEmpty,
          ),
          _buildSummaryRow(
            'Histórico de UTI por Asma:',
            _profile!.hadIcuAdmission ? 'SIM (${_profile!.icuAdmissionsCount}x)' : 'Não',
            isDark: isDark,
            isWarning: _profile!.hadIcuAdmission,
          ),
          _buildSummaryRow(
            'Intubação Prévia:',
            _profile!.intubatedPast ? 'SIM (Alto Risco)' : 'Não',
            isDark: isDark,
            isWarning: _profile!.intubatedPast,
          ),
          _buildSummaryRow(
            'Tipo Sanguíneo:',
            _profile!.bloodType,
            isDark: isDark,
          ),
          _buildSummaryRow(
            'Convênio / Cartão SUS:',
            '${_profile!.healthInsurance} ${_profile!.susCardNumber.isNotEmpty ? "• SUS: ${_profile!.susCardNumber}" : ""}',
            isDark: isDark,
          ),
          _buildSummaryRow(
            'Hospital de Preferência:',
            _profile!.preferredHospital,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {required bool isDark, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.w500,
                color: isWarning ? HCColors.redMain : (isDark ? HCColors.darkTextMuted : HCColors.neutral600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.w600,
                color: isWarning ? HCColors.redMain : (isDark ? HCColors.darkText : HCColors.neutral900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
