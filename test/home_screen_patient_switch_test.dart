import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/theme/app_theme.dart';
import 'package:health_control/core/storage/health_storage_service.dart';
import 'package:health_control/core/design_system/design_system.dart';
import 'package:health_control/features/home/screens/home_screen.dart';

/// Regressão: troca de filho na HomeScreen precisa "colar" através de
/// múltiplas trocas e sobreviver a um refresh sem argumento (ex: retorno
/// de uma sub-tela, que sempre chama `_loadData()` sem targetPatientId
/// via `onRefresh`/callbacks de navegação). Antes da correção, esse
/// refresh sem argumento caía de volta em widget.initialPatientId,
/// revertendo silenciosamente qualquer troca.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final arthur = PatientProfile(
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

  final beatriz = PatientProfile(
    id: 'beatriz_01',
    name: 'Beatriz Saccomani',
    birthDate: DateTime(2019, 3, 2),
    gender: 'Feminino',
    heightCm: 118,
    weightKg: 24.0,
    personalBestPef: 260,
    susCardNumber: '898.000.456',
    healthInsurance: 'Bradesco Saúde',
    insuranceCardNumber: '456',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HealthStorageService().clearMemoryCache();
  });

  Future<void> switchToChildViaUi(WidgetTester tester, PatientProfile target) async {
    // 1. Abre o seletor de crianças tocando no badge do header (appBar).
    await tester.tap(find.byType(HCChildContextBadge));
    await tester.pumpAndSettle();

    // 2. Toca no nome da criança alvo dentro do bottom sheet.
    await tester.tap(find.text(target.name));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Arthur -> Beatriz -> Arthur -> Beatriz: cada troca "cola" e sobrevive a refresh sem argumento',
    (tester) async {
      final storage = HealthStorageService();
      await storage.savePatientProfile(arthur);
      await storage.savePatientProfile(beatriz);
      await storage.setSelectedProfileId(arthur.id);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(initialPatientId: arthur.id),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(arthur.name), findsWidgets);

      // Arthur -> Beatriz
      await switchToChildViaUi(tester, beatriz);
      expect(find.text(beatriz.name), findsWidgets);
      expect(find.text(arthur.name), findsNothing);

      // Refresh sem argumento (simula retorno de sub-tela, que sempre
      // chama _loadData() sem targetPatientId): NÃO pode reverter para o
      // paciente original da instância (Arthur). Invoca o callback
      // `onRefresh` público já conectado pela própria HomeScreen ao
      // RefreshIndicator — não é um método privado da tela, é o field
      // público do widget do framework que a tela conectou. Evita a
      // engrenagem interna de gesto/animação de RefreshIndicator.show(),
      // que trava quando o rebuild troca a tela inteira para o estado de
      // loading no meio do próprio refresh.
      final refreshCallback = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).onRefresh;
      await refreshCallback();
      await tester.pumpAndSettle();
      expect(find.text(beatriz.name), findsWidgets);
      expect(find.text(arthur.name), findsNothing);

      // Beatriz -> Arthur
      await switchToChildViaUi(tester, arthur);
      expect(find.text(arthur.name), findsWidgets);
      expect(find.text(beatriz.name), findsNothing);

      // Arthur -> Beatriz (novamente, garantindo que não é coincidência de estado inicial)
      await switchToChildViaUi(tester, beatriz);
      expect(find.text(beatriz.name), findsWidgets);
      expect(find.text(arthur.name), findsNothing);
    },
  );
}
