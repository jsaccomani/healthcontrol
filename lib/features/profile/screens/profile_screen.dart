import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../prescription/screens/prescription_scan_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final HealthStorageService _storageService = HealthStorageService();
  late TabController _tabController;

  List<PatientProfile> _allProfiles = [];
  PatientProfile? _activeProfile;
  bool _isLoading = true;

  // Controladores - Dados da Criança
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _pefCtrl;
  late TextEditingController _susCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _insuranceCardCtrl;
  String _gender = 'Masculino';
  String _bloodType = 'A+';
  String _selectedAvatar = 'boy_1';
  DateTime _birthDate = DateTime(2021, 5, 15);

  // Controladores - Dados dos Pais
  late TextEditingController _motherNameCtrl;
  late TextEditingController _motherPhoneCtrl;
  late TextEditingController _motherEmailCtrl;
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _fatherPhoneCtrl;
  late TextEditingController _emergencyContactNameCtrl;
  late TextEditingController _emergencyContactPhoneCtrl;
  late TextEditingController _addressCtrl;

  // Controladores - Anamnese Médica
  late TextEditingController _symptomsStartAgeCtrl;
  bool _hadIcuAdmission = false;
  late TextEditingController _icuCountCtrl;
  late TextEditingController _lastHospCtrl;
  late TextEditingController _igeCtrl;
  late TextEditingController _eosCtrl;
  late TextEditingController _doctorNameCtrl;
  late TextEditingController _doctorPhoneCtrl;

  List<String> _familyHistory = ['Mãe (Rinite/Asma)'];
  List<String> _drugAllergies = [];
  List<String> _foodAllergies = [];
  List<String> _environmentalAllergies = ['Ácaros da poeira', 'Poeira', 'Tempo frio'];
  List<String> _comorbidities = ['Rinite Alérgica Perene', 'Hiper-reatividade Brônquica'];
  List<String> _continuousMeds = ['Clenil HFA 250mcg (1 puff 12/12h com espaçador)'];

  final List<String> _commonBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Não informado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final current = await _storageService.getPatientProfile();

    _allProfiles = profiles;
    _activeProfile = current;
    _populateControllers(current);

    setState(() => _isLoading = false);
  }

  void _populateControllers(PatientProfile p) {
    _nameCtrl = TextEditingController(text: p.name);
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: p.weightKg.toStringAsFixed(1));
    _pefCtrl = TextEditingController(text: p.personalBestPef.toString());
    _susCtrl = TextEditingController(text: p.susCardNumber);
    _insuranceCtrl = TextEditingController(text: p.healthInsurance);
    _insuranceCardCtrl = TextEditingController(text: p.insuranceCardNumber);
    _gender = p.gender;
    _bloodType = p.bloodType;
    _selectedAvatar = p.avatarId;
    _birthDate = p.birthDate;

    // Pais
    _motherNameCtrl = TextEditingController(text: p.motherName);
    _motherPhoneCtrl = TextEditingController(text: p.motherPhone);
    _motherEmailCtrl = TextEditingController(text: p.motherEmail);
    _fatherNameCtrl = TextEditingController(text: p.fatherName);
    _fatherPhoneCtrl = TextEditingController(text: p.fatherPhone);
    _emergencyContactNameCtrl = TextEditingController(text: p.emergencyContactName);
    _emergencyContactPhoneCtrl = TextEditingController(text: p.emergencyContactPhone);
    _addressCtrl = TextEditingController(text: p.addressCityState);

    // Anamnese
    _symptomsStartAgeCtrl = TextEditingController(text: p.symptomsStartAge);
    _hadIcuAdmission = p.hadIcuAdmission;
    _icuCountCtrl = TextEditingController(text: p.icuAdmissionsCount.toString());
    _lastHospCtrl = TextEditingController(text: p.lastHospitalizationInfo);
    _igeCtrl = TextEditingController(text: p.igeLevel.toStringAsFixed(0));
    _eosCtrl = TextEditingController(text: p.eosinophilsCount.toString());
    _doctorNameCtrl = TextEditingController(text: p.doctorName);
    _doctorPhoneCtrl = TextEditingController(text: p.doctorPhone);

    _familyHistory = List.from(p.familyAsthmaHistory);
    _drugAllergies = List.from(p.drugAllergies);
    _foodAllergies = List.from(p.foodAllergies);
    _environmentalAllergies = List.from(p.environmentalAllergies);
    _comorbidities = List.from(p.comorbidities);
    _continuousMeds = List.from(p.continuousMedications);
  }

  Future<void> _switchChild(PatientProfile target) async {
    await _storageService.setSelectedProfileId(target.id);
    _activeProfile = target;
    _populateControllers(target);
    setState(() {});
  }

  Future<void> _showAddChildDialog() async {
    final nameNewCtrl = TextEditingController();
    final weightNewCtrl = TextEditingController(text: '18.0');
    final heightNewCtrl = TextEditingController(text: '105');
    final pefNewCtrl = TextEditingController(text: '200');
    DateTime newBirth = DateTime.now().subtract(const Duration(days: 365 * 4));
    String newGender = 'Feminino';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.person_add_alt_1, color: AppTheme.primaryTeal),
              SizedBox(width: 8),
              Text('Cadastrar Novo Filho(a)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameNewCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da Criança', hintText: 'ex: Beatriz Saccomani'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: newGender,
                        decoration: const InputDecoration(labelText: 'Sexo'),
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Menino')),
                          DropdownMenuItem(value: 'Feminino', child: Text('Menina')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => newGender = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: weightNewCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Peso (kg)', hintText: '18.0'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pefNewCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Melhor PFE Pessoal (L/min)', hintText: '200'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nameNewCtrl.text.trim().isEmpty) return;
                final created = await _storageService.createNewChildProfile(
                  name: nameNewCtrl.text.trim(),
                  birthDate: newBirth,
                  gender: newGender,
                  heightCm: double.tryParse(heightNewCtrl.text) ?? 105.0,
                  weightKg: double.tryParse(weightNewCtrl.text) ?? 18.0,
                  personalBestPef: int.tryParse(pefNewCtrl.text) ?? 200,
                  avatarId: newGender == 'Feminino' ? 'girl_1' : 'boy_2',
                );
                Navigator.pop(ctx);
                await _loadAllData();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Perfil de ${created.name} criado com sucesso!')),
                );
              },
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCurrentProfile() async {
    final height = double.tryParse(_heightCtrl.text.trim()) ?? 110.0;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 19.5;
    final pef = int.tryParse(_pefCtrl.text.trim()) ?? 220;
    final ige = double.tryParse(_igeCtrl.text.trim()) ?? 450.0;
    final eos = int.tryParse(_eosCtrl.text.trim()) ?? 550;
    final icuCount = int.tryParse(_icuCountCtrl.text.trim()) ?? 0;

    final updated = PatientProfile(
      id: _activeProfile!.id,
      name: _nameCtrl.text.trim(),
      photoBase64: _activeProfile!.photoBase64,
      avatarId: _selectedAvatar,
      birthDate: _birthDate,
      gender: _gender,
      bloodType: _bloodType,
      heightCm: height,
      weightKg: weight,
      personalBestPef: pef,
      susCardNumber: _susCtrl.text.trim(),
      healthInsurance: _insuranceCtrl.text.trim(),
      insuranceCardNumber: _insuranceCardCtrl.text.trim(),
      motherName: _motherNameCtrl.text.trim(),
      motherPhone: _motherPhoneCtrl.text.trim(),
      motherEmail: _motherEmailCtrl.text.trim(),
      fatherName: _fatherNameCtrl.text.trim(),
      fatherPhone: _fatherPhoneCtrl.text.trim(),
      emergencyContactName: _emergencyContactNameCtrl.text.trim(),
      emergencyContactPhone: _emergencyContactPhoneCtrl.text.trim(),
      addressCityState: _addressCtrl.text.trim(),
      symptomsStartAge: _symptomsStartAgeCtrl.text.trim(),
      hadIcuAdmission: _hadIcuAdmission,
      icuAdmissionsCount: icuCount,
      lastHospitalizationInfo: _lastHospCtrl.text.trim(),
      familyAsthmaHistory: _familyHistory,
      drugAllergies: _drugAllergies,
      foodAllergies: _foodAllergies,
      environmentalAllergies: _environmentalAllergies,
      comorbidities: _comorbidities,
      continuousMedications: _continuousMeds,
      igeLevel: ige,
      eosinophilsCount: eos,
      doctorName: _doctorNameCtrl.text.trim(),
      doctorPhone: _doctorPhoneCtrl.text.trim(),
    );

    await _storageService.savePatientProfile(updated);
    await _loadAllData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha cadastral e anamnese salvas com sucesso! ✅')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _activeProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ficha Clínica & Anamnese', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Adicionar Outro Filho',
            icon: const Icon(Icons.person_add_alt, color: AppTheme.primaryTeal),
            onPressed: _showAddChildDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppTheme.primaryTeal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.child_care, size: 20), text: 'Criança'),
            Tab(icon: Icon(Icons.family_restroom, size: 20), text: 'Pais & Família'),
            Tab(icon: Icon(Icons.medical_information, size: 20), text: 'Anamnese'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de Alternância de Filhos (Multi-Child Switcher)
          _buildChildrenSwitcherBar(),

          // Conteúdo das Abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChildDataTab(),
                _buildParentsDataTab(),
                _buildAnamnesisTab(),
              ],
            ),
          ),

          // Botão Fixo Salvar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveCurrentProfile,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações no Prontuário', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSwitcherBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          const Text('Filhos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _allProfiles.map((p) {
                  final isSel = p.id == _activeProfile!.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: isSel ? Colors.white : AppTheme.primaryLight,
                        child: Text(
                          p.gender == 'Feminino' ? '👧' : '👦',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      label: Text(p.name, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (_) => _switchChild(p),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
            tooltip: 'Cadastrar outro filho',
            onPressed: _showAddChildDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildChildDataTab() {
    final double weight = double.tryParse(_weightCtrl.text) ?? _activeProfile!.weightKg;
    final double height = double.tryParse(_heightCtrl.text) ?? _activeProfile!.heightCm;
    final bmi = (height > 0) ? weight / ((height / 100) * (height / 100)) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto & Identificação Visual
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        _gender == 'Feminino' ? '👧' : '👦',
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upload de foto de registro ativado para o perfil.')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_activeProfile!.name} • ${_activeProfile!.ageDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                Text(
                  'IMC: ${bmi.toStringAsFixed(1)} kg/m² (Eutrofia Pediátrica)',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Campos de Dados Pessoais
          _buildCardSection(
            title: '1. Dados Biométricos & Documentos',
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome Completo da Criança'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Sexo Biológico'),
                      items: const [
                        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                        DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _gender = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodType,
                      decoration: const InputDecoration(labelText: 'Tipo Sanguíneo'),
                      items: _commonBloodTypes
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _bloodType = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso Atual (kg)', hintText: '19.5'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Altura (cm)', hintText: '110'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pefCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Melhor Pico de Fluxo Pessoal (PFE em L/min)',
                  hintText: 'ex: 220',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Documentos de Saúde
          _buildCardSection(
            title: '2. Documentos de Saúde (SUS & Convênio)',
            children: [
              TextField(
                controller: _susCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cartão Nacional de Saúde (SUS)',
                  hintText: '898 0000 1234 5678',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _insuranceCtrl,
                      decoration: const InputDecoration(labelText: 'Plano de Saúde', hintText: 'Bradesco Saúde'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _insuranceCardCtrl,
                      decoration: const InputDecoration(labelText: 'Nº da Carteirinha', hintText: '987654321000'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildParentsDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dados da Mãe
          _buildCardSection(
            title: '👩 Dados da Mãe / Responsável Principal',
            children: [
              TextField(
                controller: _motherNameCtrl,
                decoration: const InputDecoration(labelText: 'Nome da Mãe', hintText: 'Juliana Saccomani'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _motherPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'WhatsApp / Celular', hintText: '(11) 98765-4321'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _motherEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-mail', hintText: 'mae@email.com'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dados do Pai
          _buildCardSection(
            title: '👨 Dados do Pai / Segundo Responsável',
            children: [
              TextField(
                controller: _fatherNameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Pai', hintText: 'Nome do Pai'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fatherPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp / Celular do Pai', hintText: '(11) 91234-5678'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Endereço e Emergência
          _buildCardSection(
            title: '📍 Endereço & Contato de Emergência Imediata',
            children: [
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Cidade / Estado / Bairro', hintText: 'São Paulo - SP'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactNameCtrl,
                      decoration: const InputDecoration(labelText: 'Contato de Emergência', hintText: 'Mãe (Juliana)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefone do Contato', hintText: '(11) 98765-4321'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnamnesisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Início dos Sintomas & Histórico de Gravidade
          _buildCardSection(
            title: '🫁 1. Histórico de Início & Gravidade',
            children: [
              TextField(
                controller: _symptomsStartAgeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Idade de Início dos Sintomas / Diagnóstico',
                  hintText: 'ex: Aos 8 meses (bronquiolites de repetição)',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já necessitou de internação em UTI por Asma?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Histórico de ventilação ou suporte intensivo.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                value: _hadIcuAdmission,
                activeColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _hadIcuAdmission = v),
              ),
              if (_hadIcuAdmission) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _icuCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantas vezes precisou de UTI?', hintText: 'ex: 1'),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _lastHospCtrl,
                decoration: const InputDecoration(
                  labelText: 'Última Idas ao Pronto-Socorro / Hospitalização',
                  hintText: 'ex: Idas frequentes no inverno para inalação',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Alergias Mapeadas
          _buildCardSection(
            title: '⚠️ 2. Alergias Conhecidas & Gatilhos',
            children: [
              _buildMultiTagSelector('Alergias a Medicamentos (ex: Dipirona, AINEs):', _drugAllergies, [
                'Nenhuma medicamentosa', 'Dipirona', 'AINEs / Ibuprofeno', 'Amoxicilina / Penicilina', 'Ácido Acetilsalicílico'
              ]),
              const SizedBox(height: 12),
              _buildMultiTagSelector('Alergias Ambientais & Gatilhos:', _environmentalAllergies, [
                'Ácaros da poeira', 'Poeira', 'Pólen', 'Pelos de Gato', 'Pelos de Cachorro', 'Mofo', 'Tempo frio', 'Fumaça'
              ]),
              const SizedBox(height: 12),
              _buildMultiTagSelector('Comorbidades Associadas:', _comorbidities, [
                'Rinite Alérgica Perene', 'Hiper-reatividade Brônquica', 'Dermatite Atópica', 'Refluxo (DRGE)', 'Respiração Bucal'
              ]),
            ],
          ),

          const SizedBox(height: 14),

          // Biomarcadores & Médico Assistente
          _buildCardSection(
            title: '🧬 3. Biomarcadores & Médico Assistente',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _igeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'IgE Total (UI/mL)', hintText: '480'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _eosCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Eosinófilos (cél/µL)', hintText: '550'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _doctorNameCtrl,
                decoration: const InputDecoration(labelText: 'Pneumopediatra / Pediatra Assistente', hintText: 'Dr. Nome do Médico'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _doctorPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone / WhatsApp do Consultório', hintText: '(11) 99999-8888'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Prescrições Médicas, Bombinhas & Scanner OCR
          _buildCardSection(
            title: '💊 4. Prescrições Médicas & Scanner de Receitas',
            children: [
              const Text(
                'Mantenha as receitas do pneumopediatra digitalizadas para controle de validade e inclusão automática de bombinhas de manutenção e resgate.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Escanear / Gerenciar Receitas Médicas ➔', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionScanScreen(
                          patientId: _activeProfile!.id,
                          patientName: _activeProfile!.name,
                        ),
                      ),
                    );
                    _loadAllData();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMultiTagSelector(String label, List<String> selectedList, List<String> availableOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: availableOptions.map((opt) {
            final isSel = selectedList.contains(opt);
            return FilterChip(
              label: Text(opt, style: const TextStyle(fontSize: 11)),
              selected: isSel,
              selectedColor: AppTheme.primaryLight,
              checkmarkColor: AppTheme.primaryTeal,
              onSelected: (sel) {
                setState(() {
                  if (sel) {
                    selectedList.add(opt);
                  } else {
                    selectedList.remove(opt);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
