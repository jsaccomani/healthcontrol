import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Componente Isolado de Temporizador de Reavaliação Pós-Resgate (20 minutos).
/// Responde imediatamente: "QUANDO REAVALIAR?"
///
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
                  'Tempo de reavaliação atingido (20 min). Observe o esforço respiratório e meça o Peak Flow.',
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
    final theme = context.hcTheme;
    final isRunning = _secondsRemaining > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(
          color: isRunning ? theme.primaryBorder : theme.border,
          width: isRunning ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.primarySubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: theme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'REAVALIAÇÃO (20 MIN)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (!isRunning && widget.onStartManualTimer != null)
                TextButton(
                  onPressed: widget.onStartManualTimer,
                  child: Text(
                    'Iniciar Manualmente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isRunning) ...[
            Center(
              child: Text(
                _formatTimer(_secondsRemaining),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: theme.primary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (20 * 60 - _secondsRemaining) / (20 * 60),
                backgroundColor: theme.elevatedSurface,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde 20 minutos para a ação plena do broncodilatador. Ao zerar, observe o esforço torácico e realize a medição do sopro.',
              textAlign: TextAlign.center,
              style: HCTypography.bodySmall.copyWith(
                color: theme.textSecondary,
                fontSize: 11,
              ),
            ),
          ] else ...[
            Text(
              'O temporizador de 20 minutos iniciará automaticamente ao confirmar a administração da dose de resgate.',
              style: HCTypography.bodySmall.copyWith(
                color: theme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
