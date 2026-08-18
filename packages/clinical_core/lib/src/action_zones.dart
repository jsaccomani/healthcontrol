/// Zonas do Plano de Ação para Manejo da Asma (Diretrizes GINA / PCDT).
enum ActionZoneType {
  /// Zona Verde: >= 80% do Melhor PFE Pessoal (Asma Controlada)
  green,

  /// Zona Amarela: 50% a 79% do Melhor PFE Pessoal (Alerta / Início de Crise)
  yellow,

  /// Zona Vermelha: < 50% do Melhor PFE Pessoal (Crise Severa / Emergência)
  red,
}

/// Avaliação da Zona de Ação do Paciente.
class ActionZoneEvaluation {
  final ActionZoneType zone;
  final double percentageOfPersonalBest;
  final int currentPef;
  final int personalBestPef;
  final String title;
  final String clinicalGuidance;
  final bool requiresEmergencyGps;

  const ActionZoneEvaluation({
    required this.zone,
    required this.percentageOfPersonalBest,
    required this.currentPef,
    required this.personalBestPef,
    required this.title,
    required this.clinicalGuidance,
    required this.requiresEmergencyGps,
  });
}

/// Avaliador de Zonas do Plano de Ação.
class ActionZoneEvaluator {
  /// Avalia a zona de ação com base no PFE medido e no melhor PFE pessoal.
  static ActionZoneEvaluation evaluate({
    required int currentPef,
    required int personalBestPef,
  }) {
    if (personalBestPef <= 0) {
      throw ArgumentError('Melhor PFE Pessoal deve ser maior que zero.');
    }
    if (currentPef < 0) {
      throw ArgumentError('PFE Atual não pode ser negativo.');
    }

    final percentage = (currentPef / personalBestPef) * 100;

    if (percentage >= 80.0) {
      return ActionZoneEvaluation(
        zone: ActionZoneType.green,
        percentageOfPersonalBest: percentage,
        currentPef: currentPef,
        personalBestPef: personalBestPef,
        title: 'ZONA VERDE - Asma Controlada',
        clinicalGuidance:
            'Bom controle respiratório. Mantenha as medicações preventivas de rotina e atividades normais.',
        requiresEmergencyGps: false,
      );
    } else if (percentage >= 50.0) {
      return ActionZoneEvaluation(
        zone: ActionZoneType.yellow,
        percentageOfPersonalBest: percentage,
        currentPef: currentPef,
        personalBestPef: personalBestPef,
        title: 'ZONA AMARELA - Início de Crise',
        clinicalGuidance:
            'Atenção: Queda no fluxo respiratório. Inicie o protocolo de resgate com SABA (broncodilatador de curta ação) conforme prescrição médica e reavalie em 20 minutos.',
        requiresEmergencyGps: false,
      );
    } else {
      return ActionZoneEvaluation(
        zone: ActionZoneType.red,
        percentageOfPersonalBest: percentage,
        currentPef: currentPef,
        personalBestPef: personalBestPef,
        title: 'ZONA VERMELHA - Crise Severa (Emergência)',
        clinicalGuidance:
            'PERIGO: Obstrução brônquica severa. Administre a medicação de resgate imediata e dirija-se com urgência ao Pronto-Socorro ou UPA mais próxima.',
        requiresEmergencyGps: true,
      );
    }
  }
}
