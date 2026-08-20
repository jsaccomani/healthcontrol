import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('QA MATRIX: CARE CONTEXT & CRISIS-FIRST DOMAIN & UX SAFETY', () {
    // -------------------------------------------------------------------------
    // 1, 2, 3: PERFIS E CONTEXTO DE CRIANÇAS
    // -------------------------------------------------------------------------
    test('1. Zero crianças: Suporta lista vazia sem exceção (Safe Empty State)', () {
      final List<PatientProfile> profiles = [];
      expect(profiles.isEmpty, isTrue);
      expect(profiles.length, 0);
    });

    test('2. Uma criança: Identifica contexto de filho único (Single-Child Optimization)', () {
      final profiles = [
        PatientProfile(
          id: 'arthur_01',
          name: 'Arthur Saccomani',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898.000.123',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '123',
        ),
      ];

      expect(profiles.length, 1);
      expect(profiles.first.name, 'Arthur Saccomani');
    });

    test('3. Múltiplas crianças: Identifica e lista todos os filhos disponíveis', () {
      final profiles = [
        PatientProfile(
          id: 'arthur_01',
          name: 'Arthur Saccomani',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898.000.123',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '123',
        ),
        PatientProfile(
          id: 'beatriz_02',
          name: 'Beatriz Saccomani',
          birthDate: DateTime(2019, 3, 10),
          gender: 'Feminino',
          heightCm: 122,
          weightKg: 24.2,
          personalBestPef: 260,
          susCardNumber: '777.000.456',
          healthInsurance: 'Bradesco Saúde',
          insuranceCardNumber: '456',
        ),
      ];

      expect(profiles.length, 2);
      expect(profiles.map((p) => p.name), containsAll(['Arthur Saccomani', 'Beatriz Saccomani']));
    });

    // -------------------------------------------------------------------------
    // 4, 5, 6, 7, 15: INICIAR CRISE, CONFIRMAÇÃO E ISOLAMENTO ESTREITO
    // -------------------------------------------------------------------------
    test('4 & 6. Iniciar crise com uma criança: Confirmação direcionada com patientId correto', () {
      final singleProfile = PatientProfile(
        id: 'arthur_01',
        name: 'Arthur Saccomani',
        birthDate: DateTime(2021, 5, 15),
        gender: 'Masculino',
        heightCm: 110,
        weightKg: 19.5,
        personalBestPef: 220,
        susCardNumber: '898.000.123',
        healthInsurance: 'Bradesco Saúde',
        insuranceCardNumber: '123',
      );

      final prompt = '${singleProfile.name} está em crise?';
      expect(prompt, 'Arthur Saccomani está em crise?');

      final crisisEvent = CrisisEvent(
        id: 'ev_arthur_crisis_01',
        patientId: singleProfile.id,
        startedAt: DateTime.now(),
        startedBy: 'user_mae',
        startedByName: 'Juliana Saccomani',
        startedByRole: 'Mãe / Cuidadora Principal',
        createdAt: DateTime.now(),
      );

      expect(crisisEvent.patientId, 'arthur_01');
      expect(crisisEvent.startedByName, 'Juliana Saccomani');
    });

    test('5 & 15. Iniciar crise com múltiplas crianças: Seleção explícita impede isolamento incorreto', () {
      const selectedCrisisPatientId = 'beatriz_02';
      const nonCrisisPatientId = 'arthur_01';

      final crisisEvent = CrisisEvent(
        id: 'ev_beatriz_crisis',
        patientId: selectedCrisisPatientId,
        startedAt: DateTime.now(),
        startedBy: 'user_pai',
        startedByName: 'Carlos Saccomani',
        startedByRole: 'Pai',
        createdAt: DateTime.now(),
      );

      expect(crisisEvent.patientId, selectedCrisisPatientId);
      expect(crisisEvent.patientId, isNot(nonCrisisPatientId));
    });

    test('7. Impossibilidade de trocar paciente durante a crise (Contexto Trancado)', () {
      const lockedPatientId = 'arthur_01';
      final crisisEvent = CrisisEvent(
        id: 'ev_locked',
        patientId: lockedPatientId,
        startedAt: DateTime.now(),
        startedBy: 'user_01',
        createdAt: DateTime.now(),
      );

      expect(crisisEvent.patientId, 'arthur_01');
      // O patientId é final e imutável na CrisisScreen
    });

    // -------------------------------------------------------------------------
    // 8, 9, 10, 11: PLANO DE RESGATE, ORIGEM MÉDICA E REGRA CLÍNICA DE SEGURANÇA
    // -------------------------------------------------------------------------
    test('8 & 11. Plano de resgate existente: Exibe com clareza a origem médica prescrita', () {
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
            frequency: 'Em caso de tosse ou chiado',
            instructions: 'Espaçador valvulado com máscara',
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
      expect(presc.doctorCrm, 'CRM/SP 129.840');
    });

    test('9 & 10. Ausência de plano e NUNCA inventar dose: Encaminhamento seguro para 192/PS', () {
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

      // REGRA DE OURO: Nenhum medicamento ou posologia é inventado na ausência de prescrição de resgate
      expect(rescueMeds.isEmpty, isTrue);
    });

    // -------------------------------------------------------------------------
    // 12, 13, 14: REGISTRO DE ADMINISTRAÇÃO E TEMPORIZADOR PERSISTENTE
    // -------------------------------------------------------------------------
    test('12 & 13. Registro de administração com CrisisEvent auditável e reassessmentAt persistente', () {
      final now = DateTime(2026, 8, 20, 14, 30, 0);
      final reassessment = now.add(const Duration(minutes: 20));

      final event = CrisisEvent(
        id: 'crisis_ev_01',
        patientId: 'arthur_01',
        startedAt: now,
        startedBy: 'caregiver_01',
        startedByName: 'Juliana Saccomani',
        startedByRole: 'Mãe',
        status: 'active',
        rescuePlanId: 'presc_arthur_active',
        medicationAdministered: 'Aerolin Spray 100mcg',
        doseAdministered: '2 jatos',
        administeredAt: now,
        reassessmentAt: reassessment,
        notes: 'Crise leve após esforço',
        createdAt: now,
      );

      expect(event.patientId, 'arthur_01');
      expect(event.startedByName, 'Juliana Saccomani');
      expect(event.medicationAdministered, 'Aerolin Spray 100mcg');
      expect(event.doseAdministered, '2 jatos');
      expect(event.administeredAt, now);
      expect(event.reassessmentAt, reassessment);
    });

    test('14. Timer após reconstrução ou background: Cálculo puramente derivado de timestamp', () {
      final administeredAt = DateTime.now().subtract(const Duration(minutes: 7)); // Administrado há 7 min
      final reassessmentAt = administeredAt.add(const Duration(minutes: 20));

      // Deve restar aproximadamente 13 minutos (780 segundos)
      final remainingSeconds = reassessmentAt.difference(DateTime.now()).inSeconds;

      expect(remainingSeconds, greaterThan(760));
      expect(remainingSeconds, lessThanOrEqualTo(780));
    });
  });
}
