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
    final avatarEmoji = profile.gender == 'Feminino' ? '👧' : '👦';

    if (isCompact) {
      return InkWell(
        onTap: onSwitchTap,
        borderRadius: HCRadii.radiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: HCColors.primary50,
            borderRadius: HCRadii.radiusPill,
            border: Border.all(color: HCColors.primary200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(avatarEmoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  profile.name,
                  style: HCTypography.labelBold.copyWith(
                    color: HCColors.primary700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showSwitchAction && onSwitchTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: HCColors.primary700),
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
        color: HCColors.primary50,
        borderRadius: HCRadii.radiusMd,
        border: Border.all(color: HCColors.primary200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(avatarEmoji, style: const TextStyle(fontSize: 18)),
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
                      'Paciente Selecionado:',
                      style: HCTypography.bodySmall.copyWith(
                        color: HCColors.primary700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: HCRadii.radiusSm,
                        border: Border.all(color: HCColors.primary200),
                      ),
                      child: Text(
                        profile.ageDisplay,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: HCColors.primary700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.name,
                  style: HCTypography.subHeading.copyWith(
                    color: HCColors.neutral900,
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
                backgroundColor: Colors.white,
                side: const BorderSide(color: HCColors.primary300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusSm),
              ),
              icon: const Icon(Icons.swap_horiz, size: 14, color: HCColors.primary600),
              label: Text(
                'Trocar',
                style: HCTypography.bodySmall.copyWith(
                  color: HCColors.primary700,
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
