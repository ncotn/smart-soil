import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';

class HistoryChartCard extends StatelessWidget {
  final List<SoilReading> history;
  final double threshold;

  const HistoryChartCard({
    super.key,
    required this.history,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1F2B47), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.show_chart_rounded, color: Color(0xFF64748B), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Historical trends will plot automatically once the ESP32 sensor begins transmitting.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      );
    }

    final values = history.map((e) => e.moisturePercentage).toList();
    final maxVal = values.reduce(max);
    final minVal = values.reduce(min);
    final latest = values.last;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2B47), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Moisture History & Trends',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${latest.toStringAsFixed(0)}% Now',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Min / Max summary row
          Row(
            children: [
              _buildMetricChip('Min', '${minVal.toStringAsFixed(0)}%', const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _buildMetricChip('Max', '${maxVal.toStringAsFixed(0)}%', const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildMetricChip('Threshold', '< ${threshold.toStringAsFixed(0)}%', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Canvas
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                readings: history,
                threshold: threshold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<SoilReading> readings;
  final double threshold;

  _SparklinePainter({required this.readings, required this.threshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;

    final values = readings.map((r) => r.moisturePercentage).toList();
    final pointCount = values.length;
    final stepX = size.width / (pointCount - 1);

    // Coordinate mapping (0% -> bottom, 100% -> top)
    double getY(double val) {
      final clamped = val.clamp(0.0, 100.0);
      return size.height - (clamped / 100.0 * size.height);
    }

    // Draw Threshold reference line
    final threshY = getY(threshold);
    final dashPaint = Paint()
      ..color = const Color(0xFFF59E0B).withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double curX = 0;
    while (curX < size.width) {
      canvas.drawLine(Offset(curX, threshY), Offset(min(curX + 6, size.width), threshY), dashPaint);
      curX += 12;
    }

    // Build smooth cubic path
    final path = Path();
    final fillPath = Path();

    path.moveTo(0, getY(values.first));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(values.first));

    for (int i = 0; i < pointCount - 1; i++) {
      final x0 = i * stepX;
      final y0 = getY(values[i]);
      final x1 = (i + 1) * stepX;
      final y1 = getY(values[i + 1]);

      final controlX = (x0 + x1) / 2;
      path.cubicTo(controlX, y0, controlX, y1, x1, y1);
      fillPath.cubicTo(controlX, y0, controlX, y1, x1, y1);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF10B981).withOpacity(0.35),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw stroke line
    final linePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw pulse dot on last point
    final lastX = size.width;
    final lastY = getY(values.last);

    final dotPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final haloPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(lastX, lastY), 6, haloPaint);
    canvas.drawCircle(Offset(lastX, lastY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.readings != readings || oldDelegate.threshold != threshold;
  }
}
