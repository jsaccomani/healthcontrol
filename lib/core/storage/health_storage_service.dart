import 'dart:convert';
import 'package:clinical_core/clinical_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço de Armazenamento Local e Versionamento Clínico (Offline-First).
class HealthStorageService {
  static const String _keyPatientProfile = 'asma_control_patient_profile';
  static const String _keyHealthEntries = 'asma_control_health_entries';
  static const String _keyEventLogs = 'asma_control_event_logs';
  static const String _keyDoctorPairingCode = 'asma_control_doctor_pairing_code';

  final Uuid _uuid = const Uuid();

  /// Carrega o perfil do paciente ou retorna perfil padrão (Criança de 5 anos).
  Future<PatientProfile> getPatientProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPatientProfile);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return PatientProfile(
          id: map['id'] as String? ?? 'paciente-001',
          name: map['name'] as String? ?? 'Filho',
          birthDate: DateTime.parse(map['birth_date'] as String? ?? '2021-04-10'),
          gender: map['gender'] as String? ?? 'Masculino',
          heightCm: (map['height_cm'] as num?)?.toDouble() ?? 110.0,
          weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 19.5,
          personalBestPef: map['personal_best_pef'] as int? ?? 220,
          susCardNumber: map['sus_card_number'] as String? ?? '700000000000000',
          healthInsurance: map['health_insurance'] as String? ?? 'Unimed',
          insuranceCardNumber: map['insurance_card_number'] as String? ?? '123456789',
          igeLevel: (map['ige_level'] as num?)?.toDouble() ?? 450.0,
          eosinophilsCount: map['eosinophils_count'] as int? ?? 580,
          comorbidities: (map['comorbidities'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              ['Rinite Alérgica', 'Refluxo Gastroesofágico'],
        );
      } catch (_) {}
    }

    // Perfil Padrão Inicial para o Filho de 5 Anos
    final defaultProfile = PatientProfile(
      id: 'paciente-filho-01',
      name: 'Arthur Saccomani',
      birthDate: DateTime(2021, 5, 15),
      gender: 'Masculino',
      heightCm: 110.0,
      weightKg: 19.5,
      personalBestPef: 220,
      susCardNumber: '898 0000 1234 5678',
      healthInsurance: 'Bradesco Saúde Top',
      insuranceCardNumber: '987654321000',
      igeLevel: 480.0,
      eosinophilsCount: 550,
      comorbidities: ['Rinite Alérgica', 'Hiper-reatividade Brônquica'],
    );
    await savePatientProfile(defaultProfile);
    return defaultProfile;
  }

  /// Salva ou atualiza o perfil do paciente.
  Future<void> savePatientProfile(PatientProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'id': profile.id,
      'name': profile.name,
      'birth_date': profile.birthDate.toIso8601String(),
      'gender': profile.gender,
      'height_cm': profile.heightCm,
      'weight_kg': profile.weightKg,
      'personal_best_pef': profile.personalBestPef,
      'sus_card_number': profile.susCardNumber,
      'health_insurance': profile.healthInsurance,
      'insurance_card_number': profile.insuranceCardNumber,
      'ige_level': profile.igeLevel,
      'eosinophils_count': profile.eosinophilsCount,
      'comorbidities': profile.comorbidities,
    };
    await prefs.setString(_keyPatientProfile, jsonEncode(map));
  }

  /// Retorna todos os lançamentos clínicos em ordem cronológica reversa (mais recente primeiro).
  Future<List<HealthControlEntry>> getHealthEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_keyHealthEntries);
    if (rawList == null || rawList.isEmpty) {
      // Cria registros semente de exemplo para visualização imediata
      final seed = _generateSeedEntries();
      await _saveHealthEntriesList(seed);
      return seed;
    }
    return rawList
        .map((str) => HealthControlEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adiciona um novo lançamento clínico com versionamento automático (v1.0.x) e hash SHA-256.
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
    
    // Cálculo do Peak Flow e Regra dos 3 Sopros
    int bestPef = 0;
    bool varianceError = false;
    if (peakFlowAttempts.isNotEmpty) {
      bestPef = peakFlowAttempts.reduce((a, b) => a > b ? a : b);
      if (peakFlowAttempts.length >= 2) {
        final minPef = peakFlowAttempts.reduce((a, b) => a < b ? a : b);
        varianceError = (bestPef - minPef) > 20;
      }
    }

    // Avaliação da Zona GINA
    final zoneEval = ActionZoneEvaluator.evaluate(
      currentPef: bestPef,
      personalBestPef: profile.personalBestPef,
    );

    // Número de sequência e Tag de versão
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

    // Salva na lista
    final updatedList = [newEntry, ...entries];
    await _saveHealthEntriesList(updatedList);

    // Registra no Event Sourcing com Hash de Auditoria
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

  Future<void> _saveHealthEntriesList(List<HealthControlEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final strList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_keyHealthEntries, strList);
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

  /// Retorna a chave de acesso para pareamento com Asma Control Pro (Médicos).
  Future<String> getOrGenerateDoctorPairingCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(_keyDoctorPairingCode);
    if (code == null) {
      // Gera código formatado de 6 caracteres (ex: AC-7842)
      code = 'AC-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      await prefs.setString(_keyDoctorPairingCode, code);
    }
    return code;
  }

  List<HealthControlEntry> _generateSeedEntries() {
    final now = DateTime.now();
    return [
      HealthControlEntry(
        id: 'seed-01',
        versionTag: 'v1.0.2',
        sequenceNumber: 2,
        timestamp: now.subtract(const Duration(hours: 4)),
        authorName: 'Mãe (Juliana)',
        authorRole: 'Cuidadora Principal',
        peakFlowAttempts: [210, 220, 215],
        peakFlowBest: 220,
        peakFlowZone: ActionZoneType.green,
        peakFlowVarianceError: false,
        spo2: 98,
        heartRate: 88,
        respiratoryRate: 22,
        symptoms: ['Sem sintomas aparentes'],
        environmentalTriggers: [],
        medications: [
          const MedicationUsage(
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
        notes: 'Soprou bem, fez bochecho certinho após o Clenil.',
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
        symptoms: ['Tosse leve ao deitar'],
        environmentalTriggers: ['Tempo seco'],
        medications: [
          const MedicationUsage(
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
