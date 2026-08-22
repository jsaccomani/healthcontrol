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
    // Prioridade correta: (1) id explícito desta chamada; (2) o paciente
    // já carregado nesta tela (_profile, reflete a última troca feita
    // pelo usuário); (3) só na primeiríssima carga, antes de _profile
    // existir, usa o id com que a tela foi aberta. Usar
    // widget.initialPatientId como fallback permanente era a causa raiz
    // do bug de troca não "colar" — qualquer refresh subsequente
    // revertia para o paciente original da instância.
    final targetId = targetPatientId ?? _profile?.id ?? widget.initialPatientId;
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
    await _loadData(targetPatientId: target.id);
  }

  void _showHashAuditDialog(HealthControlEntry entry) {
    final theme = context.hcTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(color: theme.border),
        ),
        backgroundColor: theme.surface,
        title: Row(
          children: [
            Icon(Icons.verified, color: theme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Integridade da Versão',
              style: HCTypography.title.copyWith(fontSize: 15, color: theme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsável: ${entry.authorName.isNotEmpty ? entry.authorName : "Cuidador"} (${entry.authorRole})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Data e Hora: ${entry.timestamp.day.toString().padLeft(2, "0")}/${entry.timestamp.month.toString().padLeft(2, "0")} às ${entry.timestamp.hour.toString().padLeft(2, "0")}:${entry.timestamp.minute.toString().padLeft(2, "0")}',
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
            ),
            Divider(height: 16, color: theme.border),
            Text(
              'Identificador / Hash do Registro (CFM 1.331/89):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              entry.id,
              style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: theme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fechar', style: TextStyle(color: theme.textSecondary)),
          ),
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
      await _loadData(targetPatientId: newChild.id);
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
    final theme = context.hcTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final currentMode = appThemeModeNotifier.value;
        return Material(
          color: theme.surface,
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
                    style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.brightness_auto, color: theme.textPrimary),
                    title: Text('Padrão do Sistema', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.system ? Icon(Icons.check, color: theme.primary) : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.system);
                      appThemeModeNotifier.value = ThemeMode.system;
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.light_mode, color: theme.textPrimary),
                    title: Text('Modo Claro (Calm Healthcare)', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.light ? Icon(Icons.check, color: theme.primary) : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.light);
                      appThemeModeNotifier.value = ThemeMode.light;
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dark_mode, color: theme.textPrimary),
                    title: Text('Modo Noturno (Nocturnal Healthcare)', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.dark ? Icon(Icons.check, color: theme.primary) : null,
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
    QuickActionsModalSheet.show(
      context: context,
      profile: _profile!,
      initialAction: actionKey,
      onEntrySaved: _loadData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    if (_isLoading || _profile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: HCLoadingState(message: 'Carregando painel de cuidado...')),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;
    final currentZone = latest?.peakFlowZone;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.air, color: theme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Health Control',
              style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
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
              theme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.textSecondary,
            ),
            onPressed: _showThemeSelector,
          ),

          // 3. Menu de Recursos Secundários & Navegação Especializada
          PopupMenuButton<String>(
            tooltip: 'Mais Recursos',
            icon: Icon(
              Icons.more_vert,
              color: theme.textSecondary,
            ),
            color: theme.surface,
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
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: theme.primary),
                    const SizedBox(width: 10),
                    Text('Ficha Completa da Criança', style: TextStyle(color: theme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'prescription',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 18, color: theme.primary),
                    const SizedBox(width: 10),
                    Text('Plano de Ação & Receitas', style: TextStyle(color: theme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cact',
                child: Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 18, color: theme.primary),
                    const SizedBox(width: 10),
                    Text('Questionário Mensal c-ACT', style: TextStyle(color: theme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'physio',
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_outlined, size: 18, color: theme.primary),
                    const SizedBox(width: 10),
                    Text('Fisioterapia / CPAP (AMIB)', style: TextStyle(color: theme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pro_connect',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_2, size: 18, color: theme.primary),
                    const SizedBox(width: 10),
                    Text('Conectar ao Médico (Pro)', style: TextStyle(color: theme.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency, size: 18, color: theme.critical),
                    const SizedBox(width: 10),
                    Text('Modo Crise / Emergência', style: TextStyle(color: theme.critical)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.primary,
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
                    QuickActionsModalSheet.show(
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
                      style: HCTypography.title.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.elevatedSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.border),
                      ),
                      child: Text(
                        '${_entries.length} anotações',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_entries.isEmpty)
                  HCEmptyState(
                    title: 'Nenhuma anotação gravada ainda',
                    message: 'Toque em "Registrar" para anotar o sopro no Peak Flow, bombinhas ou sintomas de hoje.',
                    icon: Icons.edit_calendar_outlined,
                    actionLabel: 'Registrar Agora',
                    onActionPressed: () {
                      QuickActionsModalSheet.show(
                        context: context,
                        profile: _profile!,
                        onEntrySaved: _loadData,
                      );
                    },
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
