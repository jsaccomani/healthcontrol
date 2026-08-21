import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('PRESCRIPTION VERIFICATION LIFECYCLE (HC-009 / HEALTH_CONTROL_CONTEXT Sec 25-27)', () {
    test('1. Prescrição criada pelo cuidador tem status unknown por padrão (nunca verified)', () {
      final presc = PrescriptionRecord(
        id: 'presc_caregiver_01',
        patientId: 'patient_01',
        doctorName: 'Dr. Valente',
        doctorCrm: 'CRM/SP 123456',
        prescriptionDate: DateTime(2026, 8, 20),
        medications: const [
          PrescribedMedication(
            id: 'med_01',
            commercialName: 'Aerolin',
            activeIngredient: 'Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 jatos',
            frequency: 'Se crise',
          ),
        ],
      );

      // Regra clínica de ouro: CRM e nome preenchidos NÃO significam receita verificada
      expect(presc.verificationStatus, equals(PrescriptionVerificationStatus.unknown));
      expect(presc.verifiedAt, isNull);
      expect(presc.verificationProvider, isEmpty);
      expect(presc.verificationReference, isEmpty);
      expect(presc.documentHash, isNull);
    });

    test('2. Desserialização de JSON legado sem campos de verificação resulta em unknown seguro', () {
      final legacyJson = {
        'id': 'presc_legacy_01',
        'patient_id': 'patient_01',
        'prescription_date': '2026-08-20T10:00:00.000',
        'validity_months': 6,
        'medications': [],
      };

      final presc = PrescriptionRecord.fromJson(legacyJson);

      expect(presc.verificationStatus, equals(PrescriptionVerificationStatus.unknown));
      expect(presc.verifiedAt, isNull);
      expect(presc.verificationProvider, isEmpty);
      expect(presc.verificationReference, isEmpty);
      expect(presc.documentHash, isNull);
      // doctorName ausente vira string vazia (sem fallback fabricado)
      expect(presc.doctorName, isEmpty);
    });

    test('3. UnknownPrescriptionVerificationService retorna unknown sem simular autoridade externa', () async {
      final service = UnknownPrescriptionVerificationService();
      final presc = PrescriptionRecord(
        id: 'presc_test',
        patientId: 'patient_01',
        doctorName: 'Dr. Marco',
        prescriptionDate: DateTime.now(),
        medications: const [],
      );

      final status = await service.checkStatus(presc);
      expect(status, equals(PrescriptionVerificationStatus.unknown));
    });

    test('4. Ciclo de vida completo: serialização e desserialização de todos os status', () {
      for (final status in PrescriptionVerificationStatus.values) {
        final verifiedDate = status == PrescriptionVerificationStatus.verified ? DateTime(2026, 8, 20, 15, 30) : null;
        final presc = PrescriptionRecord(
          id: 'presc_${status.name}',
          patientId: 'patient_01',
          doctorName: 'Dr. Teste',
          doctorCrm: 'CRM 9999',
          prescriptionDate: DateTime(2026, 8, 20),
          medications: const [],
          verificationStatus: status,
          verifiedAt: verifiedDate,
          verificationProvider: status == PrescriptionVerificationStatus.verified ? 'CFM Autentica' : '',
          verificationReference: status == PrescriptionVerificationStatus.verified ? 'REF-123456' : '',
          documentHash: status == PrescriptionVerificationStatus.verified ? 'sha256_mock_hash' : null,
        );

        final json = presc.toJson();
        expect(json['verification_status'], equals(status.name));

        final restored = PrescriptionRecord.fromJson(json);
        expect(restored.verificationStatus, equals(status));
        expect(restored.verificationProvider, equals(presc.verificationProvider));
        expect(restored.verificationReference, equals(presc.verificationReference));
        expect(restored.documentHash, equals(presc.documentHash));
      }
    });

    test('5. copyWith preserva e atualiza campos de verificação', () {
      final initial = PrescriptionRecord(
        id: 'p1',
        patientId: 'child_1',
        doctorName: 'Dr. Inicial',
        prescriptionDate: DateTime(2026, 8, 20),
        medications: const [],
      );

      expect(initial.verificationStatus, equals(PrescriptionVerificationStatus.unknown));

      final verified = initial.copyWith(
        verificationStatus: PrescriptionVerificationStatus.verified,
        verifiedAt: DateTime(2026, 8, 20, 16, 0),
        verificationProvider: 'Health Control Pro',
        verificationReference: 'HC-AUTH-991',
      );

      expect(verified.verificationStatus, equals(PrescriptionVerificationStatus.verified));
      expect(verified.verificationProvider, equals('Health Control Pro'));
      expect(verified.verificationReference, equals('HC-AUTH-991'));
      expect(verified.verifiedAt, isNotNull);
    });
  });
}
