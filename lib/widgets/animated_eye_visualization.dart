import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedEyeVisualization extends StatefulWidget {
  const AnimatedEyeVisualization({super.key});

  @override
  State<AnimatedEyeVisualization> createState() =>
      _AnimatedEyeVisualizationState();
}

class _AnimatedEyeVisualizationState extends State<AnimatedEyeVisualization>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation - full 360 degrees continuous rotation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi, // Full 360 degrees
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      child: Center(
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_rotationAnimation.value), // Full 360 degree Y-axis rotation
              child: CustomPaint(
                size: const Size(200, 200),
                painter: SimpleEyePainter(
                  rotationX: 0.0,
                  rotationY: _rotationAnimation.value,
                  zoom: 1.0,
                  animationValue: _rotationAnimation.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SimpleEyePainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double zoom;
  final double animationValue;

  SimpleEyePainter({
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) * 0.4 * zoom).clamp(50.0, 120.0);

    // Draw the eye sphere
    _drawEyeSphere(canvas, center, radius);

    // Draw iris
    _drawIris(canvas, center, radius);

    // Draw pupil
    _drawPupil(canvas, center, radius);

    // Draw highlights
    _drawHighlights(canvas, center, radius);
  }

  void _drawEyeSphere(Canvas canvas, Offset center, double radius) {
    // Create gradient for the eye
    final eyeGradient = RadialGradient(
      colors: [
        const Color(0xFFE3F2FD),
        const Color(0xFFBBDEFB),
        const Color(0xFF90CAF9),
        const Color(0xFF64B5F6),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final eyePaint = Paint()
      ..shader = eyeGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, eyePaint);
  }

  void _drawIris(Canvas canvas, Offset center, double radius) {
    final irisRadius = radius * 0.35;

    // Create iris gradient
    final irisGradient = RadialGradient(
      colors: [
        const Color(0xFF1A3A0A),
        const Color(0xFF2D5016),
        const Color(0xFF4A5D23),
        const Color(0xFF6B8E23),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final irisPaint = Paint()
      ..shader = irisGradient.createShader(
        Rect.fromCircle(center: center, radius: irisRadius),
      );

    canvas.drawCircle(center, irisRadius, irisPaint);

    // Add iris texture lines
    final texturePaint = Paint()
      ..color = const Color(0xFF2D5016).withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi) / 6;
      final startX = center.dx + math.cos(angle) * irisRadius * 0.2;
      final startY = center.dy + math.sin(angle) * irisRadius * 0.2;
      final endX = center.dx + math.cos(angle) * irisRadius * 0.9;
      final endY = center.dy + math.sin(angle) * irisRadius * 0.9;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        texturePaint,
      );
    }
  }

  void _drawPupil(Canvas canvas, Offset center, double radius) {
    final pupilRadius = radius * 0.14;

    final pupilPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black,
          Colors.black87,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: pupilRadius));

    canvas.drawCircle(center, pupilRadius, pupilPaint);
  }

  void _drawHighlights(Canvas canvas, Offset center, double radius) {
    final pupilRadius = radius * 0.14;

    // Main highlight
    final highlightOffset = Offset(
      center.dx - pupilRadius * 0.3,
      center.dy - pupilRadius * 0.3,
    );

    canvas.drawCircle(
      highlightOffset,
      pupilRadius * 0.4,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Secondary highlight
    canvas.drawCircle(
      Offset(center.dx - pupilRadius * 0.1, center.dy - pupilRadius * 0.1),
      pupilRadius * 0.2,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(covariant SimpleEyePainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.animationValue != animationValue;
  }
}
