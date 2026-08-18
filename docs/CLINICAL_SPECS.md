# 📑 Especificações Clínicas e Regulatórias - AsmaControl Pro

Este documento detalha o embasamento científico, as referências médicas e os algoritmos exatos implementados no **AsmaControl Pro**.

---

## 1. Pico de Fluxo Expiratório (PFE / Peak Flow) - Protocolo CFF

### Fundamentação
O Pico de Fluxo Expiratório (Peak Expiratory Flow - PEF) afere a velocidade máxima com que o ar pode ser expelido dos pulmões após uma inspiração máxima. Conforme as diretrizes da **CFF (Cystic Fibrosis Foundation / Consensos de Pneumologia Pediátrica)**:

- A variabilidade da medida pode decorrer de tosse precoce, escape perioral no bocal/máscara ou esforço subótimo.
- O paciente deve realizar **3 manobras expiratórias forçadas**.
- O valor representativo é sempre o **maior valor absoluto**.

### Algoritmo Matemático
```dart
int calculatePef(int pef1, int pef2, int pef3) {
  final blows = [pef1, pef2, pef3];
  final maxVal = blows.reduce(max);
  final minVal = blows.reduce(min);
  return maxVal;
}

bool isPefTechniqueUnstable(int pef1, int pef2, int pef3) {
  final blows = [pef1, pef2, pef3];
  final maxVal = blows.reduce(max);
  final minVal = blows.reduce(min);
  return (maxVal - minVal) > 20; // L/min
}
```

---

## 2. Zonas do Plano de Ação (GINA / PCDT)

A **GINA (Global Initiative for Asthma)** e o **PCDT de Asma do Ministério da Saúde (SUS)** preconizam a classificação em zonas baseadas no percentual do PFE atual em relação ao **Melhor PFE Pessoal (Personal Best PEF)** da criança (obtido em período de estabilidade clínica):

| Zona | Intervalo Percentual | Significado Clínico | Conduta do Aplicativo |
| :--- | :--- | :--- | :--- |
| 🟢 **Verde** | **≥ 80%** | Asma Controlada | Exibir mensagem de estabilidade. Manter medicação de controle prescrita. |
| 🟡 **Amarela** | **50% a 79%** | Início de Crise / Descompensação | Alerta preventivo. Orientar uso de SABA (resgate) conforme plano médico. |
| 🔴 **Vermelha** | **< 50%** | Crise Severa / Emergência Médica | Alerta de alto risco. Acionamento direto de rota GPS para o Pronto-Socorro mais próximo via `url_launcher`. |

---

## 3. Técnica Inalatória com Espaçador (GINA 2026 - pMDI)

A inalação de aerossóis pressurizados dosimetrados (pMDI) em pediatria exige o uso obrigatório de câmara de expansão (espaçador valvulado com ou sem máscara). 

Erros críticos de técnica:
1. **Falta de homogeneização:** O fármaco em suspensão decanta rapidamente. Exige agitação vertical por no mínimo 5 segundos antes de cada jato.
2. **Má vedação:** A perda de vedação facial dissipa até 80% da dose antes da penetração traqueobrônquica.

**Regra no App:** O formulário de registro de inalação bloqueia o salvamento até que o usuário confirme ativamente o checklist duplo.

---

## 4. Profilaxia de Candidíase Orofaríngea (ICS Hygiene)

Corticosteroides Inalatórios (ICS - Budesonida, Beclometasona, Fluticasona, Ciclesonida) depositados na cavidade oral e faringe alteram a microbiota local e causam imunossupressão tópica, predispondo à **candidíase orofaríngea (sapinho)** e **disfonia**.

**Regra no App:** O registro de qualquer ICS no payload dispara um temporizador local no Flutter (`flutter_local_notifications`), forçando a criança/cuidador a confirmar o bochecho com água ou escovação dental.

---

## 5. Critérios de Segurança em Fisioterapia Respiratória (AMIB)

A **Associação de Medicina Intensiva Brasileira (AMIB)** e comitês de fisioterapia pediátrica estabelecem limites de segurança hemodinâmica e ventilatória antes da execução de mobilização precoce ou cinesioterapia respiratória:

### Critérios de Bloqueio Compulsório
A terapia é imediatamente contraindicada e bloqueada no app se qualquer condição for verdadeira:
- `SpO2 < 88%` (em ar ambiente ou O2 suplementar)
- `FiO2 > 0.60` (fração inspirada de O2 superior a 60%)
- `PEEP > 10 cmH2O`
- `Frequência Respiratória > 45 rpm` (em crianças)

### Escala de Mobilização Motora AMIB (Níveis 1 a 5)
1. **Nível 1:** Mobilização passiva / mudança de decúbito no leito.
2. **Nível 2:** Mobilização ativa-assistida no leito / sedestação em leito.
3. **Nível 3:** Sedestação à beira do leito / controle de tronco.
4. **Nível 4:** Transferência leito-poltrona / ortostatismo assistido.
5. **Nível 5:** Marcha ativa / deambulação e exercícios resistidos.

---

## 6. Questionário c-ACT (Childhood Asthma Control Test)

Validado para crianças entre **4 e 11 anos**:
- Composto por 4 perguntas respondidas pela criança (escala com rostos ilustrados de 0 a 3) e 3 perguntas respondidas pelos pais/cuidadores (escala de 0 a 5).
- **Pontuação Total Máxima:** 27 pontos.
- **Interpretação Clínica:**
  - `Escore > 19`: Asma bem controlada no último mês.
  - `Escore ≤ 19`: **Asma não controlada**. Disparo de alerta no dashboard médico para ajuste de plano terapêutico.

---

## 7. Conformidade Regulatória e SUS

### LME - Laudo de Solicitação de Medicamentos do SUS (Farmácia Cidadã)
Rastreamento automático de validade de exames comprobatórios para renovação de imunobiológicos e broncodilatadores de alto custo:
- **Espirometria com prova broncodilatadora:** validade semestral (180 dias).
- **Radiografia de Tórax:** validade anual (360 dias).
- **Contagem de Eosinófilos:** validade trimestral (90 dias) para Mepolizumabe.
- **IgE Total Sérica:** validade trimestral (90 dias) para Omalizumabe.

### Guarda de Prontuário Legal (CFM e LGPD)
- **Art. 69 do Código de Ética Médica & Resolução CFM nº 1.331/89:** Guarda e disponibilidade de prontuários eletrônicos por período mínimo de **20 anos**.
- Os dados do histórico clínico (`event_log`) são gravados em modelo **append-only** (imutável), blindados contra alterações ou exclusões maliciosas.
