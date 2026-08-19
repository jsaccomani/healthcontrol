/// Tipo de Requisito de Cuidado Operacional / Acomodação de Rotina
enum CareRequirementType {
  requiresFaceMaskForInhalation,
  requiresCalmEnvironment,
  requiresAlternativeCommunication,
  requiresCaregiverAssistance,
  cannotPerformPeakFlow,
  tracheostomyCare,
  gastrostomyCare,
  other;

  String get displayName {
    switch (this) {
      case CareRequirementType.requiresFaceMaskForInhalation:
        return 'Requer Máscara Facial no Espaçador (Não veda bocal plástico)';
      case CareRequirementType.requiresCalmEnvironment:
        return 'Requer Ambiente Calmo e Dessensibilização Prévia';
      case CareRequirementType.requiresAlternativeCommunication:
        return 'Requer Comunicação Alternativa / Prancha Visual de Sintomas';
      case CareRequirementType.requiresCaregiverAssistance:
        return 'Requer Auxílio Total do Cuidador na Aplicação';
      case CareRequirementType.cannotPerformPeakFlow:
        return 'Não Realiza Pico de Fluxo (Monitorar SpO2 e Retrações)';
      case CareRequirementType.tracheostomyCare:
        return 'Cuidados Especiais com Traqueostomia';
      case CareRequirementType.gastrostomyCare:
        return 'Cuidados Especiais com Gastrostomia';
      case CareRequirementType.other:
        return 'Outro Requisito de Cuidado';
    }
  }
}

/// Modelo de Requisito de Cuidado / Acomodação Operacional (Orienta Cuidador e Socorrista)
/// IMPORTANTE: Não prescreve tratamentos médicos. Orienta a execução correta do plano.
class CareRequirement {
  final String id;
  final CareRequirementType type;
  final String title;
  final String description;
  final String? notes;

  const CareRequirement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.notes,
  });

  CareRequirement copyWith({
    String? id,
    CareRequirementType? type,
    String? title,
    String? description,
    String? notes,
  }) {
    return CareRequirement(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'notes': notes,
    };
  }

  factory CareRequirement.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = CareRequirementType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => CareRequirementType.other,
    );

    return CareRequirement(
      id: json['id'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareRequirement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ title.hashCode ^ description.hashCode;

  @override
  String toString() => 'CareRequirement(id: $id, type: ${type.name}, title: $title)';
}
