import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;

class EyeVisualizationWidget extends StatefulWidget {
  const EyeVisualizationWidget({super.key});

  @override
  State<EyeVisualizationWidget> createState() => _EyeVisualizationWidgetState();
}

class _EyeVisualizationWidgetState extends State<EyeVisualizationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _rotationZ = 0.0;
  double _zoom = 1.0;
  bool _isWireframe = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _rotationY += details.focalPointDelta.dx * 0.01;
          _rotationX += details.focalPointDelta.dy * 0.01;
          _zoom = details.scale.clamp(0.5, 2.0);
        });
      },
      child: Container(
        height: 280,
        width: double.infinity,
        child: Center(
          child: CustomPaint(
            size: const Size(200, 200),
            painter: Eye3DPainter(
              rotationX: _rotationX,
              rotationY: _rotationY,
              rotationZ: _rotationZ,
              zoom: _zoom,
              isWireframe: _isWireframe,
              animationValue: _controller.value,
            ),
          ),
        ),
      ),
    );
  }

  void toggleWireframe() {
    setState(() {
      _isWireframe = !_isWireframe;
    });
  }

  void resetView() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _rotationZ = 0.0;
      _zoom = 1.0;
    });
  }
}

class Eye3DPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double zoom;
  final bool isWireframe;
  final double animationValue;

  Eye3DPainter({
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
    required this.zoom,
    required this.isWireframe,
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

    // Apply rotations in 3D space
    canvas.rotate(rotationY);

    // Apply 3D transformations using matrix
    final matrix = vm.Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(rotationX)
      ..rotateZ(rotationZ)
      ..scale(zoom);

    canvas.transform(matrix.storage);

    // Draw the 3D eye
    if (isWireframe) {
      _drawWireframeEye(canvas, radius);
    } else {
      _drawSolidEye(canvas, radius);
    }

    canvas.restore();
  }

  void _drawSolidEye(Canvas canvas, double radius) {
    // Draw multiple circles at different depths to create sphere effect
    final numLayers = 20;

    for (int i = 0; i < numLayers; i++) {
      final depth = i / (numLayers - 1); // 0 to 1
      final layerRadius = radius * math.sqrt(1 - math.pow(depth - 0.5, 2) * 4);
      final yOffset = (depth - 0.5) * radius * 0.8;

      if (layerRadius > 5) {
        // Create gradient for each layer based on depth
        final layerGradient = RadialGradient(
          colors: [
            Color.lerp(
                const Color(0xFFF0F8FF), const Color(0xFF4A90E2), depth)!,
            Color.lerp(
                const Color(0xFFE8F4FD), const Color(0xFF2E5B8A), depth)!,
            Color.lerp(
                const Color(0xFFB8D4F0), const Color(0xFF1E3A5F), depth)!,
          ],
          stops: const [0.0, 0.6, 1.0],
        );

        final layerPaint = Paint()
          ..shader = layerGradient.createShader(
            Rect.fromCircle(center: Offset(0, yOffset), radius: layerRadius),
          );

        canvas.drawCircle(Offset(0, yOffset), layerRadius, layerPaint);
      }
    }

    // Draw iris with 3D depth
    final irisRadius = radius * 0.35;
    _drawIris3D(canvas, irisRadius);

    // Draw pupil with depth
    final pupilRadius = irisRadius * 0.4;
    final pupilPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black, Colors.black87],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: pupilRadius));

    canvas.drawCircle(Offset.zero, pupilRadius, pupilPaint);

    // Add realistic highlights for 3D effect
    final highlightOffset = Offset(-irisRadius * 0.3, -irisRadius * 0.3);
    canvas.drawCircle(
      highlightOffset,
      pupilRadius * 0.4,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Add secondary highlight
    canvas.drawCircle(
      Offset(-irisRadius * 0.1, -irisRadius * 0.1),
      pupilRadius * 0.2,
      Paint()..color = Colors.white.withOpacity(0.6),
    );

    // Draw eye veins for realism
    _drawEyeVeins(canvas, radius);

    // Add corneal reflection
    _drawCornealReflection(canvas, radius);
  }

  void _drawWireframeEye(Canvas canvas, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw horizontal circles (cross-sections) for 3D sphere effect
    final numCircles = 16;
    for (int i = 0; i < numCircles; i++) {
      final depth = i / (numCircles - 1); // 0 to 1
      final yOffset = (depth - 0.5) * radius * 0.8;
      final circleRadius = radius * math.sqrt(1 - math.pow(depth - 0.5, 2) * 4);

      if (circleRadius > 5) {
        // Apply perspective transformation
        final perspective = 1.0 - (depth - 0.5).abs() * 0.4;
        canvas.drawCircle(
          Offset(0, yOffset),
          circleRadius * perspective,
          paint,
        );
      }
    }

    // Draw vertical lines for 3D structure
    final numLines = 20;
    for (int i = 0; i < numLines; i++) {
      final angle = (i * 2 * math.pi) / numLines;
      final startX = math.cos(angle) * radius * 0.8;
      final startY = math.sin(angle) * radius * 0.8;
      final endX = math.cos(angle) * radius * 0.3;
      final endY = math.sin(angle) * radius * 0.3;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw iris wireframe
    final irisRadius = radius * 0.35;
    canvas.drawCircle(Offset.zero, irisRadius, paint);

    // Draw pupil wireframe
    final pupilRadius = irisRadius * 0.4;
    canvas.drawCircle(Offset.zero, pupilRadius, paint);
  }

  void _drawIris3D(Canvas canvas, double radius) {
    // Create realistic iris gradient with depth
    final irisGradient = RadialGradient(
      colors: [
        const Color(0xFF1A3A0A), // Very dark green center
        const Color(0xFF2D5016), // Dark green
        const Color(0xFF4A5D23), // Medium green
        const Color(0xFF6B8E23), // Light green
        const Color(0xFF8B7355), // Brown edge
      ],
      stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
    );

    final irisPaint = Paint()
      ..shader = irisGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      );

    canvas.drawCircle(Offset.zero, radius, irisPaint);

    // Add iris texture lines for realism
    final texturePaint = Paint()
      ..color = const Color(0xFF2D5016).withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi) / 6;
      final startX = math.cos(angle) * radius * 0.2;
      final startY = math.sin(angle) * radius * 0.2;
      final endX = math.cos(angle) * radius * 0.9;
      final endY = math.sin(angle) * radius * 0.9;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        texturePaint,
      );
    }

    // Add radial iris lines
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final startX = math.cos(angle) * radius * 0.3;
      final startY = math.sin(angle) * radius * 0.3;
      final endX = math.cos(angle) * radius * 0.8;
      final endY = math.sin(angle) * radius * 0.8;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        texturePaint,
      );
    }
  }

  void _drawEyeVeins(Canvas canvas, double radius) {
    final veinPaint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.25)
      ..strokeWidth = 1.5;

    // Draw realistic eye veins
    final veins = [
      [
        Offset(-radius * 0.7, -radius * 0.3),
        Offset(-radius * 0.2, -radius * 0.1)
      ],
      [
        Offset(radius * 0.5, -radius * 0.4),
        Offset(radius * 0.1, -radius * 0.2)
      ],
      [
        Offset(-radius * 0.3, radius * 0.6),
        Offset(-radius * 0.1, radius * 0.2)
      ],
      [Offset(radius * 0.4, radius * 0.3), Offset(radius * 0.2, radius * 0.1)],
      [
        Offset(-radius * 0.5, radius * 0.1),
        Offset(-radius * 0.1, radius * 0.3)
      ],
    ];

    for (final vein in veins) {
      canvas.drawLine(vein[0], vein[1], veinPaint);
    }
  }

  void _drawCornealReflection(canvas, double radius) {
    // Add corneal reflection for realistic 3D effect
    final reflectionPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius * 0.95, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant Eye3DPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.rotationZ != rotationZ ||
        oldDelegate.zoom != zoom ||
        oldDelegate.isWireframe != isWireframe ||
        oldDelegate.animationValue != animationValue;
  }
}
