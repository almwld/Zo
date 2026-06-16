import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class QuantumKey {
  final String id;
  final int length;
  final double entropy;
  final DateTime createdAt;
  bool distributed;

  QuantumKey({
    required this.id,
    required this.length,
    required this.entropy,
    required this.createdAt,
    this.distributed = false,
  });
}

class ZionQuantumEncryption extends ChangeNotifier {
  final List<QuantumKey> _generatedKeys = [];
  bool _isGenerating = false;
  bool _quantumChannelActive = false;
  double _qber = 0.0; // Quantum Bit Error Rate

  List<QuantumKey> get generatedKeys => _generatedKeys;
  bool get isGenerating => _isGenerating;
  bool get quantumChannelActive => _quantumChannelActive;
  double get qber => _qber;

  Future<QuantumKey> generateQuantumKey({int length = 256}) async {
    _isGenerating = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final random = Random.secure();
    double entropy = 0;
    for (int i = 0; i < 10; i++) {
      entropy += random.nextDouble();
    }
    entropy = entropy / 10;

    final key = QuantumKey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      length: length,
      entropy: entropy,
      createdAt: DateTime.now(),
    );

    _generatedKeys.add(key);
    _isGenerating = false;
    notifyListeners();

    return key;
  }

  void toggleQuantumChannel() {
    _quantumChannelActive = !_quantumChannelActive;
    if (_quantumChannelActive) {
      _qber = Random().nextDouble() * 0.05; // محاكاة خطأ القناة
    } else {
      _qber = 0;
    }
    notifyListeners();
  }

  String encryptQuantum(String plaintext, QuantumKey key) {
    // محاكاة تشفير كمي
    final random = Random();
    final encrypted = StringBuffer();
    for (int i = 0; i < plaintext.length; i++) {
      encrypted.writeCharCode(plaintext.codeUnitAt(i) ^ random.nextInt(256));
    }
    return encrypted.toString();
  }
}
