# 🫁 Health Control: Asma

> **Plataforma Modular de Copiloto de Saúde Digital, Prontuário Pediátrico e Reabilitação Respiratória Offline-First**

O **Health Control: Asma** é o primeiro módulo da plataforma **Health Control**, voltado para o monitoramento contínuo, prevenção de crises, profilaxia e reabilitação respiratória de pacientes pediátricos asmáticos (com foco na faixa de 4 a 11 anos).
O Health Control deve reduzir a carga mental de cuidar de uma criança com asma. A informação certa precisa estar fácil de encontrar, o registro certo precisa ser fácil de fazer e decisões inseguras precisam ser difíceis de tomar.
A plataforma foi concebida de forma modular e expansível para futuras especialidades de saúde crônica:
- 🫁 **Health Control: Asma** (Módulo Atual - Foco total em Asma Grave, Peak Flow, Espaçador e Fisioterapia).
- 🩺 *Futuro:* **Health Control: Diabetes** (Glicemia, Insulina, Contagem de Carboidratos).
- ❤️ *Futuro:* **Health Control: Cardio** (Pressão Arterial, FC, ECG, Arritmias).
- ⚖️ *Futuro:* **Health Control: Obesidade & Metabolismo** (Composição corporal, Metas calóricas).

---

## 🎯 Pilares e Regras Clínicas do Módulo de Asma

1. **Pico de Fluxo Expiratório (Protocolo CFF):** Coleta dos 3 sopros, registro do maior valor e alerta de variabilidade instável (> 20 L/min).
2. **Zonas de Ação GINA / PCDT:** Classificação automática em Verde (≥80%), Amarela (50-79%) e Vermelha (<50%).
3. **Prevenção Obrigatória de Candidíase Orofaríngea (Sapinho):** Confirmação forçada de bochecho com água ou escovação pós-corticoide inalatório (Clenil, Budesonida).
4. **Segurança Fisioterapêutica em Reabilitação (AMIB):** Bloqueio compulsório de exercícios se `SpO2 < 88%` ou `FR > 45 rpm` com suporte a Voldyne, Shaker, Acapella e POWERbreathe.
5. **Questionário c-ACT:** Teste gamificado oficial para crianças de 4 a 11 anos (score 0 a 27, corte ≤ 19).
6. **Modo Emergência Offline:** Ficha de alto contraste ("Mostrar ao Médico do Pronto-Socorro") com peso, medicações de resgate e cartão SUS.

---

## 👥 Segmentação de Produtos

- **Health Control: Asma (Versão Famílias - 100% Gratuita):** Aplicativo móvel para mães, pais e cuidadores com diário rápido, alertas visuais, histórico versionado e modo offline.
- **Health Control Pro (Versão Médicos & Clínicas - Assinatura SaaS):** Painel web/móvel para pneumologistas, pediatras e fisioterapeutas receberem os dados dos pacientes em tempo real via **Chave de Pareamento** (ex: `AC-7842`).

---

## 🧬 Versionamento Clínico & Auditoria Criptográfica (DevSecOps)

Cada lançamento gera uma tag incremental (`v1.0.1`, `v1.0.2`...) com hash **SHA-256 encadeado** (`previous_hash` + `payload`), garantindo integridade inviolável conforme a **Resolução CFM nº 1.331/89** (guarda de prontuário por 20 anos).
