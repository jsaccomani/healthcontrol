import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('DOMÍNIO & REDE DE CUIDADO: TESTES UNITÁRIOS COMPLETOS', () {
    // -------------------------------------------------------------------------
    // 1. LEGAL GUARDIANS (RESPONSÁVEIS LEGAIS)
    // -------------------------------------------------------------------------
    group('1. Responsáveis Legais (LegalGuardians)', () {
      test('1. Suporta uma mãe como responsável legal única', () {
        const guardian = LegalGuardian(
          id: 'g_mother_01',
          fullName: 'Maria da Silva',
          relationshipType: LegalGuardianRelationshipType.mother,
          phone: '(11) 98888-1111',
          email: 'maria@email.com',
          hasLegalCustody: true,
          isPrimaryContact: true,
        );

        final profile = PatientProfile(
          id: 'child_01',
          name: 'Lucas Silva',
          birthDate: DateTime(2022, 1, 10),
          gender: 'Masculino',
          heightCm: 95,
          weightKg: 14,
          personalBestPef: 160,
          susCardNumber: '123456789',
          healthInsurance: 'Unimed',
          insuranceCardNumber: '9988',
          legalGuardians: [guardian],
        );

        expect(profile.legalGuardians.length, 1);
        expect(profile.legalGuardians.first.fullName, 'Maria da Silva');
        expect(profile.legalGuardians.first.relationshipType, LegalGuardianRelationshipType.mother);
        expect(profile.legalGuardians.first.isPrimaryContact, isTrue);
      });

      test('2. Suporta um pai como responsável legal único', () {
        const guardian = LegalGuardian(
          id: 'g_father_01',
          fullName: 'Carlos Eduardo',
          relationshipType: LegalGuardianRelationshipType.father,
          phone: '(11) 97777-2222',
          hasLegalCustody: true,
          isPrimaryContact: true,
        );

        final profile = PatientProfile(
          id: 'child_02',
          name: 'Enzo Eduardo',
          birthDate: DateTime(2021, 3, 15),
          gender: 'Masculino',
          heightCm: 105,
          weightKg: 17,
          personalBestPef: 180,
          susCardNumber: '123',
          healthInsurance: 'SUS',
          insuranceCardNumber: '',
          legalGuardians: [guardian],
        );

        expect(profile.legalGuardians.length, 1);
        expect(profile.legalGuardians.first.fullName, 'Carlos Eduardo');
        expect(profile.legalGuardians.first.relationshipType, LegalGuardianRelationshipType.father);
      });

      test('3. Suporta duas mães (família homoafetiva)', () {
        final guardians = [
          const LegalGuardian(
            id: 'g_mother_01',
            fullName: 'Ana Paula Ferreira',
            relationshipType: LegalGuardianRelationshipType.mother,
            phone: '(11) 91111-1111',
            isPrimaryContact: true,
          ),
          const LegalGuardian(
            id: 'g_mother_02',
            fullName: 'Juliana Costa',
            relationshipType: LegalGuardianRelationshipType.mother,
            phone: '(11) 92222-2222',
            isPrimaryContact: false,
          ),
        ];

        final profile = PatientProfile(
          id: 'child_03',
          name: 'Clara Ferreira Costa',
          birthDate: DateTime(2020, 6, 20),
          gender: 'Feminino',
          heightCm: 110,
          weightKg: 19,
          personalBestPef: 200,
          susCardNumber: '456',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '1122',
          legalGuardians: guardians,
        );

        expect(profile.legalGuardians.length, 2);
        expect(profile.legalGuardians[0].relationshipType, LegalGuardianRelationshipType.mother);
        expect(profile.legalGuardians[1].relationshipType, LegalGuardianRelationshipType.mother);
        expect(profile.legalGuardians[0].fullName, 'Ana Paula Ferreira');
        expect(profile.legalGuardians[1].fullName, 'Juliana Costa');
      });

      test('4. Suporta dois pais (família homoafetiva)', () {
        final guardians = [
          const LegalGuardian(
            id: 'g_father_01',
            fullName: 'Rodrigo Lima',
            relationshipType: LegalGuardianRelationshipType.father,
            phone: '(21) 98888-0001',
            isPrimaryContact: true,
          ),
          const LegalGuardian(
            id: 'g_father_02',
            fullName: 'Marcos Vinicius',
            relationshipType: LegalGuardianRelationshipType.father,
            phone: '(21) 98888-0002',
            isPrimaryContact: false,
          ),
        ];

        final profile = PatientProfile(
          id: 'child_04',
          name: 'Pedro Lima',
          birthDate: DateTime(2019, 8, 12),
          gender: 'Masculino',
          heightCm: 120,
          weightKg: 22,
          personalBestPef: 240,
          susCardNumber: '789',
          healthInsurance: 'Amil',
          insuranceCardNumber: '3344',
          legalGuardians: guardians,
        );

        expect(profile.legalGuardians.length, 2);
        expect(profile.legalGuardians[0].relationshipType, LegalGuardianRelationshipType.father);
        expect(profile.legalGuardians[1].relationshipType, LegalGuardianRelationshipType.father);
      });

      test('5. Suporta avó como responsável legal (guarda judicial)', () {
        const guardian = LegalGuardian(
          id: 'g_grandma_01',
          fullName: 'Lourdes Saccomani',
          relationshipType: LegalGuardianRelationshipType.grandmother,
          phone: '(11) 99999-5555',
          hasLegalCustody: true,
          isPrimaryContact: true,
          notes: 'Guarda legal deferida judicialmente.',
        );

        final profile = PatientProfile(
          id: 'child_05',
          name: 'Gabriel Saccomani',
          birthDate: DateTime(2021, 1, 1),
          gender: 'Masculino',
          heightCm: 100,
          weightKg: 16,
          personalBestPef: 170,
          susCardNumber: '999',
          healthInsurance: 'SulAmérica',
          insuranceCardNumber: '5566',
          legalGuardians: [guardian],
        );

        expect(profile.legalGuardians.length, 1);
        expect(profile.legalGuardians.first.relationshipType, LegalGuardianRelationshipType.grandmother);
        expect(profile.legalGuardians.first.displayRelationship, 'Avó');
        expect(profile.legalGuardians.first.hasLegalCustody, isTrue);
      });

      test('6. Suporta guardião sem pai ou mãe (tutor legal ou abrigo)', () {
        const guardian = LegalGuardian(
          id: 'g_tutor_01',
          fullName: 'Dr. Roberto Meirelles (Curador Especial)',
          relationshipType: LegalGuardianRelationshipType.legalTutor,
          phone: '(11) 3333-4444',
          hasLegalCustody: true,
          isPrimaryContact: true,
        );

        final profile = PatientProfile(
          id: 'child_06',
          name: 'Joana D\'Arc',
          birthDate: DateTime(2018, 5, 5),
          gender: 'Feminino',
          heightCm: 130,
          weightKg: 28,
          personalBestPef: 260,
          susCardNumber: '000',
          healthInsurance: 'SUS',
          insuranceCardNumber: '',
          legalGuardians: [guardian],
        );

        expect(profile.legalGuardians.length, 1);
        expect(profile.legalGuardians.first.relationshipType, LegalGuardianRelationshipType.legalTutor);
        expect(profile.legalGuardians.first.displayRelationship, 'Tutor(a) Legal');
      });

      test('7. Suporta múltiplos responsáveis legais (3 guardiões: mãe, pai e avó co-responsável)', () {
        final guardians = [
          const LegalGuardian(
            id: 'g_1',
            fullName: 'Mãe Juliana',
            relationshipType: LegalGuardianRelationshipType.mother,
            phone: '111',
            isPrimaryContact: true,
          ),
          const LegalGuardian(
            id: 'g_2',
            fullName: 'Pai Marcos',
            relationshipType: LegalGuardianRelationshipType.father,
            phone: '222',
          ),
          const LegalGuardian(
            id: 'g_3',
            fullName: 'Avó Lourdes',
            relationshipType: LegalGuardianRelationshipType.grandmother,
            phone: '333',
          ),
        ];

        final profile = PatientProfile(
          id: 'child_07',
          name: 'Arthur',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '987',
          legalGuardians: guardians,
        );

        expect(profile.legalGuardians.length, 3);
        expect(profile.legalGuardians.map((g) => g.fullName), ['Mãe Juliana', 'Pai Marcos', 'Avó Lourdes']);
      });
    });

    // -------------------------------------------------------------------------
    // 2. CAREGIVERS (CUIDADORES)
    // -------------------------------------------------------------------------
    group('2. Cuidadores (Caregivers)', () {
      test('8. Suporta múltiplos cuidadores cadastrados para a mesma criança', () {
        final caregivers = [
          const Caregiver(
            id: 'cg_1',
            fullName: 'Juliana Saccomani',
            relationshipType: CaregiverRelationshipType.mother,
            phone: '(11) 98765-4321',
            accessLevel: CaregiverAccessLevel.primaryGuardian,
            isPrimary: true,
          ),
          const Caregiver(
            id: 'cg_2',
            fullName: 'Maria da Silva (Avó)',
            relationshipType: CaregiverRelationshipType.grandmother,
            phone: '(11) 99999-1111',
            accessLevel: CaregiverAccessLevel.caregiverFull,
          ),
        ];

        final profile = PatientProfile(
          id: 'child_cg_01',
          name: 'Arthur',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '987',
          caregivers: caregivers,
        );

        expect(profile.caregivers.length, 2);
        expect(profile.caregivers.first.isPrimary, isTrue);
        expect(profile.caregivers.last.relationshipType, CaregiverRelationshipType.grandmother);
      });

      test('9. Suporta cuidador que não é responsável legal (Babá / Escola)', () {
        const nanny = Caregiver(
          id: 'cg_nanny_01',
          fullName: 'Tia Rosa (Babá)',
          relationshipType: CaregiverRelationshipType.babysitter,
          phone: '(11) 94444-5555',
          accessLevel: CaregiverAccessLevel.caregiverFull,
          notes: 'Cuida no período da tarde de segunda a sexta.',
        );

        expect(nanny.relationshipType, CaregiverRelationshipType.babysitter);
        expect(nanny.displayRelationship, 'Babá');
        expect(nanny.accessLevel, CaregiverAccessLevel.caregiverFull);
      });

      test('10. Suporta múltiplos níveis de permissão operacional (CaregiverAccessLevel)', () {
        const school = Caregiver(
          id: 'cg_school_01',
          fullName: 'Professora Cláudia (Escola Infantil)',
          relationshipType: CaregiverRelationshipType.schoolCaregiver,
          phone: '(11) 3210-9876',
          accessLevel: CaregiverAccessLevel.caregiverRecordOnly,
        );

        expect(school.accessLevel, CaregiverAccessLevel.caregiverRecordOnly);
        expect(school.accessLevel.displayName, contains('Apenas Registro'));
      });
    });

    // -------------------------------------------------------------------------
    // 3. HEALTHCARE PROFESSIONALS (PROFISSIONAIS DE SAÚDE)
    // -------------------------------------------------------------------------
    group('3. Profissionais de Saúde (HealthcareProfessionals)', () {
      test('11. Suporta cadastro de um médico assistente', () {
        const doc = HealthcareProfessional(
          id: 'doc_01',
          fullName: 'Dr. Marco Aurélio Valente',
          specialty: HealthcareSpecialty.pediatricPulmonologist,
          primaryPhone: '(11) 98888-7777',
          clinicOrHospital: 'Instituto Pediátrico de Pneumologia',
          licenseNumber: 'CRM/SP 129.840',
          rqeNumber: 'RQE 48.211',
          isPrimaryAttending: true,
        );

        expect(doc.fullName, 'Dr. Marco Aurélio Valente');
        expect(doc.specialty, HealthcareSpecialty.pediatricPulmonologist);
        expect(doc.displaySpecialty, 'Pneumologista Pediátrico(a)');
        expect(doc.isPrimaryAttending, isTrue);
      });

      test('12. Suporta múltiplos profissionais multidisciplinares (Médico + Fisioterapeuta)', () {
        final team = [
          const HealthcareProfessional(
            id: 'doc_01',
            fullName: 'Dr. Marco Aurélio Valente',
            specialty: HealthcareSpecialty.pediatricPulmonologist,
            primaryPhone: '(11) 98888-7777',
            isPrimaryAttending: true,
          ),
          const HealthcareProfessional(
            id: 'physio_01',
            fullName: 'Dra. Camila Santos',
            specialty: HealthcareSpecialty.respiratoryPhysiotherapist,
            primaryPhone: '(11) 97777-6666',
            licenseNumber: 'CREFITO-3/184.220-F',
            clinicOrHospital: 'Clínica Respirar Kids',
          ),
          const HealthcareProfessional(
            id: 'allergy_01',
            fullName: 'Dr. Fernando Alencar',
            specialty: HealthcareSpecialty.allergistImmunologist,
            primaryPhone: '(11) 96666-5555',
          ),
        ];

        final profile = PatientProfile(
          id: 'child_multi_doc',
          name: 'Arthur',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '987',
          healthcareProfessionals: team,
        );

        expect(profile.healthcareProfessionals.length, 3);
        expect(profile.primaryDoctor?.fullName, 'Dr. Marco Aurélio Valente');
      });

      test('13. Identifica médico assistente principal dinamicamente', () {
        final doctors = [
          const HealthcareProfessional(
            id: 'doc_sec',
            fullName: 'Dra. Paula (Pediatra Geral)',
            specialty: HealthcareSpecialty.pediatrician,
            primaryPhone: '123',
            isPrimaryAttending: false,
          ),
          const HealthcareProfessional(
            id: 'doc_prim',
            fullName: 'Dr. Valente (Pneumopediatra)',
            specialty: HealthcareSpecialty.pediatricPulmonologist,
            primaryPhone: '456',
            isPrimaryAttending: true,
          ),
        ];

        final profile = PatientProfile(
          id: 'child_p',
          name: 'Arthur',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '987',
          healthcareProfessionals: doctors,
        );

        expect(profile.primaryDoctor?.id, 'doc_prim');
        expect(profile.primaryDoctor?.fullName, 'Dr. Valente (Pneumopediatra)');
      });

      test('14. Suporta diferentes especialidades clínicas catalogadas', () {
        expect(HealthcareSpecialty.pediatrician.displayName, 'Pediatra Geral');
        expect(HealthcareSpecialty.pediatricPulmonologist.displayName, 'Pneumologista Pediátrico(a)');
        expect(HealthcareSpecialty.allergistImmunologist.displayName, 'Alergista e Imunologista');
        expect(HealthcareSpecialty.respiratoryPhysiotherapist.displayName, 'Fisioterapeuta Respiratório(a)');
        expect(HealthcareSpecialty.otorhinolaryngologist.displayName, 'Otorrinolaringologista');
        expect(HealthcareSpecialty.generalPractitioner.displayName, 'Médico(a) de Família / UBS');
      });
    });

    // -------------------------------------------------------------------------
    // 4. SPECIAL CONDITIONS, LIMITATIONS & CARE REQUIREMENTS
    // -------------------------------------------------------------------------
    group('4. Condições Especiais, Limitações e Acessibilidade', () {
      test('15. Suporta múltiplas condições especiais diagnosticadas', () {
        final conditions = [
          const SpecialCondition(
            id: 'sc_01',
            name: 'Transtorno do Espectro Autista (TEA)',
            category: ConditionCategory.developmental,
            clinicalCode: 'F84.0',
            isConfirmed: true,
            notes: 'Sensibilidade auditiva a ruídos agudos.',
          ),
          const SpecialCondition(
            id: 'sc_02',
            name: 'Doença do Refluxo Gastroesofágico (DRGE)',
            category: ConditionCategory.other,
            clinicalCode: 'K21.0',
            isConfirmed: true,
          ),
        ];

        final profile = PatientProfile(
          id: 'child_sc',
          name: 'Enzo',
          birthDate: DateTime(2020, 1, 1),
          gender: 'Masculino',
          heightCm: 100,
          weightKg: 16,
          personalBestPef: 180,
          susCardNumber: '111',
          healthInsurance: 'SUS',
          insuranceCardNumber: '',
          specialConditions: conditions,
        );

        expect(profile.specialConditions.length, 2);
        expect(profile.specialConditions.first.category, ConditionCategory.developmental);
        expect(profile.specialConditions.first.clinicalCode, 'F84.0');
      });

      test('16. Suporta múltiplas limitações funcionais (Acessibilidade)', () {
        final limitations = [
          const FunctionalLimitation(
            id: 'fl_01',
            type: LimitationType.nonVerbal,
            severity: LimitationSeverity.severe,
            description: 'Comunicação através de prancha visual PECS.',
          ),
          const FunctionalLimitation(
            id: 'fl_02',
            type: LimitationType.unableToPerformPeakFlow,
            severity: LimitationSeverity.severe,
            description: 'Não realiza manobra forçada de Peak Flow.',
          ),
        ];

        final profile = PatientProfile(
          id: 'child_fl',
          name: 'Theo',
          birthDate: DateTime(2019, 10, 10),
          gender: 'Masculino',
          heightCm: 115,
          weightKg: 20,
          personalBestPef: 0,
          susCardNumber: '222',
          healthInsurance: 'SUS',
          insuranceCardNumber: '',
          functionalLimitations: limitations,
        );

        expect(profile.functionalLimitations.length, 2);
        expect(profile.functionalLimitations.first.type, LimitationType.nonVerbal);
        expect(profile.functionalLimitations.last.type, LimitationType.unableToPerformPeakFlow);
      });

      test('17. Suporta requisitos de cuidado operacional (CareRequirement)', () {
        final requirements = [
          const CareRequirement(
            id: 'cr_01',
            type: CareRequirementType.requiresFaceMaskForInhalation,
            title: 'Máscara Facial Obrigatória',
            description: 'Não vedar com bocal plástico; usar máscara com vedação suave.',
          ),
          const CareRequirement(
            id: 'cr_02',
            type: CareRequirementType.requiresCalmEnvironment,
            title: 'Ambiente Calmo',
            description: 'Evitar sons estridentes durante a crise.',
          ),
        ];

        final profile = PatientProfile(
          id: 'child_cr',
          name: 'Theo',
          birthDate: DateTime(2019, 10, 10),
          gender: 'Masculino',
          heightCm: 115,
          weightKg: 20,
          personalBestPef: 0,
          susCardNumber: '222',
          healthInsurance: 'SUS',
          insuranceCardNumber: '',
          careRequirements: requirements,
        );

        expect(profile.careRequirements.length, 2);
        expect(profile.careRequirements.first.type, CareRequirementType.requiresFaceMaskForInhalation);
      });
    });

    // -------------------------------------------------------------------------
    // 5. DETERMINISTIC & IDEMPOTENT MIGRATION (MIGRAÇÃO DE SCHEMA v1 -> v2)
    // -------------------------------------------------------------------------
    group('5. Migração de Dados Legados (Schema v1 -> v2)', () {
      test('18. Migra mãe legada para LegalGuardian de forma determinística', () {
        final legacyJson = {
          'id': 'child_leg_01',
          'name': 'Arthur Saccomani',
          'birth_date': '2021-05-15T00:00:00.000',
          'gender': 'Masculino',
          'height_cm': 110.0,
          'weight_kg': 19.5,
          'personal_best_pef': 220,
          'sus_card_number': '898',
          'health_insurance': 'Bradesco',
          'insurance_card_number': '987',
          'mother_name': 'Juliana Saccomani',
          'mother_phone': '(11) 98765-4321',
          'mother_email': 'juliana@email.com',
        };

        final profile = PatientProfile.fromJson(legacyJson);

        expect(profile.legalGuardians.isNotEmpty, isTrue);
        final mother = profile.legalGuardians.firstWhere(
          (g) => g.relationshipType == LegalGuardianRelationshipType.mother,
        );
        expect(mother.fullName, 'Juliana Saccomani');
        expect(mother.phone, '(11) 98765-4321');
        expect(mother.email, 'juliana@email.com');
        expect(mother.isPrimaryContact, isTrue);
      });

      test('19. Migra pai legado para LegalGuardian de forma determinística', () {
        final legacyJson = {
          'id': 'child_leg_02',
          'name': 'Beatriz',
          'birth_date': '2020-02-02T00:00:00.000',
          'gender': 'Feminino',
          'height_cm': 105.0,
          'weight_kg': 17.0,
          'personal_best_pef': 190,
          'sus_card_number': '111',
          'health_insurance': 'Unimed',
          'insurance_card_number': '222',
          'father_name': 'Marcos Vinicius',
          'father_phone': '(11) 91234-5678',
        };

        final profile = PatientProfile.fromJson(legacyJson);

        expect(profile.legalGuardians.isNotEmpty, isTrue);
        final father = profile.legalGuardians.firstWhere(
          (g) => g.relationshipType == LegalGuardianRelationshipType.father,
        );
        expect(father.fullName, 'Marcos Vinicius');
        expect(father.phone, '(11) 91234-5678');
      });

      test('20. Migra médico assistente legado para HealthcareProfessional', () {
        final legacyJson = {
          'id': 'child_leg_03',
          'name': 'Arthur',
          'birth_date': '2021-05-15T00:00:00.000',
          'gender': 'Masculino',
          'height_cm': 110.0,
          'weight_kg': 19.5,
          'personal_best_pef': 220,
          'sus_card_number': '898',
          'health_insurance': 'Bradesco',
          'insurance_card_number': '987',
          'doctor_name': 'Dr. Marco Aurélio Valente',
          'doctor_phone': '(11) 98888-7777',
          'preferred_hospital': 'Hospital Infantil Sabará',
        };

        final profile = PatientProfile.fromJson(legacyJson);

        expect(profile.healthcareProfessionals.isNotEmpty, isTrue);
        final doc = profile.healthcareProfessionals.first;
        expect(doc.fullName, 'Dr. Marco Aurélio Valente');
        expect(doc.primaryPhone, '(11) 98888-7777');
        expect(doc.clinicOrHospital, 'Hospital Infantil Sabará');
        expect(doc.isPrimaryAttending, isTrue);
      });

      test('21. Re-execução da migração em JSON já migrado não duplica registros (Idempotência)', () {
        final legacyJson = {
          'id': 'child_idemp_01',
          'name': 'Arthur',
          'birth_date': '2021-05-15T00:00:00.000',
          'gender': 'Masculino',
          'height_cm': 110.0,
          'weight_kg': 19.5,
          'personal_best_pef': 220,
          'sus_card_number': '898',
          'health_insurance': 'Bradesco',
          'insurance_card_number': '987',
          'mother_name': 'Juliana Saccomani',
          'mother_phone': '(11) 98765-4321',
          'father_name': 'Pai',
          'father_phone': '(11) 91234-5678',
          'doctor_name': 'Dr. Marco Aurélio Valente',
          'doctor_phone': '(11) 98888-7777',
        };

        // 1ª Passada: Migração de Legado
        final profile1 = PatientProfile.fromJson(legacyJson);
        final serialized1 = profile1.toJson();

        // 2ª Passada: Leitura do JSON gerado
        final profile2 = PatientProfile.fromJson(serialized1);
        final serialized2 = profile2.toJson();

        // 3ª Passada: Leitura novamente
        final profile3 = PatientProfile.fromJson(serialized2);

        expect(profile1.legalGuardians.length, 2);
        expect(profile2.legalGuardians.length, 2);
        expect(profile3.legalGuardians.length, 2);

        expect(profile1.healthcareProfessionals.length, 1);
        expect(profile2.healthcareProfessionals.length, 1);
        expect(profile3.healthcareProfessionals.length, 1);

        expect(profile3.legalGuardians.map((g) => g.fullName), ['Juliana Saccomani', 'Pai']);
      });

      test('22. Ausência total de campos legados não quebra a desserialização (Safe Defaults)', () {
        final emptyJson = {
          'id': 'child_empty',
          'name': 'Criança Nova',
          'birth_date': '2023-01-01T00:00:00.000',
          'gender': 'Feminino',
          'height_cm': 85.0,
          'weight_kg': 12.0,
          'personal_best_pef': 150,
          'sus_card_number': '',
          'health_insurance': '',
          'insurance_card_number': '',
        };

        final profile = PatientProfile.fromJson(emptyJson);

        expect(profile.legalGuardians, isEmpty);
        expect(profile.caregivers, isEmpty);
        expect(profile.emergencyContacts, isEmpty);
        expect(profile.healthcareProfessionals, isEmpty);
        expect(profile.specialConditions, isEmpty);
        expect(profile.functionalLimitations, isEmpty);
        expect(profile.careRequirements, isEmpty);
        expect(profile.name, 'Criança Nova');
      });

      test('23. Dados clínicos e vitais não relacionados permanecem 100% intactos após migração', () {
        final legacyJson = {
          'id': 'child_intact',
          'name': 'Arthur',
          'birth_date': '2021-05-15T00:00:00.000',
          'gender': 'Masculino',
          'height_cm': 110.0,
          'weight_kg': 19.5,
          'personal_best_pef': 220,
          'sus_card_number': '898 0000 1234 5678',
          'health_insurance': 'Bradesco Saúde Top',
          'insurance_card_number': '987654321000',
          'gestational_age_weeks': 38,
          'birth_weight_grams': 3100,
          'neonatal_icu_or_oxygen': true,
          'symptoms_start_age': 'Aos 6 meses',
          'had_icu_admission': true,
          'icu_admissions_count': 1,
          'intubated_past': false,
          'er_visits_last_12_months': 3,
          'oral_steroid_courses_last_year': 4,
          'night_awakenings_per_month': 2,
          'crisis_triggers': ['Tempo seco', 'Frio'],
          'drug_allergies': ['Dipirona'],
          'food_allergies': ['Leite'],
          'environmental_allergies': ['Ácaros'],
          'ige_level': 520.0,
          'eosinophils_count': 600,
          'mother_name': 'Juliana',
          'mother_phone': '123',
        };

        final profile = PatientProfile.fromJson(legacyJson);

        expect(profile.gestationalAgeWeeks, 38);
        expect(profile.birthWeightGrams, 3100);
        expect(profile.neonatalIcuOrOxygen, isTrue);
        expect(profile.hadIcuAdmission, isTrue);
        expect(profile.icuAdmissionsCount, 1);
        expect(profile.erVisitsLast12Months, 3);
        expect(profile.oralSteroidCoursesLastYear, 4);
        expect(profile.nightAwakeningsPerMonth, 2);
        expect(profile.crisisTriggers, ['Tempo seco', 'Frio']);
        expect(profile.drugAllergies, ['Dipirona']);
        expect(profile.foodAllergies, ['Leite']);
        expect(profile.environmentalAllergies, ['Ácaros']);
        expect(profile.igeLevel, 520.0);
        expect(profile.eosinophilsCount, 600);
      });
    });

    // -------------------------------------------------------------------------
    // 6. SERIALIZATION ROUNDTRIPS
    // -------------------------------------------------------------------------
    group('6. Serialização e Desserialização Roundtrips', () {
      test('24. Modelo Novo (Schema v2) -> JSON -> Modelo Novo mantém fidelidade total', () {
        final original = PatientProfile(
          id: 'child_rt_01',
          schemaVersion: 2,
          name: 'Arthur Saccomani',
          birthDate: DateTime(2021, 5, 15),
          gender: 'Masculino',
          heightCm: 110,
          weightKg: 19.5,
          personalBestPef: 220,
          susCardNumber: '898',
          healthInsurance: 'Bradesco',
          insuranceCardNumber: '987',
          legalGuardians: const [
            LegalGuardian(
              id: 'g_1',
              fullName: 'Juliana Saccomani',
              relationshipType: LegalGuardianRelationshipType.mother,
              phone: '111',
              isPrimaryContact: true,
            ),
          ],
          caregivers: const [
            Caregiver(
              id: 'cg_1',
              fullName: 'Juliana Saccomani',
              relationshipType: CaregiverRelationshipType.mother,
              phone: '111',
              accessLevel: CaregiverAccessLevel.primaryGuardian,
              isPrimary: true,
            ),
          ],
          emergencyContacts: const [
            EmergencyContact(
              id: 'em_1',
              fullName: 'Juliana (Mãe)',
              relationship: 'Mãe',
              phone: '111',
              priority: 1,
            ),
          ],
          healthcareProfessionals: const [
            HealthcareProfessional(
              id: 'doc_1',
              fullName: 'Dr. Marco Aurélio Valente',
              specialty: HealthcareSpecialty.pediatricPulmonologist,
              primaryPhone: '999',
              isPrimaryAttending: true,
            ),
          ],
          specialConditions: const [
            SpecialCondition(
              id: 'sc_1',
              name: 'Asma Grave',
              category: ConditionCategory.respiratory,
            ),
          ],
          functionalLimitations: const [
            FunctionalLimitation(
              id: 'fl_1',
              type: LimitationType.nonVerbal,
              description: 'Comunicação visual',
            ),
          ],
          careRequirements: const [
            CareRequirement(
              id: 'cr_1',
              type: CareRequirementType.requiresFaceMaskForInhalation,
              title: 'Máscara Facial',
              description: 'Usar com espaçador',
            ),
          ],
        );

        final json = original.toJson();
        final reconstructed = PatientProfile.fromJson(json);

        expect(reconstructed.id, original.id);
        expect(reconstructed.schemaVersion, 2);
        expect(reconstructed.legalGuardians.length, 1);
        expect(reconstructed.legalGuardians.first.fullName, 'Juliana Saccomani');
        expect(reconstructed.caregivers.length, 1);
        expect(reconstructed.emergencyContacts.length, 1);
        expect(reconstructed.healthcareProfessionals.length, 1);
        expect(reconstructed.healthcareProfessionals.first.fullName, 'Dr. Marco Aurélio Valente');
        expect(reconstructed.specialConditions.length, 1);
        expect(reconstructed.functionalLimitations.length, 1);
        expect(reconstructed.careRequirements.length, 1);
      });

      test('25. JSON Legado (Schema v1) -> Modelo Novo (Schema v2) -> JSON preserva interoperabilidade', () {
        final legacyJson = {
          'id': 'legacy_arthur',
          'name': 'Arthur Saccomani',
          'birth_date': '2021-05-15T00:00:00.000',
          'gender': 'Masculino',
          'height_cm': 110.0,
          'weight_kg': 19.5,
          'personal_best_pef': 220,
          'sus_card_number': '898',
          'health_insurance': 'Bradesco',
          'insurance_card_number': '987',
          'mother_name': 'Juliana Saccomani',
          'mother_phone': '(11) 98765-4321',
          'father_name': 'Pai',
          'father_phone': '(11) 91234-5678',
          'doctor_name': 'Dr. Marco Aurélio Valente',
          'doctor_phone': '(11) 98888-7777',
        };

        final newModel = PatientProfile.fromJson(legacyJson);
        final upgradedJson = newModel.toJson();

        expect(upgradedJson['schema_version'], 2);
        expect((upgradedJson['legal_guardians'] as List).length, 2);
        expect((upgradedJson['healthcare_professionals'] as List).length, 1);
        expect(upgradedJson['mother_name'], 'Juliana Saccomani');
        expect(upgradedJson['doctor_name'], 'Dr. Marco Aurélio Valente');
      });
    });
  });
}
