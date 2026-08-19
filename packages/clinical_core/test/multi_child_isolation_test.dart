import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('MULTI-CHILD ISOLATION & DATA INTEGRITY TESTS', () {
    late PatientProfile childA;
    late PatientProfile childB;

    setUp(() {
      childA = PatientProfile(
        id: 'child_arthur_01',
        name: 'Arthur Saccomani',
        birthDate: DateTime(2021, 5, 15),
        gender: 'Masculino',
        bloodType: 'A+',
        heightCm: 110.0,
        weightKg: 19.5,
        personalBestPef: 220,
        susCardNumber: '898 0000 1234 5678',
        healthInsurance: 'Bradesco Saúde',
        insuranceCardNumber: '111222333',
        motherName: 'Juliana Saccomani',
        motherPhone: '(11) 98765-4321',
        motherEmail: 'juliana@email.com',
        continuousMedications: const ['Clenil HFA 250mcg'],
        drugAllergies: const ['Nenhuma'],
      );

      childB = PatientProfile(
        id: 'child_sofia_02',
        name: 'Sofia Saccomani',
        birthDate: DateTime(2023, 8, 20),
        gender: 'Feminino',
        bloodType: 'O+',
        heightCm: 92.0,
        weightKg: 13.2,
        personalBestPef: 150,
        susCardNumber: '898 0000 8765 4321',
        healthInsurance: 'Bradesco Saúde',
        insuranceCardNumber: '111222334',
        motherName: 'Juliana Saccomani',
        motherPhone: '(11) 98765-4321',
        motherEmail: 'juliana@email.com',
        continuousMedications: const ['Flixotide 50mcg'],
        drugAllergies: const ['Dipirona'],
      );
    });

    test('1. Isolamento Clínico e Antropométrico Completo entre Filhos', () {
      expect(childA.id, isNot(equals(childB.id)));
      expect(childA.personalBestPef, equals(220));
      expect(childB.personalBestPef, equals(150));
      expect(childA.continuousMedications, contains('Clenil HFA 250mcg'));
      expect(childB.continuousMedications, contains('Flixotide 50mcg'));
      expect(childB.drugAllergies, contains('Dipirona'));
      expect(childA.drugAllergies, isNot(contains('Dipirona')));

      // Avaliação de Zona Verde para 160 L/min:
      // Para Arthur (Recorde 220): 160/220 = 72.7% -> Zona Amarela
      // Para Sofia (Recorde 150): 160/150 = 106.7% -> Zona Verde
      final zoneArthur = ActionZoneEvaluator.evaluate(currentPef: 160, personalBestPef: childA.personalBestPef);
      final zoneSofia = ActionZoneEvaluator.evaluate(currentPef: 160, personalBestPef: childB.personalBestPef);

      expect(zoneArthur.zone, equals(ActionZoneType.yellow));
      expect(zoneSofia.zone, equals(ActionZoneType.green));
    });

    test('2. Isolamento Estrito de Hash Chain no Event Log (Zero Cross-Pollution)', () {
      final now = DateTime.now();

      // Evento 1 da Criança A (Gênese de Arthur)
      final logA1 = ClinicalEventLog(
        eventId: 'evt-a-1',
        patientId: childA.id,
        version: 'v1.0.1',
        sequenceNumber: 1,
        eventType: ClinicalEventType.healthControlEntry,
        authorName: 'Mãe (Juliana)',
        authorRole: 'Cuidadora Principal',
        timestamp: now,
        payload: {'pef': 210, 'zone': 'GREEN'},
        previousHash: 'GENESIS_BLOCK_0000000000000000',
      );

      // Evento 1 da Criança B (Gênese de Sofia)
      final logB1 = ClinicalEventLog(
        eventId: 'evt-b-1',
        patientId: childB.id,
        version: 'v1.0.1',
        sequenceNumber: 1,
        eventType: ClinicalEventType.healthControlEntry,
        authorName: 'Mãe (Juliana)',
        authorRole: 'Cuidadora Principal',
        timestamp: now,
        payload: {'pef': 150, 'zone': 'GREEN'},
        previousHash: 'GENESIS_BLOCK_0000000000000000',
      );

      // Evento 2 da Criança A (encadeado em A1)
      final logA2 = ClinicalEventLog(
        eventId: 'evt-a-2',
        patientId: childA.id,
        version: 'v1.0.2',
        sequenceNumber: 2,
        eventType: ClinicalEventType.healthControlEntry,
        authorName: 'Pai',
        authorRole: 'Cuidador',
        timestamp: now.add(const Duration(hours: 4)),
        payload: {'pef': 215, 'zone': 'GREEN'},
        previousHash: logA1.hash,
      );

      // Validação: Ambas as cadeias são independentes e válidas
      expect(logA1.verifyIntegrity(), isTrue);
      expect(logB1.verifyIntegrity(), isTrue);
      expect(logA2.verifyIntegrity(), isTrue);

      expect(logA2.previousHash, equals(logA1.hash));
      expect(logA2.previousHash, isNot(equals(logB1.hash)));
      expect(logA1.patientId, equals(childA.id));
      expect(logB1.patientId, equals(childB.id));
    });

    test('3. ReBAC & Pareamento Médico: Vínculo com Filho A não confere acesso ao Filho B', () {
      // Simulação da Matriz de Decisão ReBAC
      final Map<String, List<String>> activeRelationships = {
        childA.id: ['dr_silva_crm1234'], // Dr. Silva vinculado a Arthur
        childB.id: ['dra_carla_crm5678'], // Dra. Carla vinculada a Sofia
      };

      bool hasAccess(String patientId, String professionalUid) {
        return activeRelationships[patientId]?.contains(professionalUid) ?? false;
      }

      // Dr. Silva tem acesso ao Arthur
      expect(hasAccess(childA.id, 'dr_silva_crm1234'), isTrue);
      // Dr. Silva NÃO tem acesso à Sofia
      expect(hasAccess(childB.id, 'dr_silva_crm1234'), isFalse);

      // Dra. Carla NÃO tem acesso ao Arthur
      expect(hasAccess(childA.id, 'dra_carla_crm5678'), isFalse);
      // Dra. Carla tem acesso à Sofia
      expect(hasAccess(childB.id, 'dra_carla_crm5678'), isTrue);
    });

    test('4. Prescrições Médicas e Farmacopeia Isoladas por Paciente', () {
      final prescArthur = PrescriptionRecord(
        id: 'presc_01',
        patientId: childA.id,
        doctorName: 'Dr. Silva',
        doctorCrm: '1234/SP',
        clinicName: 'Clínica Infantil',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'm1',
            commercialName: 'Clenil HFA 250mcg',
            activeIngredient: 'Beclometasona',
            category: MedicationCategory.maintenanceInhaled,
            dosage: '1 puff 12/12h',
            frequency: '12/12h',
          ),
        ],
      );

      final prescSofia = PrescriptionRecord(
        id: 'presc_02',
        patientId: childB.id,
        doctorName: 'Dra. Carla',
        doctorCrm: '5678/SP',
        clinicName: 'Clínica Pediátrica',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'm2',
            commercialName: 'Singulair Baby 4mg',
            activeIngredient: 'Montelucaste',
            category: MedicationCategory.antileukotrieneOral,
            dosage: '1 sachê/noite',
            frequency: '24/24h',
          ),
        ],
      );

      expect(prescArthur.patientId, equals('child_arthur_01'));
      expect(prescSofia.patientId, equals('child_sofia_02'));
      expect(prescArthur.medications.first.commercialName, contains('Clenil'));
      expect(prescSofia.medications.first.commercialName, contains('Singulair'));
    });
  });
}
