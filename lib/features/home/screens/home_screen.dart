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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Identificação do Filho (Simples & Acolhedora)
              _buildChildHeaderCard(),

              const SizedBox(height: 12),

              // 2. Card de Estado do Dia (Visual e em Português Claro)
              _buildCleanDailyStatusCard(latest, currentZone),

              const SizedBox(height: 14),

              // 3. Ações Rápidas (Apenas o Essencial)
              _buildEssentialActionButtons(),

              const SizedBox(height: 18),

              // 4. Histórico Recente do Dia
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
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) => _buildCleanEntryCard(_entries[idx]),
                ),

              const SizedBox(height: 16),

              // Rodapé com Termos e Aviso Médico
              _buildLegalDisclaimerFooter(),

              const SizedBox(height: 70), // Espaço para o Floating Action Button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          'Anotar Como Ele Está Agora',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
                    padding: const EdgeInsets.only(right: 6, bottom: 8),
                    child: ChoiceChip(
                      avatar: Text(p.gender == 'Feminino' ? '👧' : '👦', style: const TextStyle(fontSize: 12)),
                      label: Text(p.name, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (_) => _switchChild(p),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  _profile!.gender == 'Feminino' ? '👧' : '👦',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 10),
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _profile!.ageDisplay,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Melhor Sopro: ${_profile!.personalBestPef} L/min • ${_profile!.weightKg} kg',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  _loadData();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ficha', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios, size: 9, color: AppTheme.primaryTeal),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCleanDailyStatusCard(HealthControlEntry? latest, ActionZoneType zone) {
    Color cardColor;
    Color borderColor;
    String statusTitle;
    String statusExplanation;
    String iconEmoji;

    switch (zone) {
      case ActionZoneType.green:
        cardColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF86EFAC);
        statusTitle = 'O ${_profile!.name.split(' ').first} está bem hoje!';
        statusExplanation = 'Respiração livre e sem chiados. Mantenha a bombinha de todo dia no horário.';
        iconEmoji = '🟢';
        break;
      case ActionZoneType.yellow:
        cardColor = const Color(0xFFFEFCE8);
        borderColor = const Color(0xFFFDE047);
        statusTitle = 'Sinal de Atenção: Início de Sintomas';
        statusExplanation = 'Sopro abaixo do normal ou tosse. Dê a bombinha de resgate (Aerolin) e acompanhe.';
        iconEmoji = '🟡';
        break;
      case ActionZoneType.red:
        cardColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFCA5A5);
        statusTitle = 'Crise Aguda: Falta de Ar Forte!';
        statusExplanation = 'Dê o remédio de resgate imediatamente e procure atendimento médico no Pronto-Socorro.';
        iconEmoji = '🔴';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(iconEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
              if (latest != null)
                Text(
                  DateFormat('HH:mm').format(latest.timestamp),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusExplanation,
            style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.3),
          ),
          const SizedBox(height: 10),

          // Painel com 3 Indicadores Fáceis
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol(
                  label: 'Sopro (Pico)',
                  value: latest != null ? '${latest.peakFlowBest} L/min' : '--',
                  color: AppTheme.primaryTeal,
                ),
                Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
                _buildMetricCol(
                  label: 'Oxigênio (SpO2)',
                  value: latest != null ? '${latest.spo2}%' : '--',
                  color: const Color(0xFF0284C7),
                ),
                Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
                _buildMetricCol(
                  label: 'Bochecho',
                  value: latest != null ? (latest.mouthRinseCompleted ? 'Feito ✅' : 'Pendente ⚠️') : '--',
                  color: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEssentialActionButtons() {
    return Row(
      children: [
        // Botão SOS (Sem descrição)
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🚨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFDC2626))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Botão Atualizar receita médica (Sem descrição)
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💊', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Atualizar receita médica',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF15803D)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Botão Outros Recursos (Fisioterapia / c-ACT)
        InkWell(
          onTap: _showMoreOptionsModal,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(Icons.more_horiz, color: Color(0xFF64748B), size: 20),
                SizedBox(height: 2),
                Text('Mais', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mais Recursos Clínicos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFEEF2FF), child: Text('🫁')),
              title: const Text('Fisioterapia Respiratória', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Voldyne, Shaker e trava de segurança SpO2', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PhysioScreen()));
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFEEF2FF), child: Text('📝')),
              title: const Text('Questionário c-ACT Mensal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Avaliação de controle da asma para levar na consulta', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CactQuizScreen()));
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Text('👨‍⚕️')),
              title: const Text('Conectar com o Médico (Pro)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Chave para seu pediatra ver os dados em tempo real', style: TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProConnectScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanEntryCard(HealthControlEntry entry) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Text(
                '${DateFormat('dd/MM').format(entry.timestamp)} às ${DateFormat('HH:mm').format(entry.timestamp)} • ${entry.authorName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF334155)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: entry.peakFlowZone == ActionZoneType.green ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.peakFlowZone == ActionZoneType.green ? 'Estável 🟢' : 'Atenção 🟡',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: entry.peakFlowZone == ActionZoneType.green ? const Color(0xFF059669) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Sopro: ${entry.peakFlowBest} L/min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryTeal)),
              const SizedBox(width: 10),
              Text('SpO2: ${entry.spo2}%', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(width: 10),
              if (entry.mouthRinseCompleted)
                const Text('💧 Bochecho OK', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
            ],
          ),
          if (entry.medications.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '💊 Remédio: ${entry.medications.map((m) => m.name).join(", ")}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
          ],
          if (entry.notes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Obs: ${entry.notes}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, color: Color(0xFF94A3B8), size: 32),
          SizedBox(height: 6),
          Text(
            'Nenhuma anotação hoje.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
          ),
          Text(
            'Toque no botão abaixo para anotar como seu filho está.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalDisclaimerFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '⚠️ O Health Control é uma ferramenta de apoio ao cuidado e não substitui a consulta com o pediatra. Em caso de falta de ar forte com esforço das costelas, vá imediatamente ao Pronto-Socorro.',
        style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
      ),
    );
  }
}
