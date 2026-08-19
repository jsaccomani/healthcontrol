import 'package:test/test.dart';

/// Simulador e Avaliador de Regras de Segurança do Firestore (ReBAC Evaluation Engine).
/// Valida exaustivamente as asserções mandatórias de autorização relacional,
/// anti-role bypass, ciclo de vida de relacionamentos e imutabilidade de prontuário CFM.
class FirestoreSecurityEvaluator {
  final Map<String, Map<String, dynamic>> database;

  FirestoreSecurityEvaluator(this.database);

  /// Avalia se um relacionamento está ativo, não-revogado e não-expirado no tempo de avaliação
  bool _isRelationshipActive(Map<String, dynamic>? rel, DateTime? evaluationTime) {
    if (rel == null) return false;
    if (rel['status'] != 'ACTIVE') return false;

    final eval = evaluationTime ?? DateTime.now();

    // Checagem de revogação
    final revokedAtStr = rel['revoked_at'];
    if (revokedAtStr != null) {
      final revokedAt = DateTime.parse(revokedAtStr as String);
      if (eval.isAfter(revokedAt) || eval.isAtSameMomentAs(revokedAt)) {
        return false;
      }
    }

    // Checagem de expiração
    final expiresAtStr = rel['expires_at'];
    if (expiresAtStr != null) {
      final expiresAt = DateTime.parse(expiresAtStr as String);
      if (eval.isAfter(expiresAt) || eval.isAtSameMomentAs(expiresAt)) {
        return false;
      }
    }

    return true;
  }

