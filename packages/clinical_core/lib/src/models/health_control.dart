import 'package:clinical_core/src/action_zones.dart';

/// Tipo de Medicação Utilizada.
enum MedicationType {
  maintenance('Manutenção / Preventivo'),
  rescue('Resgate / Crise'),
  biologic('Imunobiológico (Alto Custo)'),
  oralSteroid('Corticoide Oral');

  final String label;
  const MedicationType(this.label);
}

/// Registro de Uso de Medicação.
class MedicationUsage {
  final String name;
  final String dosage;
  final MedicationType type;
  final int puffsCount;

  const MedicationUsage({
    required this.name,
    required this.dosage,
    required this.type,
    this.puffsCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'type': type.name,
        'puffs_count': puffsCount,
      };

  factory MedicationUsage.fromJson(Map<String, dynamic> json) => MedicationUsage(
        name: json['name'] as String,
        dosage: json['dosage'] as String,
        type: MedicationType.values.firstWhere((e) => e.name == json['type']),
        puffsCount: json['puffs_count'] as int? ?? 1,
      );
}

/// Registro de Sessão de Fisioterapia Respiratória.
class PhysioSessionRecord {
  final String deviceName; // Voldyne, Shaker, Acapella, POWERbreathe, EPAP
  final int durationMinutes;
  final int? loadCmH2O;
  final int? preSpo2;
  final int? postSpo2;
  final bool amibApproved;

  const PhysioSessionRecord({
    required this.deviceName,
    required this.durationMinutes,
    this.loadCmH2O,
    this.preSpo2,
    this.postSpo2,
    required this.amibApproved,
  });

  Map<String, dynamic> toJson() => {
        'device_name': deviceName,
        'duration_minutes': durationMinutes,
        'load_cm_h2o': loadCmH2O,
        'pre_spo2': preSpo2,
        'post_spo2': postSpo2,
        'amib_approved': amibApproved,
      };

  factory PhysioSessionRecord.fromJson(Map<String, dynamic> json) =>
      PhysioSessionRecord(
        deviceName: json['device_name'] as String,
        durationMinutes: json['duration_minutes'] as int,
        loadCmH2O: json['load_cm_h2o'] as int?,
        preSpo2: json['pre_spo2'] as int?,
        postSpo2: json['post_spo2'] as int?,
        amibApproved: json['amib_approved'] as bool? ?? true,
      );
}

/// Lançamento Completo de Controle de Saúde (Health Control Entry).
class HealthControlEntry {
  final String id;
  final String versionTag; // ex: v1.0.1
  final int sequenceNumber;
  final DateTime timestamp;
  final String authorName;
  final String authorRole;

  // Sinais Vitais & Peak Flow
  final List<int> peakFlowAttempts;
  final int peakFlowBest;
  final ActionZoneType? peakFlowZone;
  final bool peakFlowVarianceError;
  final int? spo2;
  final int? heartRate;
  final int? respiratoryRate;

  // Sintomas & Gatilhos
  final List<String> symptoms;
  final List<String> environmentalTriggers;

  // Medicações & Prevenção de Sapinho
  final List<MedicationUsage> medications;
  final bool mouthRinseCompleted;

  // Fisioterapia
  final PhysioSessionRecord? physiotherapy;

  // Observações & Alertas
  final String notes;
  final bool requiresRescueFollowup;

  const HealthControlEntry({
    required this.id,
    required this.versionTag,
    required this.sequenceNumber,
    required this.timestamp,
    required this.authorName,
    required this.authorRole,
    required this.peakFlowAttempts,
    required this.peakFlowBest,
    this.peakFlowZone,
    required this.peakFlowVarianceError,
    this.spo2,
    this.heartRate,
    this.respiratoryRate,
    this.symptoms = const [],
    this.environmentalTriggers = const [],
    this.medications = const [],
    required this.mouthRinseCompleted,
    this.physiotherapy,
    this.notes = '',
    required this.requiresRescueFollowup,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'version_tag': versionTag,
        'sequence_number': sequenceNumber,
        'timestamp': timestamp.toIso8601String(),
        'author_name': authorName,
        'author_role': authorRole,
        'peak_flow_attempts': peakFlowAttempts,
        'peak_flow_best': peakFlowBest,
        'peak_flow_zone': peakFlowZone?.name,
        'peak_flow_variance_error': peakFlowVarianceError,
        'spo2': spo2,
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'symptoms': symptoms,
        'environmental_triggers': environmentalTriggers,
        'medications': medications.map((m) => m.toJson()).toList(),
        'mouth_rinse_completed': mouthRinseCompleted,
        'physiotherapy': physiotherapy?.toJson(),
        'notes': notes,
        'requires_rescue_followup': requiresRescueFollowup,
      };

  factory HealthControlEntry.fromJson(Map<String, dynamic> json) =>
      HealthControlEntry(
        id: json['id'] as String,
        versionTag: json['version_tag'] as String? ?? 'v1.0.0',
        sequenceNumber: json['sequence_number'] as int? ?? 1,
        timestamp: DateTime.parse(json['timestamp'] as String),
        authorName: json['author_name'] as String? ?? 'Mãe/Pai',
        authorRole: json['author_role'] as String? ?? 'Cuidador',
        peakFlowAttempts: (json['peak_flow_attempts'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        peakFlowBest: json['peak_flow_best'] as int? ?? 0,
        peakFlowZone: json['peak_flow_zone'] != null
            ? ActionZoneType.values
                .firstWhere((e) => e.name == json['peak_flow_zone'])
            : null,
        peakFlowVarianceError:
            json['peak_flow_variance_error'] as bool? ?? false,
        spo2: json['spo2'] as int?,
        heartRate: json['heart_rate'] as int?,
        respiratoryRate: json['respiratory_rate'] as int?,
        symptoms: (json['symptoms'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        environmentalTriggers: (json['environmental_triggers'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        medications: (json['medications'] as List<dynamic>?)
                ?.map((e) => MedicationUsage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        mouthRinseCompleted: json['mouth_rinse_completed'] as bool? ?? false,
        physiotherapy: json['physiotherapy'] != null
            ? PhysioSessionRecord.fromJson(
                json['physiotherapy'] as Map<String, dynamic>)
            : null,
        notes: json['notes'] as String? ?? '',
        requiresRescueFollowup:
            json['requires_rescue_followup'] as bool? ?? false,
      );
}
