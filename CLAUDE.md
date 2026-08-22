# Health Control — Guia de Arquitetura e Desenvolvimento para Claude

Bem-vindo ao **Health Control: Asma** (Copiloto Pediátrico de Asma Grave e Reabilitação Respiratória).
Este documento orienta o Claude a trabalhar em perfeita harmonia com o projeto, mantendo os padrões de engenharia de software e segurança clínica.

**Antes de qualquer alteração, leia também:** `HEALTH_CONTROL_CONTEXT.md` (missão, arquitetura-alvo, roadmap) e, se existir, `CLAUDE_TEST_DIAGNOSTICS.md` (estado conhecido do ambiente de testes). Esses documentos têm prioridade sobre suposições — se o código não bater com o que eles descrevem, o código é a fonte de verdade sobre o estado atual, mas a divergência deve ser sinalizada, não ignorada.

---

## 0. PRINCÍPIO NÃO NEGOCIÁVEL (leia antes de tudo o resto)

Este é um software relacionado à saúde. Integridade de dados e segurança clínica têm prioridade absoluta sobre velocidade de implementação ou aparência de interface.

- **Nunca inventar informação clínica.** Nenhum dado de fallback pode parecer um dado real — nem um nome de médico genérico, nem uma dose "padrão", nem um SpO2 "normal" quando não foi medido, nem um perfil de paciente placeholder.
- **Nunca inferir prescrição.** Medicação, dose e posologia vêm sempre e apenas de uma prescrição real cadastrada.
- **Nunca apresentar dado não verificado como verificado.** CRM + nome do médico preenchidos não significam receita autenticada (ver `PrescriptionVerificationStatus`, default sempre `unknown`).
- **Nunca misturar dados entre pacientes.** `patientId` é a fronteira de isolamento; nunca usar o paciente atualmente selecionado como fonte implícita para outro.
- **Estado vazio é estado legítimo.** Quando não há dado real, a UI deve mostrar isso claramente (ícone + mensagem + CTA quando fizer sentido) — nunca preencher com algo plausível para não parecer incompleto.

Histórico: uma auditoria completa (ver `CLAUDE_TEST_DIAGNOSTICS.md` e o Log do Projeto) encontrou e corrigiu múltiplas violações desse princípio (histórico e prescrição fabricados para paciente vazio, dose de resgate inventada em crise, defaults clínicos fabricados no modelo de domínio, simulação falsa de OCR/câmera, referência de PFE e SpO2 fabricados, perfil demo com dados reais pré-carregado). **Antes de adicionar qualquer fallback, default, ou "valor razoável" para um campo clínico ausente, pare e pergunte: isso poderia ser confundido com um dado real por um cuidador sob estresse?** Se sim, não fabricar — usar vazio/null/estado explícito de "não informado".

---

## 1. Comandos Essenciais

```bash
# Análise estática (deve SEMPRE permanecer em 0 erros / 0 warnings)
flutter analyze

# Execução de todos os testes de domínio clínico e segurança criptográfica
# (Dart puro, sem engine Flutter — roda em segundos)
cd packages/clinical_core && dart test

# Testes de widget (dark mode, acessibilidade, fluxos de tela completos)
flutter test

# Rodar a aplicação em modo Web ou Emulador
flutter run -d chrome
```

**Nota sobre `flutter test` local:** em máquinas com política de segurança corporativa restritiva (ex: Google Santa bloqueando binários por hash), `flutter_tester` pode falhar com SIGKILL mesmo com código correto. Isso é ambiente, não bug — confirmar sempre via `flutter analyze` + `dart test` primeiro, e usar o workflow de CI (`.github/workflows/ci.yml`, GitHub Actions) como fonte de verdade para os testes de widget quando o ambiente local bloquear.

---

## 2. Arquitetura do Projeto

O projeto é dividido em **duas camadas estritas**:

```
healthcontrol/
├── packages/
│   └── clinical_core/          # Camada de Domínio Puro Dart (Zero dependência de UI/Flutter)
│       ├── lib/src/models/     # Modelos imutáveis (PatientProfile, LegalGuardian, Caregiver, PrescriptionRecord, etc.)
│       ├── lib/src/prescription_verification_service.dart  # Verificação de autenticidade (default sempre unknown)
│       ├── lib/src/event_log/  # Auditoria imutável SHA-256 (ClinicalEventLog)
│       ├── lib/src/rebac/      # Controle de acesso baseado em relacionamento (ReBAC)
│       ├── lib/src/action_zones.dart # Zonas GINA/PCDT (Verde, Amarela, Vermelha)
│       └── test/               # Testes unitários automatizados (domínio, isolamento multi-paciente, não-fabricação)
│
└── lib/                        # Camada de Apresentação Flutter
    ├── core/
    │   ├── design_system/      # Design Tokens (HCColors, HCTypography, HCRadii, HCShadows, HCTheme)
    │   └── storage/            # HealthStorageService (Cache em memória + SharedPreferences)
    └── features/
        ├── care_context/       # Tela de contexto ("Quem você vai cuidar hoje?") + seleção rápida de filho
        ├── crisis/              # CrisisScreen — Modo Crise com patientId travado, divulgação progressiva, timer GINA
        ├── home/                # Dashboard diário do cuidador e ações rápidas
        ├── prescription/       # Captura de receita, revisão humana obrigatória antes de salvar
        ├── profile/             # Perfil Clínico Vivo (Prontuário escaneável em várias seções)
        ├── cact/                # Questionário de Controle de Asma na Criança (4-11 anos)
        ├── physio/              # Fisioterapia respiratória e triagem hemodinâmica AMIB
        └── pro_connect/         # Pareamento ReBAC com médico assistente (Health Control Pro, futuro)
```

