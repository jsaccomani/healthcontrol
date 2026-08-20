import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('PATIENT PROFILE: NÃO-FABRICAÇÃO DE DEFAULTS CLÍNICOS', () {
    test('1. Construtor: defaults devem ser neutros ou vazios (sem dados clínicos inventados)', () {
      final patient = PatientProfile(
        id: 'patient_clean_01',
        name: 'Ana Silva',
        birthDate: DateTime(2022, 3, 10),
        gender: 'Feminino',
        heightCm: 95.0,
        weightKg: 14.2,
        personalBestPef: 160,
        susCardNumber: '',
        healthInsurance: '',
        insuranceCardNumber: '',
      );

      expect(patient.crisisTriggers, isEmpty);
      expect(patient.familyAsthmaHistory, isEmpty);
      expect(patient.environmentalAllergies, isEmpty);
      expect(patient.comorbidities, isEmpty);
      expect(patient.continuousMedications, isEmpty);
      expect(patient.drugAllergies, isEmpty);
      expect(patient.foodAllergies, isEmpty);

      expect(patient.doctorName, equals(''));
      expect(patient.doctorPhone, equals(''));
      expect(patient.preferredHospital, equals(''));
      expect(patient.symptomsStartAge, equals(''));

      expect(patient.activityLimitation, equals('Não informado'));
      expect(patient.householdPets, equals('Não informado'));
      expect(patient.bloodType, equals('Não informado'));

      expect(patient.fluVaccineUpToDate, isFalse);
      expect(patient.pneumococcalVaccine, isFalse);

      expect(patient.gestationalAgeWeeks, isNull);
      expect(patient.birthWeightGrams, isNull);

      expect(patient.erVisitsLast12Months, equals(0));
      expect(patient.oralSteroidCoursesLastYear, equals(0));
      expect(patient.nightAwakeningsPerMonth, equals(0));
      expect(patient.igeLevel, equals(0));
      expect(patient.eosinophilsCount, equals(0));
    });

    test('2. fromJson com payload mínimo: fallbacks neutros e sem dados clínicos fabricados', () {
      final json = <String, dynamic>{
        'id': 'patient_min_01',
      };

      final patient = PatientProfile.fromJson(json);

      expect(patient.name, equals('Criança (nome não disponível)'));
      expect(patient.birthDate, equals(DateTime(2000, 1, 1)));
      expect(patient.gender, equals('Não informado'));
      expect(patient.bloodType, equals('Não informado'));
      expect(patient.heightCm, equals(0));
      expect(patient.weightKg, equals(0));
      expect(patient.personalBestPef, equals(0));
      expect(patient.healthInsurance, equals(''));
      expect(patient.addressCityState, equals(''));

      expect(patient.doctorName, equals(''));
      expect(patient.doctorPhone, equals(''));
      expect(patient.preferredHospital, equals(''));
      expect(patient.symptomsStartAge, equals(''));

      expect(patient.activityLimitation, equals('Não informado'));
      expect(patient.householdPets, equals('Não informado'));
      expect(patient.fluVaccineUpToDate, isFalse);
      expect(patient.pneumococcalVaccine, isFalse);

      expect(patient.crisisTriggers, isEmpty);
      expect(patient.familyAsthmaHistory, isEmpty);
      expect(patient.environmentalAllergies, isEmpty);
      expect(patient.comorbidities, isEmpty);
      expect(patient.continuousMedications, isEmpty);
      expect(patient.drugAllergies, isEmpty);
      expect(patient.foodAllergies, isEmpty);

      expect(patient.gestationalAgeWeeks, isNull);
      expect(patient.birthWeightGrams, isNull);

      expect(patient.erVisitsLast12Months, equals(0));
      expect(patient.oralSteroidCoursesLastYear, equals(0));
      expect(patient.nightAwakeningsPerMonth, equals(0));
      expect(patient.igeLevel, equals(0));
      expect(patient.eosinophilsCount, equals(0));
    });
  });
}
