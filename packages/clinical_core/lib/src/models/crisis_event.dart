/// Modelo de Evento de Crise Respiratória para auditoria clínica e futuros alertas médicos (Health Control Pro).
class CrisisEvent {
  final String id;
  final String patientId;
  final DateTime startedAt;
  final String startedBy; // ID do usuário / cuidador
  final String startedByName; // Nome legível para auditoria
  final String startedByRole; // 'Cuidador Principal', 'Mãe', 'Pai', 'Médico', etc.
  final String status; // 'active', 'resolved', 'escalatedToHospital'
  final String? rescuePlanId;
  final String? medicationAdministered;
  final String? doseAdministered;
  final DateTime? administeredAt;
  final DateTime? reassessmentAt;
  final String notes;
  final DateTime createdAt;
  final int schemaVersion;

  const CrisisEvent({
    required this.id,
    required this.patientId,
    required this.startedAt,
    required this.startedBy,
    this.startedByName = 'Cuidador',
    this.startedByRole = 'Cuidador Principal',
    this.status = 'active',
    this.rescuePlanId,
    this.medicationAdministered,
    this.doseAdministered,
    this.administeredAt,
    this.reassessmentAt,
    this.notes = '',
    required this.createdAt,
    this.schemaVersion = 1,
  });

  bool get isResolved => status == 'resolved';
  bool get isEscalated => status == 'escalatedToHospital';
  bool get isActive => status == 'active';

  CrisisEvent copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    String? startedBy,
    String? startedByName,
    String? startedByRole,
    String? status,
    String? rescuePlanId,
    String? medicationAdministered,
    String? doseAdministered,
    DateTime? administeredAt,
    DateTime? reassessmentAt,
    String? notes,
    DateTime? createdAt,
    int? schemaVersion,
  }) {
    return CrisisEvent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      startedBy: startedBy ?? this.startedBy,
      startedByName: startedByName ?? this.startedByName,
      startedByRole: startedByRole ?? this.startedByRole,
      status: status ?? this.status,
      rescuePlanId: rescuePlanId ?? this.rescuePlanId,
      medicationAdministered: medicationAdministered ?? this.medicationAdministered,
      doseAdministered: doseAdministered ?? this.doseAdministered,
      administeredAt: administeredAt ?? this.administeredAt,
      reassessmentAt: reassessmentAt ?? this.reassessmentAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'started_at': startedAt.toIso8601String(),
      'started_by': startedBy,
      'started_by_name': startedByName,
      'started_by_role': startedByRole,
      'status': status,
      'rescue_plan_id': rescuePlanId,
      'medication_administered': medicationAdministered,
      'dose_administered': doseAdministered,
      'administered_at': administeredAt?.toIso8601String(),
      'reassessment_at': reassessmentAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'schema_version': schemaVersion,
    };
  }

  factory CrisisEvent.fromJson(Map<String, dynamic> json) {
    final sBy = json['started_by'] as String? ?? 'Cuidador';
    final sByName = json['started_by_name'] as String? ?? sBy;

    return CrisisEvent(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : DateTime.now(),
      startedBy: sBy,
      startedByName: sByName,
      startedByRole: json['started_by_role'] as String? ?? 'Cuidador Principal',
      status: json['status'] as String? ?? 'active',
      rescuePlanId: json['rescue_plan_id'] as String?,
      medicationAdministered: json['medication_administered'] as String?,
      doseAdministered: json['dose_administered'] as String?,
      administeredAt: json['administered_at'] != null ? DateTime.parse(json['administered_at'] as String) : null,
      reassessmentAt: json['reassessment_at'] != null ? DateTime.parse(json['reassessment_at'] as String) : null,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          patientId == other.patientId &&
          status == other.status &&
          startedAt == other.startedAt &&
          medicationAdministered == other.medicationAdministered;

  @override
  int get hashCode => Object.hash(id, patientId, status, startedAt, medicationAdministered);
}
