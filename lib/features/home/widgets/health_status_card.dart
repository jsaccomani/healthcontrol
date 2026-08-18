import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';

/// Card de Estado de Saúde Diário (Zona Verde, Amarela ou Vermelha) e SpO2.
class HealthStatusCard extends StatelessWidget {
  final HealthControlEntry? latestEntry;
  final ActionZoneType currentZone;
  final PatientProfile profile;
  final VoidCallback onSosPressed;

  const HealthStatusCard({
    super.key,
    required this.latestEntry,
    required this.currentZone,
    required this.profile,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    final (cardBg, borderColor, iconData, titleText, descText, tagBg, tagText) = switch (currentZone) {
      ActionZoneType.green => (
          const Color(0xFFF0FDF4),
          const Color(0xFFBBF7D0),
          Icons.check_circle_outline,
          'Respiração Estável (Zona Verde)',
          'Tudo calmo hoje! O fluxo respiratório está ótimo e as atividades podem seguir normalmente.',
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
        ),
      ActionZoneType.yellow => (
          const Color(0xFFFEFCE8),
          const Color(0xFFFEF08A),
          Icons.warning_amber_rounded,
          'Atenção: Início de Crise (Zona Amarela)',
          'Houve queda no sopro respiratório. Use o remédio de alívio rápido (resgate) prescrito e reavalie em 20 minutos.',
          const Color(0xFFFEF9C3),
          const Color(0xFF854D0E),
        ),
      ActionZoneType.red => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          Icons.dangerous_outlined,
          'Emergência: Falta de Ar Severa (Zona Vermelha)',
          'Queda perigosa no sopro respiratório! Aplique o resgate imediato e leve ao pronto-socorro.',
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
        ),
    };

    final percentage = (latestEntry != null && profile.personalBestPef > 0)
        ? ((latestEntry!.peakFlowBest / profile.personalBestPef) * 100).toStringAsFixed(0)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: tagText, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: tagText),
                ),
              ),
              if (percentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '$percentage% do melhor',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagText),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35),
          ),
          if (latestEntry != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (latestEntry!.peakFlowBest > 0) ...[
                  _buildMetricBadge(
                    'Sopro Atual',
                    '${latestEntry!.peakFlowBest} L/min',
                    AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 8),
                ],
                _buildMetricBadge(
                  'Oxigênio (SpO2)',
                  '${latestEntry!.spo2}%',
                  latestEntry!.spo2 < 92 ? const Color(0xFFEF4444) : const Color(0xFF059669),
                ),
              ],
            ),
          ],
          if (currentZone == ActionZoneType.red) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onSosPressed,
                icon: const Icon(Icons.emergency, size: 18),
                label: const Text('Abrir SOS e Ligar 192 (SAMU)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
