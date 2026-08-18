# 🚀 Guia Completo de Testes, Deploy (Android & iOS) e Hospedagem em Nuvem

> **Health Control: Asma & Health Control Pro**

---

## 📱 1. Como Você Pode ir Testando AGORA

Você tem 3 formas práticas para testar o aplicativo imediatamente:

### Forma 1: Testar no Navegador (Web / PWA Instantâneo)
Você pode abrir o protótipo funcional diretamente no seu navegador (Chrome, Safari, Edge) no Mac:
```bash
open web_prototype/index.html
```
- Você pode simular o celular pressionando `F12` ou `Cmd + Option + I` no Chrome e ativando o **Device Toolbar** (ícone de celular).

### Forma 2: Testar o App Flutter no seu Computador (Chrome / Desktop)
```bash
cd /Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro
export PATH="/Users/jsaccomani/development/flutter/bin:$PATH"
flutter run -d chrome
```

### Forma 3: Testar Diretamente no seu Celular Físico (via Cabo USB ou Wi-Fi)
1. **No Android:**
   - Conecte o celular via cabo USB.
   - No celular, ative a **Depuração USB** (em *Opções do Desenvolvedor*).
   - Execute no terminal:
     ```bash
     flutter run
     ```
   - O app será instalado e abrirá direto na tela do seu celular com *Hot Reload* (alterações no código refletem em segundos).
2. **No iPhone (iOS):**
   - Conecte o iPhone no Mac via cabo.
   - Abra a pasta `ios/` no **Xcode**.
   - Selecione seu dispositivo físico e clique no botão **Play (Run)**.

---

## 🏪 2. Como Funciona o Deploy nas Lojas (Google Play e Apple App Store)

### 🤖 A. No Android (Google Play Store)
1. **Conta de Desenvolvedor:**
   - Criar uma conta no [Google Play Console](https://play.google.com/console).
   - Pagamento de taxa única de **US$ 25** (vitalícia).
2. **Geração da Chave de Assinatura (Keystore):**
   - Criamos uma chave privada para assinar o aplicativo de forma segura.
3. **Geração do Paciente de Produção (AAB):**
   ```bash
   flutter build appbundle --release
   ```
   - Isso gera o arquivo `build/app/outputs/bundle/release/app-release.aab`.
4. **Trilhas de Teste (Testes Fechados / Família):**
   - No Google Play Console, você pode criar uma **Trilha de Teste Fechado** adicionando os e-mails da sua família e amigos.
   - Eles recebem um link da Play Store oficial para baixar o app antes de ele ser lançado para o público geral.
5. **Revisão e Publicação:**
   - Preencher a Ficha de Segurança de Dados da Play Store (declarando que dados de saúde são protegidos e há consentimento dos pais).
   - A aprovação do Google costuma levar de 2 a 5 dias.

---

### 🍏 B. No iOS (Apple App Store & TestFlight)
1. **Conta de Desenvolvedor Apple:**
   - Assinatura do [Apple Developer Program](https://developer.apple.com/programs/).
   - Custo: **US$ 99 por ano**.
2. **Testes com TestFlight (Recomendado antes da loja):**
   - O **TestFlight** é a plataforma da Apple para você e até 10.000 pessoas testarem o app no iPhone.
   - Você gera o build no Xcode (`Archive` -> `Distribute App` -> `App Store Connect`).
   - O app fica disponível no aplicativo TestFlight do seu iPhone e da sua esposa, recebendo atualizações com 1 clique.
3. **Revisão da Apple (Diretrizes de Saúde / Guideline 5.1.1):**
   - A Apple exige que aplicativos de saúde tenham:
     - Política de Privacidade com link público.
     - Aviso / Disclaimer Médico em destaque informando que o app não substitui atendimento de urgência.
     - Informações claras sobre onde e como os dados são guardados.

---

## ☁️ 3. Onde Ter a Nuvem para Hospedar os Dados?

Você tem duas etapas claras de infraestrutura:

### Etapa 1: Fase Atual (MVP Familiar / Offline-First)
- **Custo de Nuvem:** **R$ 0,00**.
- **Onde ficam os dados:** 100% no próprio celular (armazenamento local protegido por criptografia AES-256).
- **Vantagem:** Privacidade absoluta, funciona no pronto-socorro mesmo sem sinal de internet ou Wi-Fi.

### Etapa 2: Fase Conectada / Health Control Pro (Médicos & Clínicas)
Para permitir que o médico acerte o pareamento via chave (`AC-7842`) e veja o prontuário em tempo real, recomendamos:

#### 🥇 Opção Recomendada: Google Cloud / Firebase (Firestore NoSQL)
- **Região do Servidor:** `southamerica-east1` (**São Paulo, Brasil**).
  - *Por que São Paulo?* Conformidade absoluta com a **LGPD**, mantendo dados sensíveis de saúde em território nacional.
- **Segurança de Acesso:** O arquivo [`firestore.rules`](file:///Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro/firestore.rules) que já criamos no repositório bloqueia qualquer acesso não autorizado e impede deleção/adulteração de histórico.
- **Custo:**
  - **Plano Spark (Gratuito):** Até 50.000 leituras/dia, 20.000 escritas/dia e 1 GB de armazenamento. É mais do que suficiente para centenas de pacientes ativos sem pagar nada.
  - **Plano Blaze (Pay as you go):** Quando tiver clínicas assinando o Pro, você só paga o excedente (centavos de dólar por milhão de requisições).

#### 🥈 Opção Alternativa: Supabase (PostgreSQL Gerenciado)
- Banco de dados relacional com *Row-Level Security (RLS)*.
- Plano gratuito inclui até 500 MB de banco de dados e autenticação social.

---

## 📋 4. Checklist Regulatório & LGPD

| Item | Status | Onde está implementado |
| :--- | :--- | :--- |
| **Disclaimer Médico** | ✅ Concluído | [`docs/TERMS_AND_PRIVACY_LGPD.md`](file:///Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro/docs/TERMS_AND_PRIVACY_LGPD.md) e Telas do App |
| **Consentimento de Menores (Art. 14 LGPD)** | ✅ Concluído | Consentimento dos pais para tratamento de dados |
| **Criptografia Local (AES-256)** | ✅ Concluído | [`HealthStorageService`](file:///Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro/lib/core/storage/health_storage_service.dart) |
| **Integridade CFM 20 Anos (SHA-256)** | ✅ Concluído | [`ClinicalEventLog`](file:///Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro/packages/clinical_core/lib/src/models/event_log.dart) |
| **Revogação de Chave de Médico** | ✅ Concluído | [`ProConnectScreen`](file:///Users/jsaccomani/Documents/Jetsky/Personal/asmacontrol-pro/lib/features/pro_connect/screens/pro_connect_screen.dart) |
