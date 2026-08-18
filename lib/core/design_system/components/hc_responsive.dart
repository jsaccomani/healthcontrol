import 'package:flutter/material.dart';
import '../tokens/hc_spacing.dart';

/// Breakpoints Responsivos do Health Control (Material 3 Adaptive Design).
class HCBreakpoints {
  /// Telas compactas (Smartphones comuns e pequenos): < 600px
  static const double compact = 600.0;

  /// Telas médias (Tablets, telas dobráveis e pequenos laptops): 600px - 960px
  static const double medium = 960.0;

  /// Telas expandidas (Desktops e monitores grandes): > 960px
  static const double expanded = 1200.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

/// Container Responsivo que limita a largura máxima em telas grandes
/// garantindo leitura confortável e evitando formulários esticados em monitores desktop.
class HCResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const HCResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 760.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// Layout Adaptativo de Grade/Colunas (1 coluna no mobile, 2 colunas em tablets/desktop).
class HCAdaptiveTwoColumn extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double spacing;
  final double breakpoint;

  const HCAdaptiveTwoColumn({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.spacing = HCSpacing.md,
    this.breakpoint = HCBreakpoints.compact,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftChild),
              SizedBox(width: spacing),
              Expanded(child: rightChild),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftChild,
            SizedBox(height: spacing),
            rightChild,
          ],
        );
      },
    );
  }
}
