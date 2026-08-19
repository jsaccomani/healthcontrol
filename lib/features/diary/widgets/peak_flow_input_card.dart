import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card para Registro dos 3 Sopros de Pico de Fluxo (Peak Flow - CFF) e Cálculo Instantâneo de Zona GINA.
class PeakFlowInputCard extends StatelessWidget {
  final TextEditingController blow1Ctrl;
  final TextEditingController blow2Ctrl;
  final TextEditingController blow3Ctrl;
  final int? calculatedBest;
  final int? calculatedVariance;
  final bool hasVarianceError;
  final int personalBestPef;
  final VoidCallback onRecalculate;

  const PeakFlowInputCard({
    super.key,
    required this.blow1Ctrl,
    required this.blow2Ctrl,
    required this.blow3Ctrl,
    required this.calculatedBest,
    required this.calculatedVariance,
    required this.hasVarianceError,
    this.personalBestPef = 300,
    required this.onRecalculate,
  });

  @override
  Widget build(BuildContext context) {
    ActionZoneEvaluation? zoneEval;
    if (calculatedBest != null && calculatedBest! > 0 && personalBestPef > 0) {
      zoneEval = ActionZoneEvaluator.evaluate(
        currentPef: calculatedBest!,
        personalBestPef: personalBestPef,
      );
    }

    return Container(
      padding: HCSpacing.paddingCard,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: HCColors.neutral200),
        boxShadow: HCShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.air, color: HCColors.blueMain, size: 20),
                  SizedBox(width: HCSpacing.xs),
                  Text('Sopro da Criança (Peak Flow)', style: HCTypography.subHeading),
                ],
              ),
              if (calculatedBest != null)
                Container(
                  padding: HCSpacing.paddingBadge,
                  decoration: BoxDecoration(
                    color: HCColors.primary100,
                    borderRadius: HCRadii.radiusSm,
                  ),
                  child: Text(
                    'Maior: $calculatedBest L/min',
                    style: HCTypography.labelBold.copyWith(color: HCColors.primary700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: HCSpacing.xs),
          const Text(
            'Peça para a criança soprar 3 vezes com força máxima no aparelho:',
            style: HCTypography.bodySmall,
          ),
          const SizedBox(height: HCSpacing.md),

          // 3 Inputs de Sopros
          Row(
            children: [
              Expanded(child: _buildBlowField('1º Sopro', blow1Ctrl)),
              const SizedBox(width: HCSpacing.sm),
              Expanded(child: _buildBlowField('2º Sopro', blow2Ctrl)),
              const SizedBox(width: HCSpacing.sm),
              Expanded(child: _buildBlowField('3º Sopro', blow3Ctrl)),
            ],
          ),

          // Retorno Imediato da Zona e Percentual (Zero Cognitive Load)
          if (zoneEval != null) ...[
            const SizedBox(height: HCSpacing.md),
            Container(
              padding: HCSpacing.paddingCard,
              decoration: BoxDecoration(
                color: zoneEval.zone == ActionZoneType.green
                    ? HCColors.greenLight
                    : (zoneEval.zone == ActionZoneType.yellow ? HCColors.yellowLight : HCColors.redLight),
                borderRadius: HCRadii.radiusMd,
                border: Border.all(
                  color: zoneEval.zone == ActionZoneType.green
                      ? HCColors.greenBorder
                      : (zoneEval.zone == ActionZoneType.yellow ? HCColors.yellowBorder : HCColors.redBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HCActionZoneBadge(zone: zoneEval.zone),
                      const Spacer(),
                      Text(
                        '${zoneEval.percentageOfPersonalBest.toStringAsFixed(0)}% do melhor ($personalBestPef L/min)',
                        style: HCTypography.labelBold.copyWith(
                          color: zoneEval.zone == ActionZoneType.green
                              ? HCColors.greenText
                              : (zoneEval.zone == ActionZoneType.yellow ? HCColors.yellowText : HCColors.redText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HCSpacing.xs),
                  Text(
                    zoneEval.clinicalGuidance,
                    style: HCTypography.bodySmall.copyWith(
                      color: HCColors.neutral800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alerta de Técnica Instável (> 20 L/min)
          if (hasVarianceError && calculatedVariance != null) ...[
            const SizedBox(height: HCSpacing.sm),
            Container(
              padding: HCSpacing.paddingCompact,
              decoration: BoxDecoration(
                color: HCColors.yellowLight,
                borderRadius: HCRadii.radiusSm,
                border: Border.all(color: HCColors.yellowBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: HCColors.yellowMain, size: 16),
                  const SizedBox(width: HCSpacing.xs),
                  Expanded(
                    child: Text(
                      'Atenção: Os sopros variaram $calculatedVariance L/min (diferença > 20 L/min). Pode ter ocorrido tosse ou bocal mal vedado.',
                      style: HCTypography.bodySmall.copyWith(color: HCColors.yellowText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlowField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HCTypography.labelBold),
        const SizedBox(height: HCSpacing.xs),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: HCTypography.heading,
          decoration: InputDecoration(
            hintText: 'L/min',
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            border: OutlineInputBorder(borderRadius: HCRadii.radiusMd),
            filled: true,
            fillColor: HCColors.neutral50,
          ),
          onChanged: (_) => onRecalculate(),
        ),
      ],
    );
  }
}
