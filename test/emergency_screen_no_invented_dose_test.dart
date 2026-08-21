import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/features/crisis/widgets/crisis_no_plan_card.dart';
import 'package:health_control/features/crisis/widgets/crisis_rescue_plan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('EMERGENCY & CRISIS: NÃO-FABRICAÇÃO DE DOSES (REGRA CLÍNICA DE OURO)', () {
    testWidgets('1. Quando não há prescrição/resgate: exibe CrisisNoPlanCard com alerta e sem inventar medicação', (tester) async {
      bool samuCalled = false;
      bool summaryOpened = false;

      await tester.pumpWidget(
        createTestableWidget(
          CrisisNoPlanCard(
            onCallSamu: () => samuCalled = true,
            onOpenEmergencySummary: () => summaryOpened = true,
          ),
        ),
      );

      // Valida que o alerta clínico é exibido
      expect(find.text('PLANO DE RESGATE NÃO CADASTRADO'), findsOneWidget);
      expect(
        find.textContaining('não sugere medicamentos ou dosagens sem prévia prescrição cadastrada'),
        findsOneWidget,
      );

      // Valida as opções seguras de ação
      expect(find.text('Ligar 192 (SAMU Emergência)'), findsOneWidget);
      expect(find.text('Ver Ficha Clínica'), findsOneWidget);

      await tester.tap(find.text('Ligar 192 (SAMU Emergência)'));
      expect(samuCalled, isTrue);

      await tester.tap(find.text('Ver Ficha Clínica'));
      expect(summaryOpened, isTrue);
    });

    testWidgets('2. Quando há prescrição cadastrada: exibe CrisisRescuePlan com dados médicos originais e CRM', (tester) async {
      final mockPrescription = PrescriptionRecord(
        id: 'presc_test_01',
        patientId: 'patient_test_01',
        doctorName: 'Dr. Marco Aurélio Valente',
        doctorCrm: 'CRM/SP 129.840',
        clinicName: 'Instituto Pediátrico',
        prescriptionDate: DateTime.now(),
        medications: const [
          PrescribedMedication(
            id: 'med_01',
            commercialName: 'Aerolin 100mcg Spray',
            activeIngredient: 'Sulfato de Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 a 4 jatos',
            frequency: 'A cada 20 min se chiado',
            instructions: 'Usar com espaçador valvulado.',
            spacerRequired: true,
            isContinuous: false,
          ),
        ],
      );

      bool administered = false;

      await tester.pumpWidget(
        createTestableWidget(
          CrisisRescuePlan(
            validRescuePlans: [
              {
                'prescription': mockPrescription,
                'medication': mockPrescription.medications.first,
              }
            ],
            onAdministerDose: ({
              required String prescriptionId,
              required String medicationName,
              required String dosage,
              String administeredBy = 'Cuidador',
            }) {
              administered = true;
            },
          ),
        ),
      );

      expect(find.text('PLANO DE RESGATE PRESCRITO'), findsOneWidget);
      expect(find.textContaining('Dr. Marco Aurélio Valente'), findsOneWidget);
      expect(find.text('Aerolin 100mcg Spray'), findsOneWidget);
      expect(find.textContaining('2 a 4 jatos'), findsOneWidget);
      expect(find.textContaining('Autenticidade não verificada'), findsOneWidget);

      await tester.tap(find.text('Registrar Medicação Administrada'));
      await tester.pumpAndSettle();

      // Confirmação no dialog
      expect(find.text('Confirmar Administração'), findsOneWidget);
      await tester.tap(find.text('Confirmar e Iniciar Timer'));
      expect(administered, isTrue);
    });
  });
}
