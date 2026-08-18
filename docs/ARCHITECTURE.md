# 🏗️ Arquitetura de Software e Dados - AsmaControl Pro

O **AsmaControl Pro** foi concebido com arquitetura **Offline-First** orientada a eventos (**Event Sourcing**), garantindo resiliência em locais com baixa ou nula conectividade (subsolos hospitalares, pronto-socorros, áreas rurais).

---

## 1. Visão Geral da Arquitetura

```
+-------------------------------------------------------------+
|                      FLUTTER CLIENT                         |
|                                                             |
|   +-----------------------+     +-----------------------+   |
|   |  Presentation Layer   | <-> |  Clinical Domain Core |   |
|   | (UI / BLoC / Screens) |     |  (Pure Dart Library)  |   |
|   +-----------------------+     +-----------------------+   |
|               |                             |               |
|   +-----------------------------------------------------+   |
|   |         Local Storage Layer (Offline-First)         |   |
|   |   - Firestore Persistent SQLite Cache (Unlimited)   |   |
|   |   - Local Key-Value / Hive (Instant Configs)        |   |
|   +-----------------------------------------------------+   |
+-------------------------------------------------------------+
                              |
                     (Sync via WebSockets)
                              |
+-------------------------------------------------------------+
|               FIREBASE CLOUD FIRESTORE NOSQL                |
|                                                             |
|   /patients/{patientId} (Coleção Mestra)                    |
|          |                                                  |
|          +---> /event_log/{eventId} (Subcoleção Imutável)   |
|                (Append-only: create=true, update/del=false) |
+-------------------------------------------------------------+
```

---

## 2. Padrão Event Sourcing no Firestore

Ao invés de atualizar o documento do paciente a cada nova medição, todos os registros clínicos geram um novo evento imutável na subcoleção `/patients/{id}/event_log/{id}`.

### Vantagens:
1. **Conformidade Legal CFM (20 Anos):** Histórico inalterável com carimbo de tempo (*timestamp* ISO 8601 UTC).
2. **Sincronismo Bidirecional sem Conflitos:** Evita *race conditions* em modo offline.
3. **Auditabilidade e Real-World Data (RWD):** Permite reconstruir o estado de saúde do paciente em qualquer ponto da linha do tempo.

---

## 3. Estrutura dos Documentos NoSQL

### Documento Mestre: `/patients/{id}`
```json
{
  "id": "pat_12345",
  "full_name": "Lucas Gabriel da Silva",
  "birth_date": "2018-05-14",
  "gender": "M",
  "sus_card_number": "898000123456789",
  "health_insurance": "Unimed BH",
  "insurance_card_number": "00548962",
  "weight_kg": 24.5,
  "height_cm": 122.0,
  "best_pef_personal": 280,
  "comorbidities": [
    "rinite_alergica",
    "refluxo_gastroesofagico"
  ],
  "current_medications": [
    {
      "name": "Budesonida + Formoterol",
      "dosage": "160/4.5 mcg",
      "frequency_hours": 12,
      "device_type": "pMDI_with_spacer"
    }
  ],
  "lme_records": {
    "spirometry_date": "2026-03-10",
    "chest_xray_date": "2025-11-20",
    "eosinophils_date": "2026-06-01",
    "total_ige_date": "2026-06-01"
  },
  "created_at": "2026-01-10T10:00:00Z",
  "updated_at": "2026-06-01T14:30:00Z"
}
```

### Subcoleção de Eventos: `/patients/{id}/event_log/{id}`

#### Evento 1: `DAILY_CLINICAL_DIARY`
```json
{
  "event_id": "evt_987654",
  "patient_id": "pat_12345",
  "event_type": "DAILY_CLINICAL_DIARY",
  "timestamp": "2026-08-18T19:30:00Z",
  "payload": {
    "pef": {
      "blow_1": 250,
      "blow_2": 260,
      "blow_3": 255,
      "recorded_max": 260,
      "technique_unstable": false,
      "action_zone": "GREEN",
      "percentage_best": 92.8
    },
    "vitals": {
      "spo2": 97,
      "heart_rate_bpm": 88,
      "respiratory_rate_rpm": 22,
      "temperature_celsius": 36.6
    },
    "symptoms": {
      "cough": "mild",
      "wheezing": false,
      "night_awakening": false,
      "activity_limitation": false
    },
    "medication_taken": {
      "ics_used": true,
      "saba_used": false,
      "spacer_used": true,
      "inhaler_shaken": true,
      "mask_sealed": true,
      "oral_hygiene_confirmed": true
    },
    "physio_session": {
      "performed": true,
      "amib_level": 4,
      "duration_minutes": 20,
      "safety_cleared": true
    }
  }
}
```

#### Evento 2: `CACT_SCORE`
```json
{
  "event_id": "evt_987655",
  "patient_id": "pat_12345",
  "event_type": "CACT_SCORE",
  "timestamp": "2026-08-18T20:00:00Z",
  "payload": {
    "child_responses": [3, 2, 3, 2],
    "parent_responses": [4, 4, 3],
    "total_score": 21,
    "is_controlled": true,
    "classification": "Asma Controlada"
  }
}
```

---

## 4. Regras de Isolamento e Segurança (Trade Secrets)

Para resguardar os diferenciais competitivos e propriedades intelectuais:
1. **Core de Regras em Pacote Privado:** O diretório `packages/clinical_core` não possui acoplamento com o Flutter SDK de UI. Pode ser compilado e testado de maneira 100% autônoma.
2. **Ofuscação em Builds de Produção:**
   ```bash
   flutter build apk --obfuscate --split-debug-info=./build/app/outputs/symbols
   flutter build ipa --obfuscate --split-debug-info=./build/ios/archive/symbols
   ```