`emergency/screens/emergency_screen.dart` existe apenas como redirecionador retrocompatível para `CrisisScreen` — não usar para código novo, e `patientId` é obrigatório nele (nunca aceitar fallback implícito nesse ponto).

---

## 3. Invariantes Clínicos e Regras de Ouro

1. **OCR/captura é apenas extração, nunca fonte de verdade:**
   - Se não implementado de verdade (ex: sem SDK de câmera/OCR real integrado), NUNCA simular sucesso — dizer claramente "ainda não disponível" e direcionar para cadastro manual. Não criar preview de arquivo fictício nem animação de progresso fake.
   - Todo texto extraído passa por revisão humana explícita antes de virar prescrição salva.
   - Sempre identificar a origem do dado: "cadastrado pelo cuidador" vs. "verificado por autoridade real" — nunca deixar implícito.

2. **Modo Crise (Operação sob Pânico):**
   - `patientId` explícito e travado — nunca trocar de paciente casualmente dentro da tela de crise.
   - Se não houver plano de resgate prescrito, mostrar isso claramente (nunca inventar medicação/dose).
   - O temporizador de reavaliação deriva do timestamp absoluto (`reassessmentAt`), nunca de contador em memória sujeito a pausa em background.

3. **Multi-Child & Isolamento de Dados:**
   - Cada filho possui seu próprio namespace de chaves e hash-chain SHA-256. Nunca misturar dados ou eventos entre irmãos.
   - Ao criar uma criança nova: histórico, prescrições, medicações e medições começam vazios. Apenas contatos/responsáveis podem ser herdados por conveniência, e só quando já existe outro perfil de onde herdar.

4. **Rede de Cuidado Inclusiva (Schema v2):**
   - Suporte a múltiplos responsáveis legais (`LegalGuardian`) e cuidadores (`Caregiver`) com níveis de acesso explícitos.

5. **Design Tokens:**
   - Utilize sempre `context.hcTheme` e `HCTypography`/`HCRadii`/`HCShadows` para garantir suporte a Dark Mode e acessibilidade de alto contraste. Sombra elevada (`HCShadows.elevated`) nunca aparece em dark mode — usar borda no lugar.

---

## 4. Fluxo de Trabalho com Claude (chat) como PM/Auditor Técnico

Este projeto é conduzido em conjunto com uma instância de Claude fora deste ambiente (chat/consultoria), que atua como PM e auditor clínico. Convenções:

- Tarefas maiores chegam como **prompt formal** (contexto, causa raiz, arquivos, estratégia, validação obrigatória) — seguir exatamente o escopo descrito, não expandir por conta própria sem sinalizar.
- Toda branch nova segue o padrão `tipo/descricao-curta` (ex: `fix/patient-switch-state`, `feat/premium-visual-direction`).
- **Todo prompt termina em commit + push da branch** — nunca deixar trabalho concluído sem commitar e dar push; isso já causou dessincronização real neste projeto no passado.
- Antes de declarar uma tarefa concluída: `flutter analyze` limpo, `dart test` em `packages/clinical_core` passando, e teste de regressão específico para o bug/feature em questão.
- Se durante a implementação você encontrar uma violação do princípio da Seção 0 fora do escopo original do prompt, **sinalizar explicitamente no commit/PR**, não corrigir silenciosamente sem contexto nem ignorar.

---

## 5. Diretrizes de Edição de Código

- Sempre mantenha os comentários explicativos e docstrings, especialmente os que documentam *por que* uma decisão de segurança clínica foi tomada (não só o quê).
- Antes de concluir qualquer tarefa, certifique-se de que `flutter analyze` reporta **0 issues** e que os testes de `packages/clinical_core` continuem passando.
- Não reescrever código funcional sem necessidade; não criar abstrações por estética; não introduzir dependências novas sem justificar explicitamente (ex: fonte customizada, pacote de terceiros).
