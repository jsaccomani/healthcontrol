# 🏗️ Arquitetura de Software e Dados - Asma Control & Asma Control Pro

> **Ecossistema Clínico Digital Pediátrico: Asma Control (Mães & Famílias) e Asma Control Pro (Médicos & Clínicas).**

---

## 1. Visão Geral do Ecossistema

```
+---------------------------------------------------------------------------------+
|                       ASMA CONTROL (APLICATIVO GRATUITO DAS MÃES)               |
|                                                                                 |
|   +-----------------------+     +-----------------------+     +---------------+ |
|   |  Diário & 3 Sopros    | <-> |  Fisioterapia AMIB    | <-> | Modo Emergência| |
|   |  (PFE, SpO2, Bochecho)|     |  (Voldyne, Shaker)    |     | (Pronto-Soc)  | |
|   +-----------------------+     +-----------------------+     +---------------+ |
|                                             |                                   |
|   +---------------------------------------------------------------------------+ |
|   |          MOTOR DE VERSIONAMENTO CLÍNICO & AUDITORIA SHA-256               | |
|   |  - Cada controle gera uma versão imutável (v1.0.1, v1.0.2, v1.0.3...)     | |
|   |  - Encadeamento criptográfico: previous_hash -> hash (CFM 1.331/89)       | |
|   +---------------------------------------------------------------------------+ |
+---------------------------------------------------------------------------------+
                                       │
                              (Chave de Acesso / Token)
                                       ▼
+---------------------------------------------------------------------------------+
|                  ASMA CONTROL PRO (PAINEL SAAS DOS MÉDICOS & CLÍNICAS)          |
|                                                                                 |
|   - Assinatura Mensal B2B para Pneumopediatras, Pediatras e Fisioterapeutas     |
|   - Pareamento instantâneo via Chave de Compartilhamento (ex: AC-7842)          |
|   - Monitoramento longitudinal em tempo real de crises e descompensações        |
|   - Rastreamento de laudos LME de Alto Custo (Dupixent, Nucala, Fasenra, Xolair)|
+---------------------------------------------------------------------------------+
```

---

## 2. Mecanismo de Versionamento Clínico dos Lançamentos de Saúde

Cada registro de saúde realizado pela mãe, pai ou cuidador é tratado como uma **versão imutável do prontuário**:

### 2.1. Estrutura do Lançamento Versionado (`HealthControlEntry`):
- `version_tag`: `v1.0.1`, `v1.0.2`, `v1.0.3` (incremental a cada nova medição).
- `sequence_number`: Inteiro sequencial para ordenação precisa.
- `author_name` & `author_role`: Quem registrou (ex: "Mãe (Juliana) - Cuidadora Principal").
- `timestamp`: Data/hora exata em ISO 8601 UTC.
- `peak_flow`: 3 tentativas de sopro (`peak_flow_attempts`), maior valor registrado (`peak_flow_best`) e zona calculada.
- `spo2`: Saturação de oxigênio com alerta caso `< 92%`.
- `medications`: Medicamentos utilizados (Resgate, Manutenção, Corticoide Oral, Biológico).
- `mouth_rinse_completed`: Confirmação obrigatória de higiene bucal para prevenção de sapinho.
- `physiotherapy`: Dados da sessão respiratória (Voldyne, Shaker, POWERbreathe) com trava AMIB.
- `requires_rescue_followup`: Ativação do alarme de reavaliação de 20 minutos.

### 2.2. Encadeamento Criptográfico SHA-256 (`ClinicalEventLog`):
```dart
String computeHash(...) {
  final raw = '$previousHash|$eventId|$patientId|$version|$sequenceNumber|'
      '${eventType.code}|${timestamp.toIso8601String()}|${jsonEncode(payload)}';
  return sha256.convert(utf8.encode(raw)).toString();
}
```
Isso garante **integridade absoluta**, atendendo ao Artigo 69 do Código de Ética Médica e à Resolução CFM nº 1.331/89 (guarda de prontuário inalterável por 20 anos).

---

## 3. Modelo de Negócio e Segurança de Acesso

1. **Asma Control (Mães & Cuidadores):**
   - 100% Gratuito.
   - Offline-First (funciona sem sinal de celular).
   - Dados criptografados no aparelho.
2. **Asma Control Pro (Médicos & Clínicas):**
   - Assinatura mensal recorrente (SaaS).
   - O médico fornece chaves de pareamento aos seus pacientes.
   - Visão agregada de população de risco e alertas de exacerbação.
