import 'dart:convert';
import 'package:clinical_core/clinical_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço de Armazenamento Local, Multi-Perfil e Versionamento Clínico (Offline-First de Alta Performance).
class HealthStorageService {
  static const String _keyProfilesList = 'health_control_profiles_list';
  static const String _keySelectedProfileId = 'health_control_selected_profile_id';
  static const String _keyHealthEntriesPrefix = 'health_control_entries_';
  static const String _keyEventLogsPrefix = 'health_control_event_logs_';
  static const String _keyLegacyEventLogs = 'health_control_event_logs';
  static const String _keyDoctorPairingCodePrefix = 'health_control_pairing_code_';
  static const String _keyLegacyDoctorPairingCode = 'health_control_doctor_pairing_code';
  static const String _keyPrescriptionsPrefix = 'health_control_prescriptions_';

  static final HealthStorageService _instance = HealthStorageService._internal();
  factory HealthStorageService() => _instance;
  HealthStorageService._internal();

  final Uuid _uuid = const Uuid();

  // ---------------------------------------------------------------------------
  // Cache em Memória para Performance Instantânea (< 1ms)
  // ---------------------------------------------------------------------------
  SharedPreferences? _cachedPrefs;
  List<PatientProfile>? _cachedProfiles;
  String? _cachedSelectedProfileId;
  final Map<String, List<HealthControlEntry>> _cachedEntries = {};
  final Map<String, List<PrescriptionRecord>> _cachedPrescriptions = {};
  final Map<String, List<ClinicalEventLog>> _cachedEventLogs = {};

  Future<SharedPreferences> _getPrefs() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  /// Limpa o cache de um paciente ou de todos
  void clearMemoryCache({String? patientId}) {
    if (patientId != null) {
      _cachedEntries.remove(patientId);
      _cachedPrescriptions.remove(patientId);
      _cachedEventLogs.remove(patientId);
    } else {
      _cachedProfiles = null;
      _cachedSelectedProfileId = null;
      _cachedEntries.clear();
      _cachedPrescriptions.clear();
      _cachedEventLogs.clear();
    }
  }

