/// Especialidade do Profissional de Saúde
enum HealthcareSpecialty {
  pediatrician,
  pediatricPulmonologist,
  allergistImmunologist,
  respiratoryPhysiotherapist,
  otorhinolaryngologist,
  generalPractitioner,
  other;

  String get displayName {
    switch (this) {
      case HealthcareSpecialty.pediatrician:
        return 'Pediatra Geral';
      case HealthcareSpecialty.pediatricPulmonologist:
        return 'Pneumologista Pediátrico(a)';
      case HealthcareSpecialty.allergistImmunologist:
        return 'Alergista e Imunologista';
      case HealthcareSpecialty.respiratoryPhysiotherapist:
        return 'Fisioterapeuta Respiratório(a)';
      case HealthcareSpecialty.otorhinolaryngologist:
        return 'Otorrinolaringologista';
      case HealthcareSpecialty.generalPractitioner:
        return 'Médico(a) de Família / UBS';
      case HealthcareSpecialty.other:
        return 'Outra Especialidade';
    }
  }
}

/// Modelo de Profissional de Saúde (Médico, Fisioterapeuta, etc.)
class HealthcareProfessional {
  final String id;
  final String fullName;
  final HealthcareSpecialty specialty;
  final String? customSpecialtyLabel;
  final String primaryPhone;
  final String? secondaryPhone;
  final String? email;
  final String? clinicOrHospital;
  final String? licenseNumber; // Ex: CRM/SP 129.840, CREFITO-3/12345
  final String? rqeNumber; // Registro de Qualificação de Especialista (RQE)
  final bool isPrimaryAttending; // Médico assistente principal
  final bool isActiveRelationship; // Vínculo ativo
  final DateTime? relationshipStartDate;
  final String? clinicalNotes;

  const HealthcareProfessional({
    required this.id,
    required this.fullName,
    required this.specialty,
    this.customSpecialtyLabel,
    required this.primaryPhone,
    this.secondaryPhone,
    this.email,
    this.clinicOrHospital,
    this.licenseNumber,
    this.rqeNumber,
    this.isPrimaryAttending = false,
    this.isActiveRelationship = true,
    this.relationshipStartDate,
    this.clinicalNotes,
  });

  String get displaySpecialty {
    if (specialty == HealthcareSpecialty.other &&
        customSpecialtyLabel != null &&
        customSpecialtyLabel!.trim().isNotEmpty) {
      return customSpecialtyLabel!.trim();
    }
    return specialty.displayName;
  }

  HealthcareProfessional copyWith({
    String? id,
    String? fullName,
    HealthcareSpecialty? specialty,
    String? customSpecialtyLabel,
    String? primaryPhone,
    String? secondaryPhone,
    String? email,
    String? clinicOrHospital,
    String? licenseNumber,
    String? rqeNumber,
    bool? isPrimaryAttending,
    bool? isActiveRelationship,
    DateTime? relationshipStartDate,
    String? clinicalNotes,
  }) {
    return HealthcareProfessional(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      customSpecialtyLabel: customSpecialtyLabel ?? this.customSpecialtyLabel,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      email: email ?? this.email,
      clinicOrHospital: clinicOrHospital ?? this.clinicOrHospital,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      rqeNumber: rqeNumber ?? this.rqeNumber,
      isPrimaryAttending: isPrimaryAttending ?? this.isPrimaryAttending,
      isActiveRelationship: isActiveRelationship ?? this.isActiveRelationship,
      relationshipStartDate: relationshipStartDate ?? this.relationshipStartDate,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'specialty': specialty.name,
      'custom_specialty_label': customSpecialtyLabel,
      'primary_phone': primaryPhone,
      'secondary_phone': secondaryPhone,
      'email': email,
      'clinic_or_hospital': clinicOrHospital,
      'license_number': licenseNumber,
      'rqe_number': rqeNumber,
      'is_primary_attending': isPrimaryAttending,
      'is_active_relationship': isActiveRelationship,
      'relationship_start_date': relationshipStartDate?.toIso8601String(),
      'clinical_notes': clinicalNotes,
    };
  }

  factory HealthcareProfessional.fromJson(Map<String, dynamic> json) {
    final specStr = json['specialty'] as String?;
    final spec = HealthcareSpecialty.values.firstWhere(
      (e) => e.name == specStr,
      orElse: () => HealthcareSpecialty.other,
    );

    return HealthcareProfessional(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      specialty: spec,
      customSpecialtyLabel: json['custom_specialty_label'] as String?,
      primaryPhone: json['primary_phone'] as String? ?? '',
      secondaryPhone: json['secondary_phone'] as String?,
      email: json['email'] as String?,
      clinicOrHospital: json['clinic_or_hospital'] as String?,
      licenseNumber: json['license_number'] as String?,
      rqeNumber: json['rqe_number'] as String?,
      isPrimaryAttending: json['is_primary_attending'] as bool? ?? false,
      isActiveRelationship: json['is_active_relationship'] as bool? ?? true,
      relationshipStartDate: json['relationship_start_date'] != null
          ? DateTime.tryParse(json['relationship_start_date'] as String)
          : null,
      clinicalNotes: json['clinical_notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthcareProfessional &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          specialty == other.specialty &&
          primaryPhone == other.primaryPhone &&
          licenseNumber == other.licenseNumber &&
          isPrimaryAttending == other.isPrimaryAttending &&
          isActiveRelationship == other.isActiveRelationship;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      specialty.hashCode ^
      primaryPhone.hashCode ^
      (licenseNumber?.hashCode ?? 0) ^
      isPrimaryAttending.hashCode ^
      isActiveRelationship.hashCode;

  @override
  String toString() =>
      'HealthcareProfessional(id: $id, name: $fullName, specialty: ${specialty.name}, phone: $primaryPhone)';
}
