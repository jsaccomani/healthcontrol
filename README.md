# 🫁 AsmaControl Pro

> **Copiloto de Saúde Digital, Prontuário Pediátrico e Reabilitação Respiratória Offline-First**

O **AsmaControl Pro** é um ecossistema móvel e clínico voltado para o monitoramento contínuo, manejo de crises, profilaxia e reabilitação respiratória de pacientes pediátricos asmáticos (com foco na faixa de 4 a 11 anos).

Desenvolvido para operar em regime **Offline-First**, o sistema assegura que todas as decisões clínicas e cálculos vitais sejam executados no dispositivo sem latência e sem dependência de conectividade de rede, atendendo rigorosamente aos protocolos da **GINA**, **PCDT**, **CFF**, **AMIB**, **CFM** e **LGPD**.

---

## 🎯 Pilares e Regras Clínicas Mandatórias

### 1. Pico de Fluxo Expiratório (PFE / Peak Flow) - Protocolo CFF
- Coleta de 3 tentativas de sopro obrigatórias (`pef_1`, `pef_2`, `pef_3`).
- Registro do **maior valor absoluto**.
- Alerta visual de instabilidade técnica se a diferença absoluta entre o maior e o menor sopro exceder **20 L/min** (má vedação da máscara/bocal ou tosse).

### 2. Zonas do Plano de Ação (GINA / PCDT)
Calculadas a partir da razão `(PFE Medido / Melhor PFE Pessoal) * 100`:
- 🟢 **Zona Verde (≥ 80%):** Asma controlada. Manutenção preventiva de rotina.
- 🟡 **Zona Amarela (50% a 79%):** Início de crise. Alerta de resgate com SABA (broncodilatador de curta ação).
- 🔴 **Zona Vermelha (< 50%):** Crise severa. Disparo imediato de rota de emergência via GPS (Google Maps / Waze / Apple Maps) para o Pronto-Socorro ou UPA mais próxima.

### 3. Técnica Inalatória com Espaçador (GINA 2026 - pMDI)
- Checklists compulsórios ao registrar uso de spray pressurizado:
  1. *Agitação vigorosa do inalador em suspensão.*
  2. *Vedação hermética da máscara ou bocal ao rosto.*

### 4. Profilaxia de Candidíase Orofaríngea (Higiene Pós-ICS)
- Sempre que houver uso de Corticoide Inalatório (ICS), o sistema agenda uma notificação forçando o paciente/cuidador a confirmar o enxágue bucal ou escovação dos dentes para prevenir candidíase ("sapinho") e disfonia.

### 5. Segurança Fisioterapêutica em Reabilitação Motora (AMIB)
- Bloqueio sistêmico compulsório de exercícios caso os parâmetros vitais ultrapassem os limites de segurança:
  - `SpO2 < 88%`
  - `FiO2 > 0.60` (60%)
  - `PEEP > 10 cmH2O`
  - `Frequência Respiratória > 45 rpm`
- Classificação do paciente nos **Níveis 1 a 5 de Mobilização AMIB**.

### 6. Questionário c-ACT (Childhood Asthma Control Test)
- Questionário gamificado para crianças de 4 a 11 anos (score 0 a 27).
- Scores `≤ 19` indicam asma não controlada e disparam alerta de revisão clínica.

---

## 🏛️ Arquitetura de Dados & Event Sourcing (Firestore NoSQL)

O backend adota o padrão **Event Sourcing** imutável, atendendo ao **Art. 69 do Código de Ética Médica** e à **Resolução CFM nº 1.331/89** (guarda de prontuário por no mínimo 20 anos):

- `/patients/{id}`: Dados cadastrais, Cartão SUS, Convênio, Peso, Altura, Melhor PFE Pessoal e Comorbidades.
- `/patients/{id}/event_log/{id}`: Subcoleção *append-only* (apenas criação permitida via `firestore.rules`), gravando payloads imutáveis:
  - `DAILY_CLINICAL_DIARY`
  - `CACT_SCORE`
  - `CLINICAL_CRISIS`

---

## 📂 Estrutura do Repositório

```text
asmacontrol-pro/
├── README.md
├── PROMPT_MESTRE.md            # System Prompt completo para Copiloto de IA
├── firestore.rules             # Regras de segurança Cloud Firestore (CFM/LGPD 20 anos)
├── docs/
│   ├── CLINICAL_SPECS.md       # Especificações clínicas e regulatórias completas
│   └── ARCHITECTURE.md         # Diagrama e padrões de persistência Offline-First
├── packages/
│   └── clinical_core/          # Pacote Dart isolado com lógica de domínio pura
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── clinical_core.dart
│       │   └── src/
│       │       ├── models/
│       │       ├── peak_flow_calculator.dart
│       │       ├── action_zones.dart
│       │       ├── amib_safety_screener.dart
│       │       ├── cact_calculator.dart
│       │       └── lme_tracker.dart
│       └── test/
│           └── clinical_core_test.dart
└── web_prototype/              # Protótipo PWA para testes offline no iPhone / Safari
    └── index.html
```

---

## 🚀 Como Executar

### Testes Unitários do Módulo Clínico (Dart)
```bash
cd packages/clinical_core
dart test
```

### Teste do Protótipo Web / PWA no iPhone
1. Abra `web_prototype/index.html` no Safari do iOS.
2. Toque em **Compartilhar** > **Adicionar à Tela de Início** (Add to Home Screen).
3. O app funcionará 100% offline.
