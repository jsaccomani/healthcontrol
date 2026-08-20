import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Helper modular para seleção segura de criança em crise respiratória.
/// Garante que o contexto do paciente seja explicitamente confirmado pelo cuidador.
class CrisisChildSelector {
  static void show({
    required BuildContext context,
    required List<PatientProfile> profiles,
    required ValueChanged<PatientProfile> onChildSelected,
  }) {
    if (profiles.isEmpty) return;

    if (profiles.length == 1) {
      _showSingleChildConfirmation(
        context: context,
        profile: profiles.first,
        onConfirmed: () => onChildSelected(profiles.first),
      );
    } else {
      _showMultiChildSelectionModal(
        context: context,
        profiles: profiles,
        onChildSelected: onChildSelected,
      );
    }
  }

  static void _showSingleChildConfirmation({
    required BuildContext context,
    required PatientProfile profile,
    required VoidCallback onConfirmed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? HCColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(
            color: isDark ? HCColors.darkBorder : HCColors.neutral200,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: HCColors.redMain.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emergency, color: HCColors.redMain, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${profile.name} está em crise?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? HCColors.darkText : HCColors.neutral900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Você será direcionado para o plano de resgate médico imediato cadastrado para ${profile.name.split(" ").first}.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HCColors.redMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusMd),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirmed();
            },
            child: const Text(
              'Continuar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void _showMultiChildSelectionModal({
    required BuildContext context,
    required List<PatientProfile> profiles,
    required ValueChanged<PatientProfile> onChildSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: HCColors.redMain.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.emergency, color: HCColors.redMain, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Qual criança está em crise?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? HCColors.darkText : HCColors.neutral900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecione a criança para carregar a prescrição de resgate correta:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                  ),
                ),
                const SizedBox(height: 16),
                ...profiles.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isDark ? const Color(0xFF2C0B0B) : const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: HCRadii.radiusMd,
                        side: BorderSide(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: HCColors.redMain.withAlpha(30),
                          child: const Icon(Icons.person, color: HCColors.redMain),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : HCColors.neutral900,
                          ),
                        ),
                        subtitle: Text(
                          '${p.ageDisplay}${p.weightKg > 0 ? " • ${p.weightKg} kg" : ""}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: HCColors.redMain,
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          onChildSelected(p);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
