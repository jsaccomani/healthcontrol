/// Tipo de Relacionamento do Responsável Legal com a Criança
enum LegalGuardianRelationshipType {
  mother,
  father,
  grandmother,
  grandfather,
  aunt,
  uncle,
  adoptiveParent,
  stepmother,
  stepfather,
  legalTutor,
  institutionalGuardian,
  fosterCaregiver,
  other;

  String get displayName {
    switch (this) {
      case LegalGuardianRelationshipType.mother:
        return 'Mãe';
      case LegalGuardianRelationshipType.father:
        return 'Pai';
      case LegalGuardianRelationshipType.grandmother:
        return 'Avó';
      case LegalGuardianRelationshipType.grandfather:
        return 'Avô';
      case LegalGuardianRelationshipType.aunt:
        return 'Tia';
      case LegalGuardianRelationshipType.uncle:
        return 'Tio';
      case LegalGuardianRelationshipType.adoptiveParent:
        return 'Pai/Mãe Adotivo(a)';
      case LegalGuardianRelationshipType.stepmother:
        return 'Madrasta';
      case LegalGuardianRelationshipType.stepfather:
        return 'Padrasto';
      case LegalGuardianRelationshipType.legalTutor:
        return 'Tutor(a) Legal';
      case LegalGuardianRelationshipType.institutionalGuardian:
        return 'Guardião Institucional / Abrigo';
      case LegalGuardianRelationshipType.fosterCaregiver:
        return 'Família Acolhedora';
      case LegalGuardianRelationshipType.other:
        return 'Outro Responsável Legal';
    }
  }
}

/// Modelo de Responsável Legal (Detentor do Poder Familiar, Tutela ou Guarda)
class LegalGuardian {
  final String id;
  final String fullName;
  final LegalGuardianRelationshipType relationshipType;
  final String? customRelationshipLabel;
  final String phone;
  final String? email;
  final String? documentCpf;
  final bool hasLegalCustody;
  final bool isPrimaryContact;
  final String? notes;

  const LegalGuardian({
    required this.id,
    required this.fullName,
    required this.relationshipType,
    this.customRelationshipLabel,
    required this.phone,
    this.email,
    this.documentCpf,
    this.hasLegalCustody = true,
    this.isPrimaryContact = false,
    this.notes,
  });

  String get displayRelationship {
    if (relationshipType == LegalGuardianRelationshipType.other &&
        customRelationshipLabel != null &&
        customRelationshipLabel!.trim().isNotEmpty) {
      return customRelationshipLabel!.trim();
    }
    return relationshipType.displayName;
  }

  LegalGuardian copyWith({
    String? id,
    String? fullName,
    LegalGuardianRelationshipType? relationshipType,
    String? customRelationshipLabel,
    String? phone,
    String? email,
    String? documentCpf,
    bool? hasLegalCustody,
    bool? isPrimaryContact,
    String? notes,
  }) {
    return LegalGuardian(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relationshipType: relationshipType ?? this.relationshipType,
      customRelationshipLabel: customRelationshipLabel ?? this.customRelationshipLabel,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      documentCpf: documentCpf ?? this.documentCpf,
      hasLegalCustody: hasLegalCustody ?? this.hasLegalCustody,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
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
      'document_cpf': documentCpf,
      'has_legal_custody': hasLegalCustody,
      'is_primary_contact': isPrimaryContact,
      'notes': notes,
    };
  }

  factory LegalGuardian.fromJson(Map<String, dynamic> json) {
    final relTypeStr = json['relationship_type'] as String?;
    final relType = LegalGuardianRelationshipType.values.firstWhere(
      (e) => e.name == relTypeStr,
      orElse: () => LegalGuardianRelationshipType.other,
    );

    return LegalGuardian(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      relationshipType: relType,
      customRelationshipLabel: json['custom_relationship_label'] as String?,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      documentCpf: json['document_cpf'] as String?,
      hasLegalCustody: json['has_legal_custody'] as bool? ?? true,
      isPrimaryContact: json['is_primary_contact'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalGuardian &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          relationshipType == other.relationshipType &&
          phone == other.phone &&
          email == other.email &&
          hasLegalCustody == other.hasLegalCustody &&
          isPrimaryContact == other.isPrimaryContact;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      relationshipType.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      hasLegalCustody.hashCode ^
      isPrimaryContact.hashCode;

  @override
  String toString() => 'LegalGuardian(id: $id, name: $fullName, role: ${relationshipType.name}, phone: $phone)';
}
