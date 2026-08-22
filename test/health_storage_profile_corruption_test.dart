import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clinical_core/clinical_core.dart';
import 'package:health_control/core/storage/health_storage_service.dart';

/// Regressão: um único perfil salvo com JSON corrompido não pode apagar a
/// visibilidade dos demais perfis saudáveis (getAllProfiles parseava tudo
/// num único try/catch em volta do .map(), então uma falha isolada
/// descartava a lista inteira). Também cobre a distinção entre "nenhum
/// perfil cadastrado" (estado vazio legítimo) e "havia perfis mas alguns
/// falharam ao carregar" (erro real de integridade de dados).
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

  late HealthStorageService storageService;

  // HealthStorageService é singleton e cacheia a própria instância de
  // SharedPreferences (para performance em produção). Chamar
  // SharedPreferences.setMockInitialValues(...) de novo no meio da suíte
  // NÃO é percebido por essa instância já cacheada — por isso o backend
  // mock é inicializado apenas UMA VEZ aqui, e cada teste escreve dados
  // novos através da MESMA instância (via SharedPreferences.getInstance(),
  // que retorna a instância já cacheada) em vez de trocar o backend inteiro.
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    HealthStorageService().clearMemoryCache();
    storageService = HealthStorageService();
  });

  Future<void> seedRawProfiles(List<String> rawList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(rawListKey, rawList);
  }

  Future<void> clearRawProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(rawListKey);
  }

  group('HEALTH STORAGE SERVICE: CORRUPÇÃO PARCIAL NÃO APAGA PERFIS SAUDÁVEIS', () {
    test('1. 3 perfis válidos + 1 corrompido: getAllProfiles retorna os 3 saudáveis, nunca lista vazia', () async {
      final healthy = [
        buildProfile('child_a', 'Arthur'),
        buildProfile('child_b', 'Beatriz'),
        buildProfile('child_c', 'Carlos'),
      ];
      await seedRawProfiles([
        ...healthy.map((p) => jsonEncode(p.toJson())),
        '{"id": "child_d", "name": "Corrompido" INVALID_JSON !!!',
      ]);

      final profiles = await storageService.getAllProfiles();

      expect(profiles.length, equals(3));
      expect(profiles.map((p) => p.id).toSet(), equals({'child_a', 'child_b', 'child_c'}));
    });

    test('2. Sinal de corrupção reflete exatamente 1 perfil corrompido (não 0, não 4)', () async {
      final healthy = [
        buildProfile('child_a', 'Arthur'),
        buildProfile('child_b', 'Beatriz'),
        buildProfile('child_c', 'Carlos'),
      ];
      await seedRawProfiles([
        ...healthy.map((p) => jsonEncode(p.toJson())),
        '{"id": "child_d", "name": "Corrompido" INVALID_JSON !!!',
      ]);

      await storageService.getAllProfiles();

      expect(storageService.lastLoadCorruptedProfilesCount, equals(1));
    });

    test('3. Só corrompido, nada saudável: NÃO cai no mesmo caminho de "nenhum perfil cadastrado"', () async {
      await seedRawProfiles([
        '{{{ NOT VALID JSON AT ALL',
        '{"id": "child_z" ANOTHER BROKEN ONE',
      ]);

      final profiles = await storageService.getAllProfiles();

      // A lista fica vazia como no caso de instalação nova, mas o sinal de
      // corrupção precisa diferenciar os dois cenários — é o que a UI usa
      // para nunca mostrar o empty state de "instalação nova" quando na
      // verdade havia dados que falharam ao carregar.
      expect(profiles, isEmpty);
      expect(storageService.lastLoadCorruptedProfilesCount, equals(2));
    });

    test('4. Nenhum perfil salvo (instalação nova real): lista vazia E zero corrupção', () async {
      await clearRawProfiles();

      final profiles = await storageService.getAllProfiles();

      expect(profiles, isEmpty);
      expect(storageService.lastLoadCorruptedProfilesCount, equals(0));
    });
  });
}
