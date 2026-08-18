import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';
import '../../diary/screens/new_entry_screen.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../cact/screens/cact_quiz_screen.dart';
import '../../physio/screens/physio_screen.dart';
import '../../pro_connect/screens/pro_connect_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../prescription/screens/prescription_scan_screen.dart';
import '../widgets/home_header_card.dart';
import '../widgets/health_status_card.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/history_entry_tile.dart';
import '../widgets/pro_connect_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  List<PatientProfile> _profiles = [];
  PatientProfile? _profile;
  List<HealthControlEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _storageService.getAllProfiles(),
      _storageService.getPatientProfile(),
      _storageService.getHealthEntries(),
    ]);
    if (!mounted) return;
    setState(() {
      _profiles = results[0] as List<PatientProfile>;
      _profile = results[1] as PatientProfile;
      _entries = results[2] as List<HealthControlEntry>;
      _isLoading = false;
    });
  }

  Future<void> _switchChild(PatientProfile target) async {
    await _storageService.setSelectedProfileId(target.id);
    _loadData();
  }

  void _showHashAuditDialog(HealthControlEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppTheme.primaryTeal, size: 20),
            SizedBox(width: 8),
            Text('Integridade da Versão', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versão: ${entry.versionTag}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Responsável: ${entry.authorName} (${entry.authorRole})', style: const TextStyle(fontSize: 12)),
            const Divider(height: 16),
            const Text('Identificador / Hash do Registro (CFM 1.331/89):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            SelectableText(
              entry.id,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.primaryTeal),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;
    final currentZone = latest?.peakFlowZone ?? ActionZoneType.green;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.air, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Health Control: Asma',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ficha Completa, Remédios & Receitas',
            icon: const Icon(Icons.person_outline, color: Color(0xFF475569)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              _loadData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryTeal,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: HCResponsiveContainer(
            maxWidth: 840,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 1. Identificação do Filho
              HomeHeaderCard(
                profile: _profile!,
                allProfiles: _profiles,
                onProfileSelected: _switchChild,
                onOpenProfile: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  _loadData();
                },
              ),

              const SizedBox(height: 12),

              // 2. Card de Estado do Dia
              HealthStatusCard(
                latestEntry: latest,
                currentZone: currentZone,
                profile: _profile!,
                onSosPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
              ),

              const SizedBox(height: 14),

              // 3. Ações Rápidas
              QuickActionButtons(
                onNewEntry: () async {
                  final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const NewEntryScreen()));
                  if (created == true) _loadData();
                },
                onUpdatePrescription: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrescriptionScanScreen(
                        patientId: _profile!.id,
                        patientName: _profile!.name,
                      ),
                    ),
                  );
                  _loadData();
                },
                onSosPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
              ),

              const SizedBox(height: 18),

              // 4. Histórico Recente de Anotações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Histórico Recente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_entries.length} anotações',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_entries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.edit_calendar_outlined, color: Color(0xFF94A3B8), size: 36),
                      SizedBox(height: 8),
                      Text('Nenhuma anotação gravada ainda.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                      SizedBox(height: 4),
                      Text('Clique em "Anotar Agora 📝" para registrar o primeiro sopro ou remédio do dia.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) => HistoryEntryTile(
                    entry: _entries[idx],
                    onInspectHash: () => _showHashAuditDialog(_entries[idx]),
                  ),
                ),

              const SizedBox(height: 20),

              // 5. Integração com Médico e Fisioterapia
              ProConnectBanner(
                onOpenProConnect: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProConnectScreen())),
                onOpenCactQuiz: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CactQuizScreen())),
                onOpenPhysio: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhysioScreen())),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
}
