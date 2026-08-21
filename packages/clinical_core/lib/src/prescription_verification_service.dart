import 'models/prescription.dart';

/// Contrato de serviço para verificação de autenticidade de receitas médicas.
///
/// Princípio de Segurança Clínica (HEALTH_CONTROL_CONTEXT.md seção 25-26):
/// CRM + nome do médico NÃO significa receita autenticada.
abstract class PrescriptionVerificationService {
  Future<PrescriptionVerificationStatus> checkStatus(PrescriptionRecord prescription);
}

/// Implementação padrão do MVP: sempre retorna unknown, porque não existe
/// autoridade verificadora real integrada ainda.
///
/// Princípio de Segurança Clínica (HEALTH_CONTROL_CONTEXT.md seção 21 e 38):
/// Não simular verificação, não fingir infraestrutura que não existe.
class UnknownPrescriptionVerificationService implements PrescriptionVerificationService {
  @override
  Future<PrescriptionVerificationStatus> checkStatus(PrescriptionRecord prescription) async {
    return PrescriptionVerificationStatus.unknown;
  }
}
