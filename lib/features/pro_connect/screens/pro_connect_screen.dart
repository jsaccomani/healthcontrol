import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import 'package:clinical_core/clinical_core.dart';

class ProConnectScreen extends StatefulWidget {
  final String? patientId;
  const ProConnectScreen({super.key, this.patientId});

  @override
  State<ProConnectScreen> createState() => _ProConnectScreenState();
}

class _ProConnectScreenState extends State<ProConnectScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  List<PatientProfile> _allProfiles = [];
  PatientProfile? _profile;
  String _pairingCode = '...';
  List<HealthControlEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(targetId: widget.patientId);
  }

  Future<void> _loadData({String? targetId}) async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final profile = await _storageService.getPatientProfile(patientId: targetId);
    final code = await _storageService.getOrGenerateDoctorPairingCode(patientId: profile.id);
    final entries = await _storageService.getHealthEntries(patientId: profile.id);
    if (!mounted) return;
    setState(() {
      _allProfiles = profiles;
      _profile = profile;
      _pairingCode = code;
      _entries = entries;
      _isLoading = false;
    });
  }

  void _switchChild(PatientProfile target) {
    _loadData(targetId: target.id);
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _pairingCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chave copiada! Envie para o WhatsApp do seu médico ou clínica.'),
        backgroundColor: HCColors.greenMain,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: HCLoadingState(message: 'Carregando conexão com médico...')),
      );
    }

    final totalRescueCount = _entries
        .expand((e) => e.medications)
        .where((m) => m.type == MedicationType.rescue)
        .length;

    final mouthRinsePercent = _entries.isEmpty
        ? 100
        : ((_entries.where((e) => e.mouthRinseCompleted).length / _entries.length) * 100).round();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Conexão Health Control Pro',
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
              // Identificação do Paciente Selecionado
              HCChildContextBadge(
                profile: _profile!,
                onSwitchTap: _openChildSelectorSheet,
              ),
              const SizedBox(height: 14),

              // Banner de Apresentação
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: HCRadii.radiusLg,
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            borderRadius: HCRadii.radiusSm,
                          ),
                          child: const Icon(Icons.verified, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Health Control Pro (Médicos)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Seu médico ou clínica utiliza o painel Pro para acompanhar o prontuário de ${_profile!.name}, descompensações e laudos em tempo real.',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),

              if (_profile!.primaryDoctor != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: HCRadii.radiusMd,
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primarySubtle,
                        radius: 18,
                        child: Icon(Icons.local_hospital, color: theme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile!.primaryDoctor!.fullName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
                            ),
                            Text(
                              '${_profile!.primaryDoctor!.displaySpecialty}${_profile!.primaryDoctor!.licenseNumber != null ? " • ${_profile!.primaryDoctor!.licenseNumber}" : ""}',
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Card da Chave de Acesso
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: HCRadii.radiusLg,
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'CHAVE DE ACESSO EXCLUSIVA: ${_profile!.name.toUpperCase()}',
                      style: HCTypography.label.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pairingCode,
                      style: HCTypography.clinicalValueLarge.copyWith(
                        fontSize: 32,
                        letterSpacing: 4,
                        color: theme.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta chave concede acesso ReBAC seguro apenas aos dados de ${_profile!.name}. Outros filhos não são compartilhados.',
                      style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    HCPrimaryButton(
                      label: 'Copiar Chave para Enviar',
                      icon: Icons.copy,
                      onPressed: _copyToClipboard,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Resumo Clínico para a Próxima Consulta
              Text(
                'Resumo para a Próxima Consulta Médica',
                style: HCTypography.title.copyWith(fontSize: 15, color: theme.textPrimary),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildConsultationStat(
                      context: context,
                      title: 'Uso de Resgate',
                      value: '$totalRescueCount doses',
                      subtitle: 'Bombinhas no período',
                      color: totalRescueCount > 2 ? theme.warning : theme.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildConsultationStat(
                      context: context,
                      title: 'Higiene Bucal',
                      value: '$mouthRinsePercent%',
                      subtitle: 'Prevenção de sapinho',
                      color: theme.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationStat({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = context.hcTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: HCTypography.caption.copyWith(fontWeight: FontWeight.bold, color: theme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: HCTypography.title.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: HCTypography.caption.copyWith(color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
