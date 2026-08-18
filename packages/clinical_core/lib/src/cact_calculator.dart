/// Resultado do Teste de Controle da Asma na Infância (c-ACT: 4 a 11 anos).
class CactResult {
  /// Pontuação das 4 perguntas respondidas pela criança (0 a 3 cada, total 0 a 12).
  final List<int> childResponses;

  /// Pontuação das 3 perguntas respondidas pelos pais/cuidadores (0 a 5 cada, total 0 a 15).
  final List<int> parentResponses;

  /// Escore total somado (máximo 27).
  final int totalScore;

  /// Indica se a asma está clinicamente controlada (score > 19).
  final bool isControlled;

  /// Classificação textual clínica.
  final String classification;

  /// Recomendação de conduta médica.
  final String clinicalRecommendation;

  const CactResult({
    required this.childResponses,
    required this.parentResponses,
    required this.totalScore,
    required this.isControlled,
    required this.classification,
    required this.clinicalRecommendation,
  });
}

/// Alias de conveniência
typedef CactScoreResult = CactResult;

/// Calculador do Childhood Asthma Control Test (c-ACT).
class CactCalculator {
  /// Escore de corte clínico (<= 19 indica asma não controlada).
  static const int controlledCutoff = 19;
  static const int maxTotalScore = 27;

  /// Processa as respostas e calcula o escore c-ACT.
  static CactResult calculate({
    required List<int> childResponses,
    required List<int> parentResponses,
  }) {
    if (childResponses.length != 4) {
      throw ArgumentError('A parte da criança deve conter exatamente 4 respostas.');
    }
    if (parentResponses.length != 3) {
      throw ArgumentError('A parte dos pais/responsáveis deve conter exatamente 3 respostas.');
    }

    for (final r in childResponses) {
      if (r < 0 || r > 3) {
        throw RangeError('Cada resposta da criança deve estar entre 0 e 3.');
      }
    }
    for (final r in parentResponses) {
      if (r < 0 || r > 5) {
        throw RangeError('Cada resposta dos pais deve estar entre 0 e 5.');
      }
    }

    final childSum = childResponses.fold(0, (a, b) => a + b);
    final parentSum = parentResponses.fold(0, (a, b) => a + b);
    final total = childSum + parentSum;

    final isControlled = total > controlledCutoff;

    return CactResult(
      childResponses: List.unmodifiable(childResponses),
      parentResponses: List.unmodifiable(parentResponses),
      totalScore: total,
      isControlled: isControlled,
      classification: isControlled ? 'Asma Bem Controlada' : 'Asma Não Controlada',
      clinicalRecommendation: isControlled
          ? 'Ótimo controle clínico no último mês. Mantenha o plano de ação e acompanhamento regular.'
          : 'ALERTA: Escore c-ACT ≤ 19 indica asma não controlada. Recomendada consulta com pneumologista/pediatra para ajuste da terapia preventiva.',
    );
  }
}
