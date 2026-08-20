import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('VITAL SIGNS & PEAK FLOW: NÃO-FABRICAÇÃO EM CÁLCULOS E PERSISTÊNCIA', () {
    test('1. HealthControlEntry: SpO2 ausente deve ser null e peakFlowZone ausente deve ser null', () {
      final entry = HealthControlEntry(
        id: 'entry_unmeasured_01',
        versionTag: 'v1.0.1',
        sequenceNumber: 1,
        timestamp: DateTime(2026, 8, 20, 10, 0),
        authorName: 'Mãe',
        authorRole: 'Cuidador Principal',
        peakFlowAttempts: const [],
        peakFlowBest: 0,
        peakFlowZone: null,
        peakFlowVarianceError: false,
        spo2: null,
        mouthRinseCompleted: false,
        requiresRescueFollowup: false,
      );

      expect(entry.spo2, isNull);
      expect(entry.peakFlowZone, isNull);

      final json = entry.toJson();
      expect(json['spo2'], isNull);
      expect(json['peak_flow_zone'], isNull);

      final reconstructed = HealthControlEntry.fromJson(json);
      expect(reconstructed.spo2, isNull);
      expect(reconstructed.peakFlowZone, isNull);
    });

    test('2. PhysioSessionRecord: preSpo2 e postSpo2 ausentes devem ser null (sem fabricar 98)', () {
      const physio = PhysioSessionRecord(
        deviceName: 'Voldyne 5000',
        durationMinutes: 15,
        preSpo2: null,
        postSpo2: null,
        amibApproved: true,
      );

      expect(physio.preSpo2, isNull);
      expect(physio.postSpo2, isNull);

      final json = physio.toJson();
      expect(json['pre_spo2'], isNull);
      expect(json['post_spo2'], isNull);

      final reconstructed = PhysioSessionRecord.fromJson(json);
      expect(reconstructed.preSpo2, isNull);
      expect(reconstructed.postSpo2, isNull);
    });

    test('3. ActionZoneEvaluator: lança ArgumentError se personalBestPef <= 0 (evitando cálculo inventado)', () {
      expect(
        () => ActionZoneEvaluator.evaluate(currentPef: 150, personalBestPef: 0),
        throwsArgumentError,
      );
      expect(
        () => ActionZoneEvaluator.evaluate(currentPef: 150, personalBestPef: -10),
        throwsArgumentError,
      );
    });

    test('4. PatientProfile: gestationalAgeWeeks e birthWeightGrams são null por padrão (sem termo arbitrário 39s/3200g)', () {
      final profile = PatientProfile(
        id: 'patient_perinatal_test',
        name: 'Bebê Teste',
        birthDate: DateTime(2025, 5, 1),
        gender: 'Masculino',
        heightCm: 70,
        weightKg: 8.5,
        personalBestPef: 0,
        susCardNumber: '',
        healthInsurance: '',
        insuranceCardNumber: '',
      );

      expect(profile.gestationalAgeWeeks, isNull);
      expect(profile.birthWeightGrams, isNull);

      final json = profile.toJson();
      expect(json['gestational_age_weeks'], isNull);
      expect(json['birth_weight_grams'], isNull);

      final reconstructed = PatientProfile.fromJson(json);
      expect(reconstructed.gestationalAgeWeeks, isNull);
      expect(reconstructed.birthWeightGrams, isNull);
    });
  });
}
