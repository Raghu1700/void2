import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedEyeVisualization extends StatefulWidget {
  const AnimatedEyeVisualization({super.key});

  @override
  State<AnimatedEyeVisualization> createState() =>
      _AnimatedEyeVisualizationState();
}

class _AnimatedEyeVisualizationState extends State<AnimatedEyeVisualization> {
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _zoom = 1.0;
  Offset? _lastFocalPoint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _lastFocalPoint = details.focalPoint;
      },
      onScaleUpdate: (details) {
        setState(() {
          if (_lastFocalPoint != null) {
            final delta = details.focalPoint - _lastFocalPoint!;
            _rotationY += delta.dx * 0.01;
            _rotationX -= delta.dy * 0.01;
            _lastFocalPoint = details.focalPoint;
          }
          if (details.scale != 1.0) {
            _zoom = (_zoom * details.scale).clamp(0.5, 2.5);
          }
        });
      },
      onScaleEnd: (details) {
        _lastFocalPoint = null;
      },
      child: Container(
        height: 280,
        width: double.infinity,
        child: Center(
          child: CustomPaint(
            size: const Size(200, 200),
            painter: SimpleEyePainter(
              rotationX: _rotationX,
              rotationY: _rotationY,
              zoom: _zoom,
              animationValue: 0.0,
            ),
          ),
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

    // Apply 3D transformations
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Apply 3D rotation
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(rotationX)
      ..rotateY(rotationY);

    canvas.transform(matrix.storage);

    // Draw the spherical eye with multiple depth layers
    _drawSphericalEye(canvas, radius);

    // Draw iris
    _drawIris(canvas, Offset.zero, radius);

    // Draw pupil
    _drawPupil(canvas, Offset.zero, radius);

    // Draw highlights
    _drawHighlights(canvas, Offset.zero, radius);

    canvas.restore();
  }

  void _drawSphericalEye(Canvas canvas, double radius) {
    // Draw multiple layers to create a 3D sphere effect
    final numLayers = 25;

    for (int i = 0; i < numLayers; i++) {
      final t = i / (numLayers - 1); // 0 to 1

      // Calculate depth from center of sphere (0 at front, 1 at back)
      final depth = t;

      // Calculate radius for this layer using sphere equation
      final layerRadius = radius * math.sqrt(1 - math.pow(depth - 0.5, 2) * 4);
      final zOffset = (depth - 0.5) * radius;

      if (layerRadius > 5) {
        // Calculate color based on depth for 3D effect
        final brightness = 1.0 - (depth * 0.3);

        // Create a radial gradient for each layer
        final layerGradient = RadialGradient(
          colors: [
            Color.lerp(
              const Color(0xFFF0F8FF),
              const Color(0xFF90CAF9),
              depth * 0.5,
            )!
                .withOpacity(brightness),
            Color.lerp(
              const Color(0xFFE3F2FD),
              const Color(0xFF64B5F6),
              depth * 0.7,
            )!
                .withOpacity(brightness),
            Color.lerp(
              const Color(0xFFBBDEFB),
              const Color(0xFF42A5F5),
              depth,
            )!
                .withOpacity(brightness),
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        final layerPaint = Paint()
          ..shader = layerGradient.createShader(
            Rect.fromCircle(
                center: Offset(0, zOffset * 0.3), radius: layerRadius),
          );

        canvas.drawCircle(Offset(0, zOffset * 0.3), layerRadius, layerPaint);
      }
    }

    // Add sphere shading overlay
    final shadingGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        Colors.white.withOpacity(0.3),
        Colors.transparent,
        Colors.black.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final shadingPaint = Paint()
      ..shader = shadingGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );

    canvas.drawCircle(Offset.zero, radius, shadingPaint);
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
