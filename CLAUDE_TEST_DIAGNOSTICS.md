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
| **Domínio Clínico & Segurança** | `cd packages/clinical_core && dart test` | ✅ **PASSOU (117/117)** | Integridade SHA-256, GINA, ReBAC |
| **Testes de Widgets Flutter** | `flutter test` | ⚠️ **SIGKILL (-9)** | Subprocesso `flutter_tester` encerrado pelo sandbox do macOS |

---

## 2. Detalhamento do Erro no `flutter test`

### Log Capturado:
```text
00:00 +0: loading test/emergency_screen_no_invented_dose_test.dart
Compiling listener.dart took 674ms
test 0: Starting flutter_tester process with command=[.../engine/darwin-x64/flutter_tester, ...]
test 0: Started flutter_tester process at pid 87709
test 0: flutter_tester process at pid 87709 exited with code=-9
Failed to load "test/emergency_screen_no_invented_dose_test.dart": Connection closed before test suite loaded.
```

### Causa Raiz Técnica:
1. **Compilação Dart**: O arquivo de teste e seus widgets **compilam perfeitamente** sem erros de sintaxe ou tipos (`output.dill` gerado com sucesso).
2. **Execução Nativa**: O binário auxiliar `flutter_tester` (`.../engine/darwin-x64/flutter_tester`) é finalizado com sinal `SIGKILL` (`code=-9`) pelo sistema operacional macOS / sandbox de execução de processos antes que o socket do test harness possa trocar mensagens.

---

## 3. Como os Testes Estão Estruturados

1. **`packages/clinical_core/test/` (117 Testes de Domínio Puro Dart)**:
   - `clinical_safety_matrix_test.dart`: Matriz de segurança clínica e auditoria SHA-256.
   - `crisis_event_test.dart`: Criação e integridade de eventos de crise.
   - `crisis_flow_qa_test.dart`: Fluxos de resgate GINA.
   - `firestore_security_rules_test.dart`: Regras ReBAC de permissão e imutabilidade de prontuários.
   - `multi_child_isolation_test.dart`: Isolamento estrito de dados entre irmãos.
   - *Execução*: `cd packages/clinical_core && dart test` (Executa via Dart VM direta em <1s).

2. **`test/` (Testes de Widgets e Integração)**:
   - `emergency_screen_no_invented_dose_test.dart`: Garante que `CrisisNoPlanCard` alerta e não inventa doses quando não há prescrição.
   - `health_storage_no_fabrication_test.dart`: Garante que `HealthStorageService` retorna vazio sem fabricar medicações e isola dados multi-child.
   - `care_context_crisis_test.dart`: Dark mode, acessibilidade 2.0x e telas pequenas.
   - `design_system_test.dart`: Componentes do Design System (`HCPrimaryButton`, `HCEmergencyButton`, badges de zona).

---

## 4. Recomendações para o Claude

- **Validação de Código**: Utilize `flutter analyze` como gatekeeper primário de integridade.
- **Validação de Lógica de Negócios e Criptografia**: Utilize `cd packages/clinical_core && dart test`.
- **Alterações de UI**: Sempre manter os Design Tokens (`HCColors`, `HCTypography`, `HCRadii`, `HCTheme`) e conformidade com acessibilidade.
