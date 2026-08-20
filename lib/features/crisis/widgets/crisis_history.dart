import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';

/// Histórico Clínico sob Demanda (Nível 3 — Acesso sob Demanda).
/// Carrega dados somente quando o cuidador solicitar explicitamente, preservando performance.
class CrisisHistory extends StatefulWidget {
  final String patientId;

  const CrisisHistory({
    super.key,
    required this.patientId,
  });

  @override
  State<CrisisHistory> createState() => _CrisisHistoryState();
}

class _CrisisHistoryState extends State<CrisisHistory> {
  final HealthStorageService _storageService = HealthStorageService();
  bool _isExpanded = false;
  bool _isLoadingHistory = false;
  List<CrisisEvent> _crisisEvents = [];
  List<HealthControlEntry> _recentEntries = [];

  Future<void> _loadOnDemandHistory() async {
    if (_crisisEvents.isNotEmpty || _recentEntries.isNotEmpty) return;
    setState(() => _isLoadingHistory = true);

    final results = await Future.wait([
      _storageService.getCrisisEvents(patientId: widget.patientId),
      _storageService.getHealthEntries(patientId: widget.patientId),
    ]);

    if (!mounted) return;
    setState(() {
      _crisisEvents = results[0] as List<CrisisEvent>;
      _recentEntries = (results[1] as List<HealthControlEntry>).take(5).toList();
      _isLoadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Material(
      color: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: theme.border,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (exp) {
          setState(() => _isExpanded = exp);
          if (exp) _loadOnDemandHistory();
        },
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.elevatedSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history,
            color: theme.primary,
            size: 20,
          ),
        ),
        title: Text(
          'Histórico de Crises e Medicações',
          style: HCTypography.title.copyWith(
            fontSize: 14,
            color: theme.textPrimary,
          ),
        ),
        subtitle: Text(
          _isExpanded ? 'Toque para recolher' : 'Ver administrações recentes sob demanda',
          style: HCTypography.caption.copyWith(
            color: theme.textSecondary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _isLoadingHistory
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: theme.primary, strokeWidth: 2),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 16, color: theme.border),

                      // Eventos de Crises Registrados
                      Text(
                        'ÚLTIMAS CRISES REGISTRADAS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_crisisEvents.isEmpty)
                        Text(
                          'Nenhuma crise anterior registrada no aplicativo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        ..._crisisEvents.take(3).map((event) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.elevatedSurface,
                                borderRadius: HCRadii.radiusMd,
                                border: Border.all(
                                  color: theme.border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(event.startedAt),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: event.isResolved
                                              ? theme.successBg
                                              : theme.criticalBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          event.isResolved ? 'Resolvida' : 'Em Atendimento',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: event.isResolved ? theme.successText : theme.criticalText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (event.medicationAdministered != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Resgate: ${event.medicationAdministered} (${event.doseAdministered ?? "dose prescrita"})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    'Iniciado por: ${event.startedByName} (${event.startedByRole})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 12),

                      // Registros Recentes do Diário
                      Text(
                        'ÚLTIMAS MEDIÇÕES DO DIÁRIO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_recentEntries.isEmpty)
                        Text(
                          'Nenhuma medição recente cadastrada.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        ..._recentEntries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: entry.peakFlowZone == ActionZoneType.green
                                      ? theme.success
                                      : (entry.peakFlowZone == ActionZoneType.yellow
                                          ? theme.warning
                                          : theme.critical),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM HH:mm').format(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'PFE: ${entry.peakFlowBest > 0 ? "${entry.peakFlowBest} L/min" : "-"} • SpO2: ${entry.spo2}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
