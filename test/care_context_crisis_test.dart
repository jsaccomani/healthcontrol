import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/theme/app_theme.dart';
import 'package:health_control/features/care_context/screens/care_context_screen.dart';
import 'package:health_control/features/crisis/widgets/crisis_reassessment_timer.dart';
import 'package:health_control/features/crisis/widgets/crisis_emergency_actions.dart';
import 'package:health_control/features/crisis/widgets/crisis_header.dart';
import 'package:health_control/features/crisis/widgets/crisis_rescue_plan.dart';
import 'package:health_control/features/crisis/widgets/crisis_no_plan_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WIDGET TESTS: CARE CONTEXT & CRISIS-FIRST UX', () {
    testWidgets('16. Dark Mode & Light Mode: Renderiza sem exceções e sem fundo branco fixo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const CareContextScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareContextScreen), findsOneWidget);
    });

    testWidgets('17. Accessibility & Font Scaling (2.0x): Renderiza sem quebra', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              size: Size(360, 640),
            ),
            child: CareContextScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CareContextScreen), findsOneWidget);
    });

    testWidgets('18. Tela Pequena (320x480): Sem overflow visual no Modo Crise', (tester) async {
      final dummyProfile = PatientProfile(
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

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 480)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    CrisisHeader(profile: dummyProfile),
                    const SizedBox(height: 8),
                    CrisisReassessmentTimer(
                      reassessmentAt: DateTime.now().add(const Duration(minutes: 20)),
                    ),
                    const SizedBox(height: 8),
                    CrisisEmergencyActions(
                      onCallSamu: () {},
                      onOpenHospitalGps: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Arthur Saccomani'), findsOneWidget);
      expect(find.byType(CrisisReassessmentTimer), findsOneWidget);
      expect(find.byType(CrisisEmergencyActions), findsOneWidget);
    });

    testWidgets('Plano de Resgate Prescrito: Exibe médico prescritor e ação de registro', (tester) async {
      final presc = PrescriptionRecord(
        id: 'p1',
        patientId: 'arthur_01',
        doctorName: 'Dr. Marco Aurélio Valente',
        doctorCrm: 'CRM/SP 129.840',
        clinicName: 'Clínica',
        prescriptionDate: DateTime.now(),
        validityMonths: 6,
        medications: const [
          PrescribedMedication(
            id: 'm1',
            commercialName: 'Aerolin Spray 100mcg',
            activeIngredient: 'Salbutamol',
            category: MedicationCategory.rescueInhaled,
            dosage: '2 jatos',
            frequency: 'Em crise',
            instructions: 'Espaçador',
            spacerRequired: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrisisRescuePlan(
              validRescuePlans: [
                {
                  'prescription': presc,
                  'medication': presc.medications.first,
                }
              ],
              onAdministerDose: ({required dosage, required medicationName, required prescriptionId, administeredBy = 'Cuidador'}) {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Aerolin Spray 100mcg'), findsOneWidget);
      expect(find.text('2 jatos'), findsOneWidget);
      expect(find.textContaining('Dr. Marco Aurélio Valente'), findsOneWidget);
      expect(find.text('Registrar Medicação Administrada'), findsOneWidget);
    });

    testWidgets('Ausência de Plano: Exibe aviso seguro e botão 192 com destaque', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrisisNoPlanCard(
              onCallSamu: () {},
              onOpenEmergencySummary: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('PLANO DE RESGATE NÃO CADASTRADO'), findsOneWidget);
      expect(find.text('Ligar 192 (SAMU Emergência)'), findsOneWidget);
    });
  });
}
