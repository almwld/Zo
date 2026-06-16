import 'package:flutter/material.dart';
import 'dart:async';

class PowerProfile {
  final String name;
  final String description;
  final double cpuMaxFreq;
  final int brightnessPercent;
  final bool wifiOn;
  final bool bluetoothOn;
  final bool animationsOn;

  PowerProfile({
    required this.name,
    required this.description,
    required this.cpuMaxFreq,
    required this.brightnessPercent,
    required this.wifiOn,
    required this.bluetoothOn,
    required this.animationsOn,
  });

  static final PowerProfile performance = PowerProfile(name: 'الأداء العالي', description: 'أقصى أداء للمعالج', cpuMaxFreq: 2.8, brightnessPercent: 100, wifiOn: true, bluetoothOn: true, animationsOn: true);
  static final PowerProfile balanced = PowerProfile(name: 'متوازن', description: 'توازن بين الأداء والبطارية', cpuMaxFreq: 1.8, brightnessPercent: 70, wifiOn: true, bluetoothOn: false, animationsOn: true);
  static final PowerProfile powerSave = PowerProfile(name: 'توفير الطاقة', description: 'أقصى توفير للبطارية', cpuMaxFreq: 1.2, brightnessPercent: 40, wifiOn: true, bluetoothOn: false, animationsOn: false);
  static final PowerProfile ultraSave = PowerProfile(name: 'توفير فائق', description: 'وضع الطوارئ', cpuMaxFreq: 0.8, brightnessPercent: 20, wifiOn: false, bluetoothOn: false, animationsOn: false);
}

class ZionPowerManagement extends ChangeNotifier {
  PowerProfile _currentProfile = PowerProfile.balanced;
  int _batteryLevel = 78;
  bool _isCharging = true;
  double _temperature = 38.5;
  String _estimatedTime = '6 ساعات و 23 دقيقة';

  PowerProfile get currentProfile => _currentProfile;
  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  double get temperature => _temperature;
  String get estimatedTime => _estimatedTime;

  void setProfile(PowerProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  void toggleCharging() {
    _isCharging = !_isCharging;
    notifyListeners();
  }
}
