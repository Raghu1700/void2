import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class ESPProvider extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  double _currentIOP = 0.0;
  double _arf = 0.0;
  double _deformation = 0.0;
  double _resistance = 0.0;
  double _distance = 0.0;
  double _area = 0.0;
  double _avgIOP = 0.0;
  bool _isConnected = false;
  bool _isScanning = false;
  List<IOPReading> _readingHistory = [];
  StreamSubscription? _subscription;

  double get currentIOP => _currentIOP;
  double get arf => _arf;
  double get deformation => _deformation;
  double get resistance => _resistance;
  double get distance => _distance;
  double get area => _area;
  double get avgIOP => _avgIOP;
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  List<IOPReading> get readingHistory => _readingHistory;

  ESPProvider() {
    _setupFirebase();
  }

  void _setupFirebase() {
    // Listen to /measurements path where your data is!
    _subscription = _dbRef.child('measurements').onValue.listen((event) {
      if (event.snapshot.value == null) {
        print('⚠️ No data in measurements');
        return;
      }
      
      final measurements = event.snapshot.value as Map;
      print('🔥 Got ${measurements.length} measurements');
      print('Keys: ${measurements.keys.toList()}');
      
      // Find latest entry by timestamp
      Map? latestData;
      String? latestKey;
      int maxTimestamp = 0;
      
      measurements.forEach((key, value) {
        if (value is Map) {
          final keyStr = key.toString();
          final timestamp = int.tryParse(keyStr);
          
          if (timestamp != null && timestamp > maxTimestamp) {
            maxTimestamp = timestamp;
            latestKey = keyStr;
            latestData = value as Map;
          }
        }
      });
      
      if (latestData != null) {
        print('✅ Latest: $latestKey');
        print('   Data: $latestData');
        
        _distance = _val(latestData!['distance_cm']);
        _currentIOP = _val(latestData!['iop_mmHg']);
        _avgIOP = _currentIOP;
        _area = 0.00007854;
        _arf = _distance * 0.1;
        _deformation = (_currentIOP - 15) / 100;
        _resistance = _arf / (_deformation == 0 ? 1 : _deformation);
        _isConnected = true;
        
        print('');
        print('✅✅✅ SHOWING IN APP NOW! ✅✅✅');
        print('📊 Distance: $_distance cm');
        print('📊 IOP: $_currentIOP mmHg');
        print('');
        
        notifyListeners();
      } else {
        print('❌ No valid measurements found');
      }
    });
  }

  double _val(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Future<void> connectToDevice() async {
    _isConnected = true;
    _isScanning = true;
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    _isScanning = false;
    notifyListeners();
  }

  void startRealTimeReading() {
    _isScanning = true;
    notifyListeners();
  }

  void stopRealTimeReading() {
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class IOPReading {
  final DateTime timestamp;
  final double iop;
  final double arf;
  final double deformation;

  IOPReading({
    required this.timestamp,
    required this.iop,
    required this.arf,
    required this.deformation,
  });
}
