import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/design_system/design_system.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('Health Control Design System Tests', () {
    testWidgets('HCPrimaryButton renderiza texto, ícone e dispara clique', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestableWidget(
          HCPrimaryButton(
            label: 'Salvar Registro',
            icon: Icons.save,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Salvar Registro'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);

      await tester.tap(find.byType(HCPrimaryButton));
      expect(tapped, isTrue);
    });

    testWidgets('HCEmergencyButton renderiza estilo SOS de alta prioridade', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestableWidget(
          HCEmergencyButton(
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('SOS Emergência'), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      await tester.tap(find.byType(HCEmergencyButton));
      expect(tapped, isTrue);
    });

    testWidgets('HCActionZoneBadge renderiza corretamente para todas as Zonas GINA', (tester) async {
      // 1. Zona Verde
      await tester.pumpWidget(createTestableWidget(const HCActionZoneBadge(zone: ActionZoneType.green)));
      expect(find.text('Zona Verde (Estável)'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // 2. Zona Amarela
      await tester.pumpWidget(createTestableWidget(const HCActionZoneBadge(zone: ActionZoneType.yellow)));
      expect(find.text('Zona Amarela (Alerta)'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      // 3. Zona Vermelha
      await tester.pumpWidget(createTestableWidget(const HCActionZoneBadge(zone: ActionZoneType.red)));
      expect(find.text('Zona Vermelha (Crise)'), findsOneWidget);
      expect(find.byIcon(Icons.emergency_outlined), findsOneWidget);
    });

    testWidgets('HCMetricCard exibe valor clínico, unidade e rótulo', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const HCMetricCard(
            label: 'Melhor Sopro',
            value: '260',
            unit: 'L/min',
            icon: Icons.air,
            comparisonText: '86% do melhor pessoal',
          ),
        ),
      );

      expect(find.text('Melhor Sopro'), findsOneWidget);
      expect(find.text('260'), findsOneWidget);
      expect(find.text('L/min'), findsOneWidget);
      expect(find.text('86% do melhor pessoal'), findsOneWidget);
      expect(find.byIcon(Icons.air), findsOneWidget);
    });

    testWidgets('HCEmptyState exibe mensagem acolhedora e botão de ação', (tester) async {
      bool actionClicked = false;
      await tester.pumpWidget(
        createTestableWidget(
          HCEmptyState(
            title: 'Nenhum lançamento hoje',
            message: 'Toque abaixo para registrar o primeiro sopro do dia.',
            icon: Icons.edit_calendar_outlined,
            actionLabel: 'Novo Lançamento',
            onActionPressed: () => actionClicked = true,
          ),
        ),
      );

      expect(find.text('Nenhum lançamento hoje'), findsOneWidget);
      expect(find.text('Toque abaixo para registrar o primeiro sopro do dia.'), findsOneWidget);
      expect(find.text('Novo Lançamento'), findsOneWidget);

      await tester.tap(find.text('Novo Lançamento'));
      expect(actionClicked, isTrue);
    });

    testWidgets('HCTextField renderiza rótulo, ícone de prefixo e sufixo', (tester) async {
      final controller = TextEditingController(text: '98');
      await tester.pumpWidget(
        createTestableWidget(
          HCTextField(
            controller: controller,
            labelText: 'Saturação de Oxigênio (SpO2)',
            prefixIcon: Icons.bloodtype,
            suffixUnit: '%',
          ),
        ),
      );

      expect(find.text('Saturação de Oxigênio (SpO2)'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.byIcon(Icons.bloodtype), findsOneWidget);
    });

    testWidgets('HCCard aplica HCRadii.radiusXl e sombra elevated no modo claro, sem sombra no modo escuro', (tester) async {
      // 1. Modo Claro
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: const Scaffold(
            body: HCCard(child: Text('Card Claro')),
          ),
        ),
      );

      final Container containerLight = tester.widget<Container>(
        find.descendant(of: find.byType(HCCard), matching: find.byType(Container)),
      );
      final BoxDecoration decoLight = containerLight.decoration as BoxDecoration;
      expect(decoLight.borderRadius, equals(HCRadii.radiusXl));
      expect(decoLight.boxShadow, equals(HCShadows.elevated));

      // 2. Modo Escuro
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(
            body: HCCard(child: Text('Card Escuro')),
          ),
        ),
      );

      final Container containerDark = tester.widget<Container>(
        find.descendant(of: find.byType(HCCard), matching: find.byType(Container)),
      );
      final BoxDecoration decoDark = containerDark.decoration as BoxDecoration;
      expect(decoDark.borderRadius, equals(HCRadii.radiusXl));
      expect(decoDark.boxShadow, isNull);
    });

    testWidgets('HCMetricCard renderiza com escala de fonte 2.0x sem estourar layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(2.0),
                size: Size(400, 800),
              ),
              child: HCMetricCard(
                label: 'Pico de Fluxo',
                value: '350',
                unit: 'L/min',
                icon: Icons.air,
                comparisonText: 'Dentro do esperado',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pico de Fluxo'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('L/min'), findsOneWidget);
    });
  });
}
