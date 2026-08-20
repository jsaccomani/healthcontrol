import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../main.dart' show appThemeModeNotifier;
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../crisis/screens/crisis_screen.dart';
import '../../cact/screens/cact_quiz_screen.dart';
import '../../physio/screens/physio_screen.dart';
import '../../pro_connect/screens/pro_connect_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../prescription/screens/prescription_scan_screen.dart';
import '../widgets/home_header_card.dart';
import '../widgets/health_status_card.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/quick_actions_modal_sheet.dart';
import '../widgets/history_entry_tile.dart';

/// Tela Principal do Health Control (Foco do Cuidador).
/// Informações essenciais compreendidas em ~3 segundos:
/// A. Filho Selecionado
/// B. Estado de Saúde Diário
/// C. Ação Primária ("Registrar")
/// D. Ações Rápidas Secundárias (Medicação, Pico de Fluxo, Sintomas, Crise, Nota)
/// E. Histórico Recente Relevante
class HomeScreen extends StatefulWidget {
  final String? initialPatientId;

  const HomeScreen({super.key, this.initialPatientId});

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

  Future<void> _loadData({String? targetPatientId}) async {
    setState(() => _isLoading = true);
    final targetId = targetPatientId ?? widget.initialPatientId;
    final results = await Future.wait([
      _storageService.getAllProfiles(),
      _storageService.getPatientProfile(patientId: targetId),
      _storageService.getHealthEntries(patientId: targetId),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: HCColors.primary500, size: 20),
            SizedBox(width: 8),
            Text('Integridade da Versão', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsável: ${entry.authorName.isNotEmpty ? entry.authorName : "Cuidador"} (${entry.authorRole})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Data e Hora: ${entry.timestamp.day.toString().padLeft(2, "0")}/${entry.timestamp.month.toString().padLeft(2, "0")} às ${entry.timestamp.hour.toString().padLeft(2, "0")}:${entry.timestamp.minute.toString().padLeft(2, "0")}',
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(height: 16),
            Text(
              'Identificador / Hash do Registro (CFM 1.331/89):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral500,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              entry.id,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: HCColors.primary500),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  Future<void> _showAddChildDialog() async {
    final newChild = await HCAddChildDialog.show(
      context: context,
      onChildCreated: (child) {},
    );
    if (newChild != null) {
      await _storageService.setSelectedProfileId(newChild.id);
      await _loadData();
    }
  }

  void _openChildSelectorSheet() {
    HCChildSelectorSheet.show(
      context: context,
      profiles: _profiles,
      selectedProfileId: _profile!.id,
      onSelect: _switchChild,
      onAddNew: _showAddChildDialog,
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final currentMode = appThemeModeNotifier.value;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Material(
          color: isDark ? HCColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Aparência e Tema',
                  style: HCTypography.heading.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('Padrão do Sistema'),
                  trailing: currentMode == ThemeMode.system ? const Icon(Icons.check, color: HCColors.primary500) : null,
                  onTap: () async {
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _storageService.setThemeMode(ThemeMode.system);
                    appThemeModeNotifier.value = ThemeMode.system;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('Modo Claro (Calm Healthcare)'),
                  trailing: currentMode == ThemeMode.light ? const Icon(Icons.check, color: HCColors.primary500) : null,
                  onTap: () async {
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _storageService.setThemeMode(ThemeMode.light);
                    appThemeModeNotifier.value = ThemeMode.light;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Modo Noturno (Nocturnal Healthcare)'),
                  trailing: currentMode == ThemeMode.dark ? const Icon(Icons.check, color: HCColors.primary500) : null,
                  onTap: () async {
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _storageService.setThemeMode(ThemeMode.dark);
                    appThemeModeNotifier.value = ThemeMode.dark;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  void _openDirectAction(String actionKey) {
    HCQuickActionsModalSheet.show(
      context: context,
      profile: _profile!,
      initialView: actionKey,
      onEntrySaved: _loadData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _profile == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: isDark ? HCColors.primary400 : HCColors.primary500)),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;
    final currentZone = latest?.peakFlowZone ?? ActionZoneType.green;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? HCColors.darkSurfaceElevated : HCColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.air, color: HCColors.primary500, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Health Control',
              style: HCTypography.heading.copyWith(fontSize: 16),
            ),
          ],
        ),
        actions: [
          // 1. Seletor Canônico de Filho (Persistent Context)
          HCChildContextBadge(
            profile: _profile!,
            isCompact: true,
            onSwitchTap: _openChildSelectorSheet,
          ),
          const SizedBox(width: 4),

          // 2. Seletor de Tema (System / Light / Dark)
          IconButton(
            tooltip: 'Aparência e Tema',
            icon: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
            ),
            onPressed: _showThemeSelector,
          ),

          // 3. Menu de Recursos Secundários & Navegação Especializada
          PopupMenuButton<String>(
            tooltip: 'Mais Recursos',
            icon: Icon(
              Icons.more_vert,
              color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(patientId: _profile!.id)),
                  );
                  _loadData();
                  break;
                case 'prescription':
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
                  break;
                case 'cact':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CactQuizScreen(patientId: _profile!.id)),
                  );
                  _loadData();
                  break;
                case 'physio':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PhysioScreen(patientId: _profile!.id)),
                  );
                  _loadData();
                  break;
                case 'pro_connect':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProConnectScreen(patientId: _profile!.id)),
                  );
                  _loadData();
                  break;
                case 'emergency':
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CrisisScreen(patientId: _profile!.id)),
                  );
                  _loadData();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 10),
                    Text('Ficha Completa da Criança'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'prescription',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Plano de Ação & Receitas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cact',
                child: Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Questionário Mensal c-ACT'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'physio',
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Fisioterapia / CPAP (AMIB)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pro_connect',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_2, size: 18),
                    SizedBox(width: 10),
                    Text('Conectar ao Médico (Pro)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency, size: 18, color: HCColors.redMain),
                    SizedBox(width: 10),
                    Text('Modo Crise / Emergência', style: TextStyle(color: HCColors.redMain)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HCColors.primary500,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: HCResponsiveContainer(
            maxWidth: 840,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. Identificação do Filho Selecionado
                HomeHeaderCard(
                  profile: _profile!,
                  onSwitchChild: _openChildSelectorSheet,
                  onOpenProfile: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(patientId: _profile!.id)),
                    );
                    _loadData();
                  },
                ),

                const SizedBox(height: 12),

                // B. Estado de Saúde Diário
                HealthStatusCard(
                  latestEntry: latest,
                  currentZone: currentZone,
                  profile: _profile!,
                  onSosPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CrisisScreen(patientId: _profile!.id)),
                  ),
                ),

                const SizedBox(height: 14),

                // C & D. Ações Rápidas: Primária ("Registrar") e Secundárias em Chips
                QuickActionButtons(
                  onRegister: () {
                    HCQuickActionsModalSheet.show(
                      context: context,
                      profile: _profile!,
                      onEntrySaved: _loadData,
                    );
                  },
                  onDirectAction: _openDirectAction,
                  onSosPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CrisisScreen(patientId: _profile!.id)),
                  ),
                ),

                const SizedBox(height: 20),

                // E. Histórico Recente Relevante
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Histórico Recente',
                      style: HCTypography.subHeading.copyWith(
                        color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? HCColors.darkSurfaceElevated : HCColors.neutral100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_entries.length} anotações',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? HCColors.darkTextSecondary : HCColors.neutral500,
                          fontWeight: FontWeight.w600,
                        ),
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
                      color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
                      borderRadius: HCRadii.radiusLg,
                      border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit_calendar_outlined,
                          color: isDark ? HCColors.darkTextMuted : HCColors.neutral400,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma anotação gravada ainda.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? HCColors.darkTextPrimary : HCColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque em "Registrar" para anotar o sopro, bombinha ou sintoma.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? HCColors.darkTextSecondary : HCColors.neutral500,
                          ),
                        ),
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
