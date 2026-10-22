import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';

abstract class DataSourceService {
  Stream<SoilReading> get moistureStream;
  Stream<bool> get connectionStream;
  Future<void> setWaterPump(bool isOn);
  Future<void> setAutoMode(bool isAuto);
  Future<void> setThreshold(double threshold);
  Future<void> initialize();
  void dispose();
}

/// Production Firebase Realtime Database Service
/// Only streams and displays data when the physical ESP32 tool/sensor is connected.
class IrrigationDataService implements DataSourceService {
  final _controller = StreamController<SoilReading>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  Timer? _pollingTimer;

  bool _isPumpActive = false;
  bool _isAutoIrrigation = true;
  double _lowThreshold = 35.0;
  bool _isOnline = false;
  DateTime? _lastSeen;

  // Firebase Realtime DB configuration endpoint
  String databaseUrl = "https://your-fyp-project-default-rtdb.firebaseio.com";

  @override
  Stream<SoilReading> get moistureStream => _controller.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isPumpActive => _isPumpActive;
  bool get isAutoIrrigation => _isAutoIrrigation;
  double get lowThreshold => _lowThreshold;
  bool get isOnline => _isOnline;
  DateTime? get lastSeen => _lastSeen;

  @override
  Future<void> initialize() async {
    // Start polling the real Firebase Realtime Database
    _startRealtimeSync();
  }

  void updateDatabaseUrl(String newUrl) {
    databaseUrl = newUrl.trim();
    // Fetch immediately on URL update
    fetchLatestFromHardware();
  }

  void _startRealtimeSync() {
    _pollingTimer?.cancel();
    // Query the hardware's Firebase entry every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchLatestFromHardware();
    });

    // Initial immediate fetch
    fetchLatestFromHardware();
  }

  /// Polls the Firebase Realtime Database endpoint `/soil_moisture.json`
  Future<void> fetchLatestFromHardware() async {
    final cleanUrl = databaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (cleanUrl.isEmpty || cleanUrl.contains("your-fyp-project")) {
      _setOnlineStatus(false);
      return;
    }

    try {
      final uri = Uri.parse('$cleanUrl/soil_moisture.json');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body.isNotEmpty && body != 'null') {
          final data = jsonDecode(body);
          if (data is Map && (data.containsKey('raw') || data.containsKey('percentage'))) {
            final reading = SoilReading.fromMap(data);
            _lastSeen = DateTime.now();
            _setOnlineStatus(true);
            _controller.add(reading);

            // Auto pump handling when hardware is connected
            if (_isAutoIrrigation) {
              if (reading.moisturePercentage < _lowThreshold && !_isPumpActive) {
                setWaterPump(true);
              } else if (reading.moisturePercentage >= 75.0 && _isPumpActive) {
                setWaterPump(false);
              }
            }
            return;
          }
        }
      }
      _setOnlineStatus(false);
    } catch (_) {
      _setOnlineStatus(false);
    }
  }

  void _setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _connectionController.add(online);
    }
  }

  /// Direct feed from hardware if using local WebSocket / REST bridge
  void updateFromHardware({required int raw, required double percentage}) {
    final reading = SoilReading.fromRaw(
      rawValue: raw,
      moisturePercentage: percentage,
      timestamp: DateTime.now(),
    );
    _lastSeen = DateTime.now();
    _setOnlineStatus(true);
    _controller.add(reading);
  }

  @override
  Future<void> setWaterPump(bool isOn) async {
    _isPumpActive = isOn;
    final cleanUrl = databaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (cleanUrl.isNotEmpty && !cleanUrl.contains("your-fyp-project")) {
      try {
        final uri = Uri.parse('$cleanUrl/pump_control.json');
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
        final request = await client.putUrl(uri);
        request.headers.set('Content-Type', 'application/json');
        request.write(jsonEncode({
          'pump_on': isOn,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
        await request.close();
      } catch (_) {}
    }
  }

  @override
  Future<void> setAutoMode(bool isAuto) async {
    _isAutoIrrigation = isAuto;
  }

  @override
  Future<void> setThreshold(double threshold) async {
    _lowThreshold = threshold;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.close();
    _connectionController.close();
  }
}
