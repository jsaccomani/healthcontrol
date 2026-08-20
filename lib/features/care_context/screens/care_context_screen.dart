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
/// Responde imediatamente: "Quem você vai cuidar agora?"
/// Ponto central de decisão sem carga de dados pesados desnecessários.
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

  void _showAddChildDialog() {
    final nameCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final pefCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? HCColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(
            color: isDark ? HCColors.darkBorder : HCColors.neutral200,
          ),
        ),
        title: Text(
          'Cadastrar Nova Criança',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? HCColors.darkText : HCColors.neutral900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : HCColors.neutral900),
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Ex: Helena Saccomani',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : HCColors.neutral900),
                decoration: const InputDecoration(
                  labelText: 'Altura (cm)',
                  hintText: '105',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : HCColors.neutral900),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: '17.5',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pefCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : HCColors.neutral900),
                decoration: const InputDecoration(
                  labelText: 'Recorde PFE (L/min)',
                  hintText: '180',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? HCColors.darkTextMuted : HCColors.neutral600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HCColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
              elevation: 0,
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final height = double.tryParse(heightCtrl.text.trim()) ?? 100.0;
              final weight = double.tryParse(weightCtrl.text.trim()) ?? 16.0;
              final pef = int.tryParse(pefCtrl.text.trim()) ?? 160;

              final created = await _storageService.createNewChildProfile(
                name: name,
                birthDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
                gender: 'Não informado',
                heightCm: height,
                weightKg: weight,
                personalBestPef: pef,
              );

              if (ctx.mounted) Navigator.of(ctx).pop();
              _loadProfiles();
              _selectChildAndOpenHome(created);
            },
            child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
                      color: isDark ? HCColors.darkText : HCColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.brightness_auto),
                    title: const Text('Padrão do Sistema'),
                    trailing: currentMode == ThemeMode.system
                        ? const Icon(Icons.check, color: HCColors.primary500)
                        : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.system);
                      appThemeModeNotifier.value = ThemeMode.system;
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.light_mode),
                    title: const Text('Modo Claro (Calm Healthcare)'),
                    trailing: currentMode == ThemeMode.light
                        ? const Icon(Icons.check, color: HCColors.primary500)
                        : null,
                    onTap: () async {
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _storageService.setThemeMode(ThemeMode.light);
                      appThemeModeNotifier.value = ThemeMode.light;
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Modo Noturno (Nocturnal Healthcare)'),
                    trailing: currentMode == ThemeMode.dark
                        ? const Icon(Icons.check, color: HCColors.primary500)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? HCColors.darkBg : HCColors.neutral50,
      appBar: AppBar(
        backgroundColor: isDark ? HCColors.darkSurface : Colors.white,
        foregroundColor: isDark ? HCColors.darkText : HCColors.neutral900,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? HCColors.primary900.withAlpha(90) : HCColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.air, color: HCColors.primary500, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Health Control',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.2,
                color: isDark ? HCColors.darkText : HCColors.neutral900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
            ),
            tooltip: 'Alternar Tema',
            onPressed: _showThemeSelector,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HCColors.primary500))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: HCResponsiveContainer(
                maxWidth: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Ação Global de Crise (SOS)
                    CrisisEntryCard(onTap: _handleCrisisEntry),

                    const SizedBox(height: 24),

                    // 2. Pergunta Central de Contexto
                    Text(
                      'Quem você vai cuidar agora?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? HCColors.darkText : HCColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecione a criança para acompanhar a rotina diária de saúde.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Lista de Perfis das Crianças
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

                    // 4. Botão de Adicionar Nova Criança
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? HCColors.primary300 : HCColors.primary600,
                          side: BorderSide(
                            color: isDark ? HCColors.darkBorder : HCColors.primary200,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                        ),
                        onPressed: _showAddChildDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          'Adicionar Criança',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
