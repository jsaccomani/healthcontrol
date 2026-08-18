import 'dart:math';

/// Resultado do processamento de Pico de Fluxo Expiratório (Protocolo CFF).
class PeakFlowResult {
  /// O maior valor absoluto medido entre os 3 sopros (em L/min).
  final int recordedMax;

  /// O menor valor absoluto entre os 3 sopros (em L/min).
  final int recordedMin;

  /// Variância absoluta entre o maior e o menor sopro (em L/min).
  final int variance;

  /// Indica se a técnica foi instável (variância > 20 L/min).
  final bool isUnstable;

  /// Mensagem clínica de orientação técnica.
  final String? warningMessage;

  /// Versão explícita da diretriz clínica aplicada.
  final String clinicalRuleVersion;
  final String ruleIdentifier;

  const PeakFlowResult({
    required this.recordedMax,
    required this.recordedMin,
    required this.variance,
    required this.isUnstable,
    this.warningMessage,
    this.clinicalRuleVersion = '1.0.0',
    this.ruleIdentifier = 'CFF_PEAK_FLOW_PROTOCOL',
  });
}

/// Processador de Pico de Fluxo Expiratório (PEF) baseado nas diretrizes CFF/ATS.
class PeakFlowCalculator {
  static const int maxAllowedVariance = 20; // L/min
  static const String currentRuleVersion = '1.0.0';

  /// Processa 3 sopros consecutivos e retorna o resultado determinístico conforme protocolo CFF.
  static PeakFlowResult processBlows({
    required int blow1,
    required int blow2,
    required int blow3,
  }) {
    if (blow1 <= 0 || blow2 <= 0 || blow3 <= 0) {
      throw ArgumentError('Todos os 3 sopros devem ter valores estritamente positivos.');
    }

    final blows = [blow1, blow2, blow3];
    final maxVal = blows.reduce(max);
    final minVal = blows.reduce(min);
    final variance = maxVal - minVal;
    final isUnstable = variance > maxAllowedVariance;

    return PeakFlowResult(
      recordedMax: maxVal,
      recordedMin: minVal,
      variance: variance,
      isUnstable: isUnstable,
      clinicalRuleVersion: currentRuleVersion,
      ruleIdentifier: 'CFF_PEAK_FLOW_PROTOCOL',
      warningMessage: isUnstable
          ? 'Medição Instável: Variação de $variance L/min entre os sopros (limite máx: 20 L/min). '
              'Verifique vedação da máscara/bocal ou presença de tosse.'
          : null,
    );
  }
}
