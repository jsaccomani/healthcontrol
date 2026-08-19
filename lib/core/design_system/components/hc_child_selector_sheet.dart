import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';
import 'hc_button.dart';

/// Modal bottom sheet para seleção rápida e segura entre filhos ou adição de um novo filho.
class HCChildSelectorSheet extends StatelessWidget {
  final List<PatientProfile> profiles;
  final String selectedProfileId;
  final ValueChanged<PatientProfile> onSelect;
  final VoidCallback onAddNew;

  const HCChildSelectorSheet({
    super.key,
    required this.profiles,
    required this.selectedProfileId,
    required this.onSelect,
    required this.onAddNew,
  });

  static Future<PatientProfile?> show({
    required BuildContext context,
    required List<PatientProfile> profiles,
    required String selectedProfileId,
    required ValueChanged<PatientProfile> onSelect,
    required VoidCallback onAddNew,
  }) {
    return showModalBottomSheet<PatientProfile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => HCChildSelectorSheet(
        profiles: profiles,
        selectedProfileId: selectedProfileId,
        onSelect: (p) {
          onSelect(p);
          Navigator.pop(ctx, p);
        },
        onAddNew: () {
          Navigator.pop(ctx);
          onAddNew();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de puxar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HCColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.family_restroom, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Meus Filhos',
                  style: HCTypography.heading.copyWith(color: HCColors.neutral900),
                ),
                const Spacer(),
                Text(
                  '${profiles.length} cadastrado(s)',
                  style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Selecione a criança para visualizar ou registrar dados clínicos:',
              style: HCTypography.bodySmall.copyWith(color: HCColors.neutral600),
            ),
            const SizedBox(height: 16),

            // Lista de Crianças
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final p = profiles[idx];
                  final isSelected = p.id == selectedProfileId;
                  final emoji = p.gender == 'Feminino' ? '👧' : '👦';

                  return Material(
                    color: isSelected ? HCColors.primary50 : Colors.white,
                    borderRadius: HCRadii.radiusMd,
                    child: InkWell(
                      onTap: () => onSelect(p),
                      borderRadius: HCRadii.radiusMd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: HCRadii.radiusMd,
                          border: Border.all(
                            color: isSelected ? HCColors.primary500 : HCColors.neutral200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isSelected ? Colors.white : HCColors.neutral100,
                              child: Text(emoji, style: const TextStyle(fontSize: 22)),
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
                                          p.name,
                                          style: HCTypography.subHeading.copyWith(
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            color: isSelected ? HCColors.primary900 : HCColors.neutral900,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? HCColors.primary100 : HCColors.neutral100,
                                          borderRadius: HCRadii.radiusSm,
                                        ),
                                        child: Text(
                                          p.ageDisplay,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? HCColors.primary700 : HCColors.neutral700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PFE Recorde: ${p.personalBestPef} L/min • ${p.weightKg} kg • ${p.bloodType}',
                                    style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: HCColors.primary600, size: 22)
                            else
                              const Icon(Icons.chevron_right, color: HCColors.neutral400, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: HCColors.neutral200),
            const SizedBox(height: 8),

            // Botão Adicionar Filho
            HCSecondaryButton(
              label: 'Cadastrar Outro Filho',
              icon: Icons.person_add_alt_1,
              width: double.infinity,
              onPressed: onAddNew,
            ),
          ],
        ),
      ),
    );
  }
}
