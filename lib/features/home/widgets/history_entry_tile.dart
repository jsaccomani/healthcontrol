import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card que renderiza cada anotação de saúde na Linha do Tempo da Home.
class HistoryEntryTile extends StatelessWidget {
  final HealthControlEntry entry;
  final VoidCallback onInspectHash;

  const HistoryEntryTile({
    super.key,
    required this.entry,
    required this.onInspectHash,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (zoneColor, zoneName) = switch (entry.peakFlowZone) {
      ActionZoneType.green => (HCColors.greenMain, 'Verde (Normal)'),
      ActionZoneType.yellow => (HCColors.yellowMain, 'Amarela (Atenção)'),
      ActionZoneType.red => (HCColors.redMain, 'Vermelha (Perigo)'),
      null => (HCColors.neutral400, 'Não calculada'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: zoneColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM • HH:mm').format(entry.timestamp),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? HCColors.darkSurfaceElevated : HCColors.primary50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark ? HCColors.darkBorder : HCColors.primary200,
                      ),
                    ),
                    child: Text(
                      entry.authorName.isNotEmpty ? entry.authorName : 'Cuidador',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: HCColors.primary500,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onInspectHash,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 13, color: HCColors.primary500),
                      SizedBox(width: 3),
                      Text(
                        'Hash SHA-256',
                        style: TextStyle(
                          fontSize: 10,
                          color: HCColors.primary500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Divider(height: 14, color: isDark ? HCColors.darkBorder : HCColors.neutral100),

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (entry.peakFlowBest > 0)
                _buildChip(
                  label: entry.peakFlowZone != null
                      ? 'Sopro: ${entry.peakFlowBest} L/min ($zoneName)'
                      : 'Sopro: ${entry.peakFlowBest} L/min',
                  bg: isDark ? const Color(0xFF06281E) : HCColors.greenLight,
                  border: isDark ? const Color(0xFF0F5132) : HCColors.greenBorder,
                  text: isDark ? HCColors.greenBorder : HCColors.greenText,
                ),
              if (entry.spo2 != null)
                _buildChip(
                  label: 'SpO2: ${entry.spo2}%',
                  bg: isDark ? const Color(0xFF06281E) : HCColors.primary50,
                  border: isDark ? const Color(0xFF0F5132) : HCColors.primary200,
                  text: isDark ? HCColors.primary300 : HCColors.primary700,
                ),
              if (entry.medications.isNotEmpty)
                _buildChip(
                  label: '${entry.medications.length} medicação(ões)',
                  bg: isDark ? const Color(0xFF172554) : HCColors.blueLight,
                  border: isDark ? const Color(0xFF1E40AF) : HCColors.blueBorder,
                  text: isDark ? HCColors.blueBorder : HCColors.blueText,
                ),
              if (entry.physiotherapy != null)
                _buildChip(
                  label: 'Fisio: ${entry.physiotherapy!.deviceName}',
                  bg: isDark ? const Color(0xFF2E1065) : HCColors.purpleLight,
                  border: isDark ? const Color(0xFF581C87) : HCColors.purpleBorder,
                  text: isDark ? HCColors.purpleBorder : HCColors.purpleText,
                ),
              if (entry.mouthRinseCompleted)
                _buildChip(
                  label: 'Bochecho realizado',
                  bg: isDark ? const Color(0xFF06281E) : HCColors.greenLight,
                  border: isDark ? const Color(0xFF0F5132) : HCColors.greenBorder,
                  text: isDark ? HCColors.greenBorder : HCColors.greenText,
                ),
            ],
          ),

          if (entry.symptoms.isNotEmpty && !entry.symptoms.contains('Sem sintomas aparentes')) ...[
            const SizedBox(height: 6),
            Text(
              'Sintomas: ${entry.symptoms.join(', ')}',
              style: const TextStyle(fontSize: 11, color: HCColors.redMain, fontWeight: FontWeight.w500),
            ),
          ],

          if (entry.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Nota: "${entry.notes}"',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color bg,
    required Color border,
    required Color text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }
}
