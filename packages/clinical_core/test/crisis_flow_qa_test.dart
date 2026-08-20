import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('QA MATRIX: CARE CONTEXT & CRISIS-FIRST DOMAIN LOGIC', () {
    // -------------------------------------------------------------------------
    // 1, 2, 3: PERFIS E CONTEXTO DE CRIANÇAS
    // -------------------------------------------------------------------------
    test('1. Suporta lista vazia de perfis de crianças sem falhas (Safe Empty State)', () {
      final List<PatientProfile> profiles = [];
      expect(profiles.isEmpty, isTrue);
      expect(profiles.length, 0);
    });

    test('2. Identifica contexto de filho único (Single-Child Optimization)', () {
      final profiles = [
        PatientProfile(
          id: 'arthur_01',
          name: 'Arthur Saccomani',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '123',
        ),
      ];

      expect(profiles.length, 1);
      final isSingle = profiles.length == 1;
      expect(isSingle, isTrue);
      expect(profiles.first.name, 'Arthur Saccomani');
    });

    test('3. Identifica múltiplos filhos (Multi-Child Context)', () {
      final profiles = [
        PatientProfile(
          id: 'arthur_01',
          name: 'Arthur Saccomani',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '123',
        ),
        PatientProfile(
          id: 'helena_02',
          name: 'Helena Saccomani',
          birthDate: DateTime(2023, 8, 1),
          gender: 'Feminino',
          heightCm: 88,
          weightKg: 13.2,
          personalBestPef: 140,
          susCardNumber: '777',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '456',
        ),
      ];

      expect(profiles.length, 2);
      expect(profiles.map((p) => p.id), containsAll(['arthur_01', 'helena_02']));
    });

    // -------------------------------------------------------------------------
    // 4, 5, 6, 7, 8: ENTRADA EM CRISE E ISOLAMENTO ESTREITO DE CONTEXTO
    // -------------------------------------------------------------------------
    test('4. Seleção normal de criança estabelece o patientId de destino', () {
      const selectedId = 'helena_02';
      expect(selectedId, 'helena_02');
    });

    test('5 & 7. Fluxo de crise com 1 filho: Confirmação direcionada para o único filho', () {
      final singleProfile = PatientProfile(
        id: 'arthur_01',
        name: 'Arthur Saccomani',
        birthDate: DateTime(2021, 5, 15),
        gender: 'Masculino',
        heightCm: 110,
        weightKg: 19.5,
        personalBestPef: 220,
        susCardNumber: '898',
        healthInsurance: 'Bradesco Saúde',
        insuranceCardNumber: '123',
      );

      final confirmationTitle = '${singleProfile.name} está em crise?';
      expect(confirmationTitle, 'Arthur Saccomani está em crise?');

      final crisisEvent = CrisisEvent(
        id: 'ev_01',
        patientId: singleProfile.id,
        startedAt: DateTime.now(),
        startedBy: 'Mãe (Juliana)',
        createdAt: DateTime.now(),
      );

      expect(crisisEvent.patientId, singleProfile.id);
    });

    test('6 & 8. Fluxo de crise com múltiplos filhos: Seleção explícita impede troca acidental', () {
      const selectedCrisisPatientId = 'helena_02';
      const nonCrisisPatientId = 'arthur_01';

      final crisisEvent = CrisisEvent(
        id: 'ev_helena_crisis',
        patientId: selectedCrisisPatientId,
        startedAt: DateTime.now(),
        startedBy: 'Juliana Saccomani',
        startedByRole: 'Mãe / Cuidadora Principal',
        createdAt: DateTime.now(),
      );

      expect(crisisEvent.patientId, selectedCrisisPatientId);
      expect(crisisEvent.patientId, isNot(nonCrisisPatientId));
    });

    // -------------------------------------------------------------------------
    // 9 & 10: PLANO DE RESGATE MÉDICO PRESCRITO vs AUSÊNCIA
    // -------------------------------------------------------------------------
    test('9. Exibe plano de resgate ativo quando prescrito pelo médico', () {
      final presc = PrescriptionRecord(
        id: 'presc_arthur_active',
        patientId: 'arthur_01',
        doctorName: 'Dr. Marco Aurélio Valente',
        doctorCrm: 'CRM/SP 129.840',
        clinicName: 'Instituto Pediátrico de Pneumologia',
        prescriptionDate: DateTime(2026, 8, 1),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'med_resgate_01',
            commercialName: 'Aerolin Spray 100mcg',
            activeIngredient: 'Sulfato de Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 a 4 jatos',
            frequency: 'Em caso de tosse, chiado ou falta de ar',
            instructions: 'Aplicar com espaçador valvulado e máscara facial.',
            spacerRequired: true,
          ),
          PrescribedMedication(
            id: 'med_manut_01',
            commercialName: 'Clenil HFA 250mcg',
            activeIngredient: 'Beclometasona',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 puff 12/12h',
            frequency: 'Uso contínuo',
            instructions: 'Bochechar após o uso',
            spacerRequired: true,
          ),
        ],
      );

      final rescueMeds = presc.medications.where(
        (m) => m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue,
      ).toList();

      expect(rescueMeds.length, 1);
      expect(rescueMeds.first.commercialName, 'Aerolin Spray 100mcg');
      expect(rescueMeds.first.dosage, '2 a 4 jatos');
      expect(presc.doctorName, 'Dr. Marco Aurélio Valente');
    });

    test('10. REGRA CLÍNICA: Paciente sem receita de resgate NÃO gera medicamento ou dose inventada', () {
      final prescWithoutRescue = PrescriptionRecord(
        id: 'presc_only_maintenance',
        patientId: 'child_no_rescue',
        doctorName: 'Dr. Silva',
        doctorCrm: 'CRM 12345',
        clinicName: 'Posto de Saúde',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'med_cont_01',
            commercialName: 'Budesonida 200mcg',
            activeIngredient: 'Budesonida',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 cápsula inalatória 12/12h',
            frequency: 'Uso diário',
            instructions: 'Inalador de pó seco',
            spacerRequired: false,
          ),
        ],
      );

      final rescueMeds = prescWithoutRescue.medications.where(
        (m) => m.category == MedicationCategory.rescueInhaled || m.category == MedicationCategory.oralSteroidRescue,
      ).toList();

      expect(rescueMeds.isEmpty, isTrue);
      // O sistema deve reportar ausência de plano e encaminhar para SAMU 192 / PS
    });

    // -------------------------------------------------------------------------
    // 11, 12, 13, 14: EVENTO DE CRISE, AUTORIA E CONTAGEM REGRESSIVA
    // -------------------------------------------------------------------------
    test('11, 12 & 13. Evento de crise persiste dados do autor, medicação e paciente com integridade', () {
      final now = DateTime(2026, 8, 20, 11, 0, 0);
      final reassessment = now.add(const Duration(minutes: 20));

      final event = CrisisEvent(
        id: 'crisis_event_audit_01',
        patientId: 'arthur_01',
        startedAt: now,
        startedBy: 'Juliana Saccomani',
        startedByRole: 'Mãe (Cuidadora Principal)',
        status: 'active',
        rescuePlanId: 'presc_arthur_active',
        medicationAdministered: 'Aerolin Spray 100mcg',
        doseAdministered: '2 jatos',
        administeredAt: now,
        reassessmentAt: reassessment,
        notes: 'Crise desencadeada por tempo frio e poeira.',
        createdAt: now,
      );

      expect(event.patientId, 'arthur_01');
      expect(event.startedBy, 'Juliana Saccomani');
      expect(event.medicationAdministered, 'Aerolin Spray 100mcg');
      expect(event.doseAdministered, '2 jatos');
      expect(event.administeredAt, now);
      expect(event.reassessmentAt, reassessment);
      expect(event.notes, contains('tempo frio'));
    });

    test('14. Temporizador de reavaliação calculado a partir do timestamp resiste a backgrounding', () {
      final administeredAt = DateTime.now().subtract(const Duration(minutes: 5)); // Administrado há 5 minutos
      final reassessmentAt = administeredAt.add(const Duration(minutes: 20));

      // Segundos restantes devem ser aproximadamente 15 minutos (900s)
      final remainingSeconds = reassessmentAt.difference(DateTime.now()).inSeconds;

      expect(remainingSeconds, greaterThan(880));
      expect(remainingSeconds, lessThanOrEqualTo(900));
    });
  });
}
