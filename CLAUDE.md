# Health Control — Guia de Arquitetura e Desenvolvimento para Claude

Bem-vindo ao **Health Control: Asma** (Copiloto Pediátrico de Asma Grave e Reabilitação Respiratória).
Este documento orienta o Claude a trabalhar em perfeita harmonia com o projeto, mantendo os padrões de engenharia de software e segurança clínica.

---

## 1. Comandos Essenciais

```bash
# Análise estática (deve SEMPRE permanecer em 0 erros / 0 warnings)
flutter analyze

# Execução de todos os testes de domínio clínico e segurança criptográfica
cd packages/clinical_core && dart test

# Rodar a aplicação em modo Web ou Emulador
flutter run -d chrome
```

---

## 2. Arquitetura do Projeto

O projeto é dividido em **duas camadas estritas**:

```
healthcontrol/
├── packages/
│   └── clinical_core/          # Camada de Domínio Puro Dart (Zero dependência de UI/Flutter)
│       ├── lib/src/models/     # Modelos imutáveis (PatientProfile, LegalGuardian, Caregiver, etc.)
│       ├── lib/src/event_log/  # Auditoria imutável SHA-256 (ClinicalEventLog)
│       ├── lib/src/rebac/      # Controle de acesso baseado em relacionamento (ReBAC)
│       ├── lib/src/action_zones.dart # Zonas GINA/PCDT (Verde, Amarela, Vermelha)
│       └── test/               # 117 testes unitários automatizados
│
└── lib/                        # Camada de Apresentação Flutter
    ├── core/
    │   ├── design_system/      # Design Tokens (HCColors, HCTypography, HCRadii, HCTheme)
    │   └── storage/            # HealthStorageService (Cache em memória + SharedPreferences)
    └── features/
        ├── care_context/       # Seleção rápida de filho e entrada de crise
        ├── home/               # Dashboard diário do cuidador e ações rápidas
        ├── crisis/             # Modo Crise (Operação em pânico, timer 20 min GINA, dose 3x)
        ├── prescription/       # Captura de receita, OCR não-bloqueante e revisão humana
        ├── profile/            # Perfil Clínico Vivo (Prontuário escaneável em 8 seções)
        ├── cact/               # Questionário de Controle de Asma na Criança (4-11 anos)
        ├── physio/             # Fisioterapia respiratória e triagem hemodinâmica AMIB
        └── pro_connect/        # Pareamento ReBAC com médico assistente (Health Control Pro)
```

---

## 3. Invariantes Clínicos e Regras de Ouro

1. **OCR é apenas Extração**:
   - Nunca transforme texto extraído via OCR diretamente em prescrição ativa sem confirmação e revisão humana explícita.
   - Sempre identifique a origem: `"Extraído da receita via OCR"` ou `"Cadastrado manualmente"`.

2. **Modo Crise (Operação sob Pânico)**:
   - O temporizador de reavaliação de 20 minutos deriva do timestamp absoluto (`reassessmentAt`), nunca de contadores em memória sujeitos a pausa em background.
   - Na 3ª dose consecutiva de resgate, exibir alerta clínico de **Asma Aguda Grave** com atalho para ligar 192 (SAMU).

3. **Multi-Child & Isolamento de Dados**:
   - Cada filho possui seu próprio namespace de chaves e hash-chain SHA-256. Nunca misture dados ou eventos entre irmãos.

4. **Rede de Cuidado Inclusiva (Schema v2)**:
   - Suporte a múltiplos responsáveis legais (`LegalGuardian`: mãe, pai, avós, tutores legais) e múltiplos cuidadores (`Caregiver`: babás, escola, tios) com níveis de acesso explícitos.

5. **Design Tokens**:
   - Utilize sempre `context.hcTheme` e `HCTypography` para garantir suporte perfeito a Dark Mode e acessibilidade de alto contraste.

---

## 4. Diretrizes de Edição de Código

- Sempre mantenha os comentários explicativos e docstrings.
- Antes de concluir qualquer tarefa, certifique-se de que `flutter analyze` reporta **0 issues** e que os testes de `packages/clinical_core` continuem passando.
