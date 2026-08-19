import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Card de cabeçalho com perfil do filho, avatar de iniciais e seletor rápido.
class HomeHeaderCard extends StatelessWidget {
  final PatientProfile profile;
  final List<PatientProfile> allProfiles;
  final ValueChanged<PatientProfile> onProfileSelected;
  final VoidCallback onOpenProfile;
  final VoidCallback? onAddChild;

  const HomeHeaderCard({
    super.key,
    required this.profile,
    required this.allProfiles,
    required this.onProfileSelected,
    required this.onOpenProfile,
    this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.trim().isNotEmpty
        ? profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'HC';

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: HCColors.primary500,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: HCTypography.subHeading.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HCColors.neutral900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: HCColors.neutral100,
                            borderRadius: HCRadii.radiusSm,
                            border: Border.all(color: HCColors.neutral200),
                          ),
                          child: Text(
                            profile.ageDisplay,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: HCColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Recorde PFE: ${profile.personalBestPef} L/min • Peso: ${profile.weightKg} kg',
                      style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ficha Completa',
                onPressed: onOpenProfile,
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: HCColors.neutral400),
              ),
            ],
          ),
          if (allProfiles.length > 1) ...[
            const Divider(height: 20, color: HCColors.neutral200),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 16, color: HCColors.neutral500),
                const SizedBox(width: 6),
                Text(
                  'Crianças:',
                  style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: HCColors.neutral600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allProfiles.map((p) {
                        final isSelected = p.id == profile.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(
                              p.name.split(' ').first,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? HCColors.primary800 : HCColors.neutral700,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: HCColors.primary100,
                            backgroundColor: HCColors.neutral50,
                            side: BorderSide(
                              color: isSelected ? HCColors.primary300 : HCColors.neutral200,
                            ),
                            onSelected: (selected) {
                              if (selected) onProfileSelected(p);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
