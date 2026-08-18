import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Banner inferior com atalhos para Health Control Pro, Quiz c-ACT e Fisioterapia.
class ProConnectBanner extends StatelessWidget {
  final VoidCallback onOpenProConnect;
  final VoidCallback onOpenCactQuiz;
  final VoidCallback onOpenPhysio;

  const ProConnectBanner({
    super.key,
    required this.onOpenProConnect,
    required this.onOpenCactQuiz,
    required this.onOpenPhysio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onOpenProConnect,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_2, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conectar ao Médico (Health Control Pro)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Compartilhe os dados com o pneumologista/pediatra via QR Code',
                        style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryNavButton(
                icon: Icons.quiz_outlined,
                title: 'Questionário c-ACT',
                subtitle: 'Avalie o controle mensal',
                color: AppTheme.primaryTeal,
                onTap: onOpenCactQuiz,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSecondaryNavButton(
                icon: Icons.fitness_center_outlined,
                title: 'Fisioterapia / CPAP',
                subtitle: 'Segurança AMIB',
                color: const Color(0xFF7C3AED),
                onTap: onOpenPhysio,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryNavButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
