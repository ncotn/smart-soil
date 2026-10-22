import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:smart_irrigation_app/data/models/moisture_reading.dart';
import 'package:smart_irrigation_app/data/services/firebase_service.dart';

class IrrigationViewModel extends ChangeNotifier {
  final IrrigationDataService _dataService;
  StreamSubscription<SoilReading>? _moistureSub;
  StreamSubscription<bool>? _connectionSub;

  SoilReading? _currentReading;
  final List<SoilReading> _history = [];
  double _threshold = 35.0;
  bool _isAutoMode = true;
  bool _isPumpOn = false;
  bool _isOnline = false;
  String? _lastAlert;

  IrrigationViewModel({required IrrigationDataService dataService})
      : _dataService = dataService {
    _init();
  }

  SoilReading? get currentReading => _currentReading;
  List<SoilReading> get history => List.unmodifiable(_history);
  double get threshold => _threshold;
  bool get isAutoMode => _isAutoMode;
  bool get isPumpOn => _isPumpOn;
  bool get isOnline => _isOnline;
  String? get lastAlert => _lastAlert;
  String get databaseUrl => _dataService.databaseUrl;
  DateTime? get lastSeen => _dataService.lastSeen;

  void _init() {
    _threshold = _dataService.lowThreshold;
    _isAutoMode = _dataService.isAutoIrrigation;
    _isPumpOn = _dataService.isPumpActive;
    _isOnline = _dataService.isOnline;

    _dataService.initialize();

    // Listen to real hardware moisture readings
    _moistureSub = _dataService.moistureStream.listen((reading) {
      _currentReading = reading;
      _isOnline = true;
      _isPumpOn = _dataService.isPumpActive;

      // Add to real history (stores up to 50 real data points)
      _history.add(reading);
      if (_history.length > 50) {
        _history.removeAt(0);
      }

      // Check alert condition against threshold
      if (reading.moisturePercentage < _threshold) {
        _lastAlert =
            'Moisture level is at ${reading.moisturePercentage.toStringAsFixed(0)}% (Below $_threshold% threshold)! Soil requires irrigation.';
      } else {
        _lastAlert = null;
      }

      notifyListeners();
    });

    // Listen to hardware connection state changes
    _connectionSub = _dataService.connectionStream.listen((online) {
      _isOnline = online;
      if (!online) {
        _lastAlert = null;
      }
      notifyListeners();
    });
  }

  void updateDatabaseUrl(String newUrl) {
    _dataService.updateDatabaseUrl(newUrl);
    notifyListeners();
  }

  Future<void> refresh() async {
    await _dataService.fetchLatestFromHardware();
    notifyListeners();
  }

  void togglePump() {
    _isPumpOn = !_isPumpOn;
    _dataService.setWaterPump(_isPumpOn);
    notifyListeners();
  }

  void toggleAutoMode() {
    _isAutoMode = !_isAutoMode;
    _dataService.setAutoMode(_isAutoMode);
    notifyListeners();
  }

  void updateThreshold(double newThreshold) {
    _threshold = newThreshold;
    _dataService.setThreshold(newThreshold);
    notifyListeners();
  }

  void clearAlert() {
    _lastAlert = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _moistureSub?.cancel();
    _connectionSub?.cancel();
    _dataService.dispose();
    super.dispose();
  }
}
