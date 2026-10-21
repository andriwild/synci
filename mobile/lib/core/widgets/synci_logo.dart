import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The Synci symbol, a calendar with sync arrows, drawn as vector so the arrows can turn.
class SynciLogo extends StatelessWidget {
  const SynciLogo({super.key, this.size = 48, this.syncTurns});

  final double size;

  /// Turns of the sync arrows; they turn counterclockwise, the way they point.
  final Animation<double>? syncTurns;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Synci',
    image: true,
    child: CustomPaint(size: Size.square(size), painter: _SynciLogoPainter(syncTurns)),
  );
}

class _SynciLogoPainter extends CustomPainter {
  _SynciLogoPainter(this.syncTurns) : super(repaint: syncTurns);

  final Animation<double>? syncTurns;

  // The logo is made of two Tabler icons (24 unit grid); measured on assets/icon/symbol.png
  static const _viewBox = Rect.fromLTWH(3.02, 2.02, 30.8, 30.8);
  static const _strokeWidth = 1.95;
  static const _syncOffset = Offset(12.84, 11.89);
  static const _syncCenter = Offset(12, 12);

  static final _calendar = Path()
    ..moveTo(12.5, 21)
    ..lineTo(6, 21)
    ..arcToPoint(const Offset(4, 19), radius: const Radius.circular(2))
    ..lineTo(4, 7)
    ..arcToPoint(const Offset(6, 5), radius: const Radius.circular(2))
    ..lineTo(18, 5)
    ..arcToPoint(const Offset(20, 7), radius: const Radius.circular(2))
    ..lineTo(20, 12)
    ..moveTo(16, 3)
    ..lineTo(16, 7)
    ..moveTo(8, 3)
    ..lineTo(8, 7)
    ..moveTo(4, 11)
    ..lineTo(20, 11);

  static final _upperArrow = Path()
    ..moveTo(20, 11)
    ..arcToPoint(const Offset(4.5, 9), radius: const Radius.circular(8.1), clockwise: false)
    ..moveTo(4, 5)
    ..lineTo(4, 9)
    ..lineTo(8, 9);

  static final _lowerArrow = Path()
    ..moveTo(4, 13)
    ..arcToPoint(const Offset(19.5, 15), radius: const Radius.circular(8.1), clockwise: false)
    ..moveTo(20, 19)
    ..lineTo(20, 15)
    ..lineTo(16, 15);

  static Paint _stroke(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _viewBox.width;
    final pivot = _syncOffset + _syncCenter;
    canvas
      ..translate((size.width - _viewBox.width * scale) / 2, (size.height - _viewBox.height * scale) / 2)
      ..scale(scale)
      ..translate(-_viewBox.left, -_viewBox.top)
      ..drawPath(_calendar, _stroke(const Color(0xFF293241)))
      ..translate(pivot.dx, pivot.dy)
      ..rotate(-2 * math.pi * (syncTurns?.value ?? 0))
      ..translate(-_syncCenter.dx, -_syncCenter.dy)
      ..drawPath(_upperArrow, _stroke(const Color(0xFF3D5A80)))
      ..drawPath(_lowerArrow, _stroke(const Color(0xFF98C1D9)));
  }

  @override
  bool shouldRepaint(_SynciLogoPainter oldDelegate) => oldDelegate.syncTurns != syncTurns;
}
