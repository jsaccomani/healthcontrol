import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('1. PEAK FLOW CALCULATOR - Matriz Completa de Segurança (Protocolo CFF/ATS)', () {
    test('Valores normais e técnica consistente', () {
      final res = PeakFlowCalculator.processBlows(blow1: 220, blow2: 230, blow3: 225);
      expect(res.recordedMax, equals(230));
      expect(res.recordedMin, equals(220));
      expect(res.variance, equals(10));
      expect(res.isUnstable, isFalse);
      expect(res.warningMessage, isNull);
      expect(res.clinicalRuleVersion, equals('1.0.0'));
      expect(res.ruleIdentifier, equals('CFF_PEAK_FLOW_PROTOCOL'));
    });

    test('Independência da ordem dos sopros', () {
      // Maior sopro no 1º, 2º ou 3º sopro produz exatamente o mesmo resultado
      final res1 = PeakFlowCalculator.processBlows(blow1: 300, blow2: 290, blow3: 285);
      final res2 = PeakFlowCalculator.processBlows(blow1: 290, blow2: 300, blow3: 285);
      final res3 = PeakFlowCalculator.processBlows(blow1: 285, blow2: 290, blow3: 300);

      expect(res1.recordedMax, equals(300));
      expect(res2.recordedMax, equals(300));
      expect(res3.recordedMax, equals(300));
      expect(res1.variance, equals(15));
      expect(res2.variance, equals(15));
      expect(res3.variance, equals(15));
    });

    test('Três sopros idênticos (Variância zero)', () {
      final res = PeakFlowCalculator.processBlows(blow1: 200, blow2: 200, blow3: 200);
      expect(res.recordedMax, equals(200));
      expect(res.recordedMin, equals(200));
      expect(res.variance, equals(0));
      expect(res.isUnstable, isFalse);
    });

    test('Limiar de transição de instabilidade: Variância de exatamente 20 L/min é estável', () {
      final res = PeakFlowCalculator.processBlows(blow1: 200, blow2: 220, blow3: 210);
      expect(res.variance, equals(20));
      expect(res.isUnstable, isFalse);
      expect(res.warningMessage, isNull);
    });

    test('Limiar de transição de instabilidade: Variância de 21 L/min dispara alerta de técnica instável', () {
      final res = PeakFlowCalculator.processBlows(blow1: 200, blow2: 221, blow3: 210);
      expect(res.variance, equals(21));
      expect(res.isUnstable, isTrue);
      expect(res.warningMessage, contains('Variação de 21 L/min'));
    });

    test('Rejeição de entradas inválidas / negativas / zero', () {
      expect(() => PeakFlowCalculator.processBlows(blow1: 0, blow2: 200, blow3: 200), throwsArgumentError);
      expect(() => PeakFlowCalculator.processBlows(blow1: 200, blow2: -50, blow3: 200), throwsArgumentError);
      expect(() => PeakFlowCalculator.processBlows(blow1: -10, blow2: -20, blow3: -30), throwsArgumentError);
    });
  });

  group('2. ACTION ZONE EVALUATOR - Matriz de Transições de Limiares (GINA / PCDT)', () {
    const personalBest = 300;

    // Tabela de Testes Orientada a Dados (Table-Driven Tests)
    final testCases = [
      // PFE Medido, Zona Esperada, Descrição
      {'pef': 300, 'zone': ActionZoneType.green, 'desc': '100% (Igual ao melhor pessoal)'},
      {'pef': 360, 'zone': ActionZoneType.green, 'desc': '120% (Acima do melhor pessoal)'},
      {'pef': 240, 'zone': ActionZoneType.green, 'desc': 'Exatamente 80.0% (Limiar superior da Zona Verde)'},
      {'pef': 239, 'zone': ActionZoneType.yellow, 'desc': '79.67% (Limiar superior da Zona Amarela)'},
      {'pef': 180, 'zone': ActionZoneType.yellow, 'desc': '60.0% (Zona Amarela média)'},
      {'pef': 150, 'zone': ActionZoneType.yellow, 'desc': 'Exatamente 50.0% (Limiar inferior da Zona Amarela)'},
      {'pef': 149, 'zone': ActionZoneType.red, 'desc': '49.67% (Limiar superior da Zona Vermelha)'},
      {'pef': 60, 'zone': ActionZoneType.red, 'desc': '20.0% (Crise severa)'},
      {'pef': 0, 'zone': ActionZoneType.red, 'desc': '0% (Fluxo zerado / Apneia)'},
    ];

    for (final tc in testCases) {
      final pef = tc['pef'] as int;
      final expectedZone = tc['zone'] as ActionZoneType;
      final desc = tc['desc'] as String;

      test('$desc -> PFE $pef L/min -> ${expectedZone.name.toUpperCase()}', () {
        final eval = ActionZoneEvaluator.evaluate(currentPef: pef, personalBestPef: personalBest);
        expect(eval.zone, equals(expectedZone));
        expect(eval.clinicalRuleVersion, equals('1.0.0'));
        expect(eval.ruleIdentifier, equals('GINA_PCDT_ACTION_ZONES'));

        if (expectedZone == ActionZoneType.red) {
          expect(eval.requiresEmergencyGps, isTrue);
          expect(eval.title, contains('ZONA VERMELHA'));
        } else if (expectedZone == ActionZoneType.yellow) {
          expect(eval.requiresEmergencyGps, isFalse);
          expect(eval.title, contains('ZONA AMARELA'));
        } else {
          expect(eval.requiresEmergencyGps, isFalse);
          expect(eval.title, contains('ZONA VERDE'));
        }
      });
    }

    test('Entradas inválidas lançam ArgumentError', () {
      expect(() => ActionZoneEvaluator.evaluate(currentPef: 200, personalBestPef: 0), throwsArgumentError);
      expect(() => ActionZoneEvaluator.evaluate(currentPef: 200, personalBestPef: -100), throwsArgumentError);
      expect(() => ActionZoneEvaluator.evaluate(currentPef: -10, personalBestPef: 300), throwsArgumentError);
    });
  });

  group('3. c-ACT CALCULATOR - Matriz de Escores Pediátricos (4 a 11 anos)', () {
    test('Escore Mínimo Absoluto: 0 pontos (Asma Não Controlada Extrema)', () {
      final res = CactCalculator.calculate(
        childResponses: [0, 0, 0, 0],
        parentResponses: [0, 0, 0],
      );
      expect(res.totalScore, equals(0));
      expect(res.isControlled, isFalse);
      expect(res.classification, equals('Asma Não Controlada'));
    });

    test('Escore Máximo Absoluto: 27 pontos (Asma Perfeitamente Controlada)', () {
      final res = CactCalculator.calculate(
        childResponses: [3, 3, 3, 3], // 12
        parentResponses: [5, 5, 5],    // 15 -> total 27
      );
      expect(res.totalScore, equals(27));
      expect(res.isControlled, isTrue);
      expect(res.classification, equals('Asma Bem Controlada'));
    });

    test('Limiar de corte crítico: 19 pontos é Não Controlada', () {
      final res = CactCalculator.calculate(
        childResponses: [2, 2, 2, 2], // 8
        parentResponses: [4, 4, 3],    // 11 -> total 19
      );
      expect(res.totalScore, equals(19));
      expect(res.isControlled, isFalse);
      expect(res.clinicalRecommendation, contains('≤ 19'));
    });

    test('Limiar de corte crítico: 20 pontos é Bem Controlada', () {
      final res = CactCalculator.calculate(
        childResponses: [2, 2, 2, 2], // 8
        parentResponses: [4, 4, 4],    // 12 -> total 20
      );
      expect(res.totalScore, equals(20));
      expect(res.isControlled, isTrue);
      expect(res.classification, equals('Asma Bem Controlada'));
    });

    test('Validação estrita de tamanho e faixas de entrada', () {
      // Criança com menos ou mais de 4 respostas
      expect(() => CactCalculator.calculate(childResponses: [1, 2, 3], parentResponses: [4, 4, 4]), throwsArgumentError);
      expect(() => CactCalculator.calculate(childResponses: [1, 2, 3, 1, 2], parentResponses: [4, 4, 4]), throwsArgumentError);

      // Pais com menos ou mais de 3 respostas
      expect(() => CactCalculator.calculate(childResponses: [1, 2, 3, 1], parentResponses: [4, 4]), throwsArgumentError);

      // Resposta da criança fora da faixa 0..3
      expect(() => CactCalculator.calculate(childResponses: [1, 4, 2, 1], parentResponses: [4, 4, 4]), throwsRangeError);
      expect(() => CactCalculator.calculate(childResponses: [-1, 2, 2, 1], parentResponses: [4, 4, 4]), throwsRangeError);

      // Resposta dos pais fora da faixa 0..5
      expect(() => CactCalculator.calculate(childResponses: [1, 2, 2, 1], parentResponses: [6, 4, 4]), throwsRangeError);
      expect(() => CactCalculator.calculate(childResponses: [1, 2, 2, 1], parentResponses: [-1, 4, 4]), throwsRangeError);
    });
  });

  group('4. AMIB SAFETY SCREENER - Matriz de Limiares Fisiológicos e Segurança', () {
    test('Todos os sinais vitais normais -> Libera Nível Solicitado', () {
      final res = AmibSafetyScreener.screenVitals(
        spo2Percent: 97,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 24,
        targetLevel: AmibMobilizationLevel.level4,
      );
      expect(res.isClearedForTherapy, isTrue);
      expect(res.safetyViolations, isEmpty);
      expect(res.recommendedLevel, equals(AmibMobilizationLevel.level4));
      expect(res.clinicalRuleVersion, equals('1.0.0'));
    });

    test('Limiar de SpO2: 88% é liberado, 87% é bloqueado', () {
      final res88 = AmibSafetyScreener.screenVitals(
        spo2Percent: 88,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 24,
      );
      expect(res88.isClearedForTherapy, isTrue);

      final res87 = AmibSafetyScreener.screenVitals(
        spo2Percent: 87,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 24,
      );
      expect(res87.isClearedForTherapy, isFalse);
      expect(res87.safetyViolations.first, contains('SpO2: 87% < 88%'));
    });

    test('Limiar de FiO2: 0.60 (60%) é liberado, 0.61 (61%) é bloqueado', () {
      final res60 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.60,
        peepCmH2O: 5,
        respiratoryRateRpm: 24,
      );
      expect(res60.isClearedForTherapy, isTrue);

      final res61 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.61,
        peepCmH2O: 5,
        respiratoryRateRpm: 24,
      );
      expect(res61.isClearedForTherapy, isFalse);
      expect(res61.safetyViolations.first, contains('FiO2'));
    });

    test('Limiar de PEEP: 10 cmH2O é liberado, 11 cmH2O é bloqueado', () {
      final res10 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.21,
        peepCmH2O: 10,
        respiratoryRateRpm: 24,
      );
      expect(res10.isClearedForTherapy, isTrue);

      final res11 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.21,
        peepCmH2O: 11,
        respiratoryRateRpm: 24,
      );
      expect(res11.isClearedForTherapy, isFalse);
      expect(res11.safetyViolations.first, contains('PEEP: 11 cmH2O > 10'));
    });

    test('Limiar de Frequência Respiratória: 45 rpm é liberado, 46 rpm é bloqueado', () {
      final res45 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 45,
      );
      expect(res45.isClearedForTherapy, isTrue);

      final res46 = AmibSafetyScreener.screenVitals(
        spo2Percent: 95,
        fio2Decimal: 0.21,
        peepCmH2O: 5,
        respiratoryRateRpm: 46,
      );
      expect(res46.isClearedForTherapy, isFalse);
      expect(res46.safetyViolations.first, contains('FR: 46 rpm > 45'));
    });

    test('Múltiplas violações simultâneas são todas registradas no laudo', () {
      final resMulti = AmibSafetyScreener.screenVitals(
        spo2Percent: 82, // Violação 1
        fio2Decimal: 0.75, // Violação 2
        peepCmH2O: 14, // Violação 3
        respiratoryRateRpm: 52, // Violação 4
      );
      expect(resMulti.isClearedForTherapy, isFalse);
      expect(resMulti.safetyViolations.length, equals(4));
    });

    test('Entradas fora de faixas biológicas disparam RangeError', () {
      expect(() => AmibSafetyScreener.screenVitals(spo2Percent: 105, fio2Decimal: 0.21, peepCmH2O: 5, respiratoryRateRpm: 20), throwsRangeError);
      expect(() => AmibSafetyScreener.screenVitals(spo2Percent: 95, fio2Decimal: 0.10, peepCmH2O: 5, respiratoryRateRpm: 20), throwsRangeError);
      expect(() => AmibSafetyScreener.screenVitals(spo2Percent: 95, fio2Decimal: 0.21, peepCmH2O: -1, respiratoryRateRpm: 20), throwsRangeError);
      expect(() => AmibSafetyScreener.screenVitals(spo2Percent: 95, fio2Decimal: 0.21, peepCmH2O: 5, respiratoryRateRpm: 0), throwsRangeError);
    });
  });

  group('5. LME TRACKER - Validade Regulatória de Exames SUS', () {
    final baseDate = DateTime(2026, 8, 18);

    test('Exame recém-realizado: Status Válido com prazo total', () {
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria com Prova BD',
        examDate: baseDate,
        validityDays: LmeTracker.validitySpirometry, // 180 dias
        currentDate: baseDate,
      );
      expect(check.status, equals(LmeDocumentStatus.valid));
      expect(check.daysRemaining, equals(180));
    });

    test('Exame com 31 dias restantes: Status Válido', () {
      final examDate = baseDate.subtract(const Duration(days: 149)); // 180 - 149 = 31
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: 180,
        currentDate: baseDate,
      );
      expect(check.status, equals(LmeDocumentStatus.valid));
      expect(check.daysRemaining, equals(31));
    });

    test('Exame com 30 dias restantes: Status ExpiringSoon (Alerta Ativo)', () {
      final examDate = baseDate.subtract(const Duration(days: 150)); // 180 - 150 = 30
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: 180,
        currentDate: baseDate,
      );
      expect(check.status, equals(LmeDocumentStatus.expiringSoon));
      expect(check.daysRemaining, equals(30));
      expect(check.message, contains('Expira em 30 dias'));
    });

    test('Exame com 0 dias restantes (Último dia): Status ExpiringSoon', () {
      final examDate = baseDate.subtract(const Duration(days: 180)); // 180 - 180 = 0
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: 180,
        currentDate: baseDate,
      );
      expect(check.status, equals(LmeDocumentStatus.expiringSoon));
      expect(check.daysRemaining, equals(0));
    });

    test('Exame com 1 dia após prazo: Status Expired (Vencido)', () {
      final examDate = baseDate.subtract(const Duration(days: 181)); // 180 - 181 = -1
      final check = LmeTracker.checkExamValidity(
        examName: 'Espirometria',
        examDate: examDate,
        validityDays: 180,
        currentDate: baseDate,
      );
      expect(check.status, equals(LmeDocumentStatus.expired));
      expect(check.daysRemaining, equals(-1));
      expect(check.message, contains('VENCIDO há 1 dias'));
    });

    test('Validade inválida (<=0) dispara ArgumentError', () {
      expect(
        () => LmeTracker.checkExamValidity(examName: 'Raio X', examDate: baseDate, validityDays: 0),
        throwsArgumentError,
      );
    });
  });

  group('6. FARMACOPEIA PEDIÁTRICA & REGRAS DE INALAÇÃO', () {
    test('Identifica obrigatoriedade de bochecho para corticoides inalatórios', () {
      expect(PediatricPharmacopeia.requiresMouthRinse('Clenil HFA 250mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresMouthRinse('Symbicort 6/200mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresMouthRinse('Busonid 200mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresMouthRinse('Alenia 6/100mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresMouthRinse('Seretide 25/50mcg'), isTrue);

      // Broncodilatadores de resgate e antileucotrienos NÃO exigem bochecho
      expect(PediatricPharmacopeia.requiresMouthRinse('Aerolin Spray 100mcg'), isFalse);
      expect(PediatricPharmacopeia.requiresMouthRinse('Singulair Baby 4mg'), isFalse);
    });

    test('Identifica obrigatoriedade de espaçador valvulado para sprays', () {
      expect(PediatricPharmacopeia.requiresValvedSpacer('Clenil HFA 250mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresValvedSpacer('Aerolin Spray 100mcg'), isTrue);
      expect(PediatricPharmacopeia.requiresValvedSpacer('Seretide 25/50mcg'), isTrue);

      // Pó seco (Alenia) ou orais (Singulair) não usam espaçador
      expect(PediatricPharmacopeia.requiresValvedSpacer('Alenia 6/100mcg'), isFalse);
      expect(PediatricPharmacopeia.requiresValvedSpacer('Singulair Baby 4mg'), isFalse);
    });

    test('Parser determinístico de prescrição médica extrai dados com precisão', () {
      const sampleText = '''
        Dr. Marco Aurélio Valente
        CRM/SP 148920
        Receita Médica - 15/08/2026
        1. Clenil HFA 250mcg - 1 puff de 12 em 12 horas com espaçador
        2. Aerolin 100mcg - 2 puffs em caso de crise
        3. Singulair 4mg - 1 sachê à noite
      ''';

      final record = PrescriptionOcrParser.parseRawPrescriptionText(
        rawText: sampleText,
        patientId: 'child_arthur',
        referenceDate: DateTime(2026, 8, 18),
      );

      expect(record.patientId, equals('child_arthur'));
      expect(record.doctorName, contains('Marco Aurélio'));
      expect(record.doctorCrm, contains('148920'));
      expect(record.prescriptionDate.year, equals(2026));
      expect(record.prescriptionDate.month, equals(8));
      expect(record.prescriptionDate.day, equals(15));
      expect(record.medications.length, equals(3));
      expect(record.medications.any((m) => m.commercialName.contains('Clenil')), isTrue);
      expect(record.medications.any((m) => m.commercialName.contains('Aerolin')), isTrue);
    });
  });

  group('7. CLINICAL EVENT LOG - Integridade Criptográfica SHA-256 e Imutabilidade', () {
    test('Alteração de 1 único byte no payload corrompe o hash imediatamente', () {
      final event = ClinicalEventLog(
        eventId: 'evt_sec_001',
        patientId: 'child_arthur',
        version: 'v1.0.0',
        sequenceNumber: 1,
        eventType: ClinicalEventType.healthControlEntry,
        authorName: 'Juliana (Mãe)',
        authorRole: 'Cuidadora',
        timestamp: DateTime(2026, 8, 18, 10, 0, 0),
        payload: {'pef': 220, 'spo2': 98},
        previousHash: 'GENESIS_BLOCK_0000000000000000',
      );

      expect(event.verifyIntegrity(), isTrue);

      // Simula adulteração maliciosa pós-gravação (ex: alterando pef de 220 para 300)
      final tamperedEvent = ClinicalEventLog(
        eventId: event.eventId,
        patientId: event.patientId,
        version: event.version,
        sequenceNumber: event.sequenceNumber,
        eventType: event.eventType,
        authorName: event.authorName,
        authorRole: event.authorRole,
        timestamp: event.timestamp,
        payload: {'pef': 300, 'spo2': 98}, // Alterado!
        previousHash: event.previousHash,
        hash: event.hash, // Mantendo hash original
      );

      expect(tamperedEvent.verifyIntegrity(), isFalse);
    });
  });
}
