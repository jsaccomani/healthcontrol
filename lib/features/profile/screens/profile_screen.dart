import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final HealthStorageService _storageService = HealthStorageService();
  late TabController _tabController;

  PatientProfile? _activeProfile;
  List<PrescriptionRecord> _prescriptions = [];
  bool _isLoading = true;

  // Debounce para Salvamento Automático do Histórico
  Timer? _autoSaveDebounce;
  String _autoSaveStatus = '🟢 Salvo automaticamente';

  // 1. Controladores - Criança & Nascimento
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _pefCtrl;
  late TextEditingController _susCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _insuranceCardCtrl;
  late TextEditingController _gestationalWeeksCtrl;
  late TextEditingController _birthWeightCtrl;
  bool _neonatalIcuOrOxygen = false;
  String _gender = 'Masculino';
  String _bloodType = 'A+';
  String _selectedAvatar = 'boy_1';
  DateTime _birthDate = DateTime(2021, 5, 15);

  // 2. Controladores - Dados dos Pais
  late TextEditingController _motherNameCtrl;
  late TextEditingController _motherPhoneCtrl;
  late TextEditingController _motherEmailCtrl;
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _fatherPhoneCtrl;
  late TextEditingController _emergencyContactNameCtrl;
  late TextEditingController _emergencyContactPhoneCtrl;
  late TextEditingController _addressCtrl;

  // 3. Controladores - Triagem Médica & Perguntas Clínicas
  late TextEditingController _symptomsStartAgeCtrl;
  bool _hadIcuAdmission = false;
  bool _intubatedPast = false;
  late TextEditingController _icuCountCtrl;
  late TextEditingController _erVisitsCtrl;
  late TextEditingController _steroidCoursesCtrl;
  late TextEditingController _nightAwakeningsCtrl;
  String _activityLimitation = 'Normal - sem limitações para brincar';
  bool _fluVaccineUpToDate = true;
  bool _pneumoVaccineUpToDate = true;
  bool _householdSmokers = false;
  String _householdPets = 'Nenhum';

  late TextEditingController _doctorNameCtrl;
  late TextEditingController _doctorPhoneCtrl;
  late TextEditingController _preferredHospitalCtrl;

  List<String> _crisisTriggers = ['Resfriados / Gripes', 'Mudança brusca de temperatura', 'Tempo seco e poeira'];
  List<String> _familyHistory = ['Mãe (Rinite/Asma)'];
  List<String> _drugAllergies = [];
  List<String> _foodAllergies = [];
  List<String> _environmentalAllergies = ['Ácaros da poeira', 'Poeira', 'Tempo frio'];
  List<String> _comorbidities = ['Rinite Alérgica Perene', 'Hiper-reatividade Brônquica'];

  // 4. Histórico Contado pelos Pais (Espaço Amplo com Auto-Save)
  late TextEditingController _familyNotesCtrl;

  final List<String> _commonBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Não informado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final current = await _storageService.getPatientProfile();
    final prescriptions = await _storageService.getPrescriptions(current.id);

    _activeProfile = current;
    _prescriptions = prescriptions;
    _populateControllers(current);

    setState(() => _isLoading = false);
  }

  void _populateControllers(PatientProfile p) {
    // 1. Criança & Nascimento
    _nameCtrl = TextEditingController(text: p.name);
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(text: p.weightKg.toStringAsFixed(1));
    _pefCtrl = TextEditingController(text: p.personalBestPef.toString());
    _susCtrl = TextEditingController(text: p.susCardNumber);
    _insuranceCtrl = TextEditingController(text: p.healthInsurance);
    _insuranceCardCtrl = TextEditingController(text: p.insuranceCardNumber);
    _gestationalWeeksCtrl = TextEditingController(text: p.gestationalAgeWeeks.toString());
    _birthWeightCtrl = TextEditingController(text: p.birthWeightGrams.toString());
    _neonatalIcuOrOxygen = p.neonatalIcuOrOxygen;
    _gender = p.gender;
    _bloodType = p.bloodType;
    _selectedAvatar = p.avatarId;
    _birthDate = p.birthDate;

    // 2. Pais
    _motherNameCtrl = TextEditingController(text: p.motherName);
    _motherPhoneCtrl = TextEditingController(text: p.motherPhone);
    _motherEmailCtrl = TextEditingController(text: p.motherEmail);
    _fatherNameCtrl = TextEditingController(text: p.fatherName);
    _fatherPhoneCtrl = TextEditingController(text: p.fatherPhone);
    _emergencyContactNameCtrl = TextEditingController(text: p.emergencyContactName);
    _emergencyContactPhoneCtrl = TextEditingController(text: p.emergencyContactPhone);
    _addressCtrl = TextEditingController(text: p.addressCityState);

    // 3. Triagem Médica
    _symptomsStartAgeCtrl = TextEditingController(text: p.symptomsStartAge);
    _hadIcuAdmission = p.hadIcuAdmission;
    _intubatedPast = p.intubatedPast;
    _icuCountCtrl = TextEditingController(text: p.icuAdmissionsCount.toString());
    _erVisitsCtrl = TextEditingController(text: p.erVisitsLast12Months.toString());
    _steroidCoursesCtrl = TextEditingController(text: p.oralSteroidCoursesLastYear.toString());
    _nightAwakeningsCtrl = TextEditingController(text: p.nightAwakeningsPerMonth.toString());
    _activityLimitation = p.activityLimitation;
    _fluVaccineUpToDate = p.fluVaccineUpToDate;
    _pneumoVaccineUpToDate = p.pneumococcalVaccine;
    _householdSmokers = p.householdSmokers;
    _householdPets = p.householdPets;
    _doctorNameCtrl = TextEditingController(text: p.doctorName);
    _doctorPhoneCtrl = TextEditingController(text: p.doctorPhone);
    _preferredHospitalCtrl = TextEditingController(text: p.preferredHospital);

    _crisisTriggers = List.from(p.crisisTriggers);
    _familyHistory = List.from(p.familyAsthmaHistory);
    _drugAllergies = List.from(p.drugAllergies);
    _foodAllergies = List.from(p.foodAllergies);
    _environmentalAllergies = List.from(p.environmentalAllergies);
    _comorbidities = List.from(p.comorbidities);

    // 4. Histórico da Família
    _familyNotesCtrl = TextEditingController(text: p.familyNotesAndHistory);
  }

  void _onFamilyHistoryChanged(String text) {
    setState(() => _autoSaveStatus = '⏳ Salvando alterações...');
    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 900), () async {
      await _silentSaveProfile();
      if (mounted) {
        setState(() => _autoSaveStatus = '🟢 Salvo automaticamente às ${DateFormat('HH:mm:ss').format(DateTime.now())}');
      }
    });
  }

  Future<void> _silentSaveProfile() async {
    if (_activeProfile == null) return;
    final updated = _buildCurrentProfileObject();
    await _storageService.savePatientProfile(updated);
    _activeProfile = updated;
  }

  PatientProfile _buildCurrentProfileObject() {
    final height = double.tryParse(_heightCtrl.text.trim()) ?? 110.0;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 19.5;
    final pef = int.tryParse(_pefCtrl.text.trim()) ?? 220;
    final icuCount = int.tryParse(_icuCountCtrl.text.trim()) ?? 0;
    final erVisits = int.tryParse(_erVisitsCtrl.text.trim()) ?? 1;
    final steroidCourses = int.tryParse(_steroidCoursesCtrl.text.trim()) ?? 2;
    final nightAwakenings = int.tryParse(_nightAwakeningsCtrl.text.trim()) ?? 1;
    final gestWeeks = int.tryParse(_gestationalWeeksCtrl.text.trim()) ?? 39;
    final birthWeight = int.tryParse(_birthWeightCtrl.text.trim()) ?? 3200;

    return PatientProfile(
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
      gestationalAgeWeeks: gestWeeks,
      birthWeightGrams: birthWeight,
      neonatalIcuOrOxygen: _neonatalIcuOrOxygen,
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
      intubatedPast: _intubatedPast,
      erVisitsLast12Months: erVisits,
      oralSteroidCoursesLastYear: steroidCourses,
      hospitalizationsCount: _activeProfile!.hospitalizationsCount,
      lastHospitalizationInfo: _activeProfile!.lastHospitalizationInfo,
      nightAwakeningsPerMonth: nightAwakenings,
      activityLimitation: _activityLimitation,
      crisisTriggers: _crisisTriggers,
      fluVaccineUpToDate: _fluVaccineUpToDate,
      pneumococcalVaccine: _pneumoVaccineUpToDate,
      householdSmokers: _householdSmokers,
      householdPets: _householdPets,
      familyAsthmaHistory: _familyHistory,
      drugAllergies: _drugAllergies,
      foodAllergies: _foodAllergies,
      environmentalAllergies: _environmentalAllergies,
      comorbidities: _comorbidities,
      continuousMedications: _activeProfile!.continuousMedications,
      igeLevel: _activeProfile!.igeLevel,
      eosinophilsCount: _activeProfile!.eosinophilsCount,
      doctorName: _doctorNameCtrl.text.trim(),
      doctorPhone: _doctorPhoneCtrl.text.trim(),
      preferredHospital: _preferredHospitalCtrl.text.trim(),
      familyNotesAndHistory: _familyNotesCtrl.text,
    );
  }

  Future<void> _saveAll() async {
    final updated = _buildCurrentProfileObject();
    await _storageService.savePatientProfile(updated);
    await _loadAllData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha completa da criança salva com sucesso! ✅'), backgroundColor: Color(0xFF059669)),
    );
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
        title: const Text('Ficha Médica & Anamnese', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppTheme.primaryTeal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.child_care, size: 18), text: '1. Criança'),
            Tab(icon: Icon(Icons.family_restroom, size: 18), text: '2. Pais'),
            Tab(icon: Icon(Icons.medication, size: 18), text: '3. Remédios'),
            Tab(icon: Icon(Icons.local_hospital, size: 18), text: '4. Triagem Médica'),
            Tab(icon: Icon(Icons.menu_book, size: 18), text: '5. História da Família ✍️'),
          ],
        ),
      ),
      body: HCResponsiveContainer(
        maxWidth: 840,
        child: Column(
          children: [
            // Conteúdo das 5 Abas
            Expanded(
              child: TabBarView(
              controller: _tabController,
              children: [
                _buildChildDataTab(),
                _buildParentsDataTab(),
                _buildMedicationsTab(),
                _buildMedicalTriageTab(),
                _buildFamilyHistoryFreeTextTab(),
              ],
            ),
          ),

          // Barra Inferior de Ação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _autoSaveStatus,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveAll,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Salvar Tudo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // 1. Aba Criança & Nascimento
  Widget _buildChildDataTab() {
    final double weight = double.tryParse(_weightCtrl.text) ?? _activeProfile!.weightKg;
    final double height = double.tryParse(_heightCtrl.text) ?? _activeProfile!.heightCm;
    final bmi = (height > 0) ? weight / ((height / 100) * (height / 100)) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Identificação
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(_gender == 'Feminino' ? '👧' : '👦', style: const TextStyle(fontSize: 38)),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_activeProfile!.name} • ${_activeProfile!.ageDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                Text(
                  'IMC: ${bmi.toStringAsFixed(1)} kg/m² • Sangue: $_bloodType',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _buildCardSection(
            title: '👦 1. Dados Pessoais da Criança',
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome Completo da Criança')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Sexo'),
                      items: const [
                        DropdownMenuItem(value: 'Masculino', child: Text('Menino')),
                        DropdownMenuItem(value: 'Feminino', child: Text('Menina')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _gender = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodType,
                      decoration: const InputDecoration(labelText: 'Tipo Sanguíneo'),
                      items: _commonBloodTypes.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
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
                  const SizedBox(width: 8),
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
                  labelText: 'Melhor Sopro Pessoal (Pico de Fluxo - L/min)',
                  hintText: 'ex: 220 (valor de referência quando está bem)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '🍼 2. Histórico de Nascimento & Perinatal',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gestationalWeeksCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Idade Gestacional (Semanas)', hintText: '39'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _birthWeightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso ao Nascer (gramas)', hintText: '3200'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Precisou de Oxigênio ou UTI Neonatal ao nascer?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                value: _neonatalIcuOrOxygen,
                activeThumbColor: AppTheme.primaryTeal,
                onChanged: (v) => setState(() => _neonatalIcuOrOxygen = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '🏥 3. Cartão SUS & Convênio Médico',
            children: [
              TextField(controller: _susCtrl, decoration: const InputDecoration(labelText: 'Nº do Cartão Nacional de Saúde (SUS)', hintText: '898 0000 1234 5678')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: _insuranceCtrl, decoration: const InputDecoration(labelText: 'Plano de Saúde', hintText: 'Bradesco / Unimed'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _insuranceCardCtrl, decoration: const InputDecoration(labelText: 'Nº da Carteirinha', hintText: '987654321'))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 2. Aba Pais
  Widget _buildParentsDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardSection(
            title: '👩 Dados da Mãe / Responsável',
            children: [
              TextField(controller: _motherNameCtrl, decoration: const InputDecoration(labelText: 'Nome da Mãe', hintText: 'Juliana Saccomani')),
              const SizedBox(height: 10),
              TextField(controller: _motherPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp / Celular da Mãe', hintText: '(11) 98765-4321')),
            ],
          ),
          const SizedBox(height: 12),
          _buildCardSection(
            title: '👨 Dados do Pai / 2º Responsável',
            children: [
              TextField(controller: _fatherNameCtrl, decoration: const InputDecoration(labelText: 'Nome do Pai', hintText: 'Pai')),
              const SizedBox(height: 10),
              TextField(controller: _fatherPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp / Celular do Pai', hintText: '(11) 91234-5678')),
            ],
          ),
          const SizedBox(height: 12),
          _buildCardSection(
            title: '📍 Endereço & Contato de Emergência Imediata',
            children: [
              TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Cidade / Endereço Completo', hintText: 'São Paulo - SP')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: _emergencyContactNameCtrl, decoration: const InputDecoration(labelText: 'Contato de Emergência', hintText: 'Mãe (Juliana)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _emergencyContactPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone', hintText: '(11) 98765-4321'))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 3. Aba Remédios
  Widget _buildMedicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.document_scanner, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Escanear Receita do Médico', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tire foto da receita para o app ler os nomes das bombinhas e horários automaticamente.',
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Bombinhas & Remédios Cadastrados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          if (_prescriptions.isEmpty)
            const Text('Nenhum remédio cadastrado.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))
          else
            ..._prescriptions.map((p) => _buildPrescriptionCard(p)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionRecord p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Text('Receita: ${p.doctorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
              Text('Válida (${p.daysUntilExpiration} dias)', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
            ],
          ),
          const Divider(height: 12),
          ...p.medications.map((m) => Text('• ${m.commercialName} - ${m.dosage} (${m.frequency})', style: const TextStyle(fontSize: 11, color: Color(0xFF334155)))),
        ],
      ),
    );
  }

  // 4. Aba Triagem Médica & Perguntas de Consultório
  Widget _buildMedicalTriageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardSection(
            title: '🚨 1. Gravidade das Crises & Histórico de Pronto-Socorro',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _erVisitsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Idas ao PS (Últimos 12 meses)', hintText: '1'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _steroidCoursesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ciclos de Prednisolona/ano', hintText: '2'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já precisou ficar internado em UTI por crise de falta de ar?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                value: _hadIcuAdmission,
                activeThumbColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _hadIcuAdmission = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já precisou de intubação endotraqueal no passado?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                value: _intubatedPast,
                activeThumbColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _intubatedPast = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '🌙 2. Sintomas Noturnos & Limitação nas Brincadeiras',
            children: [
              TextField(
                controller: _nightAwakeningsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantas noites por mês acorda tossindo ou chiando?', hintText: '1'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _activityLimitation,
                decoration: const InputDecoration(labelText: 'Limitação nas Atividades / Brincadeiras da Escola'),
                items: const [
                  DropdownMenuItem(value: 'Normal - sem limitações para brincar', child: Text('Normal - corre e brinca normalmente')),
                  DropdownMenuItem(value: 'Leve - tosse apenas em corrida intensa', child: Text('Leve - tosse em corrida intensa')),
                  DropdownMenuItem(value: 'Moderada - cansa antes dos coleguinhas', child: Text('Moderada - cansa antes dos amigos')),
                  DropdownMenuItem(value: 'Severa - evita brincadeiras ativas', child: Text('Severa - evita brincadeiras ativas')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _activityLimitation = v);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '⚡ 3. O que costuma desencadear as crises dele (Gatilhos):',
            children: [
              _buildMultiTagSelector('Gatilhos Principais:', _crisisTriggers, [
                'Resfriados / Gripes', 'Mudança brusca de temperatura', 'Tempo seco e poeira',
                'Fumaça / Queimadas', 'Cheiros fortes / Perfumes', 'Exercício físico intenso', 'Riso ou choro forte'
              ]),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '💉 4. Vacinação & Ambiente da Casa',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vacina da Gripe (Influenza) anual em dia?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                value: _fluVaccineUpToDate,
                activeThumbColor: const Color(0xFF059669),
                onChanged: (v) => setState(() => _fluVaccineUpToDate = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Há fumantes no ambiente da casa ou carro?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                value: _householdSmokers,
                activeThumbColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _householdSmokers = v),
              ),
              DropdownButtonFormField<String>(
                value: _householdPets,
                decoration: const InputDecoration(labelText: 'Animais de Estimação em Casa'),
                items: const [
                  DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
                  DropdownMenuItem(value: 'Cachorro', child: Text('Cachorro')),
                  DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                  DropdownMenuItem(value: 'Cachorro e Gato', child: Text('Cachorro e Gato')),
                  DropdownMenuItem(value: 'Outros', child: Text('Outros')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _householdPets = v);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '👨‍⚕️ 5. Médico Assistente & Hospital de Emergência',
            children: [
              TextField(controller: _doctorNameCtrl, decoration: const InputDecoration(labelText: 'Nome do Pediatra / Pneumopediatra', hintText: 'Dr. Marco Aurélio Valente')),
              const SizedBox(height: 10),
              TextField(controller: _doctorPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp do Consultório', hintText: '(11) 98888-7777')),
              const SizedBox(height: 10),
              TextField(controller: _preferredHospitalCtrl, decoration: const InputDecoration(labelText: 'Hospital de Preferência para Emergência', hintText: 'Hospital Infantil Sabará / Samaritano')),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 5. Aba História Contada pelos Pais (Auto-Save Amplo)
  Widget _buildFamilyHistoryFreeTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text('✍️', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Text('História do Filho Contada pelos Pais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Text(_autoSaveStatus, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Este espaço é livre para você escrever a história da respiração do seu filho, detalhes que os médicos precisam saber, como foram os primeiros sintomas e dicas especiais para quem for cuidar dele.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Relato Livre dos Pais (Salva automaticamente ao digitar):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _familyNotesCtrl,
                  maxLines: 15,
                  maxLength: 5000,
                  onChanged: _onFamilyHistoryChanged,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    hintText: 'Escreva aqui com calma...\nExemplo:\n- "O Arthur começou a chiar com 7 meses durante um resfriado no berçário."\n- "Notamos que quando esfria de repente, a tosse piora à noite."\n- "Ele aceita muito bem o espaçador quando contamos uma historinha."\n- "Em caso de crise, o hospital mais perto de casa é o Sabará."',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const Divider(height: 14, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMultiTagSelector(String label, List<String> selectedList, List<String> availableOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF334155))),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
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
