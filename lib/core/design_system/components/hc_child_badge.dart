import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';

/// Badge / Pílula visual que indica inequivocamente qual filho está ativo no momento.
/// Evita erro humano de lançar dados clínicos para a criança errada.
class HCChildContextBadge extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback? onSwitchTap;
  final bool isCompact;
  final bool showSwitchAction;

  const HCChildContextBadge({
    super.key,
    required this.profile,
    this.onSwitchTap,
    this.isCompact = false,
    this.showSwitchAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'HC';

    if (isCompact) {
      return InkWell(
        onTap: onSwitchTap,
        borderRadius: HCRadii.radiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? HCColors.darkSurfaceElevated : HCColors.primary50,
            borderRadius: HCRadii.radiusPill,
            border: Border.all(
              color: isDark ? HCColors.darkBorder : HCColors.primary200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: HCColors.primary500,
                child: Text(
                  initials.isNotEmpty ? initials[0] : 'P',
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  profile.name,
                  style: HCTypography.labelBold.copyWith(
                    color: isDark ? HCColors.darkTextPrimary : HCColors.primary700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showSwitchAction && onSwitchTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark ? HCColors.darkTextSecondary : HCColors.primary700,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurfaceElevated : HCColors.primary50,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(
          color: isDark ? HCColors.darkBorder : HCColors.primary200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: HCColors.primary500,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Criança Ativa:',
                      style: HCTypography.bodySmall.copyWith(
                        color: isDark ? HCColors.darkTextSecondary : HCColors.primary700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? HCColors.darkSurface : Colors.white,
                        borderRadius: HCRadii.radiusSm,
                        border: Border.all(
                          color: isDark ? HCColors.darkBorder : HCColors.primary200,
                        ),
                      ),
                      child: Text(
                        profile.ageDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? HCColors.darkTextPrimary : HCColors.primary700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.name,
                  style: HCTypography.subHeading.copyWith(
                    color: isDark ? HCColors.darkTextPrimary : HCColors.neutral900,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showSwitchAction && onSwitchTap != null) ...[
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSwitchTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark ? HCColors.darkSurface : Colors.white,
                side: BorderSide(
                  color: isDark ? HCColors.darkBorder : HCColors.primary300,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusSm),
              ),
              icon: const Icon(Icons.swap_horiz, size: 14, color: HCColors.primary500),
              label: Text(
                'Trocar',
                style: HCTypography.bodySmall.copyWith(
                  color: isDark ? HCColors.darkTextPrimary : HCColors.primary700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
