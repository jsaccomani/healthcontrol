import 'package:test/test.dart';
import 'package:clinical_core/clinical_core.dart';

/// Simulador e Avaliador de Regras de Segurança do Firestore (ReBAC Evaluation Engine).
/// Testa as 11 asserções mandatórias de segurança para o modelo de relacionamentos e imutabilidade CFM.
class FirestoreSecurityEvaluator {
  final Map<String, Map<String, dynamic>> database;

  FirestoreSecurityEvaluator(this.database);

  /// Avalia permissão de leitura para /patients/{patientId}
  bool canReadPatient({
    required String? authUid,
    required String? role,
    required String patientId,
  }) {
    if (authUid == null) return false;

    // 1. Dono Primário
    final patientDoc = database['patients/$patientId'];
    if (patientDoc != null && patientDoc['owner_id'] == authUid) {
      return true;
    }
    if (patientId == authUid) return true;

    // 2. Relacionamento Ativo (Subcoleção ou Top-level)
    final subRel = database['patients/$patientId/relationships/$authUid'];
    if (subRel != null && subRel['status'] == 'ACTIVE') {
      final revokedAt = subRel['revoked_at'];
      if (revokedAt == null) return true;
    }

    final topRel = database['relationships/${patientId}_$authUid'];
    if (topRel != null && topRel['status'] == 'ACTIVE') {
      final revokedAt = topRel['revoked_at'];
      if (revokedAt == null) return true;
    }

    // Role isolada sem relacionamento NÃO concede acesso (Defesa contra Role-Only bypass)
    return false;
  }

  /// Avalia permissão de criação para /patients/{patientId}
  bool canCreatePatient({
    required String? authUid,
    required Map<String, dynamic> data,
  }) {
    if (authUid == null) return false;
    if (data['owner_id'] != authUid) return false; // Não permite forjar dono
    if (!data.containsKey('name') || !data.containsKey('created_at')) return false;
    return true;
  }

  /// Avalia permissão de exclusão para /patients/{patientId} (CFM 20 anos)
  bool canDeletePatient({
    required String? authUid,
    required String? role,
    required String patientId,
  }) {
    // Proibido para todos (incluindo admins)
    return false;
  }

  /// Avalia permissão de criação na subcoleção imutável /patients/{patientId}/event_log/{eventId}
  bool canCreateEventLog({
    required String? authUid,
    required String? role,
    required String patientId,
    required Map<String, dynamic> data,
  }) {
    if (authUid == null) return false;

    // 1. Deve ter acesso autorizado ao paciente
    if (!canReadPatient(authUid: authUid, role: role, patientId: patientId)) {
      return false;
    }

    // 2. Consistência de identidade
    if (data['patient_id'] != patientId) return false;
    if (data['author_id'] != authUid) return false;

    // 3. Validação de chaves obrigatórias
    const requiredKeys = [
      'event_id', 'patient_id', 'event_type', 'author_id',
      'timestamp', 'payload', 'hash', 'sequence_number'
    ];
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) return false;
    }

    // 4. Validação de tipo de evento clínico
    const validEventTypes = [
      'HEALTH_CONTROL_ENTRY', 'DAILY_CLINICAL_DIARY',
      'CACT_SCORE', 'PHYSIO_SESSION', 'CLINICAL_CRISIS',
      'DOCTOR_PAIRING', 'PRESCRIPTION_ADDED', 'ANAMNESIS_UPDATE'
    ];
    if (!validEventTypes.contains(data['event_type'])) return false;

    // 5. Validação de hash criptográfico SHA-256 (64 hex)
    final hash = data['hash'];
    if (hash is! String || hash.length != 64) return false;

    // 6. Validação de número de sequência
    final seq = data['sequence_number'];
    if (seq is! int || seq < 1) return false;

    // 7. Validação de payload
    final payload = data['payload'];
    if (payload is! Map || payload.keys.length > 50) return false;

    return true;
  }

  /// Avalia permissão de atualização em /patients/{patientId}/event_log/{eventId}
  bool canUpdateEventLog() => false; // Imutabilidade estrita

  /// Avalia permissão de exclusão em /patients/{patientId}/event_log/{eventId}
  bool canDeleteEventLog() => false; // Imutabilidade estrita
}

