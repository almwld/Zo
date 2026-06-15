import 'dart:io';
import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';

class WirelessService {
  static final WirelessService _instance = WirelessService._internal();
  factory WirelessService() => _instance;
  WirelessService._internal();
  
  final NetworkInfo _networkInfo = NetworkInfo();
  
  List<Map<String, String>> _wifiNetworks = [];
  List<Map<String, String>> _savedNetworks = [];
  bool _isScanning = false;
  
  Future<void> init() async {
    await _loadSavedNetworks();
  }
  
  Future<void> _loadSavedNetworks() async {
    // Load saved networks from preferences
    _savedNetworks = [
      {'ssid': 'Zion_Secure', 'security': 'WPA2', 'saved': 'true'},
      {'ssid': 'Home_Network', 'security': 'WPA3', 'saved': 'true'},
      {'ssid': 'Office_WiFi', 'security': 'WPA2', 'saved': 'false'},
    ];
  }
  
  Future<void> scanWiFiNetworks() async {
    _isScanning = true;
    _wifiNetworks.clear();
    
    try {
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      
      final regex = RegExp(r'SSID: "([^"]+)".*?BSSID: ([0-9a-f:]+).*?RSSI: (-?\d+)', caseSensitive: false);
      final matches = regex.allMatches(output);
      
      for (final match in matches) {
        _wifiNetworks.add({
          'ssid': match.group(1) ?? 'Unknown',
          'bssid': match.group(2) ?? 'Unknown',
          'signal': match.group(3) ?? '0',
          'security': 'WPA2',
          'channel': '6',
        });
      }
    } catch (_) {}
    
    _isScanning = false;
  }
  
  Future<bool> connectToWiFi(String ssid, String password) async {
    try {
      // Simulate connection
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (_) {
      return false;
    }
  }
  
  Future<void> forgetNetwork(String ssid) async {
    _savedNetworks.removeWhere((n) => n['ssid'] == ssid);
  }
  
  String getCurrentWiFiName() {
    try {
      return _networkInfo.getWifiName() ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }
  
  String getCurrentIP() {
    try {
      return _networkInfo.getWifiIP() ?? '0.0.0.0';
    } catch (_) {
      return '0.0.0.0';
    }
  }
  
  List<Map<String, String>> get wifiNetworks => _wifiNetworks;
  List<Map<String, String>> get savedNetworks => _savedNetworks;
  bool get isScanning => _isScanning;
}
