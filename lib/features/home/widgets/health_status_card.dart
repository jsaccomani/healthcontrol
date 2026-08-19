import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Estado de Saúde Diário com Alta Clareza e Baixa Carga Cognitiva.
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
          HCColors.greenLight,
          HCColors.greenBorder,
          Icons.check_circle_outline,
          'Respiração Estável (Zona Verde)',
          'O fluxo respiratório está normal e as atividades habituais podem seguir com as medicações de rotina.',
          const Color(0xFFDCFCE7),
          HCColors.greenText,
        ),
      ActionZoneType.yellow => (
          HCColors.yellowLight,
          HCColors.yellowBorder,
          Icons.warning_amber_rounded,
          'Alerta: Início de Crise (Zona Amarela)',
          'Queda no fluxo respiratório. Administre o medicamento de alívio rápido (resgate) prescrito e reavalie em 20 minutos.',
          const Color(0xFFFEF9C3),
          HCColors.yellowText,
        ),
      ActionZoneType.red => (
          HCColors.redLight,
          HCColors.redBorder,
          Icons.dangerous_outlined,
          'Emergência: Crise Severa (Zona Vermelha)',
          'Obstrução respiratória crítica. Aplique a medicação de resgate de ataque e busque atendimento médico imediato.',
          const Color(0xFFFEE2E2),
          HCColors.redText,
        ),
    };

    final percentage = (latestEntry != null && profile.personalBestPef > 0)
        ? ((latestEntry!.peakFlowBest / profile.personalBestPef) * 100).toStringAsFixed(0)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: HCShadows.subtle,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tagText),
                ),
              ),
              if (percentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: tagBg, borderRadius: HCRadii.radiusSm),
                  child: Text(
                    '$percentage% do recorde',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagText),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descText,
            style: const TextStyle(fontSize: 12, color: HCColors.neutral700, height: 1.4),
          ),
          if (latestEntry != null) ...[
            const SizedBox(height: 12),
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
                  'Saturação (SpO2)',
                  '${latestEntry!.spo2}%',
                  latestEntry!.spo2 < 92 ? HCColors.redMain : HCColors.greenMain,
                ),
              ],
            ),
          ],
          if (currentZone == ActionZoneType.red) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HCColors.redMain,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                  elevation: 0,
                ),
                onPressed: onSosPressed,
                icon: const Icon(Icons.emergency, size: 18),
                label: const Text('Abrir Modo Crise / Ligar SAMU 192', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: HCRadii.radiusSm,
        border: Border.all(color: HCColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 11, color: HCColors.neutral500)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
