import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/storage/health_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HEALTH STORAGE SERVICE: NÃO-FABRICAÇÃO & ISOLAMENTO DE DADOS', () {
    late HealthStorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = HealthStorageService();
    });

    test('1. Paciente novo sem receitas: getPrescriptions retorna lista vazia (sem fabricar medicações)', () async {
      const patientId = 'arthur_new_id';
      final prescriptions = await storageService.getPrescriptions(patientId);

      // Regra de ouro: se não há receitas cadastradas, a lista deve ser rigorosamente vazia
      expect(prescriptions, isEmpty);
    });

    test('2. Salvar e recuperar receita: preserva exatamente CRM, posologia e instruções sem mutação', () async {
      const patientId = 'arthur_01';
      final testPrescription = PrescriptionRecord(
        id: 'presc_123',
        patientId: patientId,
        doctorName: 'Dr. Marco Aurélio Valente',
        doctorCrm: 'CRM/SP 129.840',
        clinicName: 'Clínica Respiratória Infantil',
        prescriptionDate: DateTime(2026, 8, 20),
        medications: const [
          PrescribedMedication(
            id: 'med_01',
            commercialName: 'Aerolin 100mcg Spray',
            activeIngredient: 'Sulfato de Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 a 4 jatos',
            frequency: 'A cada 20 minutos se houver chiado',
            instructions: 'Usar sempre com espaçador valvulado.',
            spacerRequired: true,
            isContinuous: false,
          ),
          PrescribedMedication(
            id: 'med_02',
            commercialName: 'Clenil HFA 50mcg',
            activeIngredient: 'Dipropionato de Beclometasona',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 jato 12/12h',
            frequency: 'Manhã e noite',
            instructions: 'Enxaguar a boca após a aplicação.',
            spacerRequired: true,
            isContinuous: true,
          ),
        ],
      );

      await storageService.savePrescription(testPrescription);

      final retrieved = await storageService.getPrescriptions(patientId);
      expect(retrieved.length, equals(1));
      
      final presc = retrieved.first;
      expect(presc.doctorName, equals('Dr. Marco Aurélio Valente'));
      expect(presc.doctorCrm, equals('CRM/SP 129.840'));
      expect(presc.medications.length, equals(2));
      
      final rescueMed = presc.medications.firstWhere((m) => m.category == MedicationCategory.rescueInhaled);
      expect(rescueMed.commercialName, equals('Aerolin 100mcg Spray'));
      expect(rescueMed.dosage, equals('2 a 4 jatos'));
      expect(rescueMed.spacerRequired, isTrue);
    });

    test('3. Isolamento Multi-Child: receitas de um filho não aparecem para outro irmão', () async {
      const patientA = 'child_arthur';
      const patientB = 'child_beatriz';

      final prescA = PrescriptionRecord(
        id: 'presc_a',
        patientId: patientA,
        doctorName: 'Dr. Pediatra A',
        prescriptionDate: DateTime.now(),
        medications: const [
          PrescribedMedication(
            id: 'med_a',
            commercialName: 'Medicamento A',
            activeIngredient: 'Princípio A',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 dose',
            frequency: '1x ao dia',
          ),
        ],
      );

      await storageService.savePrescription(prescA);

      // Paciente A tem 1 receita
      final listA = await storageService.getPrescriptions(patientA);
      expect(listA.length, equals(1));

      // Paciente B deve ter 0 receitas (isolamento absoluto)
      final listB = await storageService.getPrescriptions(patientB);
      expect(listB, isEmpty);
    });

    test('4. getPatientProfile() lança StateError se nenhum perfil existir e createNewChildProfile() cria o primeiro perfil com sucesso', () async {
      // Segurança clínica estrita: nunca fabricar placeholder patient
      expect(
        storageService.getPatientProfile(),
        throwsA(isA<StateError>()),
      );

      final created = await storageService.createNewChildProfile(
        name: 'Primeiro Filho',
        birthDate: DateTime(2022, 1, 1),
        gender: 'Masculino',
        heightCm: 98,
        weightKg: 15,
        personalBestPef: 160,
      );

      expect(created.name, equals('Primeiro Filho'));
      expect(created.personalBestPef, equals(160));

      final active = await storageService.getPatientProfile();
      expect(active.name, equals('Primeiro Filho'));
    });
  });
}
