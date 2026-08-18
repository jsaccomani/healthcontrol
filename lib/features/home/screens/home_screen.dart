import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../diary/screens/new_entry_screen.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../cact/screens/cact_quiz_screen.dart';
import '../../physio/screens/physio_screen.dart';
import '../../pro_connect/screens/pro_connect_screen.dart';
import '../../profile/screens/profile_screen.dart';

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
    final allProfiles = await _storageService.getAllProfiles();
    final prof = await _storageService.getPatientProfile();
    final entries = await _storageService.getHealthEntries();
    setState(() {
      _profiles = allProfiles;
      _profile = prof;
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _switchChild(PatientProfile target) async {
    await _storageService.setSelectedProfileId(target.id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    final latestEntry = _entries.isNotEmpty ? _entries.first : null;
    final currentZone = latestEntry?.peakFlowZone ?? ActionZoneType.green;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.air, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Health Control: Asma',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Conectar com Médico (Health Control Pro)',
            icon: const Icon(Icons.medical_services_outlined, color: AppTheme.primaryTeal),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProConnectScreen()),
              );
              _loadData();
            },
          ),
          IconButton(
            tooltip: 'Perfil Clínico',
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
        onRefresh: _loadData,
        color: AppTheme.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com Perfil do Filho
              _buildChildHeaderCard(),

              const SizedBox(height: 14),

              // Card Dinâmico de Status Atual (Verde / Amarelo / Vermelho)
              _buildClinicalStatusCard(latestEntry, currentZone),

              const SizedBox(height: 16),

              // Botões de Ação Rápida
              _buildActionButtonsGrid(),

              const SizedBox(height: 20),

              // Título da Linha do Tempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Linha do Tempo & Versões',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_entries.length} registros',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Lista de Lançamentos Versionados
              if (_entries.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) => _buildVersionedEntryCard(_entries[idx]),
                ),

              const SizedBox(height: 20),

              // Disclaimer Médico & LGPD Footer
              _buildLegalDisclaimerFooter(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewEntryScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppTheme.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Lançamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildChildHeaderCard() {
    return Column(
      children: [
        if (_profiles.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._profiles.map((p) {
                  final isSel = p.id == _profile!.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: ChoiceChip(
                      avatar: Text(p.gender == 'Feminino' ? '👧' : '👦', style: const TextStyle(fontSize: 12)),
                      label: Text(p.name, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (_) => _switchChild(p),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 14, color: AppTheme.primaryTeal),
                    label: const Text('Novo Filho', style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  _profile!.gender == 'Feminino' ? '👧' : '👦',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _profile!.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _profile!.ageDisplay,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Melhor PFE: ${_profile!.personalBestPef} L/min • ${_profile!.weightKg} kg • Sangue ${_profile!.bloodType}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ficha Completa & Anamnese',
                icon: const Icon(Icons.edit_note, color: AppTheme.primaryTeal),
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
        ),
      ],
    );
  }

  Widget _buildClinicalStatusCard(HealthControlEntry? entry, ActionZoneType zone) {
    Color zoneColor;
    Color bgColor;
    String zoneTitle;
    String zoneDescription;
    IconData zoneIcon;

    switch (zone) {
      case ActionZoneType.green:
        zoneColor = AppTheme.zoneGreen;
        bgColor = AppTheme.zoneGreenBg;
        zoneTitle = '🟢 ZONA VERDE (Asma Estável)';
        zoneDescription = 'Respiração livre, sem sintomas agudos. Mantenha a medicação preventiva e a rotina normal.';
        zoneIcon = Icons.check_circle_outline;
        break;
      case ActionZoneType.yellow:
        zoneColor = AppTheme.zoneYellow;
        bgColor = AppTheme.zoneYellowBg;
        zoneTitle = '🟡 ZONA AMARELA (Início de Descompensação)';
        zoneDescription = 'PFE entre 50-79% ou tosse/cansaço. Administre o broncodilatador de resgate com espaçador.';
        zoneIcon = Icons.warning_amber_rounded;
        break;
      case ActionZoneType.red:
        zoneColor = AppTheme.zoneRed;
        bgColor = AppTheme.zoneRedBg;
        zoneTitle = '🔴 ZONA VERMELHA (Emergência Médica)';
        zoneDescription = 'PFE < 50% ou tiragem severa. Faça resgate imediato e dirija-se ao Pronto-Socorro.';
        zoneIcon = Icons.emergency;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: zoneColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(zoneIcon, color: zoneColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  zoneTitle,
                  style: TextStyle(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (entry != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(entry.timestamp),
                    style: TextStyle(fontSize: 11, color: zoneColor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            zoneDescription,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniMetric(
                'Último PFE',
                entry != null ? '${entry.peakFlowBest} L/min' : '--',
                Icons.air,
                zoneColor,
              ),
              const SizedBox(width: 10),
              _buildMiniMetric(
                'Saturação (SpO2)',
                entry != null ? '${entry.spo2}%' : '--',
                Icons.favorite_outline,
                entry != null && entry.spo2 < 92 ? AppTheme.zoneRed : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 10),
              _buildMiniMetric(
                'Higiene Bucal',
                entry?.mouthRinseCompleted == true ? 'Feita ✅' : 'Pendente ⚠️',
                Icons.clean_hands_outlined,
                entry?.mouthRinseCompleted == true ? AppTheme.zoneGreen : AppTheme.zoneYellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: '🚨 Modo Emergência',
                subtitle: 'Mostrar ao Médico do PS',
                color: AppTheme.zoneRed,
                bgColor: AppTheme.zoneRedBg,
                icon: Icons.emergency,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                label: '🫁 Fisioterapia',
                subtitle: 'Voldyne, Shaker & AMIB',
                color: AppTheme.primaryTeal,
                bgColor: AppTheme.primaryLight.withOpacity(0.5),
                icon: Icons.fitness_center,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PhysioScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: '📝 Teste c-ACT',
                subtitle: 'Escore Pediátrico Mensal',
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
                icon: Icons.quiz_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CactQuizScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                label: '👨‍⚕️ Health Control Pro',
                subtitle: 'Pareamento com Médico',
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
                icon: Icons.share_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProConnectScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionedEntryCard(HealthControlEntry entry) {
    Color badgeColor;
    switch (entry.peakFlowZone) {
      case ActionZoneType.green:
        badgeColor = AppTheme.zoneGreen;
        break;
      case ActionZoneType.yellow:
        badgeColor = AppTheme.zoneYellow;
        break;
      case ActionZoneType.red:
        badgeColor = AppTheme.zoneRed;
        break;
    }

    final dateStr = DateFormat('dd/MM HH:mm').format(entry.timestamp);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.versionTag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.authorName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PFE: ${entry.peakFlowBest} L/min',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SpO2: ${entry.spo2}%',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
              if (entry.mouthRinseCompleted) ...[
                const SizedBox(width: 12),
                const Icon(Icons.clean_hands_outlined, size: 14, color: AppTheme.zoneGreen),
                const SizedBox(width: 2),
                const Text('Bochecho OK', style: TextStyle(fontSize: 11, color: AppTheme.zoneGreen)),
              ],
            ],
          ),
          if (entry.medications.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.medications.map((m) {
                final isRescue = m.type == MedicationType.rescue;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRescue ? AppTheme.zoneYellowBg : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isRescue ? AppTheme.zoneYellow.withOpacity(0.5) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    '💊 ${m.name} (${m.dosage})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isRescue ? FontWeight.bold : FontWeight.normal,
                      color: isRescue ? const Color(0xFFB45309) : const Color(0xFF334155),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (entry.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Obs: ${entry.notes}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_toggle_off, color: Color(0xFF94A3B8), size: 40),
          SizedBox(height: 8),
          Text(
            'Nenhum controle registrado ainda.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            'Clique no botão abaixo para adicionar a primeira medição do seu filho.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimerFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Aviso Médico & Proteção de Dados (LGPD)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'O Health Control é uma ferramenta de suporte ao autogerenciamento respiratório e NÃO substitui o diagnóstico ou a consulta médica. Em caso de emergência com seu filho, ligue para o SAMU (192) ou vá ao Pronto-Socorro.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showLegalTermsModal,
            child: const Text(
              '⚖️ Ler Termos de Uso, Privacidade LGPD & Resolução CFM 1.331/89 ➔',
              style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollCtrl,
            children: const [
              Center(
                child: Text(
                  '⚖️ Termos de Uso e Privacidade LGPD',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '1. Finalidade e Disclaimer Médico',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                'O Health Control: Asma visa auxiliar pais e cuidadores na rotina de registro respiratório e adesão terapêutica. Não realiza diagnósticos automáticos nem prescreve doses sem supervisão médica.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              SizedBox(height: 12),
              Text(
                '2. Proteção de Dados de Menores (Art. 14 da LGPD)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                'O tratamento dos dados de saúde da criança é realizado exclusivamente com o consentimento do responsável legal e no melhor interesse do menor. Os dados são armazenados sob criptografia local AES-256.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              SizedBox(height: 12),
              Text(
                '3. Guarda e Imutabilidade (CFM nº 1.331/89)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 4),
              Text(
                'Cada lançamento gera um hash criptográfico (SHA-256) garantindo que o histórico não sofra adulterações retroativas e tenha garantia de guarda legal de 20 anos.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
