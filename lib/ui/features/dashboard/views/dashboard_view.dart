import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/view_models/irrigation_view_model.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/moisture_gauge.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/status_badge.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/quick_stats_grid.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/pump_control_card.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/history_chart_card.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/widgets/threshold_dialog.dart';
import 'package:smart_irrigation_app/ui/features/settings/settings_view.dart';

class DashboardView extends StatelessWidget {
  final IrrigationViewModel viewModel;

  const DashboardView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final reading = viewModel.currentReading;
        final isOnline = viewModel.isOnline;

        return Scaffold(
          backgroundColor: const Color(0xFF0B0F19),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0B0F19),
            elevation: 0,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Soil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Smart Irrigation & Soil Monitor',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                ),
                tooltip: 'Check Hardware Connection',
                onPressed: () => viewModel.refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                tooltip: 'Settings & Hardware Config',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => SettingsView(viewModel: viewModel),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: const Color(0xFF10B981),
            backgroundColor: const Color(0xFF131B2E),
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Disconnected Hardware Alert Banner
                  if (!isOnline) ...[
                    _buildDisconnectedBanner(context),
                    const SizedBox(height: 16),
                  ] else if (viewModel.lastAlert != null) ...[
                    _buildAlertBanner(context),
                    const SizedBox(height: 16),
                  ],

                  // Hero Soil Gauge Card
                  _buildHeroGaugeCard(reading, isOnline),
                  const SizedBox(height: 16),

                  // 4-Card Quick Metrics Grid
                  QuickStatsGrid(
                    rawValue: reading?.rawValue ?? 0,
                    threshold: viewModel.threshold,
                    isOnline: isOnline,
                    isAutoMode: viewModel.isAutoMode,
                    onThresholdTap: () => _openThresholdDialog(context),
                  ),
                  const SizedBox(height: 16),

                  // Water Pump Actuator Control Card
                  PumpControlCard(
                    isPumpOn: viewModel.isPumpOn,
                    isAutoMode: viewModel.isAutoMode,
                    onTogglePump: isOnline ? viewModel.togglePump : () {},
                    onToggleAuto: (val) => viewModel.toggleAutoMode(),
                  ),
                  const SizedBox(height: 16),

                  // History Trends Chart
                  HistoryChartCard(
                    history: viewModel.history,
                    threshold: viewModel.threshold,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisconnectedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.sensors_off_rounded,
            color: Color(0xFFF59E0B),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hardware Offline / Sensor Not Connected',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Power on your ESP32 board and connect to Wi-Fi to begin live monitoring.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFF59E0B), size: 20),
            tooltip: 'Retry Connection',
            onPressed: () => viewModel.refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Critical Soil Alert!',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.lastAlert ?? '',
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!viewModel.isPumpOn)
                      ElevatedButton(
                        onPressed: viewModel.togglePump,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Start Pump', style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: viewModel.clearAlert,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGaugeCard(SoilReading? reading, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F2B47), width: 1.2),
        gradient: const LinearGradient(
          colors: [Color(0xFF162038), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          MoistureGauge(
            percentage: reading?.moisturePercentage,
            status: reading?.status,
            isOnline: isOnline,
          ),
          const SizedBox(height: 12),
          StatusBadge(
            status: reading?.status,
            isOnline: isOnline,
          ),
        ],
      ),
    );
  }

  void _openThresholdDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ThresholdDialog(
        currentThreshold: viewModel.threshold,
        onSave: (val) => viewModel.updateThreshold(val),
      ),
    );
  }
}
