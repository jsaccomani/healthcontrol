import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/theme/app_theme.dart';

/// Card de cabeçalho com perfil do filho, avatar e seletor rápido.
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  profile.gender == 'Feminino' ? '👧' : '👦',
                  style: const TextStyle(fontSize: 24),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            profile.ageDisplay,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Melhor Sopro Pessoal: ${profile.personalBestPef} L/min • ${profile.weightKg} kg • Sangue ${profile.bloodType}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ver Ficha Completa',
                onPressed: onOpenProfile,
                icon: const Icon(Icons.edit_note, color: AppTheme.primaryTeal),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...allProfiles.map((p) {
                  final isSelected = p.id == profile.id;
                  final emoji = p.gender == 'Feminino' ? '👧' : '👦';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Text(emoji, style: const TextStyle(fontSize: 12)),
                      label: Text(p.name.split(' ').first, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryLight,
                      onSelected: (selected) {
                        if (selected) onProfileSelected(p);
                      },
                    ),
                  );
                }),
                if (onAddChild != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: ActionChip(
                      avatar: const Icon(Icons.add, size: 14, color: AppTheme.primaryTeal),
                      label: const Text('+ Filho', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFCBD5E1), style: BorderStyle.solid),
                      onPressed: onAddChild,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
