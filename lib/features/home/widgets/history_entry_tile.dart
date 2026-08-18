import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';

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
    final (zoneColor, zoneName) = switch (entry.peakFlowZone) {
      ActionZoneType.green => (const Color(0xFF059669), 'Verde (Normal)'),
      ActionZoneType.yellow => (const Color(0xFFD97706), 'Amarela (Atenção)'),
      ActionZoneType.red => (const Color(0xFFDC2626), 'Vermelha (Perigo)'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM • HH:mm').format(entry.timestamp),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.versionTag,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
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
                      Icon(Icons.verified_outlined, size: 13, color: AppTheme.primaryTeal),
                      SizedBox(width: 3),
                      Text('Hash SHA-256', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 12, color: Color(0xFFF1F5F9)),

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (entry.peakFlowBest > 0)
                _buildChip('🫁 Sopro: ${entry.peakFlowBest} L/min ($zoneName)', const Color(0xFFF0FDF4), const Color(0xFF166534)),
              _buildChip('🩸 Oxigênio: ${entry.spo2}%', const Color(0xFFF0FDFA), const Color(0xFF0F766E)),
              if (entry.medications.isNotEmpty)
                _buildChip('💊 ${entry.medications.length} remédio(s) administrado(s)', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
              if (entry.physiotherapy != null)
                _buildChip('🫁 Fisioterapia: ${entry.physiotherapy!.deviceName}', const Color(0xFFFAF5FF), const Color(0xFF7E22CE)),
              if (entry.mouthRinseCompleted)
                _buildChip('💧 Bochecho Realizado', const Color(0xFFECFDF5), const Color(0xFF047857)),
            ],
          ),

          if (entry.symptoms.isNotEmpty && !entry.symptoms.contains('Sem sintomas aparentes')) ...[
            const SizedBox(height: 6),
            Text(
              'Sintomas notados: ${entry.symptoms.join(', ')}',
              style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w500),
            ),
          ],

          if (entry.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Nota: "${entry.notes}"',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: text)),
    );
  }
}
