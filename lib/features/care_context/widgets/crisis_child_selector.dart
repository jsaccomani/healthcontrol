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
    final theme = context.hcTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: HCRadii.radiusLg,
          side: BorderSide(
            color: theme.border,
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
                style: HCTypography.heading.copyWith(
                  fontSize: 16,
                  color: theme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Você será direcionado para o plano de resgate médico imediato cadastrado para ${profile.name.split(" ").first}.',
          style: HCTypography.bodySmall.copyWith(
            color: theme.textSecondary,
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
                color: theme.textSecondary,
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
    final theme = context.hcTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: theme.surface,
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
                      style: HCTypography.heading.copyWith(
                        fontSize: 16,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecione a criança para carregar a prescrição de resgate correta:',
                  style: HCTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...profiles.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: theme.criticalBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: HCRadii.radiusMd,
                        side: BorderSide(
                          color: theme.criticalBorder,
                          width: 1.2,
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
                            color: theme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${p.ageDisplay}${p.weightKg > 0 ? " • ${p.weightKg.toString().replaceAll('.', ',')} kg" : ""}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
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
