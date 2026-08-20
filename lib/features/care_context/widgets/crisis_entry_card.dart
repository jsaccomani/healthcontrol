import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Ação Global de Crise ("CRIANÇA EM CRISE").
/// Projetado com alta saliência visual e controle estético sofisticado (sem vermelho berrante excessivo).
/// Hierarquia: Ícone -> Título -> Descrição Curta -> Ação.
class CrisisEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const CrisisEntryCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    return Material(
      color: theme.criticalBg,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: theme.criticalBorder,
          width: 1.2,
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
                width: 42,
                height: 42,
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

              // Textos do Alerta de Crise (Título + Descrição Curta)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRIANÇA EM CRISE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: theme.criticalText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Iniciar atendimento de emergência',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

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
                      size: 10,
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
