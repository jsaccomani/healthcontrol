import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de Identificação da Criança Selecionada na Home.
/// Apresenta os dados vitais de contexto (idade, peso e PFE recorde) com alta escaneabilidade.
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
    final theme = context.hcTheme;
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'HC';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusXl,
        border: Border.all(color: theme.border),
        boxShadow: theme.isDark ? null : HCShadows.elevated,
      ),
      child: Row(
        children: [
          // Avatar com iniciais em squircle com gradiente e sombra sutil
          InkWell(
            onTap: onSwitchChild ?? onOpenProfile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary,
                    Color.lerp(theme.primary, Colors.black, 0.18) ?? theme.primary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
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
                          color: theme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.elevatedSurface,
                        borderRadius: HCRadii.radiusSm,
                        border: Border.all(color: theme.border),
                      ),
                      child: Text(
                        profile.ageDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Recorde PFE: ${profile.personalBestPef} L/min • Peso: ${profile.weightKg} kg',
                  style: HCTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
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
              size: 14,
              color: theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
