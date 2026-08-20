import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

void main() {
  group('PRESCRIPTION OCR PARSER: NÃO-FABRICAÇÃO & EXTRAÇÃO HONESTA', () {
    test('1. Texto genérico sem medicamentos: lista de medicações retorna vazia (sem fabricar Clenil/Aerolin)', () {
      const rawText = 'Receita médica para controle de saúde. Repouso e hidratação.';
      final record = PrescriptionOcrParser.parseRawPrescriptionText(
        rawText: rawText,
        patientId: 'patient_01',
      );

      expect(record.medications, isEmpty);
      expect(record.doctorName, equals(''));
      expect(record.doctorCrm, equals(''));
      expect(record.clinicName, equals(''));
      expect(
        record.notes,
        equals('Prescrição cadastrada manualmente pelo cuidador a partir de texto transcrito. Autenticidade não verificada.'),
      );
    });

    test('2. Texto com CRM e médico reais: extrai dados do texto sem adicionar defaults artificiais', () {
      const rawText = '''
        Dr. Carlos Eduardo Santos
        CRM 12345/SP
        Uso Contínuo:
        - Clenil HFA 250mcg - 1 puff 12/12h
        Data: 15/08/2026
      ''';

      final record = PrescriptionOcrParser.parseRawPrescriptionText(
        rawText: rawText,
        patientId: 'patient_01',
      );

      expect(record.doctorName, equals('Dr(a). Carlos Eduardo Santos'));
      expect(record.doctorCrm, equals('CRM 12345/SP'));
      expect(record.medications.length, equals(1));
      expect(record.medications.first.commercialName, equals('Clenil HFA 250mcg'));
    });
  });
}
