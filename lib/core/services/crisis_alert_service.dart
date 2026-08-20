import 'package:clinical_core/clinical_core.dart';
import '../storage/health_storage_service.dart';

/// Abstração para emissão de alertas e auditoria de eventos de crise respiratória.
/// Prepara o sistema para o Health Control Pro (Notificações Push para o Médico Assistente,
/// Sincronização com Dashboard Clínico e Webhooks Hospitalares) sem acoplar a UI.
abstract class CrisisAlertService {
  Future<void> notifyCrisisStarted(CrisisEvent event, PatientProfile patient);
  Future<void> notifyMedicationAdministered(CrisisEvent event, PatientProfile patient);
  Future<void> notifyCrisisReassessment(CrisisEvent event, PatientProfile patient);
  Future<void> notifyCrisisResolved(CrisisEvent event, PatientProfile patient);
  Future<void> notifyCrisisEscalated(CrisisEvent event, PatientProfile patient);
}

/// Implementação padrão que realiza a persistência e auditoria clínica local dos eventos de crise.
class LocalAuditCrisisAlertService implements CrisisAlertService {
  final HealthStorageService _storageService;

  LocalAuditCrisisAlertService({HealthStorageService? storageService})
      : _storageService = storageService ?? HealthStorageService();

  @override
  Future<void> notifyCrisisStarted(CrisisEvent event, PatientProfile patient) async {
    await _storageService.saveCrisisEvent(event);
  }

  @override
  Future<void> notifyMedicationAdministered(CrisisEvent event, PatientProfile patient) async {
    await _storageService.saveCrisisEvent(event);

    // Registra a administração no histórico clínico com hash de auditoria
    if (event.medicationAdministered != null && event.medicationAdministered!.isNotEmpty) {
      await _storageService.addHealthControlEntry(
        targetPatientId: patient.id,
        authorName: event.startedByName.isNotEmpty ? event.startedByName : event.startedBy,
        authorRole: event.startedByRole,
        peakFlowAttempts: [],
        spo2: null,
        symptoms: const ['Crise Respiratória / Resgate Administrado'],
        medications: [
          MedicationUsage(
            name: event.medicationAdministered!,
            dosage: event.doseAdministered ?? 'Dose conforme prescrição médica',
            type: MedicationType.rescue,
          ),
        ],
        mouthRinseCompleted: false,
        notes: 'Dose de resgate administrada via Modo Crise. ${event.notes}'.trim(),
      );
    }
  }

  @override
  Future<void> notifyCrisisReassessment(CrisisEvent event, PatientProfile patient) async {
    await _storageService.saveCrisisEvent(event);
  }

  @override
  Future<void> notifyCrisisResolved(CrisisEvent event, PatientProfile patient) async {
    final updated = event.copyWith(status: 'resolved');
    await _storageService.saveCrisisEvent(updated);
  }

  @override
  Future<void> notifyCrisisEscalated(CrisisEvent event, PatientProfile patient) async {
    final updated = event.copyWith(status: 'escalatedToHospital');
    await _storageService.saveCrisisEvent(updated);
  }
}
