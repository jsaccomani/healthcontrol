import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('PeakFlowCalculator (Protocolo CFF)', () {
    test('Registra o maior valor absoluto e detecta técnica estável', () {
      final result = PeakFlowCalculator.processBlows(
        blow1: 240,
        blow2: 255,
        blow3: 250,
      );

      expect(result.recordedMax, equals(255));
      expect(result.recordedMin, equals(240));
      expect(result.variance, equals(15));
      expect(result.isUnstable, isFalse);
      expect(result.warningMessage, isNull);
    });

    test('Dispara alerta de técnica instável quando variância > 20 L/min', () {
      final result = PeakFlowCalculator.processBlows(
        blow1: 220,
        blow2: 250,
        blow3: 230,
      );

      expect(result.recordedMax, equals(250));
      expect(result.variance, equals(30));
      expect(result.isUnstable, isTrue);
      expect(result.warningMessage, contains('Variação de 30 L/min'));
    });
  });

  group('ActionZoneEvaluator (GINA / PCDT)', () {
    const personalBest = 300;

    test('Classifica Zona Verde (>= 80%)', () {
      final eval = ActionZoneEvaluator.evaluate(
        currentPef: 250,
        personalBestPef: personalBest,
      ); // 250 / 300 = 83.33%

      expect(eval.zone, equals(ActionZoneType.green));
      expect(eval.requiresEmergencyGps, isFalse);
    });

    test('Classifica Zona Amarela (50% a 79%)', () {
      final eval = ActionZoneEvaluator.evaluate(
        currentPef: 200,
        personalBestPef: personalBest,
      ); // 200 / 300 = 66.67%

      expect(eval.zone, equals(ActionZoneType.yellow));
      expect(eval.requiresEmergencyGps, isFalse);
    });

    test('Classifica Zona Vermelha (< 50%) e dispara GPS de emergência', () {
      final eval = ActionZoneEvaluator.evaluate(
        currentPef: 140,
        personalBestPef: personalBest,
      ); // 140 / 300 = 46.67%

      expect(eval.zone, equals(ActionZoneType.red));
      expect(eval.requiresEmergencyGps, isTrue);
    });
  });

  group('AmibSafetyScreener (Fisioterapia AMIB)', () {
    test('Libera terapia quando todos os sinais vitais estão nos limites', () {
      final result = AmibSafetyScreener.screenVitals(
        spo2Percent: 96,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 22,
        targetLevel: AmibMobilizationLevel.level3,
      );

      expect(result.isClearedForTherapy, isTrue);
      expect(result.safetyViolations, isEmpty);
      expect(result.recommendedLevel, equals(AmibMobilizationLevel.level3));
    });

    test('Bloqueia terapia quando SpO2 < 88% ou FR > 45 rpm', () {
      final result = AmibSafetyScreener.screenVitals(
        spo2Percent: 86,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 48,
      );

      expect(result.isClearedForTherapy, isFalse);
      expect(result.safetyViolations.length, equals(2));
    });
  });

  group('CactCalculator (Questionário c-ACT 4 a 11 anos)', () {
    test('Identifica Asma Bem Controlada (score > 19)', () {
      final result = CactCalculator.calculate(
        childResponses: [3, 2, 3, 2], // 10
        parentResponses: [4, 4, 4],    // 12 -> total 22
      );

      expect(result.totalScore, equals(22));
      expect(result.isControlled, isTrue);
    });

    test('Identifica Asma Não Controlada (score <= 19) e gera alerta clínico', () {
      final result = CactCalculator.calculate(
        childResponses: [1, 1, 2, 1], // 5
        parentResponses: [2, 3, 2],    // 7 -> total 12
      );

      expect(result.totalScore, equals(12));
      expect(result.isControlled, isFalse);
      expect(result.clinicalRecommendation, contains('Escore c-ACT ≤ 19'));
    });
  });

  group('LmeTracker (SUS Farmácia Cidadã)', () {
    test('Informa dias restantes para exame válido', () {
      final examDate = DateTime.now().subtract(const Duration(days: 30));
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: LmeTracker.validitySpirometry, // 180 dias
      );

      expect(check.status, equals(LmeDocumentStatus.valid));
      expect(check.daysRemaining, greaterThan(140));
    });

    test('Identifica exame vencido', () {
      final examDate = DateTime.now().subtract(const Duration(days: 200));
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: LmeTracker.validitySpirometry, // 180 dias
      );

      expect(check.status, equals(LmeDocumentStatus.expired));
      expect(check.message, contains('VENCIDO'));
    });
  });
}