  /// Avalia permissão de leitura para /patients/{patientId}
  bool canReadPatient({
    required String? authUid,
    required String? role,
    required String patientId,
    DateTime? evaluationTime,
  }) {
    if (authUid == null) return false;

    // 1. Dono Primário
    final patientDoc = database['patients/$patientId'];
    if (patientDoc != null && patientDoc['owner_id'] == authUid) {
      return true;
    }
    if (patientId == authUid) return true;

    // 2. Relacionamento Ativo na Subcoleção (/patients/{patientId}/relationships/{userId})
    final subRel = database['patients/$patientId/relationships/$authUid'];
    if (_isRelationshipActive(subRel, evaluationTime)) {
      return true;
    }

    // 3. Relacionamento Ativo na Coleção Top-Level (/relationships/{patientId}_{userId})
    final topRel = database['relationships/${patientId}_$authUid'];
    if (_isRelationshipActive(topRel, evaluationTime)) {
      return true;
    }

    // Role isolada sem relacionamento NÃO concede acesso (Anti-Role Bypass)
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
    DateTime? evaluationTime,
  }) {
    if (authUid == null) return false;

    // 1. Deve ter acesso autorizado ao paciente
    if (!canReadPatient(authUid: authUid, role: role, patientId: patientId, evaluationTime: evaluationTime)) {
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
  group('Firestore ReBAC Security Rules Audit (Reconciliação & Matriz Completa)', () {
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
        // Médico ativo
        'patients/child_arthur/relationships/physician_dr_valente': {
          'patient_id': 'child_arthur',
          'user_id': 'physician_dr_valente',
          'relationship_type': 'PHYSICIAN',
          'status': 'ACTIVE',
          'granted_by': 'parent_juliana',
        },
        // Fisioterapeuta ativo
        'patients/child_arthur/relationships/physio_dra_ana': {
          'patient_id': 'child_arthur',
          'user_id': 'physio_dra_ana',
          'relationship_type': 'PHYSIOTHERAPIST',
          'status': 'ACTIVE',
          'granted_by': 'parent_juliana',
        },
        // Cuidador ativo via coleção top-level
        'relationships/child_arthur_caregiver_maria': {
          'patient_id': 'child_arthur',
          'user_id': 'caregiver_maria',
          'relationship_type': 'CAREGIVER',
          'status': 'ACTIVE',
          'granted_by': 'parent_juliana',
        },
        // Relacionamento revogado
        'patients/child_arthur/relationships/physician_dr_revoked': {
          'patient_id': 'child_arthur',
          'user_id': 'physician_dr_revoked',
          'relationship_type': 'PHYSICIAN',
          'status': 'REVOKED',
          'revoked_at': '2026-08-18T12:00:00Z',
          'revoked_by': 'parent_juliana',
        },
        // Relacionamento expirado (com validade de 30 dias que passou)
        'patients/child_arthur/relationships/physician_dr_expired': {
          'patient_id': 'child_arthur',
          'user_id': 'physician_dr_expired',
          'relationship_type': 'PHYSICIAN',
          'status': 'ACTIVE',
          'expires_at': '2026-08-01T00:00:00Z',
          'granted_by': 'parent_juliana',
        },
      };
      evaluator = FirestoreSecurityEvaluator(mockDb);
    });

    test('1. Acesso não-autenticado é estritamente rejeitado (Default Deny)', () {
      final canAccess = evaluator.canReadPatient(
        authUid: null,
        role: null,
        patientId: 'child_arthur',
      );
      expect(canAccess, isFalse);
    });

    test('2. Paciente/Dono pode acessar os próprios dados', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('3. Usuário autenticado NÃO pode acessar paciente de terceiro não vinculado', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isFalse);
    });

    test('4. Médico sem vínculo ativo é rejeitado mesmo tendo role="physician" (Anti-Role Bypass)', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_valente',
        role: 'physician',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isFalse);
    });

    test('5. Médico com vínculo ativo tem acesso concedido', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_valente',
        role: 'physician',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('6. Fisioterapeuta sem vínculo ativo é rejeitado mesmo tendo role="physiotherapist"', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physio_dra_ana',
        role: 'physiotherapist',
        patientId: 'child_beatriz',
      );
      expect(canAccess, isFalse);
    });

    test('7. Fisioterapeuta com vínculo ativo tem acesso concedido', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physio_dra_ana',
        role: 'physiotherapist',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('8. Cuidador / Familiar com relacionamento top-level ativo tem acesso concedido', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'caregiver_maria',
        role: 'caregiver',
        patientId: 'child_arthur',
      );
      expect(canAccess, isTrue);
    });

    test('9. Relacionamento revogado bloqueia o acesso imediatamente', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_revoked',
        role: 'physician',
        patientId: 'child_arthur',
      );
      expect(canAccess, isFalse);
    });

    test('10. Relacionamento expirado no tempo bloqueia o acesso', () {
      final canAccess = evaluator.canReadPatient(
        authUid: 'physician_dr_expired',
        role: 'physician',
        patientId: 'child_arthur',
        evaluationTime: DateTime.parse('2026-08-18T10:00:00Z'),
      );
      expect(canAccess, isFalse);
    });

    test('11. Criação de paciente não permite forjar outro owner_id', () {
      final canForgeOwner = evaluator.canCreatePatient(
        authUid: 'parent_juliana',
        data: {
          'owner_id': 'victim_marcos',
          'name': 'Fraudulent Profile',
          'created_at': '2026-08-18T10:00:00Z',
        },
      );
      expect(canForgeOwner, isFalse);

      final canCreateValid = evaluator.canCreatePatient(
        authUid: 'parent_juliana',
        data: {
          'owner_id': 'parent_juliana',
          'name': 'Novo Filho',
          'created_at': '2026-08-18T10:00:00Z',
        },
      );
      expect(canCreateValid, isTrue);
    });

    test('12. Criação não autorizada de eventos é rejeitada (Usuário sem vínculo)', () {
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
          'hash': 'a' * 64,
          'sequence_number': 1,
        },
      );
      expect(canCreateUnauth, isFalse);
    });

    test('13. Tentativa de forjar author_id é rejeitada', () {
      final canSpoofAuthor = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'HEALTH_CONTROL_ENTRY',
          'author_id': 'physician_dr_valente', // Forjando médico
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': 'a' * 64,
          'sequence_number': 1,
        },
      );
      expect(canSpoofAuthor, isFalse);
    });

    test('14. Tentativa de forjar patient_id no documento é rejeitada', () {
      final canSpoofPatient = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_beatriz', // Paciente mismatch
          'event_type': 'HEALTH_CONTROL_ENTRY',
          'author_id': 'parent_juliana',
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': 'a' * 64,
          'sequence_number': 1,
        },
      );
      expect(canSpoofPatient, isFalse);
    });

    test('15. Evento com tipo inválido ou não catalogado é rejeitado', () {
      final canCreateInvalidType = evaluator.canCreateEventLog(
        authUid: 'parent_juliana',
        role: 'parent',
        patientId: 'child_arthur',
        data: {
          'event_id': 'evt_001',
          'patient_id': 'child_arthur',
          'event_type': 'UNAUTHORIZED_INJECTION_TYPE',
          'author_id': 'parent_juliana',
          'timestamp': '2026-08-18T12:00:00Z',
          'payload': {'pef': 200},
          'hash': 'a' * 64,
          'sequence_number': 1,
        },
      );
      expect(canCreateInvalidType, isFalse);
    });

    test('16. Evento com hash inválido ou corrompido é rejeitado', () {
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
          'hash': 'too_short_hash_32chars',
          'sequence_number': 1,
        },
      );
      expect(canCreateInvalidHash, isFalse);
    });

    test('17. Evento com número de sequência inválido (<=0) é rejeitado', () {
      final canCreateInvalidSeq = evaluator.canCreateEventLog(
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
          'hash': 'a' * 64,
          'sequence_number': 0,
        },
      );
      expect(canCreateInvalidSeq, isFalse);
    });

    test('18. Modificação de eventos registrados é estritamente proibida (Imutabilidade)', () {
      expect(evaluator.canUpdateEventLog(), isFalse);
    });

    test('19. Exclusão de eventos registrados é estritamente proibida (Guarda CFM 20 anos)', () {
      expect(evaluator.canDeleteEventLog(), isFalse);
    });

    test('20. Administrador não pode excluir prontuários de pacientes', () {
      final canAdminDelete = evaluator.canDeletePatient(
        authUid: 'admin_sys',
        role: 'admin',
        patientId: 'child_arthur',
      );
      expect(canAdminDelete, isFalse);
    });
  });
}
