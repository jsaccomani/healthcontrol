import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Tipos de Eventos Imutáveis do Prontuário Clínico.
enum ClinicalEventType {
  healthControlEntry('HEALTH_CONTROL_ENTRY'),
  dailyClinicalDiary('DAILY_CLINICAL_DIARY'),
  cactScore('CACT_SCORE'),
  physiotherapySession('PHYSIO_SESSION'),
  clinicalCrisis('CLINICAL_CRISIS'),
  doctorPairing('DOCTOR_PAIRING');

  final String code;
  const ClinicalEventType(this.code);

  static ClinicalEventType fromCode(String code) {
    return ClinicalEventType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Tipo de evento inválido: $code'),
    );
  }
}

/// Registro Imutável e Versionado de Saúde (Auditoria & Event Sourcing).
/// Garante conformidade com a Resolução CFM nº 1.331/89 e integridade contra adulterações.
class ClinicalEventLog {
  final String eventId;
  final String patientId;
  final String version;
  final int sequenceNumber;
  final ClinicalEventType eventType;
  final String authorName;
  final String authorRole;
  final DateTime timestamp;
  final Map<String, dynamic> payload;
  final String previousHash;
  final String hash;

  ClinicalEventLog({
    required this.eventId,
    required this.patientId,
    required this.version,
    required this.sequenceNumber,
    required this.eventType,
    required this.authorName,
    required this.authorRole,
    required this.timestamp,
    required this.payload,
    required this.previousHash,
    String? hash,
  }) : hash = hash ?? computeHash(
          eventId: eventId,
          patientId: patientId,
          version: version,
          sequenceNumber: sequenceNumber,
          eventType: eventType,
          timestamp: timestamp,
          payload: payload,
          previousHash: previousHash,
        );

  static String computeHash({
    required String eventId,
    required String patientId,
    required String version,
    required int sequenceNumber,
    required ClinicalEventType eventType,
    required DateTime timestamp,
    required Map<String, dynamic> payload,
    required String previousHash,
  }) {
    final rawString = '$previousHash|$eventId|$patientId|$version|$sequenceNumber|'
        '${eventType.code}|${timestamp.toIso8601String()}|${jsonEncode(payload)}';
    return sha256.convert(utf8.encode(rawString)).toString();
  }

  bool verifyIntegrity() {
    final recalculated = computeHash(
      eventId: eventId,
      patientId: patientId,
      version: version,
      sequenceNumber: sequenceNumber,
      eventType: eventType,
      timestamp: timestamp,
      payload: payload,
      previousHash: previousHash,
    );
    return recalculated == hash;
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'patient_id': patientId,
      'version': version,
      'sequence_number': sequenceNumber,
      'event_type': eventType.code,
      'author_name': authorName,
      'author_role': authorRole,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
      'previous_hash': previousHash,
      'hash': hash,
    };
  }

  factory ClinicalEventLog.fromJson(Map<String, dynamic> json) {
    return ClinicalEventLog(
      eventId: json['event_id'] as String,
      patientId: json['patient_id'] as String,
      version: json['version'] as String? ?? 'v1.0.0',
      sequenceNumber: json['sequence_number'] as int? ?? 1,
      eventType: ClinicalEventType.fromCode(json['event_type'] as String),
      authorName: json['author_name'] as String? ?? 'Mãe/Pai',
      authorRole: json['author_role'] as String? ?? 'Cuidador',
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      previousHash: json['previous_hash'] as String? ?? '0',
      hash: json['hash'] as String?,
    );
  }
}
