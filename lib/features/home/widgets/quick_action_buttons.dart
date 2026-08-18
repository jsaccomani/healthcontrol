import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Botões de Ações Rápidas da Home: SOS, Atualizar Receita, Novo Lançamento.
class QuickActionButtons extends StatelessWidget {
  final VoidCallback onNewEntry;
  final VoidCallback onUpdatePrescription;
  final VoidCallback onSosPressed;

  const QuickActionButtons({
    super.key,
    required this.onNewEntry,
    required this.onUpdatePrescription,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: onNewEntry,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'Anotar Agora 📝',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onSosPressed,
              child: const Text('🚨 SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E),
              side: const BorderSide(color: Color(0xFF99F6E4)),
              backgroundColor: const Color(0xFFF0FDFA),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onUpdatePrescription,
            icon: const Icon(Icons.document_scanner_outlined, size: 16, color: Color(0xFF0F766E)),
            label: const Text(
              'Atualizar receita médica da criança 📸',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
