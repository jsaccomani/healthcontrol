import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Estado de Saúde Diário com Alta Clareza e Baixa Carga Cognitiva.
/// Responde imediatamente: "Como está meu filho agora?" e "O que devo fazer?".
class HealthStatusCard extends StatelessWidget {
  final HealthControlEntry? latestEntry;
  final ActionZoneType? currentZone;
  final PatientProfile profile;
  final VoidCallback onSosPressed;
  final VoidCallback? onOpenActionPlan;

  const HealthStatusCard({
    super.key,
    required this.latestEntry,
    required this.currentZone,
    required this.profile,
    required this.onSosPressed,
    this.onOpenActionPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (cardBg, borderColor, iconData, titleText, whyText, actionGuideText, tagColor) = switch (currentZone) {
      ActionZoneType.green => (
          isDark ? const Color(0xFF06281E) : HCColors.greenLight,
          isDark ? const Color(0xFF0F5132) : HCColors.greenBorder,
          Icons.check_circle_outline,
          'Respiração Estável (Zona Verde)',
          'Fluxo respiratório adequado e sem sintomas de crise.',
          'Mantenha as medicações de manutenção prescritas no plano médico.',
          HCColors.greenMain,
        ),
      ActionZoneType.yellow => (
          isDark ? const Color(0xFF2E1A03) : HCColors.yellowLight,
          isDark ? const Color(0xFF78350F) : HCColors.yellowBorder,
          Icons.warning_amber_rounded,
          'Alerta: Início de Crise (Zona Amarela)',
          'Queda no fluxo respiratório ou presença de sintomas.',
          'Consulte o plano de ação médica para medicações de alívio e reavalie.',
          HCColors.yellowMain,
        ),
      ActionZoneType.red => (
          isDark ? const Color(0xFF350A0A) : HCColors.redLight,
          isDark ? const Color(0xFF991B1B) : HCColors.redBorder,
          Icons.emergency,
          'Emergência: Crise Severa (Zona Vermelha)',
          'Obstrução respiratória crítica.',
          'Inicie o plano de emergência médica e busque atendimento imediatamente.',
          HCColors.redMain,
        ),
      null => (
          isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
          isDark ? HCColors.darkBorder : HCColors.neutral300,
          Icons.info_outline,
          latestEntry == null
              ? 'Nenhum registro de saúde hoje'
              : 'Sem Zona de Ação Calculada',
          latestEntry == null
              ? 'Registre as medições de fluxo respiratório ou sintomas para acompanhar a saúde diária.'
              : 'Cadastre o Melhor PFE Pessoal no perfil para habilitar a classificação automática de zonas (GINA).',
          'Mantenha os registros do seu filho atualizados.',
          HCColors.primary500,
        ),
    };

    final percentage = (latestEntry != null && profile.personalBestPef > 0 && latestEntry!.peakFlowBest > 0)
        ? ((latestEntry!.peakFlowBest / profile.personalBestPef) * 100).toStringAsFixed(0)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark ? null : HCShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho de Estado
          Row(
            children: [
              Icon(iconData, color: tagColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : HCColors.neutral900,
                  ),
                ),
              ),
              if (percentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? HCColors.darkSurfaceElevated : Colors.white,
                    borderRadius: HCRadii.radiusSm,
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    '$percentage% do recorde',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Texto de motivo & conduta
          Text(
            whyText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? HCColors.darkTextPrimary : HCColors.neutral800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            actionGuideText,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
              height: 1.35,
            ),
          ),

          // Badges de Métricas Fisiológicas
          if (latestEntry != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (latestEntry!.peakFlowBest > 0)
                  _buildMetricBadge(
                    context: context,
                    label: 'Sopro Atual',
                    value: '${latestEntry!.peakFlowBest} L/min',
                    valueColor: tagColor,
                  ),
                if (latestEntry!.spo2 != null)
                  _buildMetricBadge(
                    context: context,
                    label: 'Saturação (SpO2)',
                    value: '${latestEntry!.spo2}%',
                    valueColor: latestEntry!.spo2! < 92 ? HCColors.redMain : HCColors.greenMain,
                  ),
              ],
            ),
          ],

          // Ação Crítica em Zona Vermelha ou Amarela
          if (currentZone == ActionZoneType.red) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HCColors.redMain,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
                  elevation: 0,
                ),
                onPressed: onSosPressed,
                icon: const Icon(Icons.emergency, size: 20),
                label: const Text(
                  'Abrir Modo Crise / Ligar 192 (SAMU)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricBadge({
    required BuildContext context,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusSm,
        border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? HCColors.darkTextMuted : HCColors.neutral500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
