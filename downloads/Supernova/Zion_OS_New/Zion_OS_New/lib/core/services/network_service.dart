import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();
  
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  String _wifiName = '';
  String _wifiBSSID = '';
  String _ipAddress = '';
  String _gateway = '';
  String _subnetMask = '';
  
  List<Map<String, dynamic>> _networkInterfaces = [];
  List<Map<String, dynamic>> _activeConnections = [];
  Timer? _scanTimer;
  
  Future<void> init() async {
    _connectionStatus = await _connectivity.checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    await _updateNetworkInfo();
    _startScanning();
  }
  
  void _startScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateNetworkInfo();
      _scanActiveConnections();
    });
  }
  
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    await _updateNetworkInfo();
    notifyListeners();
  }
  
  Future<void> _updateNetworkInfo() async {
    try {
      _wifiName = await _networkInfo.getWifiName() ?? 'Unknown';
      _wifiBSSID = await _networkInfo.getWifiBSSID() ?? 'Unknown';
      _ipAddress = await _networkInfo.getWifiIP() ?? 'Unknown';
      _gateway = await _networkInfo.getWifiGatewayIP() ?? 'Unknown';
      _subnetMask = await _networkInfo.getWifiSubmask() ?? 'Unknown';
    } catch (e) {
      print('Network info error: $e');
    }
    notifyListeners();
  }
  
  Future<void> _scanActiveConnections() async {
    _activeConnections.clear();
    try {
      final result = await Process.run('netstat', ['-an'], runInShell: true);
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.contains('ESTABLISHED')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 6) {
            _activeConnections.add({
              'protocol': parts[0],
              'local': parts[3],
              'foreign': parts[4],
              'state': parts[5],
            });
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }
  
  Future<void> scanNetworkInterfaces() async {
    _networkInterfaces.clear();
    try {
      final result = await Process.run('ip', ['addr', 'show'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      String currentInterface = '';
      for (final line in lines) {
        if (line.contains(':') && !line.contains('lo:')) {
          currentInterface = line.split(':')[1].trim();
          _networkInterfaces.add({
            'name': currentInterface,
            'status': 'down',
            'ip': '',
          });
        } else if (currentInterface.isNotEmpty && line.contains('inet ')) {
          final ipMatch = RegExp(r'inet (\d+\.\d+\.\d+\.\d+)').firstMatch(line);
          if (ipMatch != null) {
            final index = _networkInterfaces.length - 1;
            _networkInterfaces[index]['ip'] = ipMatch.group(1)!;
            _networkInterfaces[index]['status'] = 'up';
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }
  
  Future<bool> pingHost(String host) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '2', host], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
  
  Future<String> traceroute(String host) async {
    try {
      final result = await Process.run('traceroute', ['-n', '-m', '10', host], runInShell: true);
      return result.stdout.toString();
    } catch (_) {
      return 'Traceroute not available';
    }
  }
  
  ConnectivityResult get connectionStatus => _connectionStatus;
  String get wifiName => _wifiName;
  String get wifiBSSID => _wifiBSSID;
  String get ipAddress => _ipAddress;
  String get gateway => _gateway;
  String get subnetMask => _subnetMask;
  List<Map<String, dynamic>> get activeConnections => _activeConnections;
  List<Map<String, dynamic>> get networkInterfaces => _networkInterfaces;
  
  String getConnectionStatusText() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'Disconnected';
    }
  }
  
  Color getConnectionStatusColor() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return Colors.green;
      case ConnectivityResult.mobile:
        return Colors.orange;
      case ConnectivityResult.ethernet:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
  
  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}
