import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
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
      const SnackBar(content: Text('Chave copiada! Envie para o WhatsApp do seu médico ou clínica.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
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
      appBar: AppBar(
        title: const Text('Conexão Health Control Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(8),
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
                    'Seu médico ou clínica utiliza o painel Pro para acompanhar o prontuário de ${_profile!.name}, descompensações e laudos do SUS em tempo real.',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card da Chave de Acesso
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    'CHAVE DE ACESSO EXCLUSIVA: ${_profile!.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pairingCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppTheme.primaryTeal,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta chave concede acesso ReBAC seguro apenas aos dados de ${_profile!.name}. Outros filhos não são compartilhados.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar Chave para Enviar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Resumo Clínico para a Próxima Consulta
            const Text(
              'Resumo para a Próxima Consulta Médica',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildConsultationStat(
                    title: 'Uso de Resgate',
                    value: '$totalRescueCount doses',
                    subtitle: 'Bombinhas no período',
                    color: totalRescueCount > 2 ? AppTheme.zoneYellow : AppTheme.zoneGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildConsultationStat(
                    title: 'Higiene Bucal',
                    value: '$mouthRinsePercent%',
                    subtitle: 'Prevenção de sapinho',
                    color: AppTheme.zoneGreen,
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
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
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
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
