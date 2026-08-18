/// Status de validade de um documento / exame para o LME (SUS Alto Custo).
enum LmeDocumentStatus {
  valid,
  expiringSoon,
  expired,
}

/// Relatório de validade de um exame do LME.
class LmeExamCheck {
  final String examName;
  final DateTime examDate;
  final int validityDays;
  final int daysRemaining;
  final LmeDocumentStatus status;
  final String message;
  final String clinicalRuleVersion;
  final String ruleIdentifier;

  const LmeExamCheck({
    required this.examName,
    required this.examDate,
    required this.validityDays,
    required this.daysRemaining,
    required this.status,
    required this.message,
    this.clinicalRuleVersion = '1.0.0',
    this.ruleIdentifier = 'SUS_LME_REGULATORY_TRACKER',
  });
}

/// Rastreador de Validade para Laudo de Solicitação de Medicamentos (LME - Farmácia Cidadã SUS).
class LmeTracker {
  /// Prazos regulatórios de validade:
  /// - Espirometria com prova BD: 180 dias (6 meses)
  /// - Raio-X de Tórax: 360 dias (1 ano)
  /// - Eosinófilos (Mepolizumabe): 90 dias (3 meses)
  /// - IgE Total Sérica (Omalizumabe): 90 dias (3 meses)
  static const int validitySpirometry = 180;
  static const int validityChestXray = 360;
  static const int validityEosinophils = 90;
  static const int validityTotalIge = 90;

  static const int warningThresholdDays = 30; // Alerta 30 dias antes de expirar
  static const String currentRuleVersion = '1.0.0';

  static LmeExamCheck checkExamValidity({
    required String examName,
    required DateTime examDate,
    required int validityDays,
    DateTime? currentDate,
  }) {
    if (validityDays <= 0) {
      throw ArgumentError('validityDays deve ser estritamente maior que zero.');
    }

    final now = currentDate ?? DateTime.now();
    final expirationDate = examDate.add(Duration(days: validityDays));
    final daysRemaining = expirationDate.difference(now).inDays;

    final LmeDocumentStatus status;
    final String message;

    if (daysRemaining < 0) {
      status = LmeDocumentStatus.expired;
      message = 'VENCIDO há ${daysRemaining.abs()} dias. Necessário novo exame para renovação do LME no SUS.';
    } else if (daysRemaining <= warningThresholdDays) {
      status = LmeDocumentStatus.expiringSoon;
      message = 'Expira em $daysRemaining dias. Agende a renovação do exame junto ao especialista.';
    } else {
      status = LmeDocumentStatus.valid;
      message = 'Válido por mais $daysRemaining dias.';
    }

    return LmeExamCheck(
      examName: examName,
      examDate: examDate,
      validityDays: validityDays,
      daysRemaining: daysRemaining,
      status: status,
      message: message,
      clinicalRuleVersion: currentRuleVersion,
      ruleIdentifier: 'SUS_LME_REGULATORY_TRACKER',
    );
  }
}
