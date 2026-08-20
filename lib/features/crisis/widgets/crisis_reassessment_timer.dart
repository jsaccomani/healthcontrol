import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Componente Isolado de Temporizador de Reavaliação Pós-Resgate (20 minutos).
/// Princípio de Performance & Resiliência:
/// - Possui seu próprio ciclo de rebuild (não reconstrói a tela inteira a cada segundo).
/// - Deriva a contagem estritamente do timestamp absoluto [reassessmentAt] (resiste a background/restart).
class CrisisReassessmentTimer extends StatefulWidget {
  final DateTime? reassessmentAt;
  final VoidCallback? onStartManualTimer;

  const CrisisReassessmentTimer({
    super.key,
    this.reassessmentAt,
    this.onStartManualTimer,
  });

  @override
  State<CrisisReassessmentTimer> createState() => _CrisisReassessmentTimerState();
}

class _CrisisReassessmentTimerState extends State<CrisisReassessmentTimer> {
  Timer? _ticker;
  int _secondsRemaining = 0;
  bool _hasTriggeredNotification = false;

  @override
  void initState() {
    super.initState();
    _recalcTime();
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant CrisisReassessmentTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reassessmentAt != widget.reassessmentAt) {
      _hasTriggeredNotification = false;
      _recalcTime();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _recalcTime() {
    if (widget.reassessmentAt != null) {
      final diff = widget.reassessmentAt!.difference(DateTime.now()).inSeconds;
      _secondsRemaining = diff > 0 ? diff : 0;
    } else {
      _secondsRemaining = 0;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (widget.reassessmentAt != null) {
        final diff = widget.reassessmentAt!.difference(DateTime.now()).inSeconds;
        if (diff > 0) {
          setState(() => _secondsRemaining = diff);
        } else {
          setState(() => _secondsRemaining = 0);
          if (!_hasTriggeredNotification) {
            _hasTriggeredNotification = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tempo de reavaliação atingido (20 min). Observe a respiração e meça o Peak Flow da criança.',
                ),
                backgroundColor: HCColors.redMain,
                duration: Duration(seconds: 8),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = _secondsRemaining > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HCColors.darkSurface : Colors.white,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
        ),
        boxShadow: HCShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: HCColors.primary600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reavaliação Pós-Resgate (20 min)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? HCColors.darkText : HCColors.primary700,
                    ),
                  ),
                ],
              ),
              if (!isRunning && widget.onStartManualTimer != null)
                TextButton(
                  onPressed: widget.onStartManualTimer,
                  child: const Text(
                    'Iniciar 20 min',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isRunning) ...[
            Center(
              child: Text(
                _formatTimer(_secondsRemaining),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: HCColors.primary600,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (20 * 60 - _secondsRemaining) / (20 * 60),
                backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(HCColors.primary500),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde o tempo de ação do broncodilatador. Ao zerar, verifique a expansão torácica e meça o sopro.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
              ),
            ),
          ] else ...[
            Text(
              'Recomenda-se aguardar 20 minutos após a bombinha de resgate para verificar se o sopro voltou para a Zona Verde ou se necessita ir ao Pronto-Socorro.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
