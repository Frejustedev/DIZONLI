import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/app_colors.dart';

/// Widget de cercle de progression animé pour les pas
class ProgressRing extends StatelessWidget {
  final int current;
  final int goal;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    Key? key,
    required this.current,
    required this.goal,
    this.size = 200,
    this.strokeWidth = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: Colors.grey[200]!,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: progress,
              color: _getProgressColor(progress),
              strokeWidth: strokeWidth,
              gradient: LinearGradient(
                colors: [
                  _getProgressColor(progress),
                  _getProgressColor(progress).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                current.toString(),
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                'pas',
                style: TextStyle(
                  fontSize: size * 0.06,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(progress).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: size * 0.05,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(progress),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Objectif: $goal',
                style: TextStyle(
                  fontSize: size * 0.04,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Achievement badge if goal reached
          if (progress >= 1.0)
            Positioned(
              top: size * 0.1,
              right: size * 0.15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return AppColors.success;
    } else if (progress >= 0.75) {
      return AppColors.primary;
    } else if (progress >= 0.5) {
      return AppColors.secondary;
    } else {
      return AppColors.accent;
    }
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Gradient? gradient;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = color;
    }

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

