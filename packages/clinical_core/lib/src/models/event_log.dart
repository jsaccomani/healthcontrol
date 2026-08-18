/// Tipos de Eventos Imutáveis do Prontuário (/patients/{id}/event_log/{id}).
enum ClinicalEventType {
  dailyClinicalDiary('DAILY_CLINICAL_DIARY'),
  cactScore('CACT_SCORE'),
  clinicalCrisis('CLINICAL_CRISIS');

  final String code;
  const ClinicalEventType(this.code);

  static ClinicalEventType fromCode(String code) {
    return ClinicalEventType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Tipo de evento inválido: $code'),
    );
  }
}

/// Registro Imutável de Evento Clínico (Event Sourcing).
class ClinicalEventLog {
  final String eventId;
  final String patientId;
  final ClinicalEventType eventType;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  const ClinicalEventLog({
    required this.eventId,
    required this.patientId,
    required this.eventType,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'patient_id': patientId,
      'event_type': eventType.code,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
    };
  }

  factory ClinicalEventLog.fromJson(Map<String, dynamic> json) {
    return ClinicalEventLog(
      eventId: json['event_id'] as String,
      patientId: json['patient_id'] as String,
      eventType: ClinicalEventType.fromCode(json['event_type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}
