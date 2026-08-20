import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../main.dart' show appThemeModeNotifier;
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/screens/home_screen.dart';
import '../../crisis/screens/crisis_screen.dart';

/// Tela de Entrada e Contexto de Cuidado (CareContextScreen).
/// Estabelece o foco do cuidador:
/// 1. Qual criança está sendo cuidada agora?
/// 2. Entrada direta para a rotina diária.
/// 3. Acesso imediato ao Modo Crise com confirmação segura de paciente.
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
    if (_profiles.isEmpty) return;

    if (_profiles.length == 1) {
      _confirmSingleChildCrisis(_profiles.first);
    } else {
      _showMultiChildCrisisSelector();
    }
  }

  void _confirmSingleChildCrisis(PatientProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? HCColors.darkSurface : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.emergency, color: HCColors.redMain, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${profile.name} está em crise?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? HCColors.darkText : HCColors.neutral900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Você será direcionado para o plano de resgate médico e contatos de urgência específicos de ${profile.name.split(" ").first}.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
            height: 1.4,
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
              backgroundColor: HCColors.redMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _openCrisisScreen(profile.id);
            },
            child: const Text('Continuar para Modo Crise', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMultiChildCrisisSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency, color: HCColors.redMain, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Qual criança está em crise?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? HCColors.darkText : HCColors.neutral900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecione a criança para carregar a prescrição de resgate correta.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                  ),
                ),
                const SizedBox(height: 16),
                ..._profiles.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: HCRadii.radiusMd,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: HCColors.redMain.withAlpha(30),
                          child: const Icon(Icons.person, color: HCColors.redMain),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : HCColors.neutral900,
                          ),
                        ),
                        subtitle: Text(
                          '${p.ageDisplay} • Recorde PFE: ${p.personalBestPef} L/min',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: HCColors.redMain),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _openCrisisScreen(p.id);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
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
        title: const Text('Cadastrar Nova Criança', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome Completo', hintText: 'Ex: Helena Saccomani'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura (cm)', hintText: '105'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso (kg)', hintText: '17.5'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pefCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Melhor Sopro PFE (L/min)', hintText: '180'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HCColors.primary500,
              foregroundColor: Colors.white,
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
            child: const Text('Cadastrar'),
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
                color: HCColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: HCColors.primary500, size: 18),
            ),
            const SizedBox(width: 8),
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
                    // 1. Ação Prominente de Modo Crise (SOS)
                    _buildProminentCrisisAction(isDark),

                    const SizedBox(height: 24),

                    // 2. Pergunta Principal de Contexto
                    Text(
                      _profiles.length == 1 ? 'Cuidado Diário' : 'Quem você vai cuidar agora?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? HCColors.darkText : HCColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profiles.length == 1
                          ? 'Abra a rotina diária de medições, sintomas e medicações.'
                          : 'Selecione o perfil da criança para abrir o diário de monitoramento.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Lista de Perfis das Crianças
                    ..._profiles.map((profile) => _buildChildCard(profile, isDark)),

                    const SizedBox(height: 12),

                    // 4. Botão de Adicionar Nova Criança
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HCColors.primary600,
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

  /// Card de Ação Prominente de Crise ("Meu filho está em crise")
  Widget _buildProminentCrisisAction(bool isDark) {
    return Material(
      color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2),
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _handleCrisisEntry,
        borderRadius: HCRadii.radiusLg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HCColors.redMain,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profiles.length == 1
                          ? '${_profiles.first.name.split(" ").first} está em crise?'
                          : 'Meu filho está em crise',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFFCA5A5) : HCColors.redMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Acesse o plano de resgate médico imediato e telefones de emergência.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: HCColors.redMain),
            ],
          ),
        ),
      ),
    );
  }

  /// Card do Perfil da Criança (Estilo Calmo e Confiável)
  Widget _buildChildCard(PatientProfile profile, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? HCColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(
            color: isDark ? HCColors.darkBorder : HCColors.neutral200,
          ),
        ),
        child: InkWell(
          onTap: () => _selectChildAndOpenHome(profile),
          borderRadius: HCRadii.radiusLg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar da criança
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: HCColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : 'C',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: HCColors.primary600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Dados de identificação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? HCColors.darkText : HCColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${profile.ageDisplay} • Recorde: ${profile.personalBestPef} L/min',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (profile.healthInsurance.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : HCColors.neutral100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            profile.healthInsurance,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Ícone de Navegação
                const Icon(Icons.arrow_forward_ios, size: 14, color: HCColors.neutral400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
