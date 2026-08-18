# 📚 Base de Conhecimento Clínico e Evidências: AsmaControl Pro

> **Consolidação de Diretrizes Internacionais, Nacionais, Fisioterapia Respiratória, Inteligência Clínica e Segurança da Informação.**

---

## 📑 Sumário Executivo de Fontes Integradas

| Seção | Domínio | Principais Referências & Diretrizes | Aplicação no AsmaControl Pro |
| :--- | :--- | :--- | :--- |
| **1** | **Diretrizes Globais de Asma** | • **GINA 2026 / OpenEvidence**<br>• **GINA 2025 Summary Guide**<br>• **NHLBI NAEPPCC (GRADE)** | • Classificação de Zonas (Verde, Amarela, Vermelha)<br>• Regimes SMART/MART e AIR (ICS + Broncodilatador rápido)<br>• Fatores de risco ambientais (ORACLE2) |
| **2** | **Protocolos Nacionais & Regulatórios** | • **PCDT Asma SUS (Conitec nº 1078/2025)**<br>• **Farmácia Cidadã / SES-MG (LME)**<br>• **ASBAI CERN POPs (2024)**<br>• **CFF (Conselho Federal de Farmácia)** | • Rastreamento de laudos de alto custo (Dupixent, Nucala, Fasenra, Xolair)<br>• Retenção de prontuário por 20 anos (CFM 1.331/89 / CFM 69)<br>• SOP de Peak Flow e tabela Leiner (1963) |
| **3** | **Fisioterapia & Reabilitação** | • **AMIB (Medicina Intensiva Brasileira)**<br>• **Dispositivos PEP/OPEP (Acapella, Shaker)**<br>• **Espirometria de Incentivo (Voldyne vs Respiron)**<br>• **TMI (Threshold / POWERbreathe)** | • Travas de segurança fisioterapêutica (SpO2, FR, desconforto)<br>• Higiene brônquica e prevenção de atelectasias<br>• Exercícios respiratórios lúdicos pediátricos |
| **4** | **Suporte à Decisão Clínica & IA** | • **KPMG/FICCI AI in Healthcare**<br>• **Mayo Clinic CDS (Jvion Study)**<br>• **Kaiser Permanente (AAM)**<br>• **Intermountain & Mount Sinai** | • Detecção precoce de descompensação (IA/Regras)<br>• Alertas preditivos pós-resgate (Loop de 20 min)<br>• Redução de idas desnecessárias a Pronto-Socorro |
| **5** | **Governança, Ética & Segurança** | • **WHO Guidance on AI for Health**<br>• **LGPD (Lei 13.709/18) & CFM**<br>• **Privacidade Federada / On-Device** | • Criptografia local (AES-256) sem vazamento de dados<br>• Proteção contra triangulação de prontuário<br>• Imutabilidade de registros clínicos |
| **6** | **Dispositivos & Farmácia** | • **WHO Model List of Essential Medicines**<br>• **Symbicort & Inaladores pMDI/DPI**<br>• **Terapia Tripla (Breztri)** | • Lembretes pós-spray (higiene bucal anti-sapinho)<br>• Gestão de doses restantes (contador de puffs)<br>• Suporte a espaçadores valvulados infantis |

---

## 🔬 Seção 1: Diretrizes Globais de Asma (GINA & NHLBI)

### 1.1. GINA 2026 & OpenEvidence
- **Estratégia AIR / SMART:** Combinação de Corticoide Inalatório (ICS) com broncodilatador de ação rápida para mitigar inflamação subjacente e reduzir mortalidade.
- **Fatores de Desencadeamento (ORACLE2):** Mudanças bruscas de temperatura, umidade, fungos/mofo e poluição aumentam drasticamente o risco de exacerbação grave em pacientes pediátricos.

### 1.2. NHLBI (GRADE Methodology)
- **Mitigação de Alérgenos:** Capas de colchão/travesseiro impermeáveis, controle de poeira e ácaros, filtragem de ar HEPA.
- **Fração Exalada de Óxido Nítrico (FeNO):** Marcador complementar de inflamação eosinofílica das vias aéreas.

---

## 🏛️ Seção 2: Protocolos Nacionais (SUS, CFF, ASBAI, CFM)

