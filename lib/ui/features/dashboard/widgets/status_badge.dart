import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';

class StatusBadge extends StatelessWidget {
  final SoilStatus? status;
  final bool isOnline;

  const StatusBadge({
    super.key,
    required this.status,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    if (!isOnline || status == null) {
      label = 'Hardware Disconnected (Waiting for Tool)';
      color = const Color(0xFFF59E0B); // Amber warning
      icon = Icons.sensors_off_rounded;
    } else {
      switch (status!) {
        case SoilStatus.dry:
          label = 'Dry Soil (Needs Water)';
          color = const Color(0xFFEF4444);
          icon = Icons.error_outline_rounded;
          break;
        case SoilStatus.normal:
          label = 'Optimal Moisture';
          color = const Color(0xFF10B981);
          icon = Icons.check_circle_outline_rounded;
          break;
        case SoilStatus.wet:
          label = 'Wet Soil (Saturated)';
          color = const Color(0xFF3B82F6);
          icon = Icons.water_rounded;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
