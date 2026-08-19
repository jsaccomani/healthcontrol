/// Tipo de Limitação Funcional / Sensorial / Acessibilidade
enum LimitationType {
  nonVerbal,
  visualImpairment,
  hearingImpairment,
  reducedMobility,
  unableToPerformPeakFlow,
  communicationDifficulty,
  cognitiveDifficulty,
  sensorySensitivity,
  other;

  String get displayName {
    switch (this) {
      case LimitationType.nonVerbal:
        return 'Não-verbal / Comunicação sem Fala';
      case LimitationType.visualImpairment:
        return 'Deficiência Visual';
      case LimitationType.hearingImpairment:
        return 'Deficiência Auditiva';
      case LimitationType.reducedMobility:
        return 'Mobilidade Reduzida / Uso de Cadeira ou Andador';
      case LimitationType.unableToPerformPeakFlow:
        return 'Incapaz de Realizar Pico de Fluxo Expiratório';
      case LimitationType.communicationDifficulty:
        return 'Dificuldade de Compreensão ou Expressão sob Estresse';
      case LimitationType.cognitiveDifficulty:
        return 'Dificuldade Cognitiva';
      case LimitationType.sensorySensitivity:
        return 'Hipersensibilidade Sensorial (Ruídos, Toque)';
      case LimitationType.other:
        return 'Outra Limitação Funcional';
    }
  }
}

/// Grau de Severidade da Limitação Funcional
enum LimitationSeverity {
  mild,
  moderate,
  severe;

  String get displayName {
    switch (this) {
      case LimitationSeverity.mild:
        return 'Leve';
      case LimitationSeverity.moderate:
        return 'Moderada';
      case LimitationSeverity.severe:
        return 'Severa / Total';
    }
  }
}

/// Modelo de Limitação Funcional / Acessibilidade (Impacta a UX e o Atendimento)
class FunctionalLimitation {
  final String id;
  final LimitationType type;
  final LimitationSeverity severity;
  final String description;
  final String? notes;

  const FunctionalLimitation({
    required this.id,
    required this.type,
    this.severity = LimitationSeverity.moderate,
    required this.description,
    this.notes,
  });

  FunctionalLimitation copyWith({
    String? id,
    LimitationType? type,
    LimitationSeverity? severity,
    String? description,
    String? notes,
  }) {
    return FunctionalLimitation(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'description': description,
      'notes': notes,
    };
  }

  factory FunctionalLimitation.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = LimitationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => LimitationType.other,
    );

    final sevStr = json['severity'] as String?;
    final sev = LimitationSeverity.values.firstWhere(
      (e) => e.name == sevStr,
      orElse: () => LimitationSeverity.moderate,
    );

    return FunctionalLimitation(
      id: json['id'] as String? ?? '',
      type: type,
      severity: sev,
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionalLimitation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          severity == other.severity &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ severity.hashCode ^ description.hashCode;

  @override
  String toString() => 'FunctionalLimitation(id: $id, type: ${type.name}, sev: ${severity.name})';
}
