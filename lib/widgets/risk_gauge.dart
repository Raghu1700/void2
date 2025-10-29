import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class RiskGaugeWidget extends StatelessWidget {
  final double riskLevel;

  const RiskGaugeWidget({
    super.key,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: RiskGaugePainter(riskLevel: riskLevel),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                riskLevel.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                'Risk Score',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiskGaugePainter extends CustomPainter {
  final double riskLevel;

  RiskGaugePainter({required this.riskLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Draw risk arc
    final riskPaint = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Color based on risk level
    if (riskLevel < 30) {
      riskPaint.shader = const LinearGradient(
        colors: [AppTheme.successGreen, Color(0xFF4CAF50)],
      ).createShader(rect);
    } else if (riskLevel < 60) {
      riskPaint.shader = const LinearGradient(
        colors: [AppTheme.warningOrange, Color(0xFFFF9800)],
      ).createShader(rect);
    } else {
      riskPaint.shader = const LinearGradient(
        colors: [AppTheme.dangerRed, Color(0xFFD32F2F)],
      ).createShader(rect);
    }

    final sweepAngle = (riskLevel / 100) * math.pi;

    canvas.drawArc(
      rect,
      math.pi,
      sweepAngle,
      false,
      riskPaint,
    );

    // Draw indicator line
    final indicatorAngle = math.pi + sweepAngle;
    final indicatorPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3;

    final indicatorX = center.dx + radius * math.cos(indicatorAngle);
    final indicatorY = center.dy + radius * math.sin(indicatorAngle);

    canvas.drawLine(
      center,
      Offset(indicatorX, indicatorY),
      indicatorPaint,
    );

    // Draw risk labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Low
    textPainter.text = const TextSpan(
      text: 'Low',
      style: TextStyle(
        color: AppTheme.successGreen,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - 30, center.dy + radius + 20),
    );

    // Moderate
    textPainter.text = const TextSpan(
      text: 'Mod',
      style: TextStyle(
        color: AppTheme.warningOrange,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - 20, center.dy - radius - 35),
    );

    // High
    textPainter.text = const TextSpan(
      text: 'High',
      style: TextStyle(
        color: AppTheme.dangerRed,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx + 30, center.dy + radius + 20),
    );
  }

  @override
  bool shouldRepaint(covariant RiskGaugePainter oldDelegate) {
    return oldDelegate.riskLevel != riskLevel;
  }
}

