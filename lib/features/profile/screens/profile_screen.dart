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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final HealthStorageService _storageService = HealthStorageService();
  late TabController _tabController;

  List<PatientProfile> _allProfiles = [];
  PatientProfile? _activeProfile;
  List<PrescriptionRecord> _prescriptions = [];
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

  final List<String> _commonBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Não informado'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final current = await _storageService.getPatientProfile();
    final prescriptions = await _storageService.getPrescriptions(current.id);

    _allProfiles = profiles;
    _activeProfile = current;
    _prescriptions = prescriptions;
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
  }

  Future<void> _switchChild(PatientProfile target) async {
    await _storageService.setSelectedProfileId(target.id);
    _activeProfile = target;
    _populateControllers(target);
    final presc = await _storageService.getPrescriptions(target.id);
    _prescriptions = presc;
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
              Text('Cadastrar Outro Filho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: 'Melhor Sopro / PFE (L/min)', hintText: '200'),
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

  void _openScanPrescriptionModal() {
    final rawTextCtrl = TextEditingController();
    int sampleSelected = 0;

    final samples = [
      {
        'title': '📋 Receita Médica de Rotina (Manutenção + Resgate)',
        'text': '''INSTITUTO PEDIÁTRICO DE PNEUMOLOGIA
Dr. Marco Aurélio Valente - CRM 129.840/SP
Data: 18/08/2026

Paciente: ${_activeProfile!.name}

USO INALATÓRIO:
1. Clenil HFA 250mcg Spray
   - Fazer 1 jato (puff) de 12 em 12 horas.
   - Usar com espaçador valvulado e máscara.
   - Lavar/enxaguar a boca após a aplicação.

2. Aerolin Spray 100mcg (Sulfato de Salbutamol)
   - Fazer 2 jatos no espaçador em caso de tosse, chiado ou falta de ar.

USO ORAL:
3. Singulair Baby 4mg Sachê (Montelucaste)
   - 1 sachê à noite misturado em alimento pastoso.

Validade: 6 meses.''',
      },
      {
        'title': '🚨 Receita de Crise / Exacerbação',
        'text': '''HOSPITAL INFANTIL PRONTO-SOCORRO
Dra. Renata Silveira - CRM 165.430/SP
Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}

Paciente: ${_activeProfile!.name}

1. Aerolin 100mcg Spray
   - 2 a 4 jatos a cada 4 horas com espaçador por 48 horas.

2. Prednisolona 3mg/mL Solução Oral
   - Tomar 6,5 mL (1mg/kg) 1x ao dia pela manhã por 5 dias consecutivos.

3. Clenil HFA 250mcg
   - Manter 1 jato 12/12h com espaçador.''',
      },
    ];

    rawTextCtrl.text = samples[0]['text'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.document_scanner, color: AppTheme.primaryTeal, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Escanear Receita do Médico',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tire foto da receita ou use o leitor inteligente para cadastrar as bombinhas, horários e data de validade sem precisar digitar nada.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                ),
                const SizedBox(height: 14),

                // Botões de Câmera e Arquivo
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Tirar Foto da Receita'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Foto da receita capturada! Reconhecendo medicações...')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('Importar PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0284C7),
                          side: const BorderSide(color: Color(0xFF0284C7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receita digital PDF carregada.')),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text('Modelos de Teste (Simular Leitura OCR):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: List.generate(samples.length, (idx) {
                    final isSel = sampleSelected == idx;
                    return ChoiceChip(
                      label: Text(idx == 0 ? 'Receita de Rotina (Clenil+Aerolin)' : 'Receita de Crise (Prednisolona)', style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (sel) {
                        if (sel) {
                          setModalState(() {
                            sampleSelected = idx;
                            rawTextCtrl.text = samples[idx]['text'] as String;
                          });
                        }
                      },
                    );
                  }),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: rawTextCtrl,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'Texto Extraído da Receita',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Cadastrar Medicações da Receita', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (rawTextCtrl.text.trim().isEmpty) return;

                      final parsed = PrescriptionOcrParser.parseRawPrescriptionText(
                        rawText: rawTextCtrl.text.trim(),
                        patientId: _activeProfile!.id,
                      );

                      await _storageService.savePrescription(parsed);
                      Navigator.pop(ctx);
                      await _loadAllData();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Receita médica de ${parsed.doctorName} cadastrada com sucesso! ✅'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddMedicationCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                children: const [
                  Icon(Icons.medication, color: AppTheme.primaryTeal),
                  SizedBox(width: 8),
                  Text(
                    'Escolher Bombinha ou Remédio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Toque no remédio que o médico receitou para adicionar à ficha:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              ...PediatricPharmacopeia.catalog.map((item) {
                final category = item['category'] as MedicationCategory;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(category.iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    subtitle: Text('${item['active']} • ${item['defaultDosage']}\n${category.displayName}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    trailing: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                    onTap: () async {
                      final newMed = PrescribedMedication(
                        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                        commercialName: item['name'] as String,
                        activeIngredient: item['active'] as String,
                        category: category,
                        dosage: item['defaultDosage'] as String,
                        frequency: item['defaultFrequency'] as String,
                        instructions: item['instructions'] as String,
                        spacerRequired: item['spacer'] as bool,
                        isContinuous: item['continuous'] as bool,
                      );

                      if (_prescriptions.isNotEmpty) {
                        final active = _prescriptions.first;
                        final updated = PrescriptionRecord(
                          id: active.id,
                          patientId: active.patientId,
                          doctorName: active.doctorName,
                          doctorCrm: active.doctorCrm,
                          clinicName: active.clinicName,
                          prescriptionDate: active.prescriptionDate,
                          validityMonths: active.validityMonths,
                          medications: [...active.medications, newMed],
                          notes: active.notes,
                        );
                        await _storageService.savePrescription(updated);
                      } else {
                        final newPresc = PrescriptionRecord(
                          id: 'presc_manual_${DateTime.now().millisecondsSinceEpoch}',
                          patientId: _activeProfile!.id,
                          doctorName: 'Prescrição Cadastrada pelos Pais',
                          prescriptionDate: DateTime.now(),
                          validityMonths: 6,
                          medications: [newMed],
                        );
                        await _storageService.savePrescription(newPresc);
                      }

                      Navigator.pop(ctx);
                      await _loadAllData();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${newMed.commercialName} adicionado com sucesso! ✅')),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
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
      igeLevel: ige,
      eosinophilsCount: eos,
      doctorName: _doctorNameCtrl.text.trim(),
      doctorPhone: _doctorPhoneCtrl.text.trim(),
    );

    await _storageService.savePatientProfile(updated);
    await _loadAllData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha do paciente salva com sucesso! ✅')),
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
        title: const Text('Ficha & Anamnese da Criança', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'Cadastrar outro filho',
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
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.child_care, size: 18), text: '1. Criança'),
            Tab(icon: Icon(Icons.family_restroom, size: 18), text: '2. Pais'),
            Tab(icon: Icon(Icons.medication, size: 18), text: '3. Remédios'),
            Tab(icon: Icon(Icons.favorite_border, size: 18), text: '4. Saúde'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de Filhos
          _buildChildrenSwitcherBar(),

          // Conteúdo das Abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChildDataTab(),
                _buildParentsDataTab(),
                _buildMedicationsAndPrescriptionsTab(),
                _buildHealthHistoryTab(),
              ],
            ),
          ),

          // Botão Salvar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveCurrentProfile,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Dados da Ficha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSwitcherBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Text('Filho:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _allProfiles.map((p) {
                  final isSel = p.id == _activeProfile!.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Text(p.gender == 'Feminino' ? '👧' : '👦', style: const TextStyle(fontSize: 12)),
                      label: Text(p.name, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
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
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal, size: 20),
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
          // Foto / Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    _gender == 'Feminino' ? '👧' : '👦',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_activeProfile!.name} • ${_activeProfile!.ageDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                Text(
                  'IMC: ${bmi.toStringAsFixed(1)} kg/m² • Tipo Sanguíneo: $_bloodType',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _buildCardSection(
            title: '👦 1. Dados da Criança',
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
                  labelText: 'Melhor Sopro Pessoal (Pico de Fluxo em L/min)',
                  hintText: 'ex: 220 (valor de referência quando ele está 100% bem)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '🏥 2. Cartão SUS e Convênio',
            children: [
              TextField(
                controller: _susCtrl,
                decoration: const InputDecoration(labelText: 'Nº do Cartão SUS', hintText: '898 0000 1234 5678'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _insuranceCtrl,
                      decoration: const InputDecoration(labelText: 'Plano de Saúde', hintText: 'Bradesco / Unimed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _insuranceCardCtrl,
                      decoration: const InputDecoration(labelText: 'Nº da Carteirinha', hintText: '987654321'),
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
          _buildCardSection(
            title: '👩 Dados da Mãe / Responsável',
            children: [
              TextField(
                controller: _motherNameCtrl,
                decoration: const InputDecoration(labelText: 'Nome da Mãe', hintText: 'Juliana Saccomani'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _motherPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp / Celular da Mãe', hintText: '(11) 98765-4321'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '👨 Dados do Pai / 2º Responsável',
            children: [
              TextField(
                controller: _fatherNameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Pai', hintText: 'Pai'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fatherPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp / Celular do Pai', hintText: '(11) 91234-5678'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '📍 Endereço & Contato de Emergência Imediata',
            children: [
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Cidade / Bairro / Endereço', hintText: 'São Paulo - SP'),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _emergencyContactPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefone', hintText: '(11) 98765-4321'),
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

  Widget _buildMedicationsAndPrescriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Scanner com 1 Toque
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
                    Text(
                      'Escanear Receita do Pneumopediatra',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tire foto da receita para o app ler os nomes das bombinhas, doses e acompanhar a data de validade automaticamente.',
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Tirar Foto / Ler OCR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _openScanPrescriptionModal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Escolher da Lista', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _openAddMedicationCatalog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de Prescrições e Bombinhas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bombinhas e Remédios Cadastrados',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              TextButton(
                onPressed: _openAddMedicationCatalog,
                child: const Text('+ Adicionar Remédio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          if (_prescriptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.medication_outlined, color: Color(0xFF94A3B8), size: 36),
                  SizedBox(height: 6),
                  Text('Nenhum remédio cadastrado ainda.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  Text('Toque em "Escanear Receita" acima para começar.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            )
          else
            ..._prescriptions.map((p) => _buildPrescriptionCardInAnamnesis(p)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCardInAnamnesis(PrescriptionRecord p) {
    final isExp = p.isExpired;
    final days = p.daysUntilExpiration;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExp ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Receita: ${p.doctorName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isExp ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isExp ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                ),
                child: Text(
                  isExp ? 'Receita Vencida' : 'Válida ($days dias)',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isExp ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Emitida em ${DateFormat('dd/MM/yyyy').format(p.prescriptionDate)}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          ...p.medications.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.category.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.commercialName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: m.isContinuous ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                m.isContinuous ? 'Todo dia' : 'Resgate',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: m.isContinuous ? const Color(0xFF0369A1) : const Color(0xFFB45309)),
                              ),
                            ),
                          ],
                        ),
                        Text('Dose: ${m.dosage} • ${m.frequency}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                        if (m.spacerRequired)
                          const Text('🫧 Usar com espaçador e máscara facial', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardSection(
            title: '🫁 Início dos Sintomas & Gravidade',
            children: [
              TextField(
                controller: _symptomsStartAgeCtrl,
                decoration: const InputDecoration(labelText: 'Com que idade começaram as tosses/chiados?', hintText: 'ex: Aos 8 meses'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já precisou ficar internado em UTI por crise?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                value: _hadIcuAdmission,
                activeThumbColor: const Color(0xFFEF4444),
                onChanged: (v) => setState(() => _hadIcuAdmission = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '⚠️ Alergias & O que piora a respiração dele:',
            children: [
              _buildMultiTagSelector('Alergias a Medicamentos:', _drugAllergies, [
                'Nenhuma medicamentosa', 'Dipirona', 'Ibuprofeno / AINEs', 'Amoxicilina'
              ]),
              const SizedBox(height: 10),
              _buildMultiTagSelector('Alergias do Ambiente / Gatilhos:', _environmentalAllergies, [
                'Ácaros da poeira', 'Poeira', 'Pólen', 'Gato / Cachorro', 'Mofo', 'Tempo frio', 'Fumaça'
              ]),
              const SizedBox(height: 10),
              _buildMultiTagSelector('Outros problemas associados:', _comorbidities, [
                'Rinite Alérgica', 'Hiper-reatividade Brônquica', 'Dermatite', 'Refluxo'
              ]),
            ],
          ),

          const SizedBox(height: 12),

          _buildCardSection(
            title: '👨‍⚕️ Médico Pediatra / Pneumopediatra',
            children: [
              TextField(
                controller: _doctorNameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Médico Assistente', hintText: 'Dr. Nome do Médico'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _doctorPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone / WhatsApp do Consultório', hintText: '(11) 99999-8888'),
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
