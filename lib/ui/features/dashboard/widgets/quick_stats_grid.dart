import 'package:flutter/material.dart';

class QuickStatsGrid extends StatelessWidget {
  final int rawValue;
  final double threshold;
  final bool isOnline;
  final bool isAutoMode;
  final VoidCallback onThresholdTap;

  const QuickStatsGrid({
    super.key,
    required this.rawValue,
    required this.threshold,
    required this.isOnline,
    required this.isAutoMode,
    required this.onThresholdTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Sensor ADC',
          value: isOnline ? '$rawValue' : '--',
          subtext: isOnline ? 'GPIO 34 (3.3V)' : 'Tool Disconnected',
          icon: Icons.memory_rounded,
          iconColor: isOnline ? const Color(0xFF06B6D4) : const Color(0xFF64748B),
        ),
        GestureDetector(
          onTap: onThresholdTap,
          child: _buildStatCard(
            title: 'Low Threshold',
            value: '< ${threshold.toStringAsFixed(0)}%',
            subtext: 'Tap to configure',
            icon: Icons.tune_rounded,
            iconColor: const Color(0xFFF59E0B),
            isActionable: true,
          ),
        ),
        _buildStatCard(
          title: 'ESP32 Status',
          value: isOnline ? 'Online' : 'Offline',
          subtext: 'Wi-Fi / Firebase',
          icon: Icons.wifi_rounded,
          iconColor: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        _buildStatCard(
          title: 'Irrigation Mode',
          value: isAutoMode ? 'Automated' : 'Manual',
          subtext: isAutoMode ? 'Smart Control' : 'User Control',
          icon: Icons.smart_toy_outlined,
          iconColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    bool isActionable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActionable
              ? iconColor.withOpacity(0.4)
              : const Color(0xFF1F2B47),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 11,
                  color: isActionable
                      ? iconColor
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
