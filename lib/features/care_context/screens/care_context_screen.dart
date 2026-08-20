import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../main.dart' show appThemeModeNotifier;
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/screens/home_screen.dart';
import '../../crisis/screens/crisis_screen.dart';
import '../widgets/child_context_card.dart';
import '../widgets/crisis_entry_card.dart';
import '../widgets/crisis_child_selector.dart';

/// Tela de Entrada e Contexto de Cuidado (CareContextScreen).
/// Central de Decisão: "Quem você vai cuidar agora?"
///
/// Princípios:
/// - Alta velocidade (não carrega prescrições, histórico ou event logs).
/// - 3 ações em segundos: Selecionar Criança, Adicionar Criança ou Iniciar Crise.
/// - Sofisticada mesmo com 1 criança, permitindo whitespace limpo.
class CareContextScreen extends StatefulWidget {
  const CareContextScreen({super.key});

  @override
  State<CareContextScreen> createState() => _CareContextScreenState();
}

class _CareContextScreenState extends State<CareContextScreen> {
  final HealthStorageService _storageService = HealthStorageService();
  List<PatientProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  void _selectChildAndOpenHome(PatientProfile profile) async {
    await _storageService.setSelectedProfileId(profile.id);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(initialPatientId: profile.id),
      ),
    ).then((_) => _loadProfiles());
  }

  void _handleCrisisEntry() {
    if (_profiles.isEmpty) {
      _showAddChildDialog();
      return;
    }

    CrisisChildSelector.show(
      context: context,
      profiles: _profiles,
      onChildSelected: (selectedProfile) => _openCrisisScreen(selectedProfile.id),
    );
  }

  void _openCrisisScreen(String patientId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrisisScreen(patientId: patientId),
      ),
    ).then((_) => _loadProfiles());
  }

  Future<void> _showAddChildDialog() async {
    final created = await HCAddChildDialog.show(
      context: context,
      onChildCreated: (c) {},
    );
    if (created != null) {
      await _storageService.setSelectedProfileId(created.id);
      _loadProfiles();
      _selectChildAndOpenHome(created);
    }
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aparência e Tema',
                    style: HCTypography.heading.copyWith(
                      fontSize: 16,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.brightness_auto, color: theme.textPrimary),
                    title: Text('Padrão do Sistema', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.system
                        ? Icon(Icons.check, color: theme.primary)
                        : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.system);
                      appThemeModeNotifier.value = ThemeMode.system;
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.light_mode, color: theme.textPrimary),
                    title: Text('Modo Claro (Calm Healthcare)', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.light
                        ? Icon(Icons.check, color: theme.primary)
                        : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.light);
                      appThemeModeNotifier.value = ThemeMode.light;
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dark_mode, color: theme.textPrimary),
                    title: Text('Modo Noturno (Nocturnal Healthcare)', style: TextStyle(color: theme.textPrimary)),
                    trailing: currentMode == ThemeMode.dark
                        ? Icon(Icons.check, color: theme.primary)
                        : null,
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

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primarySubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.air, color: theme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Health Control',
              style: HCTypography.heading.copyWith(
                fontSize: 16,
                letterSpacing: -0.2,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.textSecondary,
            ),
            tooltip: 'Alternar Tema',
            onPressed: _showThemeSelector,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: HCLoadingState(message: 'Carregando...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: HCResponsiveContainer(
                maxWidth: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Componente de Emergência Premium (Sempre evidente, sem ser assustador)
                    CrisisEntryCard(onTap: _handleCrisisEntry),

                    const SizedBox(height: 28),

                    // 2. Subtítulo Contextual Curto ("Quem você vai cuidar agora?")
                    Text(
                      'Quem você vai cuidar agora?',
                      style: HCTypography.heading.copyWith(
                        fontSize: 20,
                        letterSpacing: -0.3,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecione a criança para acompanhar a rotina de saúde.',
                      style: HCTypography.bodySmall.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Estados: Empty State vs Lista de Crianças
                    if (_profiles.isEmpty)
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.primarySubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.family_restroom,
                                size: 36,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Vamos começar pelo cadastro da criança.',
                              textAlign: TextAlign.center,
                              style: HCTypography.title.copyWith(
                                fontSize: 16,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Cadastre o perfil para acompanhar o controle da asma, receitas e orientações de emergência.',
                              textAlign: TextAlign.center,
                              style: HCTypography.bodySmall.copyWith(
                                color: theme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            HCPrimaryButton(
                              label: 'Adicionar Criança',
                              icon: Icons.person_add_alt_1,
                              onPressed: _showAddChildDialog,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Lista de Crianças
                      ..._profiles.map(
                        (profile) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ChildContextCard(
                            profile: profile,
                            onSelect: () => _selectChildAndOpenHome(profile),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Botão de Adicionar Criança
                      HCOutlineButton(
                        label: _profiles.length == 1 ? 'Adicionar Outra Criança' : 'Adicionar Criança',
                        icon: Icons.person_add_alt_1,
                        width: double.infinity,
                        onPressed: _showAddChildDialog,
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