  /// Retorna a lista de todos os filhos/perfis cadastrados.
  Future<List<PatientProfile>> getAllProfiles() async {
    if (_cachedProfiles != null && _cachedProfiles!.isNotEmpty) {
      return List.unmodifiable(_cachedProfiles!);
    }

    final prefs = await _getPrefs();
    final rawList = prefs.getStringList(_keyProfilesList);
    if (rawList == null || rawList.isEmpty) {
      final defaultChild = _generateDefaultArthurProfile();
      _cachedProfiles = [defaultChild];
      _cachedSelectedProfileId = defaultChild.id;
      await savePatientProfile(defaultChild);
      await setSelectedProfileId(defaultChild.id);
      return [defaultChild];
    }

    try {
      final loaded = rawList
          .map((str) => PatientProfile.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
      _cachedProfiles = loaded;
      return List.unmodifiable(loaded);
    } catch (_) {
      final defaultChild = _generateDefaultArthurProfile();
      _cachedProfiles = [defaultChild];
      return [defaultChild];
    }
  }

  /// Retorna o perfil do filho específico ou do atualmente selecionado.
  Future<PatientProfile> getPatientProfile({String? patientId}) async {
    final profiles = await getAllProfiles();
    
    if (patientId != null) {
      final found = profiles.where((p) => p.id == patientId);
      if (found.isNotEmpty) return found.first;
    }

    final prefs = await _getPrefs();
    _cachedSelectedProfileId ??= prefs.getString(_keySelectedProfileId);

    if (_cachedSelectedProfileId != null) {
      final found = profiles.where((p) => p.id == _cachedSelectedProfileId);
      if (found.isNotEmpty) return found.first;
    }

    return profiles.first;
  }

  /// Retorna um perfil específico por ID, ou null se não existir.
  Future<PatientProfile?> getProfileById(String profileId) async {
    final profiles = await getAllProfiles();
    final matches = profiles.where((p) => p.id == profileId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Define qual filho está selecionado no topo do app.
  Future<void> setSelectedProfileId(String profileId) async {
    _cachedSelectedProfileId = profileId;
    final prefs = await _getPrefs();
    await prefs.setString(_keySelectedProfileId, profileId);
  }

  /// Salva ou atualiza os dados de um perfil de filho.
  Future<void> savePatientProfile(PatientProfile profile) async {
    final profiles = await getAllProfiles();
    
    final existingIdx = profiles.indexWhere((p) => p.id == profile.id);
    List<PatientProfile> updated;
    if (existingIdx >= 0) {
      updated = List.from(profiles)..[existingIdx] = profile;
    } else {
      updated = [...profiles, profile];
    }

    _cachedProfiles = updated;
    _cachedSelectedProfileId = profile.id;

    final prefs = await _getPrefs();
    final rawList = updated.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyProfilesList, rawList);
    await prefs.setString(_keySelectedProfileId, profile.id);
  }

  /// Cria um novo perfil para outro filho com herança automática dos dados familiares.
  Future<PatientProfile> createNewChildProfile({
    required String name,
    required DateTime birthDate,
    required String gender,
    required double heightCm,
    required double weightKg,
    required int personalBestPef,
    String? photoBase64,
    String avatarId = 'boy_1',
    String susCardNumber = '',
    String healthInsurance = '',
    String insuranceCardNumber = '',
  }) async {
    final active = await getPatientProfile();
    final newId = 'child_${_uuid.v4().substring(0, 8)}';

    final newProfile = PatientProfile(
      id: newId,
      name: name,
      photoBase64: photoBase64,
      avatarId: avatarId,
      birthDate: birthDate,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      personalBestPef: personalBestPef,
      susCardNumber: susCardNumber,
      healthInsurance: healthInsurance,
      insuranceCardNumber: insuranceCardNumber,
      // Herda contatos dos pais para conveniência
      motherName: active.motherName,
      motherPhone: active.motherPhone,
      motherEmail: active.motherEmail,
      fatherName: active.fatherName,
      fatherPhone: active.fatherPhone,
      emergencyContactName: active.emergencyContactName,
      emergencyContactPhone: active.emergencyContactPhone,
      addressCityState: active.addressCityState,
    );

    await savePatientProfile(newProfile);
    return newProfile;
  }

  /// Exclui o perfil de um filho (se houver mais de um cadastrado).
  Future<bool> deleteChildProfile(String profileId) async {
    final profiles = await getAllProfiles();
    if (profiles.length <= 1) return false;

    final updated = profiles.where((p) => p.id != profileId).toList();
    _cachedProfiles = updated;
    _cachedSelectedProfileId = updated.first.id;

    final prefs = await _getPrefs();
    final rawList = updated.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyProfilesList, rawList);
    await setSelectedProfileId(updated.first.id);

    // Limpa caches do perfil removido
    clearMemoryCache(patientId: profileId);
    return true;
  }

  /// Retorna lançamentos clínicos de um filho específico ou do filho ativo.
  Future<List<HealthControlEntry>> getHealthEntries({String? patientId}) async {
    final profile = await getPatientProfile(patientId: patientId);
    if (_cachedEntries.containsKey(profile.id)) {
      return List.unmodifiable(_cachedEntries[profile.id]!);
    }

    final prefs = await _getPrefs();
    final rawList = prefs.getStringList('$_keyHealthEntriesPrefix${profile.id}');

    if (rawList == null || rawList.isEmpty) {
      final seed = _generateSeedEntries(profile.personalBestPef);
      _cachedEntries[profile.id] = seed;
      await _saveHealthEntriesList(profile.id, seed);
      return seed;
    }

    final entries = rawList
        .map((str) => HealthControlEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
    _cachedEntries[profile.id] = entries;
    return List.unmodifiable(entries);
  }

  /// Adiciona um novo lançamento diário versionado (v1.0.x) com hash SHA-256 para o filho selecionado.
  Future<HealthControlEntry> addHealthControlEntry({
    String? targetPatientId,
    required String authorName,
    required String authorRole,
    required List<int> peakFlowAttempts,
    required int spo2,
    int? heartRate,
    int? respiratoryRate,
    List<String> symptoms = const [],
    List<String> environmentalTriggers = const [],
    List<MedicationUsage> medications = const [],
    required bool mouthRinseCompleted,
    PhysioSessionRecord? physiotherapy,
    String notes = '',
  }) async {
    final profile = await getPatientProfile(patientId: targetPatientId);
    final entries = await getHealthEntries(patientId: profile.id);

    int bestPef = 0;
    bool varianceError = false;
    if (peakFlowAttempts.isNotEmpty) {
      bestPef = peakFlowAttempts.reduce((a, b) => a > b ? a : b);
      if (peakFlowAttempts.length >= 2) {
        final minPef = peakFlowAttempts.reduce((a, b) => a < b ? a : b);
        varianceError = (bestPef - minPef) > 20;
      }
    }

    final zoneEval = ActionZoneEvaluator.evaluate(
      currentPef: bestPef,
      personalBestPef: profile.personalBestPef,
    );

    final nextSeq = entries.length + 1;
    final versionTag = 'v1.0.$nextSeq';
    final entryId = _uuid.v4();
    final now = DateTime.now();

    final hasRescueMed = medications.any((m) => m.type == MedicationType.rescue);
    final isYellowOrRed = zoneEval.zone != ActionZoneType.green;
    final requiresRescueFollowup = hasRescueMed || isYellowOrRed;

    final newEntry = HealthControlEntry(
      id: entryId,
      versionTag: versionTag,
      sequenceNumber: nextSeq,
      timestamp: now,
      authorName: authorName,
      authorRole: authorRole,
      peakFlowAttempts: peakFlowAttempts,
      peakFlowBest: bestPef,
      peakFlowZone: zoneEval.zone,
      peakFlowVarianceError: varianceError,
      spo2: spo2,
      heartRate: heartRate,
      respiratoryRate: respiratoryRate,
      symptoms: symptoms,
      environmentalTriggers: environmentalTriggers,
      medications: medications,
      mouthRinseCompleted: mouthRinseCompleted,
      physiotherapy: physiotherapy,
      notes: notes,
      requiresRescueFollowup: requiresRescueFollowup,
    );

    final updatedList = [newEntry, ...entries];
    _cachedEntries[profile.id] = updatedList;
    await _saveHealthEntriesList(profile.id, updatedList);

    await _appendEventLog(
      patientId: profile.id,
      version: versionTag,
      sequenceNumber: nextSeq,
      authorName: authorName,
      authorRole: authorRole,
      payload: newEntry.toJson(),
    );

    return newEntry;
  }

  Future<void> _saveHealthEntriesList(String profileId, List<HealthControlEntry> list) async {
    final prefs = await _getPrefs();
    final strList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('$_keyHealthEntriesPrefix$profileId', strList);
  }

  /// Retorna os registros do event log criptográfico isolados por paciente.
  Future<List<ClinicalEventLog>> getEventLogs({String? patientId}) async {
    final profile = await getPatientProfile(patientId: patientId);
    if (_cachedEventLogs.containsKey(profile.id)) {
      return List.unmodifiable(_cachedEventLogs[profile.id]!);
    }

    final prefs = await _getPrefs();
    final key = '$_keyEventLogsPrefix${profile.id}';
    var rawLogs = prefs.getStringList(key);

    // Migração de dados legados se existirem
    if (rawLogs == null || rawLogs.isEmpty) {
      final legacy = prefs.getStringList(_keyLegacyEventLogs);
      if (legacy != null && legacy.isNotEmpty && profile.id == 'arthur_saccomani_01') {
        rawLogs = legacy;
        await prefs.setStringList(key, legacy);
        await prefs.remove(_keyLegacyEventLogs);
      }
    }

    if (rawLogs == null || rawLogs.isEmpty) {
      return [];
    }

    try {
      final loaded = rawLogs
          .map((str) => ClinicalEventLog.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
      _cachedEventLogs[profile.id] = loaded;
      return List.unmodifiable(loaded);
    } catch (_) {
      return [];
    }
  }

  Future<void> _appendEventLog({
    required String patientId,
    required String version,
    required int sequenceNumber,
    required String authorName,
    required String authorRole,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await _getPrefs();
    final key = '$_keyEventLogsPrefix$patientId';
    final existingLogs = await getEventLogs(patientId: patientId);

    String prevHash = 'GENESIS_BLOCK_0000000000000000';
    if (existingLogs.isNotEmpty) {
      prevHash = existingLogs.first.hash;
    }

    final log = ClinicalEventLog(
      eventId: _uuid.v4(),
      patientId: patientId,
      version: version,
      sequenceNumber: sequenceNumber,
      eventType: ClinicalEventType.healthControlEntry,
      authorName: authorName,
      authorRole: authorRole,
      timestamp: DateTime.now(),
      payload: payload,
      previousHash: prevHash,
    );

    final updated = [log, ...existingLogs];
    _cachedEventLogs[patientId] = updated;

    final rawList = updated.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(key, rawList);
  }

  /// Retorna ou gera a chave de acesso exclusiva do paciente para pareamento médico.
  Future<String> getOrGenerateDoctorPairingCode({String? patientId}) async {
    final profile = await getPatientProfile(patientId: patientId);
    final prefs = await _getPrefs();
    final key = '$_keyDoctorPairingCodePrefix${profile.id}';
    
    String? code = prefs.getString(key);
    if (code == null) {
      // Migra legado se Arthur
      if (profile.id == 'arthur_saccomani_01') {
        code = prefs.getString(_keyLegacyDoctorPairingCode);
        if (code != null) {
          await prefs.setString(key, code);
          await prefs.remove(_keyLegacyDoctorPairingCode);
          return code;
        }
      }
      code = 'AC-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      await prefs.setString(key, code);
    }
    return code;
  }

  /// Retorna a lista de prescrições médicas ativas do paciente.
  Future<List<PrescriptionRecord>> getPrescriptions(String patientId) async {
    if (_cachedPrescriptions.containsKey(patientId)) {
      return List.unmodifiable(_cachedPrescriptions[patientId]!);
    }

    final prefs = await _getPrefs();
    final rawList = prefs.getStringList('$_keyPrescriptionsPrefix$patientId');

    if (rawList == null || rawList.isEmpty) {
      final seed = [_generateDefaultArthurPrescription(patientId)];
      _cachedPrescriptions[patientId] = seed;
      await _savePrescriptionsList(patientId, seed);
      return seed;
    }

    try {
      final loaded = rawList
          .map((str) => PrescriptionRecord.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
      _cachedPrescriptions[patientId] = loaded;
      return List.unmodifiable(loaded);
    } catch (_) {
      return [];
    }
  }

  /// Salva ou atualiza uma prescrição médica escaneada/inserida.
  Future<void> savePrescription(PrescriptionRecord prescription) async {
    final list = await getPrescriptions(prescription.patientId);
    final idx = list.indexWhere((p) => p.id == prescription.id);
    List<PrescriptionRecord> updated;
    if (idx >= 0) {
      updated = List.from(list)..[idx] = prescription;
    } else {
      updated = [prescription, ...list];
    }
    _cachedPrescriptions[prescription.patientId] = updated;
    await _savePrescriptionsList(prescription.patientId, updated);
  }

  /// Remove uma prescrição médica.
  Future<void> deletePrescription(String patientId, String prescriptionId) async {
    final list = await getPrescriptions(patientId);
    final updated = list.where((p) => p.id != prescriptionId).toList();
    _cachedPrescriptions[patientId] = updated;
    await _savePrescriptionsList(patientId, updated);
  }

  Future<void> _savePrescriptionsList(String patientId, List<PrescriptionRecord> list) async {
    final prefs = await _getPrefs();
    final raw = list.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('$_keyPrescriptionsPrefix$patientId', raw);
  }

  PatientProfile _generateDefaultArthurProfile() {
    return PatientProfile(
      id: 'arthur_saccomani_01',
      name: 'Arthur Saccomani',
      avatarId: 'boy_1',
      birthDate: DateTime(2021, 5, 15),
      gender: 'Masculino',
      bloodType: 'A+',
      heightCm: 110.0,
      weightKg: 19.5,
      personalBestPef: 220,
      susCardNumber: '898 0000 1234 5678',
      healthInsurance: 'Bradesco Saúde Top',
      insuranceCardNumber: '987654321000',
      motherName: 'Juliana Saccomani',
      motherPhone: '(11) 98765-4321',
      motherEmail: 'juliana.saccomani@email.com',
      fatherName: 'Pai',
      fatherPhone: '(11) 91234-5678',
      emergencyContactName: 'Mãe (Juliana)',
      emergencyContactPhone: '(11) 98765-4321',
      addressCityState: 'São Paulo - SP',
      symptomsStartAge: 'Aos 8 meses de idade (bronquiolites de repetição)',
      hadIcuAdmission: false,
      icuAdmissionsCount: 0,
      lastHospitalizationInfo: 'Atendimento ambulatorial e pronto-socorro para inalação',
      familyAsthmaHistory: const ['Mãe (Rinite/Asma)', 'Pai (Rinite)'],
      drugAllergies: const ['Nenhuma conhecida até o momento'],
      foodAllergies: const ['Nenhuma alimentar confirmada'],
      environmentalAllergies: const ['Ácaros da poeira doméstica', 'Pólen', 'Mudança brusca de temperatura'],
      comorbidities: const ['Rinite Alérgica Perene', 'Hiper-reatividade Brônquica'],
      continuousMedications: const ['Clenil HFA 250mcg (1 puff 12/12h com espaçador valvulado)'],
      igeLevel: 480.0,
      eosinophilsCount: 550,
      doctorName: 'Dr. Pneumopediatra Especialista',
      doctorPhone: '(11) 99999-8888',
    );
  }

  List<HealthControlEntry> _generateSeedEntries(int personalBest) {
    final now = DateTime.now();
    return [
      HealthControlEntry(
        id: 'seed-01',
        versionTag: 'v1.0.2',
        sequenceNumber: 2,
        timestamp: now.subtract(const Duration(hours: 3)),
        authorName: 'Mãe (Juliana)',
        authorRole: 'Cuidadora Principal',
        peakFlowAttempts: [210, 220, 215],
        peakFlowBest: 220,
        peakFlowZone: ActionZoneType.green,
        peakFlowVarianceError: false,
        spo2: 98,
        heartRate: 88,
        respiratoryRate: 22,
        symptoms: const ['Sem sintomas aparentes'],
        environmentalTriggers: const [],
        medications: const [
          MedicationUsage(
            name: 'Clenil HFA 250mcg (com espaçador)',
            dosage: '1 puff',
            type: MedicationType.maintenance,
          ),
        ],
        mouthRinseCompleted: true,
        physiotherapy: const PhysioSessionRecord(
          deviceName: 'Voldyne 2500 (Espirometria a Volume)',
          durationMinutes: 10,
          preSpo2: 97,
          postSpo2: 99,
          amibApproved: true,
        ),
        notes: 'Soprou com boa vedação, fez bochecho certinho após o spray.',
        requiresRescueFollowup: false,
      ),
      HealthControlEntry(
        id: 'seed-02',
        versionTag: 'v1.0.1',
        sequenceNumber: 1,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        authorName: 'Pai',
        authorRole: 'Cuidador',
        peakFlowAttempts: [195, 200, 205],
        peakFlowBest: 205,
        peakFlowZone: ActionZoneType.green,
        peakFlowVarianceError: false,
        spo2: 97,
        heartRate: 92,
        respiratoryRate: 24,
        symptoms: const ['Tosse seca leve ao deitar'],
        environmentalTriggers: const ['Tempo seco / Baixa umidade'],
        medications: const [
          MedicationUsage(
            name: 'Clenil HFA 250mcg',
            dosage: '1 puff',
            type: MedicationType.maintenance,
          ),
        ],
        mouthRinseCompleted: true,
        notes: 'Umidificador de ar ligado no quarto.',
        requiresRescueFollowup: false,
      ),
    ];
  }

  PrescriptionRecord _generateDefaultArthurPrescription(String patientId) {
    return PrescriptionRecord(
      id: 'presc_arthur_initial',
      patientId: patientId,
      doctorName: 'Dr. Marco Aurélio Valente',
      doctorCrm: 'CRM/SP 129.840 - RQE 48.211',
      clinicName: 'Instituto Pediátrico de Pneumologia e Alergia',
      prescriptionDate: DateTime.now().subtract(const Duration(days: 20)),
      validityMonths: 6,
      medications: const [
        PrescribedMedication(
          id: 'med_01',
          commercialName: 'Clenil HFA 250mcg Spray',
          activeIngredient: 'Dipropionato de Beclometasona',
          category: MedicationCategory.maintenanceInhaled,
          dosage: '1 jato (puff)',
          frequency: '12/12 horas (Manhã e Noite)',
          instructions: 'Agitar bem a bombinha, usar com espaçador valvulado e máscara facial. Bochechar a boca com água após o uso para prevenir candidíase.',
          spacerRequired: true,
          isContinuous: true,
        ),
        PrescribedMedication(
          id: 'med_02',
          commercialName: 'Aerolin Spray 100mcg',
          activeIngredient: 'Sulfato de Salbutamol',
          category: MedicationCategory.rescueInhaled,
          dosage: '2 a 4 jatos',
          frequency: 'Uso se tosse, chiado ou falta de ar (Resgate)',
          instructions: 'Aplicar 1 jato por vez no espaçador, aguardar 6 respirações calmas por jato. Repetir conforme plano de ação.',
          spacerRequired: true,
          isContinuous: false,
        ),
        PrescribedMedication(
          id: 'med_03',
          commercialName: 'Singulair Baby 4mg Sachê',
          activeIngredient: 'Montelucaste de Sódio',
          category: MedicationCategory.antileukotrieneOral,
          dosage: '1 sachê (grânulos orais)',
          frequency: '1x ao dia à noite',
          instructions: 'Administrar à noite misturado em uma colher de alimento pastoso.',
          spacerRequired: false,
          isContinuous: true,
        ),
      ],
      notes: 'Plano terapêutico de manutenção para Asma Grave Pediátrica. Retorno programado em 6 meses com diário e medições de Peak Flow.',
      isLmeAltoCusto: false,
    );
  }
}
