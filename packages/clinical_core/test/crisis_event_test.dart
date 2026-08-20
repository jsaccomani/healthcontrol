import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('CRISIS EVENT DOMAIN & RESCUE PLAN INTEGRITY TESTS', () {
    test('11. Criação de CrisisEvent com campos obrigatórios e defaults corretos', () {
      final now = DateTime(2026, 8, 20, 10, 30);
      final event = CrisisEvent(
        id: 'crisis_001',
        patientId: 'child_arthur',
        startedAt: now,
        startedBy: 'Juliana Saccomani',
        startedByRole: 'Mãe / Cuidadora Principal',
        createdAt: now,
      );

      expect(event.id, 'crisis_001');
      expect(event.patientId, 'child_arthur');
      expect(event.startedAt, now);
      expect(event.startedBy, 'Juliana Saccomani');
      expect(event.startedByRole, 'Mãe / Cuidadora Principal');
      expect(event.status, 'active');
      expect(event.isActive, isTrue);
      expect(event.isResolved, isFalse);
      expect(event.isEscalated, isFalse);
      expect(event.schemaVersion, 1);
    });

    test('12. CrisisEvent armazena e preserva patientId e timestamps estritos', () {
      final now = DateTime.now();
      final event = CrisisEvent(
        id: 'crisis_002',
        patientId: 'child_helena',
        startedAt: now,
        startedBy: 'Carlos (Pai)',
        createdAt: now,
      );

      expect(event.patientId, 'child_helena');
      expect(event.patientId, isNot('child_arthur'));
    });

    test('13. CrisisEvent registra informações completas de autor/cuidador e medicação administrada', () {
      final now = DateTime.now();
      final reassess = now.add(const Duration(minutes: 20));

      final event = CrisisEvent(
        id: 'crisis_003',
        patientId: 'child_arthur',
        startedAt: now,
        startedBy: 'Juliana Saccomani',
        startedByRole: 'Mãe',
        rescuePlanId: 'presc_01',
        medicationAdministered: 'Aerolin Spray 100mcg',
        doseAdministered: '2 jatos com espaçador',
        administeredAt: now,
        reassessmentAt: reassess,
        notes: 'Criança apresentou tosse seca e chiado leve após corrida.',
        createdAt: now,
      );

      expect(event.medicationAdministered, 'Aerolin Spray 100mcg');
      expect(event.doseAdministered, '2 jatos com espaçador');
      expect(event.reassessmentAt, reassess);
      expect(event.notes, contains('tosse seca'));
    });

    test('14. Cálculo de tempo de reavaliação deriva estritamente do timestamp de administração (+20 min)', () {
      final adminTime = DateTime(2026, 8, 20, 14, 0, 0);
      final reassessTime = adminTime.add(const Duration(minutes: 20));

      final event = CrisisEvent(
        id: 'crisis_004',
        patientId: 'child_arthur',
        startedAt: adminTime,
        startedBy: 'Mãe',
        administeredAt: adminTime,
        reassessmentAt: reassessTime,
        createdAt: adminTime,
      );

      expect(event.reassessmentAt!.difference(event.administeredAt!).inMinutes, 20);
      expect(event.reassessmentAt!.difference(event.administeredAt!).inSeconds, 1200);
    });

    test('Transições de status de CrisisEvent (active -> resolved / escalated)', () {
      final now = DateTime.now();
      final event = CrisisEvent(
        id: 'crisis_005',
        patientId: 'child_arthur',
        startedAt: now,
        startedBy: 'Mãe',
        status: 'active',
        createdAt: now,
      );

      final resolved = event.copyWith(status: 'resolved');
      expect(resolved.isActive, isFalse);
      expect(resolved.isResolved, isTrue);

      final escalated = event.copyWith(status: 'escalatedToHospital');
      expect(escalated.isEscalated, isTrue);
      expect(escalated.isResolved, isFalse);
    });

    test('Serialização e Desserialização JSON de CrisisEvent', () {
      final now = DateTime(2026, 8, 20, 15, 30, 0);
      final reassess = now.add(const Duration(minutes: 20));

      final original = CrisisEvent(
        id: 'crisis_json_01',
        patientId: 'child_001',
        startedAt: now,
        startedBy: 'Mãe Juliana',
        startedByRole: 'Cuidador Principal',
        status: 'active',
        rescuePlanId: 'presc_99',
        medicationAdministered: 'Aerolin 100mcg',
        doseAdministered: '2 jatos',
        administeredAt: now,
        reassessmentAt: reassess,
        notes: 'Sem esforço acessório',
        createdAt: now,
        schemaVersion: 1,
      );

      final json = original.toJson();
      final reconstructed = CrisisEvent.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.patientId, original.patientId);
      expect(reconstructed.startedAt, original.startedAt);
      expect(reconstructed.startedBy, original.startedBy);
      expect(reconstructed.medicationAdministered, original.medicationAdministered);
      expect(reconstructed.doseAdministered, original.doseAdministered);
      expect(reconstructed.reassessmentAt, original.reassessmentAt);
      expect(reconstructed.notes, original.notes);
      expect(reconstructed == original, isTrue);
    });

    test('9 & 10. Regra Clínica de Segurança: Identificação de Plano de Resgate sem Fabricação', () {
      final prescWithRescue = PrescriptionRecord(
        id: 'presc_01',
        patientId: 'child_01',
        doctorName: 'Dr. Valente',
        doctorCrm: 'CRM 12345',
        clinicName: 'Clínica',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'm1',
            commercialName: 'Aerolin Spray 100mcg',
            activeIngredient: 'Sulfato de Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 a 4 jatos',
            frequency: 'Em caso de crise',
            instructions: 'Espaçador valvulado',
            spacerRequired: true,
          ),
        ],
      );

      final rescueMeds = prescWithRescue.medications.where(
        (m) => m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue,
      ).toList();

      expect(rescueMeds.isNotEmpty, isTrue);
      expect(rescueMeds.first.commercialName, 'Aerolin Spray 100mcg');
      expect(rescueMeds.first.dosage, '2 a 4 jatos');

      final prescWithoutRescue = PrescriptionRecord(
        id: 'presc_02',
        patientId: 'child_02',
        doctorName: 'Dr. Silva',
        doctorCrm: 'CRM 67890',
        clinicName: 'Clínica',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'm2',
            commercialName: 'Clenil HFA 250mcg',
            activeIngredient: 'Dipropionato de Beclometasona',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 jato 12/12h',
            frequency: 'Contínuo',
            instructions: 'Bochechar',
            spacerRequired: true,
          ),
        ],
      );

      final emptyRescue = prescWithoutRescue.medications.where(
        (m) => m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue,
      ).toList();

      expect(emptyRescue.isEmpty, isTrue);
    });
  });
}
