import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';

class MoistureGauge extends StatefulWidget {
  final double? percentage;
  final SoilStatus? status;
  final bool isOnline;

  const MoistureGauge({
    super.key,
    required this.percentage,
    required this.status,
    required this.isOnline,
  });

  @override
  State<MoistureGauge> createState() => _MoistureGaugeState();
}

class _MoistureGaugeState extends State<MoistureGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animValue;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final target = (widget.isOnline && widget.percentage != null)
        ? widget.percentage!
        : 0.0;
    _animValue = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(MoistureGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = (widget.isOnline && widget.percentage != null)
        ? widget.percentage!
        : 0.0;
    final oldTarget = (oldWidget.isOnline && oldWidget.percentage != null)
        ? oldWidget.percentage!
        : 0.0;

    if (oldTarget != target) {
      _animValue = Tween<double>(
        begin: _animValue.value,
        end: target,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (!widget.isOnline || widget.percentage == null) {
      statusColor = const Color(0xFF64748B); // Slate grey when offline
    } else if (widget.status == SoilStatus.dry) {
      statusColor = const Color(0xFFEF4444);
    } else if (widget.status == SoilStatus.normal) {
      statusColor = const Color(0xFF10B981);
    } else {
      statusColor = const Color(0xFF3B82F6);
    }

    return AnimatedBuilder(
      animation: _animValue,
      builder: (context, _) {
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: _GaugePainter(
                  percentage: widget.isOnline ? _animValue.value : 0.0,
                  activeColor: statusColor,
                  isOnline: widget.isOnline,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    !widget.isOnline
                        ? Icons.sensors_off_rounded
                        : widget.status == SoilStatus.dry
                            ? Icons.warning_amber_rounded
                            : Icons.water_drop_rounded,
                    color: statusColor,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.isOnline && widget.percentage != null
                            ? _animValue.value.toStringAsFixed(0)
                            : '--',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: widget.isOnline
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.isOnline ? 'SOIL MOISTURE' : 'TOOL OFFLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: widget.isOnline
                          ? Colors.white.withOpacity(0.6)
                          : const Color(0xFFEF4444).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final bool isOnline;

  _GaugePainter({
    required this.percentage,
    required this.activeColor,
    required this.isOnline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 28) / 2;
    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // Background track paint
    final trackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    if (!isOnline || percentage <= 0) return;

    // Active progress arc paint
    final progressSweep = (percentage / 100.0) * sweepAngle;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          activeColor.withOpacity(0.5),
          activeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glowing shadow
    final glowPaint = Paint()
      ..color = activeColor.withOpacity(0.25)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.isOnline != isOnline;
  }
}
