import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/theme/app_theme.dart';
import 'package:health_control/core/storage/health_storage_service.dart';
import 'package:health_control/features/care_context/screens/care_context_screen.dart';

/// Complemento de UI ao teste de HealthStorageService: confirma que a
/// CareContextScreen de fato usa o sinal de corrupção — não é só que o
/// service o calcula certo, é que a tela nunca mascara o problema como
/// "instalação nova" nem trava o acesso aos filhos saudáveis. Este teste
/// vai além do escopo estritamente pedido no prompt (que cobria só o
/// storage service); adicionado porque a metade da correção que vive na
/// tela ficaria sem cobertura de regressão sem ele.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const rawListKey = 'health_control_profiles_list';

  PatientProfile buildProfile(String id, String name) => PatientProfile(
        id: id,
        name: name,
        birthDate: DateTime(2020, 1, 1),
        gender: 'Masculino',
        heightCm: 100,
        weightKg: 16,
        personalBestPef: 180,
        susCardNumber: '000',
        healthInsurance: '',
        insuranceCardNumber: '',
      );

  // Mesmo motivo do teste de HealthStorageService: a instância de
  // SharedPreferences cacheada pelo singleton não é atualizada por um
  // segundo SharedPreferences.setMockInitialValues(...) no meio da suíte —
  // então o backend mock é inicializado uma única vez aqui, e cada teste
  // escreve os dados através da mesma instância já cacheada.
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    HealthStorageService().clearMemoryCache();
  });

  Future<void> seedRawProfiles(List<String> rawList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(rawListKey, rawList);
  }

  testWidgets(
    '1. Corrupção + perfis saudáveis: lista continua acessível com banner de aviso não bloqueante',
    (tester) async {
      final arthur = buildProfile('child_a', 'Arthur Saccomani');
      await seedRawProfiles([
        jsonEncode(arthur.toJson()),
        '{"id": "child_b" INVALID JSON !!!',
      ]);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const CareContextScreen()),
      );
      await tester.pumpAndSettle();

      // Filho saudável continua visível e selecionável.
      expect(find.text('Arthur Saccomani'), findsOneWidget);
      // Aviso de corrupção presente, mas não bloqueante (mensagem singular
      // ou plural conforme a contagem — aqui basta o trecho comum a ambas).
      expect(find.textContaining('estar corrompidos'), findsOneWidget);
      // Nunca o empty state de "instalação nova" quando há filho saudável.
      expect(find.text('Vamos começar pelo cadastro da criança.'), findsNothing);
    },
  );

  testWidgets(
    '2. Só corrupção, nenhum perfil saudável: estado de erro distinto, nunca o empty state de instalação nova',
    (tester) async {
      await seedRawProfiles(['{{{ NOT VALID JSON AT ALL']);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const CareContextScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os perfis'), findsOneWidget);
      expect(find.text('Vamos começar pelo cadastro da criança.'), findsNothing);
    },
  );
}
