/// Tipo de Vínculo do Cuidador com a Criança
enum CaregiverRelationshipType {
  mother,
  father,
  grandmother,
  grandfather,
  aunt,
  uncle,
  babysitter,
  schoolCaregiver,
  nanny,
  familyFriend,
  fosterCaregiver,
  other;

  String get displayName {
    switch (this) {
      case CaregiverRelationshipType.mother:
        return 'Mãe';
      case CaregiverRelationshipType.father:
        return 'Pai';
      case CaregiverRelationshipType.grandmother:
        return 'Avó';
      case CaregiverRelationshipType.grandfather:
        return 'Avô';
      case CaregiverRelationshipType.aunt:
        return 'Tia';
      case CaregiverRelationshipType.uncle:
        return 'Tio';
      case CaregiverRelationshipType.babysitter:
        return 'Babá';
      case CaregiverRelationshipType.schoolCaregiver:
        return 'Cuidador(a) Escolar / Professor(a)';
      case CaregiverRelationshipType.nanny:
        return 'Cuidador(a) Domiciliar / Enfermagem';
      case CaregiverRelationshipType.familyFriend:
        return 'Amigo(a) da Família';
      case CaregiverRelationshipType.fosterCaregiver:
        return 'Cuidador(a) Acolhedor(a)';
      case CaregiverRelationshipType.other:
        return 'Outro Cuidador';
    }
  }
}

/// Nível de Acesso / Autorização Operacional do Cuidador
enum CaregiverAccessLevel {
  primaryGuardian,
  guardian,
  caregiverFull,
  caregiverRecordOnly;

  String get displayName {
    switch (this) {
      case CaregiverAccessLevel.primaryGuardian:
        return 'Responsável Principal (Acesso Total & Gestão)';
      case CaregiverAccessLevel.guardian:
        return 'Co-Responsável Legal';
      case CaregiverAccessLevel.caregiverFull:
        return 'Cuidador(a) Regular (Leitura & Registro Completo)';
      case CaregiverAccessLevel.caregiverRecordOnly:
        return 'Cuidador(a) Pontual / Escolar (Apenas Registro Rápido)';
    }
  }
}

/// Modelo de Cuidador (Pessoa responsável pelo cuidado cotidiano e registro de dados)
class Caregiver {
  final String id;
  final String fullName;
  final CaregiverRelationshipType relationshipType;
  final String? customRelationshipLabel;
  final String phone;
  final String? email;
  final CaregiverAccessLevel accessLevel;
  final bool isPrimary;
  final String? notes;

  const Caregiver({
    required this.id,
    required this.fullName,
    required this.relationshipType,
    this.customRelationshipLabel,
    required this.phone,
    this.email,
    this.accessLevel = CaregiverAccessLevel.caregiverFull,
    this.isPrimary = false,
    this.notes,
  });

  String get displayRelationship {
    if (relationshipType == CaregiverRelationshipType.other &&
        customRelationshipLabel != null &&
        customRelationshipLabel!.trim().isNotEmpty) {
      return customRelationshipLabel!.trim();
    }
    return relationshipType.displayName;
  }

  Caregiver copyWith({
    String? id,
    String? fullName,
    CaregiverRelationshipType? relationshipType,
    String? customRelationshipLabel,
    String? phone,
    String? email,
    CaregiverAccessLevel? accessLevel,
    bool? isPrimary,
    String? notes,
  }) {
    return Caregiver(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relationshipType: relationshipType ?? this.relationshipType,
      customRelationshipLabel: customRelationshipLabel ?? this.customRelationshipLabel,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      accessLevel: accessLevel ?? this.accessLevel,
      isPrimary: isPrimary ?? this.isPrimary,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'relationship_type': relationshipType.name,
      'custom_relationship_label': customRelationshipLabel,
      'phone': phone,
      'email': email,
      'access_level': accessLevel.name,
      'is_primary': isPrimary,
      'notes': notes,
    };
  }

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    final relStr = json['relationship_type'] as String?;
    final rel = CaregiverRelationshipType.values.firstWhere(
      (e) => e.name == relStr,
      orElse: () => CaregiverRelationshipType.other,
    );

    final accessStr = json['access_level'] as String?;
    final access = CaregiverAccessLevel.values.firstWhere(
      (e) => e.name == accessStr,
      orElse: () => CaregiverAccessLevel.caregiverFull,
    );

    return Caregiver(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      relationshipType: rel,
      customRelationshipLabel: json['custom_relationship_label'] as String?,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      accessLevel: access,
      isPrimary: json['is_primary'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Caregiver &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          relationshipType == other.relationshipType &&
          phone == other.phone &&
          email == other.email &&
          accessLevel == other.accessLevel &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      relationshipType.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      accessLevel.hashCode ^
      isPrimary.hashCode;

  @override
  String toString() => 'Caregiver(id: $id, name: $fullName, role: ${relationshipType.name}, access: ${accessLevel.name})';
}