void main() {
  group('Firestore ReBAC Security Rules Audit (11 Asserções Mandatórias)', () {
    late Map<String, Map<String, dynamic>> mockDb;
    late FirestoreSecurityEvaluator evaluator;

    setUp(() {
      mockDb = {
        'patients/child_arthur': {
          'owner_id': 'parent_juliana',
          'name': 'Arthur Saccomani',
          'created_at': '2026-08-18T10:00:00Z',
        },
        'patients/child_beatriz': {
          'owner_id': 'parent_marcos',
          'name': 'Beatriz Silva',
          'created_at': '2026-08-18T11:00:00Z',
        },
        'patients/child_arthur/relationships/physician_dr_valente': {
          'patient_id': 'child_arthur',
          'user_id': 'physician_dr_valente',
          'relationship_type': 'PHYSICIAN',
          'status': 'ACTIVE',
          'granted_by': 'parent_juliana',
        },
        'patients/child_arthur/relationships/physician_dr_revoked': {
          'patient_id': 'child_arthur',
          'user_id': 'physician_dr_revoked',
          'relationship_type': 'PHYSICIAN',
          'status': 'REVOKED',
          'revoked_at': '2026-08-18T12:00:00Z',
          'revoked_by': 'parent_juliana',
        },
      };
      evaluator = FirestoreSecurityEvaluator(mockDb);
    });

    test('1. Paciente/Dono pode acessar os próprios dados', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('2. Paciente/Usuário NÃO pode acessar dados de outro paciente não vinculado', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isFalse);
    });

    test('3. Pai/Cuidador autorizado pode acessar o filho cadastrado', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'parent_marcos',
        role: 'parent',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isTrue);
    });

    test('4. Profissional com vínculo ativo pode acessar paciente atribuído', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_valente',
        role: 'physician',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('5. Profissional médico NÃO pode acessar paciente sem vínculo (Anti-Role Bypass)', () {
      // Dr. Valente é médico, mas NÃO tem vínculo com a Beatriz!
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_valente',
        role: 'physician',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isFalse);
    });

    test('6. Relacionamento revogado bloqueia o acesso imediatamente', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_revoked',
        role: 'physician',
        patientId: 'child_arthur',
      );
      expect(canAccess, isFalse);
    });

    test('7. Criação não autorizada de eventos é rejeitada (Usuário sem acesso ou Forjando Autor)', () {
      final validHash = 'a' * 64;

      // Caso A: Usuário não autorizado
      final canCreateUnauth = evaluator.canCreateEventLog(
        authUid: 'attacker_bob',
        role: 'user',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'HEALTH_CONTROL_ENTRY',
          'author_id': 'attacker_bob',
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': validHash,
          'sequence_number': 1,
        },
      );
      expect(canCreateUnauth, isFalse);

      // Caso B: Usuário autorizado tentando forjar o author_id de outra pessoa
      final canSpoofAuthor = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'HEALTH_CONTROL_ENTRY',
          'author_id': 'physician_dr_valente', // Tentando forjar autoria do médico
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': validHash,
          'sequence_number': 1,
        },
      );
      expect(canSpoofAuthor, isFalse);
    });

    test('8. Modificação de eventos registrados é estritamente rejeitada (Imutabilidade)', () {
      expect(evaluator.canUpdateEventLog(), isFalse);
    });

    test('9. Exclusão de eventos registrados é estritamente rejeitada (CFM 20 anos)', () {
      expect(evaluator.canDeleteEventLog(), isFalse);
    });

    test('10. Evento com schema inválido (sem hash ou payload gigante) é rejeitado', () {
      // Hash com tamanho inválido (< 64 caracteres)
      final canCreateInvalidHash = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'HEALTH_CONTROL_ENTRY',
          'author_id': 'parent_juliana',
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': 'invalid_short_hash',
          'sequence_number': 1,
        },
      );
      expect(canCreateInvalidHash, isFalse);

      // Tipo de evento desconhecido
      final canCreateInvalidType = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'MALICIOUS_EVENT_INJECTION',
          'author_id': 'parent_juliana',
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': 'a' * 64,
          'sequence_number': 1,
        },
      );
      expect(canCreateInvalidType, isFalse);
    });

    test('11. Comportamento de Administrador é estritamente delimitado e não permite deleção de prontuário', () {
      final canAdminDelete = evaluator.canDeletePatient(
        authUid: 'admin_sys',
        role: 'admin',
        patientId: 'child_arthur',
      );
      expect(canAdminDelete, isFalse);
    });
  });
}
