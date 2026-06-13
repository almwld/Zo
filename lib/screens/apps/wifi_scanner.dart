import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class WiFiScannerApp extends StatefulWidget {
  const WiFiScannerApp({super.key});

  @override
  State<WiFiScannerApp> createState() => _WiFiScannerAppState();
}

class _WiFiScannerAppState extends State<WiFiScannerApp> {
  List<Map<String, String>> _networks = [];
  bool _isScanning = false;
  String _errorMessage = '';
  String _currentWiFi = '';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    _hasPermission = await Permission.location.isGranted;
    if (_hasPermission) {
      _getCurrentWiFi();
      _scanWiFi();
    } else {
      setState(() => _errorMessage = 'مطلوب صلاحية الموقع لمسح شبكات WiFi');
    }
  }

  Future<void> _getCurrentWiFi() async {
    try {
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'mWifiInfo.*?SSID: "([^"]+)"').firstMatch(output);
      if (match != null && match.group(1) != null && match.group(1) != '<unknown ssid>') {
        setState(() => _currentWiFi = match.group(1)!);
      }
    } catch (_) {}
  }

  Future<void> _scanWiFi() async {
    if (!_hasPermission) {
      setState(() => _errorMessage = 'مطلوب صلاحية الموقع');
      return;
    }

    setState(() {
      _isScanning = true;
      _networks.clear();
      _errorMessage = '';
    });

    try {
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      final regex = RegExp(r'SSID: "([^"]+)".*?RSSI: (-?\d+)');
      final matches = regex.allMatches(output);

      for (final match in matches) {
        final ssid = match.group(1);
        final rssi = match.group(2);
        if (ssid != null && ssid.isNotEmpty && ssid != 'unknown' && ssid != '<unknown ssid>') {
          _networks.add({
            'ssid': ssid,
            'signal': rssi ?? '0',
          });
        }
      }

      setState(() {
        _isScanning = false;
        if (_networks.isEmpty) {
          _errorMessage = 'لم يتم العثور على شبكات WiFi';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ: $e';
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text('WiFi Scanner', style: TextStyle(color: theme.primaryColor)),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryColor),
            onPressed: _scanWiFi,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasPermission)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('مطلوب صلاحية الموقع لمسح شبكات WiFi')),
                  TextButton(onPressed: _checkPermissions, child: const Text('منح', style: TextStyle(color: Color(0xFF00BCD4)))),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.5)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('متصل بـ:', style: TextStyle(color: Colors.white70)),
                      Text(_currentWiFi.isNotEmpty ? _currentWiFi : 'غير متصل', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isScanning ? null : _scanWiFi,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: theme.primaryColor),
                  child: Text(_isScanning ? 'جاري المسح...' : 'مسح'),
                ),
              ],
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.white70)),
            ),
          Expanded(
            child: _isScanning
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري مسح الشبكات...', style: TextStyle(color: Colors.white38)),
                  ]))
                : _networks.isEmpty
                    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.wifi_off, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('لم يتم العثور على شبكات', style: TextStyle(color: Colors.white38)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _networks.length,
                        itemBuilder: (context, index) {
                          final net = _networks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.wifi, color: theme.primaryColor, size: 28),
                                const SizedBox(width: 12),
                                Expanded(child: Text(net['ssid']!, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87))),
                                Text('${net['signal']} dBm', style: TextStyle(color: theme.primaryColor)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
