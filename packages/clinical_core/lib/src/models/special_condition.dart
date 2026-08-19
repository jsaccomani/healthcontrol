/// Categoria da Condição Especial / Diagnóstica
enum ConditionCategory {
  developmental,
  neurological,
  respiratory,
  sensory,
  communication,
  mobility,
  genetic,
  other;

  String get displayName {
    switch (this) {
      case ConditionCategory.developmental:
        return 'Neurodesenvolvimento (TEA, TDAH, etc.)';
      case ConditionCategory.neurological:
        return 'Neurológica';
      case ConditionCategory.respiratory:
        return 'Respiratória Crônica (além da Asma)';
      case ConditionCategory.sensory:
        return 'Sensorial (Visual, Auditiva, Tátil)';
      case ConditionCategory.communication:
        return 'Comunicação e Fala';
      case ConditionCategory.mobility:
        return 'Mobilidade e Motora';
      case ConditionCategory.genetic:
        return 'Genética ou Metabólica';
      case ConditionCategory.other:
        return 'Outra Condição';
    }
  }
}

/// Modelo de Condição Especial / Diagnóstico Associado
class SpecialCondition {
  final String id;
  final String name;
  final ConditionCategory category;
  final DateTime? diagnosisDate;
  final String? clinicalCode; // CID-10 / CID-11
  final bool isConfirmed;
  final String? diagnosingProfessional;
  final String? notes;

  const SpecialCondition({
    required this.id,
    required this.name,
    required this.category,
    this.diagnosisDate,
    this.clinicalCode,
    this.isConfirmed = true,
    this.diagnosingProfessional,
    this.notes,
  });

  SpecialCondition copyWith({
    String? id,
    String? name,
    ConditionCategory? category,
    DateTime? diagnosisDate,
    String? clinicalCode,
    bool? isConfirmed,
    String? diagnosingProfessional,
    String? notes,
  }) {
    return SpecialCondition(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      diagnosisDate: diagnosisDate ?? this.diagnosisDate,
      clinicalCode: clinicalCode ?? this.clinicalCode,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      diagnosingProfessional: diagnosingProfessional ?? this.diagnosingProfessional,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'diagnosis_date': diagnosisDate?.toIso8601String(),
      'clinical_code': clinicalCode,
      'is_confirmed': isConfirmed,
      'diagnosing_professional': diagnosingProfessional,
      'notes': notes,
    };
  }

  factory SpecialCondition.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String?;
    final cat = ConditionCategory.values.firstWhere(
      (e) => e.name == catStr,
      orElse: () => ConditionCategory.other,
    );

    return SpecialCondition(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: cat,
      diagnosisDate: json['diagnosis_date'] != null
          ? DateTime.tryParse(json['diagnosis_date'] as String)
          : null,
      clinicalCode: json['clinical_code'] as String?,
      isConfirmed: json['is_confirmed'] as bool? ?? true,
      diagnosingProfessional: json['diagnosing_professional'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialCondition &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          clinicalCode == other.clinicalCode &&
          isConfirmed == other.isConfirmed;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      (clinicalCode?.hashCode ?? 0) ^
      isConfirmed.hashCode;

  @override
  String toString() => 'SpecialCondition(id: $id, name: $name, category: ${category.name})';
}
