import 'package:flutter/material.dart';
import 'dart:math';

class ARTarget {
  final String id;
  final String name;
  final String type; // wifi, bluetooth, iot, device
  final double distance;
  final int signalStrength;
  final List<String> vulnerabilities;

  ARTarget({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.signalStrength,
    required this.vulnerabilities,
  });
}

class ZionARHacking extends ChangeNotifier {
  bool _isScanning = false;
  final List<ARTarget> _targets = [];
  bool _arMode = false;
  String _cameraView = 'back';

  List<ARTarget> get targets => _targets;
  bool get isScanning => _isScanning;
  bool get arMode => _arMode;

  void toggleARMode() { _arMode = !_arMode; notifyListeners(); }

  Future<void> startARScan() async {
    _isScanning = true;
    _targets.clear();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final deviceTypes = ['wifi', 'bluetooth', 'iot', 'device'];
    final vulnLists = [
      ['WPA2 Weak Password'],
      ['BlueBorne', 'Bluetooth PIN Cracking'],
      ['Default Credentials', 'Telnet Open'],
      ['Open ADB', 'USB Debugging Enabled'],
    ];

    for (int i = 0; i < 8; i++) {
      _targets.add(ARTarget(
        id: 'target_$i',
        name: 'جهاز ${i + 1}',
        type: deviceTypes[random.nextInt(4)],
        distance: random.nextDouble() * 50,
        signalStrength: random.nextInt(100),
        vulnerabilities: vulnLists[random.nextInt(4)],
      ));
    }

    _isScanning = false;
    notifyListeners();
  }

  void attackTarget(ARTarget target) {
    // محاكاة هجوم عبر AR
  }
}
