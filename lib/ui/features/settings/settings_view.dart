import 'package:flutter/material.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/view_models/irrigation_view_model.dart';

class SettingsView extends StatefulWidget {
  final IrrigationViewModel viewModel;

  const SettingsView({super.key, required this.viewModel});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _firebaseUrlController;
  late TextEditingController _airValueController;
  late TextEditingController _waterValueController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firebaseUrlController = TextEditingController(
      text: widget.viewModel.databaseUrl,
    );
    _airValueController = TextEditingController(text: "3200");
    _waterValueController = TextEditingController(text: "1400");
  }

  @override
  void dispose() {
    _firebaseUrlController.dispose();
    _airValueController.dispose();
    _waterValueController.dispose();
    super.dispose();
  }

  Future<void> _saveAndConnect() async {
    setState(() => _isSaving = true);
    widget.viewModel.updateDatabaseUrl(_firebaseUrlController.text);
    await widget.viewModel.refresh();
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.isOnline
                ? 'Connected to ESP32 Hardware!'
                : 'URL saved. Waiting for ESP32 hardware to send data...',
          ),
          backgroundColor: widget.viewModel.isOnline
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: const Text('Configuration & Hardware'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hardware Status Card
            _buildSectionHeader('Live Tool Status'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: vm.isOnline
                      ? const Color(0xFF10B981).withOpacity(0.4)
                      : const Color(0xFF1F2B47),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: vm.isOnline
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFEF4444).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      vm.isOnline ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                      color: vm.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.isOnline
                              ? 'ESP32 Connected & Active'
                              : 'ESP32 Not Detected (Offline)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: vm.isOnline
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.isOnline
                              ? 'Receiving real-time readings from sensor'
                              : 'Waiting for hardware to push data to Firebase',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Firebase Settings
            _buildSectionHeader('Firebase Realtime Database URL'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2B47)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Endpoint',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _firebaseUrlController,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0B0F19),
                      hintText: "https://your-project-default-rtdb.firebaseio.com",
                      hintStyle: const TextStyle(color: Color(0xFF475569)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1F2B47)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF1F2B47)),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveAndConnect,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        _isSaving ? 'Connecting...' : 'Save & Connect to Hardware',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calibration Constants
            _buildSectionHeader('Sensor Calibration Reference (ADC Raw)'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2B47)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dry Air (0% Moisture)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _airValueController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0B0F19),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Water (100% Moisture)',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _waterValueController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0B0F19),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hardware Pinout Guide
            _buildSectionHeader('ESP32 Hardware Pinout Reference'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F2B47)),
              ),
              child: const Column(
                children: [
                  _PinRow(
                      label: 'Sensor VCC',
                      pin: 'ESP32 3.3V Pin',
                      color: Color(0xFFEF4444)),
                  Divider(color: Color(0xFF1E293B), height: 16),
                  _PinRow(
                      label: 'Sensor GND',
                      pin: 'ESP32 GND Pin',
                      color: Color(0xFF94A3B8)),
                  Divider(color: Color(0xFF1E293B), height: 16),
                  _PinRow(
                      label: 'Sensor AOUT',
                      pin: 'ESP32 GPIO 34 (ADC1)',
                      color: Color(0xFF06B6D4)),
                  Divider(color: Color(0xFF1E293B), height: 16),
                  _PinRow(
                      label: 'Water Pump Relay',
                      pin: 'ESP32 GPIO 23',
                      color: Color(0xFF10B981)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  final String label;
  final String pin;
  final Color color;

  const _PinRow({required this.label, required this.pin, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            pin,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}
