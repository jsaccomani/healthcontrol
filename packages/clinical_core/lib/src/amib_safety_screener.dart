/// Níveis de Mobilização e Reabilitação Motora (Protocolo AMIB).
enum AmibMobilizationLevel {
  /// Nível 1: Mobilização passiva no leito / Mudança de decúbito
  level1(1, 'Mobilização Passiva no Leito'),

  /// Nível 2: Mobilização ativa-assistida no leito / Sedestação em leito
  level2(2, 'Mobilização Ativa-Assistida no Leito'),

  /// Nível 3: Sedestação à beira do leito (controle de tronco)
  level3(3, 'Sedestação à Beira do Leito'),

  /// Nível 4: Transferência para poltrona / Ortostatismo assistido
  level4(4, 'Transferência para Poltrona / Ortostatismo'),

  /// Nível 5: Marcha ativa / Deambulação e exercícios resistidos
  level5(5, 'Marcha Ativa e Deambulação');

  final int code;
  final String label;
  const AmibMobilizationLevel(this.code, this.label);
}

/// Resultado da triagem de segurança em fisioterapia respiratória / motora.
class AmibSafetyResult {
  final bool isClearedForTherapy;
  final List<String> safetyViolations;
  final AmibMobilizationLevel? recommendedLevel;
  final String clinicalRuleVersion;
  final String ruleIdentifier;

  const AmibSafetyResult({
    required this.isClearedForTherapy,
    required this.safetyViolations,
    this.recommendedLevel,
    this.clinicalRuleVersion = '1.0.0',
    this.ruleIdentifier = 'AMIB_PHYSIO_SAFETY_GUIDELINE',
  });
}

/// Triador de Segurança para Fisioterapia Respiratória e Motora Pediátrica (AMIB).
class AmibSafetyScreener {
  /// Limiares de segurança mandatórios:
  /// - SpO2 mínimo: 88%
  /// - FiO2 máxima: 0.60 (60%)
  /// - PEEP máxima: 10 cmH2O
  /// - Frequência Respiratória máxima: 45 rpm (pediátrico)
  static const int minSpo2 = 88;
  static const double maxFio2 = 0.60;
  static const int maxPeep = 10;
  static const int maxRespiratoryRate = 45;
  static const String currentRuleVersion = '1.0.0';

  /// Avalia se o paciente atende aos critérios de segurança para início da sessão.
  static AmibSafetyResult screenVitals({
    required int spo2Percent,
    required double fio2Decimal,
    required int peepCmH2O,
    required int respiratoryRateRpm,
    AmibMobilizationLevel? targetLevel,
  }) {
    if (spo2Percent < 0 || spo2Percent > 100) {
      throw RangeError('SpO2 deve estar entre 0% e 100%.');
    }
    if (fio2Decimal < 0.21 || fio2Decimal > 1.0) {
      throw RangeError('FiO2 deve estar entre 0.21 (ar ambiente) e 1.0 (100% O2).');
    }
    if (peepCmH2O < 0) {
      throw RangeError('PEEP não pode ser negativa.');
    }
    if (respiratoryRateRpm <= 0) {
      throw RangeError('Frequência Respiratória deve ser maior que zero.');
    }

    final violations = <String>[];

    if (spo2Percent < minSpo2) {
      violations.add('Saturação de Oxigênio crítica (SpO2: $spo2Percent% < $minSpo2%). Risco de hipoxemia.');
    }
    if (fio2Decimal > maxFio2) {
      violations.add('Fração Inspirada de O2 excessiva (FiO2: ${(fio2Decimal * 100).toStringAsFixed(0)}% > 60%). Instabilidade gasométrica.');
    }
    if (peepCmH2O > maxPeep) {
      violations.add('Pressão Positiva Expiratória elevada (PEEP: $peepCmH2O cmH2O > 10 cmH2O). Risco de barotrauma.');
    }
    if (respiratoryRateRpm > maxRespiratoryRate) {
      violations.add('Taquipneia severa (FR: $respiratoryRateRpm rpm > $maxRespiratoryRate rpm). Desconforto respiratório agudo.');
    }

    final isCleared = violations.isEmpty;

    return AmibSafetyResult(
      isClearedForTherapy: isCleared,
      safetyViolations: List.unmodifiable(violations),
      recommendedLevel: isCleared ? (targetLevel ?? AmibMobilizationLevel.level1) : null,
      clinicalRuleVersion: currentRuleVersion,
      ruleIdentifier: 'AMIB_PHYSIO_SAFETY_GUIDELINE',
    );
  }
}
