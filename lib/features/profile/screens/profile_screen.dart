import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final HealthStorageService _storageService = HealthStorageService();

  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _pefCtrl;
  late TextEditingController _susCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _insuranceCardCtrl;
  late TextEditingController _igeCtrl;
  late TextEditingController _eosCtrl;

  DateTime _birthDate = DateTime(2021, 5, 15);
  String _gender = 'Masculino';
  List<String> _comorbidities = ['Rinite Alérgica', 'Hiper-reatividade Brônquica'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _storageService.getPatientProfile();
    _nameCtrl = TextEditingController(text: p.name);
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: p.weightKg.toStringAsFixed(1));
    _pefCtrl = TextEditingController(text: p.personalBestPef.toString());
    _susCtrl = TextEditingController(text: p.susCardNumber);
    _insuranceCtrl = TextEditingController(text: p.healthInsurance);
    _insuranceCardCtrl = TextEditingController(text: p.insuranceCardNumber);
    _igeCtrl = TextEditingController(text: p.igeLevel.toStringAsFixed(0));
    _eosCtrl = TextEditingController(text: p.eosinophilsCount.toString());
    _birthDate = p.birthDate;
    _gender = p.gender;
    _comorbidities = List.from(p.comorbidities);

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    final height = double.tryParse(_heightCtrl.text.trim()) ?? 110.0;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 19.5;
    final pef = int.tryParse(_pefCtrl.text.trim()) ?? 220;
    final ige = double.tryParse(_igeCtrl.text.trim()) ?? 480.0;
    final eos = int.tryParse(_eosCtrl.text.trim()) ?? 550;

    final updated = PatientProfile(
      id: 'paciente-filho-01',
      name: _nameCtrl.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      heightCm: height,
      weightKg: weight,
      personalBestPef: pef,
      susCardNumber: _susCtrl.text.trim(),
      healthInsurance: _insuranceCtrl.text.trim(),
      insuranceCardNumber: _insuranceCardCtrl.text.trim(),
      igeLevel: ige,
      eosinophilsCount: eos,
      comorbidities: _comorbidities,
    );

    await _storageService.savePatientProfile(updated);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil clínico salvo com sucesso!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha Clínica do Filho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identificação
            _buildSection(
              title: '1. Dados Pessoais & Biométricos',
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da Criança'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Peso Atual (kg)', hintText: '19.5'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Altura (cm)', hintText: '110'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pefCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Melhor PFE Pessoal (Personal Best em L/min)',
                    hintText: 'ex: 220',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Documentos de Saúde
            _buildSection(
              title: '2. Documentos de Saúde (SUS & Convênio)',
              children: [
                TextField(
                  controller: _susCtrl,
                  decoration: const InputDecoration(labelText: 'Cartão SUS (LME / Alto Custo)'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _insuranceCtrl,
                        decoration: const InputDecoration(labelText: 'Plano de Saúde'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _insuranceCardCtrl,
                        decoration: const InputDecoration(labelText: 'Carteirinha'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Biomarcadores Asma Grave
            _buildSection(
              title: '3. Biomarcadores de Asma Grave (T2-High)',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _igeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'IgE Total (UI/mL)', hintText: 'ex: 480'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _eosCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Eosinófilos (cél/µL)', hintText: 'ex: 550'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações no Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }
}
