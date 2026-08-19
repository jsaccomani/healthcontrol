import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Identificação da Criança Selecionada na Home.
/// Apresenta os dados vitais de contexto (idade, peso e PFE recorde) sem duplicar a seleção de filhos.
class HomeHeaderCard extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onOpenProfile;
  final VoidCallback? onSwitchChild;

  const HomeHeaderCard({
    super.key,
    required this.profile,
    required this.onOpenProfile,
    this.onSwitchChild,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'HC';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : HCColors.surfaceWhite,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: isDark ? HCColors.darkBorder : HCColors.neutral200),
        boxShadow: isDark ? null : HCShadows.subtle,
      ),
      child: Row(
        children: [
          // Avatar com iniciais
          InkWell(
            onTap: onSwitchChild ?? onOpenProfile,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: HCColors.primary500,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informações Principais
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        style: HCTypography.heading.copyWith(
                          fontSize: 16,
                          color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? HCColors.darkSurfaceElevated : HCColors.neutral100,
                        borderRadius: HCRadii.radiusSm,
                        border: Border.all(
                          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
                        ),
                      ),
                      child: Text(
                        profile.ageDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? HCColors.darkTextSecondary : HCColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Recorde PFE: ${profile.personalBestPef} L/min • Peso: ${profile.weightKg} kg',
                  style: HCTypography.bodySmall.copyWith(
                    color: isDark ? HCColors.darkTextSecondary : HCColors.neutral600,
                  ),
                ),
              ],
            ),
          ),

          // Ação para abrir perfil completo
          IconButton(
            tooltip: 'Ficha Completa e Receitas',
            onPressed: onOpenProfile,
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? HCColors.darkTextMuted : HCColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
