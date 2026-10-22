import 'package:flutter/material.dart';

class PumpControlCard extends StatelessWidget {
  final bool isPumpOn;
  final bool isAutoMode;
  final VoidCallback onTogglePump;
  final ValueChanged<bool> onToggleAuto;

  const PumpControlCard({
    super.key,
    required this.isPumpOn,
    required this.isAutoMode,
    required this.onTogglePump,
    required this.onToggleAuto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPumpOn
              ? const Color(0xFF06B6D4).withOpacity(0.5)
              : const Color(0xFF1F2B47),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPumpOn
                          ? const Color(0xFF06B6D4).withOpacity(0.15)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.water_damage_rounded,
                      color: isPumpOn ? const Color(0xFF06B6D4) : const Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Water Pump Control',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isPumpOn ? 'Actively Irrigating...' : 'Pump is Idle',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPumpOn ? const Color(0xFF06B6D4) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Pump State Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPumpOn
                      ? const Color(0xFF06B6D4).withOpacity(0.15)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPumpOn ? 'RUNNING' : 'STOPPED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPumpOn ? const Color(0xFF06B6D4) : const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 14),

          // Auto mode toggle switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Auto Irrigation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  Text(
                    'Triggers automatically when soil < threshold',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Switch(
                value: isAutoMode,
                onChanged: onToggleAuto,
                activeThumbColor: const Color(0xFF10B981),
                activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                inactiveThumbColor: const Color(0xFF64748B),
                inactiveTrackColor: const Color(0xFF1E293B),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Manual Trigger Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onTogglePump,
              icon: Icon(
                isPumpOn ? Icons.stop_circle_rounded : Icons.play_arrow_rounded,
                size: 20,
              ),
              label: Text(
                isPumpOn ? 'Stop Watering' : 'Manual Water Now',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPumpOn
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isPumpOn ? 4 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
