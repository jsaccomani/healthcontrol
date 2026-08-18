import 'dart:convert';
import 'package:clinical_core/clinical_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço de Armazenamento Local, Multi-Perfil e Versionamento Clínico (Offline-First).
class HealthStorageService {
  static const String _keyProfilesList = 'health_control_profiles_list';
  static const String _keySelectedProfileId = 'health_control_selected_profile_id';
  static const String _keyHealthEntriesPrefix = 'health_control_entries_';
  static const String _keyEventLogs = 'health_control_event_logs';
  static const String _keyDoctorPairingCode = 'health_control_doctor_pairing_code';

  final Uuid _uuid = const Uuid();

  /// Retorna a lista de todos os filhos/perfis cadastrados.
  Future<List<PatientProfile>> getAllProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_keyProfilesList);
    if (rawList == null || rawList.isEmpty) {
      final defaultChild = _generateDefaultArthurProfile();
      await savePatientProfile(defaultChild);
      await setSelectedProfileId(defaultChild.id);
      return [defaultChild];
    }

    try {
      return rawList
          .map((str) => PatientProfile.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final defaultChild = _generateDefaultArthurProfile();
      return [defaultChild];
    }
  }

  /// Retorna o perfil do filho atualmente selecionado.
  Future<PatientProfile> getPatientProfile() async {
    final profiles = await getAllProfiles();
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_keySelectedProfileId);

    if (activeId != null) {
      final found = profiles.where((p) => p.id == activeId);
      if (found.isNotEmpty) return found.first;
    }

    return profiles.first;
  }

  /// Define qual filho está selecionado no topo do app.
  Future<void> setSelectedProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedProfileId, profileId);
  }

  /// Salva ou atualiza os dados de um perfil de filho.
  Future<void> savePatientProfile(PatientProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getAllProfiles();
    
    final existingIdx = profiles.indexWhere((p) => p.id == profile.id);
    List<PatientProfile> updated;
    if (existingIdx >= 0) {
      updated = List.from(profiles)..[existingIdx] = profile;
    } else {
      updated = [...profiles, profile];
    }

    final rawList = updated.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyProfilesList, rawList);
    await setSelectedProfileId(profile.id);
  }

  /// Cria um novo perfil para outro filho.
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
    if (profiles.length <= 1) return false; // Não permite excluir o único filho

    final updated = profiles.where((p) => p.id != profileId).toList();
    final prefs = await SharedPreferences.getInstance();
    final rawList = updated.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_keyProfilesList, rawList);

    await setSelectedProfileId(updated.first.id);
    return true;
  }

  /// Retorna lançamentos clínicos do filho ativo.
  Future<List<HealthControlEntry>> getHealthEntries() async {
    final profile = await getPatientProfile();
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('$_keyHealthEntriesPrefix${profile.id}');

    if (rawList == null || rawList.isEmpty) {
      final seed = _generateSeedEntries(profile.personalBestPef);
      await _saveHealthEntriesList(profile.id, seed);
      return seed;
    }

    return rawList
        .map((str) => HealthControlEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adiciona um novo lançamento diário versionado (v1.0.x) com hash SHA-256 para o filho ativo.
  Future<HealthControlEntry> addHealthControlEntry({
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
    final profile = await getPatientProfile();
    final entries = await getHealthEntries();

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
    final prefs = await SharedPreferences.getInstance();
    final strList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('$_keyHealthEntriesPrefix$profileId', strList);
  }

  Future<void> _appendEventLog({
    required String patientId,
    required String version,
    required int sequenceNumber,
    required String authorName,
    required String authorRole,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList(_keyEventLogs) ?? [];

    String prevHash = 'GENESIS_BLOCK_0000000000000000';
    if (rawLogs.isNotEmpty) {
      try {
        final last = ClinicalEventLog.fromJson(jsonDecode(rawLogs.first));
        prevHash = last.hash;
      } catch (_) {}
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

    final updated = [jsonEncode(log.toJson()), ...rawLogs];
    await prefs.setStringList(_keyEventLogs, updated);
  }

  /// Retorna ou gera a chave de acesso do paciente para pareamento médico.
  Future<String> getOrGenerateDoctorPairingCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(_keyDoctorPairingCode);
    if (code == null) {
      code = 'AC-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      await prefs.setString(_keyDoctorPairingCode, code);
    }
    return code;
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
}
