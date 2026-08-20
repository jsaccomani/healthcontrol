import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Ação Global de Crise ("CRIANÇA EM CRISE").
/// Projetado com alta saliência visual e controle estético (sem vermelho berrante excessivo).
class CrisisEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const CrisisEntryCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF2C0B0B) : const Color(0xFFFEF2F2),
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: HCRadii.radiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ícone de Emergência Clínico
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HCColors.redMain,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Textos do Alerta de Crise
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRIANÇA EM CRISE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFFFCA5A5) : HCColors.redMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Iniciar atendimento de emergência e resgate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador de Ação Imediata
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: HCColors.redMain,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