### 2.1. PCDT Asma SUS (Conitec nº 1078/2025) & LME de Alto Custo
- **Critérios de Elegibilidade para Biológicos Pediátricos/Adolescentes:**
  - **Dupilumabe (Dupixent):** Bloqueio de vias IL-4 / IL-13.
  - **Mepolizumabe (Nucala) / Benralizumabe (Fasenra):** Anti-IL-5 para asma eosinofílica grave.
  - **Omalizumabe (Xolair):** Anti-IgE para asma alérgica grave.
- **Rastreamento de LME:** Notificação de renovação trimestral/semestral de laudos médicos e exames de espirometria para evitar interrupção de tratamento pelo SUS/Farmácia Cidadã.

### 2.2. Conselho Federal de Farmácia (CFF) & SOP de Pico de Fluxo
- **Protocolo de 3 Sopros:** O paciente realiza 3 tentativas expiratórias máximas; o app seleciona automaticamente o **maior valor absoluto**.
- **Trava de Variabilidade:** Se a diferença entre os sopros for > 20 L/min, o app alerta erro de esforço ou técnica inadequada.

### 2.3. Resoluções CFM nº 1.331/89 e Art. 69 do Código de Ética Médica
- **Retenção de 20 Anos:** Todo registro de saúde infantil deve ter garantia de preservação por no mínimo 20 anos.
- **Auditabilidade e Imutabilidade:** Proibição de alteração retrospectiva de registros clínicos (apenas adendos com carimbo de tempo).

---

## 🫁 Seção 3: Fisioterapia Respiratória e Reabilitação (AMIB & Evidências)

### 3.1. Associação de Medicina Intensiva Brasileira (AMIB) - Travas de Segurança
Antes de qualquer exercício respiratório domiciliar, o app verifica:
1. **SpO2 < 88%:** ⛔ Bloqueio de fisioterapia ativa (indicação de oxigenoterapia e resgate).
2. **Taquipneia Excessiva ou Tiragem:** ⚠️ Orientação para repouso e reavaliação.

### 3.2. Dispositivos de Higiene Brônquica e Expansão Pulmonar
- **PEP / OPEP (Acapella, Shaker):** Mobilização de secreções espessas, desobstrução e prevenção de atelectasias.
- **Espirometria a Volume (Voldyne) vs Fluxo (Respiron):** Dispositivos a volume proporcionam maior excursão diafragmática sustentada e menor uso de musculatura acessória em crianças.
- **Treinamento Muscular Inspiratório (Threshold IMT / POWERbreathe):** Fortalecimento diafragmático (PImáx) para redução da sensação de dispneia.

---

## 🤖 Seção 4: Suporte à Decisão Clínica & Modelagem Preditiva

### 4.1. Aprendizados Mayo Clinic & Kaiser Permanente (AAM)
- **Detecção Precoce de Descompensação:** O valor real do copiloto reside em alertar **antes** do colapso respiratório completo.
- **Loop de Reavaliação Pós-Resgate (20 Minutos):** Após uma dose de resgate na Zona Amarela, o app dispara um lembrete aos pais para verificar a resposta clínica:
  - *Se melhorou:* Manter vigilância e registrar estabilização.
  - *Se permaneceu na Zona Amarela/Vermelha:* Orientar repetição de resgate conforme plano de ação médico ou encaminhamento imediato ao Pronto-Socorro.

---

## 🔐 Seção 5: Segurança, Privacidade e Ética (WHO & LGPD)

### 5.1. Privacidade On-Device (Offline-First)
- **Mitigação do Risco de Triangulação (Caso Dinerstein vs Google):** Os dados de saúde do paciente são processados e armazenados com criptografia local (AES-256) no próprio dispositivo.
- **Sincronização Segura:** Apenas dados estritamente necessários são sincronizados com o backend via Firestore Security Rules imutáveis, garantindo que ninguém além dos pais e dos médicos autorizados acesse o prontuário.

---

## 💊 Seção 6: Uso Prático de Inaladores e Cuidados Domiciliares

### 6.1. Cuidados Pediátricos com Inaladores Dosimetrados (pMDI com Espaçador)
1. **Uso Correto do Espaçador:** Máscara bem vedada no rosto da criança de 5 anos; 1 spray por vez com 5 a 10 respirações calmas.
2. **Prevenção Obrigatória de Candidíase (Sapinho) e Disfonia:** Após qualquer spray de corticoide (Clenil, Budesonida, Fluticasona, Symbicort), o app exibe um **alerta visual** para bochecho com água ou higiene bucal/escovação imediata.
3. **Controle de Doses do Inalador:** Contador regressivo de puffs para evitar que a família use um inalador vazio sem propelente de medicamento ativo.
