import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_tokens.dart';

/// Superfície de vidro fosco translúcida com fio dourado de acabamento.
///
/// Padrão LCF: fundo translúcido (30 %) sobre BackdropFilter (efeito fosco do
/// que está atrás da folha) + fio dourado acompanhando a aresta superior e os
/// arcos dos cantos arredondados (30 px) — para no fim do arredondamento;
/// laterais e base sem dourado. Conteúdo interno deve ser sólido/opaco.
class LexGlassSheet extends StatelessWidget {
  const LexGlassSheet({
    super.key,
    required this.child,
    this.height,
    this.topRadius = 30.0,
  });

  final Widget child;
  final double? height;
  final double topRadius;

  /// Exibe um [LexGlassSheet] como bottom sheet com a configuração padrão LEX
  /// (fundo transparente, scroll controlado).
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    double? height,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => LexGlassSheet(height: height, child: builder(ctx)),
      );

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(top: Radius.circular(topRadius));
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassFrostSigma, sigmaY: kGlassFrostSigma),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withValues(alpha: kGlassSurfaceOpacity),
              borderRadius: radius,
            ),
            child: Stack(
              children: [
                // Com height definido o conteúdo preenche a folha; sem height a
                // folha dimensiona pela altura intrínseca do conteúdo.
                if (height != null) Positioned.fill(child: child) else child,
                // Fio dourado: arco esquerdo + aresta do topo + arco direito.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GoldTrimPainter(
                        radius: topRadius,
                        color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
                        strokeWidth: kGlassTrimStroke,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Traça o fio dourado seguindo a curvatura do topo: começa onde a lateral
/// reta encontra o arco do canto superior esquerdo, percorre o arco, a aresta
/// superior e o arco do canto direito, e para no início da lateral direita.
class _GoldTrimPainter extends CustomPainter {
  const _GoldTrimPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
  });

  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Inset de meia espessura — sem ele o ClipRRect externo cortaria a metade
    // de fora do traço.
    final inset = strokeWidth / 2;
    final arcRadius = Radius.circular(radius - inset);

    final path = Path()
      ..moveTo(inset, radius)
      ..arcToPoint(Offset(radius, inset), radius: arcRadius)
      ..lineTo(size.width - radius, inset)
      ..arcToPoint(Offset(size.width - inset, radius), radius: arcRadius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GoldTrimPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
