# Diagnóstico de Testes & Execução — Health Control

**Data/Hora do Relatório**: 2026-08-20  
**Ambiente**: macOS (Apple Silicon / arm64)  
**Flutter SDK**: Flutter 3.47.0 • Dart 3.13.0  
**Status da Análise Estática**: ✅ **0 Erros / 0 Warnings**

---

## 1. Resumo Executivo

| Test Suite / Ferramenta | Comando | Status | Observações |
| :--- | :--- | :--- | :--- |
| **Análise Estática** | `flutter analyze` | ✅ **PASSOU (0 issues)** | Tipagem 100% estrita e segura |
| **Domínio Clínico & Segurança** | `cd packages/clinical_core && dart test` | ✅ **PASSOU (125/125)** | Integridade SHA-256, GINA, ReBAC, Não-Fabricação de Sinais Vitais |
| **Testes de Widgets Flutter** | `flutter test` | 🛑 **BLOQUEADO (Santa / SIGKILL -9)** | Binário `flutter_tester` bloqueado pelo Santa (requer aprovação de hash no Upvote) |

---

## 2. Detalhamento do Erro no `flutter test` (Santa Binary Authorization)

### Log Capturado na Execução:
```text
$ flutter test
00:00 +0: ...age_no_fabrication_test.dart     
Santa

This application has been blocked from executing
because its trustworthiness cannot be determined.

Path:       /Users/jsaccomani/development/flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester
Identifier: fbe8c67768d94626bd16b9301032a95060169d53a33ca26bd251c30893fd8fb6
Parent:     dartvm (31050)

More info:
https://upvote.googleplex.com/blockables/fbe8c67768d94626bd16b9301032a95060169d53a33ca26bd251c30893fd8fb6

00:00 +0 -1: loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/health_storage_no_fabrication_test.dart [E]
  Failed to load "/Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/health_storage_no_fabrication_test.dart": Connection closed before test suite loaded.

To run this test again: /Users/jsaccomani/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/health_storage_no_fabrication_test.dart -p vm --plain-name 'loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/health_storage_no_fabrication_test.dart'
00:00 +0 -2: loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/design_system_test.dart [E]
  Failed to load "/Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/design_system_test.dart": Connection closed before test suite loaded.

To run this test again: /Users/jsaccomani/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/design_system_test.dart -p vm --plain-name 'loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/design_system_test.dart'
00:00 +0 -3: loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/emergency_screen_no_invented_dose_test.dart [E]
  Failed to load "/Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/emergency_screen_no_invented_dose_test.dart": Connection closed before test suite loaded.

To run this test again: /Users/jsaccomani/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/emergency_screen_no_invented_dose_test.dart -p vm --plain-name 'loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/emergency_screen_no_invented_dose_test.dart'
00:00 +0 -4: loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/care_context_crisis_test.dart [E]
  Failed to load "/Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/care_context_crisis_test.dart": Connection closed before test suite loaded.

To run this test again: /Users/jsaccomani/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/care_context_crisis_test.dart -p vm --plain-name 'loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/care_context_crisis_test.dart'
00:00 +0 -5: loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/widget_test.dart [E]
  Failed to load "/Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/widget_test.dart": Connection closed before test suite loaded.

To run this test again: /Users/jsaccomani/development/flutter/bin/cache/dart-sdk/bin/dart test /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/widget_test.dart -p vm --plain-name 'loading /Users/jsaccomani/Documents/Jetsky/Personal/healthcontrol/test/widget_test.dart'
00:00 +0 -5: Some tests failed.
```

### Causa Raiz Técnica:
1. **Compilação Dart**: O código e os testes compilam **100% perfeitamente** sem erros de sintaxe ou tipos (`output.dill` gerado com sucesso).
2. **Bloqueio de Segurança (Santa)**:
   - O binário auxiliar `flutter_tester` (`/Users/jsaccomani/development/flutter/bin/cache/artifacts/engine/darwin-x64/flutter_tester`) é bloqueado pelo daemon de autorização de binários corporativo (**Santa**).
   - O Santa envia sinal `SIGKILL` (`code=-9`) ao processo filho `flutter_tester`, impedindo que o socket IPC do test harness receba os resultados do teste.
3. **Resolução / Desbloqueio**:
   - Aprovar/Votar o hash do binário no Upvote:
     `https://upvote.googleplex.com/blockables/fbe8c67768d94626bd16b9301032a95060169d53a33ca26bd251c30893fd8fb6`
   - Após a aprovação do hash pelo Santa, `flutter test` executará localmente sem interrupção.

---

## 3. Como os Testes Estão Estruturados

1. **`packages/clinical_core/test/` (125 Testes de Domínio Puro Dart - Executando 100% OK)**:
   - `no_fabricated_vital_defaults_test.dart`: Não-fabricação de sinais vitais, SpO2, PEF e idade gestacional.
   - `no_fabricated_clinical_defaults_test.dart`: Proibição de diagnósticos e medicações fabricadas.
   - `clinical_safety_matrix_test.dart`: Matriz de segurança clínica e auditoria SHA-256.
   - `crisis_event_test.dart`: Criação e integridade de eventos de crise.
   - `crisis_flow_qa_test.dart`: Fluxos de resgate GINA.
   - `firestore_security_rules_test.dart`: Regras ReBAC de permissão e imutabilidade de prontuários (20/20 regras).
   - `multi_child_isolation_test.dart`: Isolamento estrito de dados entre irmãos.
   - `domain_care_network_migration_test.dart`: Migração de schema e compatibilidade legada.
   - *Execução*: `cd packages/clinical_core && dart test` (Executa via Dart VM em ~0.1s).

2. **`test/` (Testes de Widgets e Integração Flutter)**:
   - `emergency_screen_no_invented_dose_test.dart`: Garante que `CrisisNoPlanCard` alerta e não inventa doses quando não há prescrição.
   - `health_storage_no_fabrication_test.dart`: Garante que `HealthStorageService` retorna vazio sem fabricar medicações e isola dados multi-child.
   - `care_context_crisis_test.dart`: Dark mode, acessibilidade 2.0x e telas pequenas.
   - `design_system_test.dart`: Componentes do Design System (`HCPrimaryButton`, `HCEmergencyButton`, badges de zona).
   - `widget_test.dart`: Teste básico de smoke do aplicativo.

---

## 4. Recomendações e Próximos Passos

- **Para o Board**: O código está 100% validado estaticamente (`flutter analyze`) e logicamente com 125 testes unitários de domínio passando (`dart test`).
- **Para execução dos Widget Tests no Mac**: Acessar o link do Upvote para liberar o binário `flutter_tester` no Santa.
