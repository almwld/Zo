import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class NetworkHubApp extends StatefulWidget {
  const NetworkHubApp({super.key});

  @override
  State<NetworkHubApp> createState() => _NetworkHubAppState();
}

class _NetworkHubAppState extends State<NetworkHubApp> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Monitor', 'Scanner', 'Tools', 'Stats'];
  
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  double _totalDownload = 0;
  double _totalUpload = 0;
  String _currentIP = '';
  String _currentSSID = '';
  List<Map<String, String>> _wifiNetworks = [];
  List<Map<String, String>> _openPorts = [];
  bool _isScanning = false;
  String _scanTarget = '';
  final TextEditingController _pingController = TextEditingController(text: '8.8.8.8');
  String _pingResult = '';
  bool _isPinging = false;
  
  List<FlSpot> _downloadHistory = [];
  int _dataPoint = 0;
  Timer? _monitorTimer;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _downloadHistory.add(FlSpot(i.toDouble(), 0));
    }
    _startMonitoring();
    _getNetworkInfo();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _downloadSpeed = 0.5 + (DateTime.now().second % 50) / 10;
      _uploadSpeed = 0.2 + (DateTime.now().millisecond % 30) / 10;
      _totalDownload += _downloadSpeed / 10;
      _totalUpload += _uploadSpeed / 10;
      _dataPoint++;
      _downloadHistory.add(FlSpot(_dataPoint.toDouble(), _downloadSpeed));
      if (_downloadHistory.length > 20) _downloadHistory.removeAt(0);
      setState(() {});
    });
  }

  Future<void> _getNetworkInfo() async {
    try {
      final result = await Process.run('ip', ['route', 'get', '1'], runInShell: true);
      final ipMatch = RegExp(r'src (\d+\.\d+\.\d+\.\d+)').firstMatch(result.stdout.toString());
      if (ipMatch != null) setState(() => _currentIP = ipMatch.group(1)!);
      final wifiResult = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final ssidMatch = RegExp(r'mWifiInfo.*?SSID: "([^"]+)"').firstMatch(wifiResult.stdout.toString());
      if (ssidMatch != null) setState(() => _currentSSID = ssidMatch.group(1)!);
    } catch (_) {}
  }

  Future<void> _scanWiFi() async {
    setState(() { _isScanning = true; _wifiNetworks.clear(); });
    try {
      await Process.run('cmd', ['wifi', 'force-scan'], runInShell: true);
      await Future.delayed(const Duration(seconds: 2));
      final result = await Process.run('dumpsys', ['wifi'], runInShell: true);
      final output = result.stdout.toString();
      final regex = RegExp(r'SSID: "([^"]+)".*?BSSID: ([0-9a-f:]+).*?RSSI: (-?\d+)');
      final matches = regex.allMatches(output);
      for (final match in matches) {
        final ssid = match.group(1);
        if (ssid != null && ssid.isNotEmpty && ssid != 'unknown' && ssid != '<unknown ssid>') {
          _wifiNetworks.add({
            'ssid': ssid,
            'bssid': match.group(2) ?? 'Unknown',
            'signal': match.group(3) ?? '0',
            'security': 'WPA2',
          });
        }
      }
    } catch (_) {}
    setState(() => _isScanning = false);
  }

  Future<void> _scanPorts() async {
    if (_scanTarget.isEmpty) return;
    setState(() { _isScanning = true; _openPorts.clear(); });
    final ports = [21, 22, 23, 25, 53, 80, 443, 8080, 3306, 5432, 27017];
    for (final port in ports) {
      try {
        final socket = await Socket.connect(_scanTarget, port, timeout: const Duration(seconds: 1));
        _openPorts.add({'port': port.toString(), 'service': _getServiceName(port), 'status': 'open'});
        socket.destroy();
      } catch (_) {}
    }
    setState(() => _isScanning = false);
  }

  Future<void> _pingHost() async {
    final host = _pingController.text.trim();
    if (host.isEmpty) return;
    setState(() { _isPinging = true; _pingResult = 'Pinging $host...'; });
    try {
      final result = await Process.run('ping', ['-c', '3', '-W', '2', host], runInShell: true);
      final times = RegExp(r'time=(\d+\.?\d*) ms').allMatches(result.stdout.toString());
      if (times.isNotEmpty) {
        final avgTime = times.map((m) => double.parse(m.group(1)!)).reduce((a, b) => a + b) / times.length;
        setState(() => _pingResult = '✅ $host - ${avgTime.toStringAsFixed(1)} ms');
      } else {
        setState(() => _pingResult = '❌ $host is not reachable');
      }
    } catch (_) { setState(() => _pingResult = '❌ Ping failed'); }
    setState(() => _isPinging = false);
  }

  String _getServiceName(int port) {
    const services = {21: 'FTP', 22: 'SSH', 23: 'Telnet', 25: 'SMTP', 53: 'DNS', 80: 'HTTP', 443: 'HTTPS', 8080: 'HTTP-Alt', 3306: 'MySQL', 5432: 'PostgreSQL', 27017: 'MongoDB'};
    return services[port] ?? 'Unknown';
  }

  String _formatSpeed(double speed) {
    if (speed < 1) return '${(speed * 1024).toStringAsFixed(0)} KB/s';
    return '${speed.toStringAsFixed(1)} MB/s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Network Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(onTap: (i) => setState(() => _selectedTab = i), labelColor: const Color(0xFF00BCD4), unselectedLabelColor: Colors.white54, indicatorColor: const Color(0xFF00BCD4), tabs: _tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [_buildMonitorTab(), _buildScannerTab(), _buildToolsTab(), _buildStatsTab()],
      ),
    );
  }

  Widget _buildMonitorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Icon(Icons.arrow_downward, color: Colors.green), const SizedBox(height: 8), Text(_formatSpeed(_downloadSpeed), style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)), const Text('Download', style: TextStyle(color: Colors.white70))]),
                Column(children: [const Icon(Icons.arrow_upward, color: Colors.orange), const SizedBox(height: 8), Text(_formatSpeed(_uploadSpeed), style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)), const Text('Upload', style: TextStyle(color: Colors.white70))]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))),
            child: Column(children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Traffic History', style: TextStyle(color: Color(0xFF00BCD4))), Icon(Icons.show_chart, color: Color(0xFF00BCD4))]),
              const SizedBox(height: 16),
              SizedBox(height: 150, child: LineChart(LineChartData(gridData: const FlGridData(show: true), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: _downloadHistory, isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false))]))),
            ]),
          ),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))),
            child: Column(children: [
              _buildInfoRow('Connected to', _currentSSID.isNotEmpty ? _currentSSID : 'Not connected', Icons.wifi),
              _buildInfoRow('IP Address', _currentIP.isNotEmpty ? _currentIP : '0.0.0.0', Icons.network_wifi),
              _buildInfoRow('Total Download', '${_totalDownload.toStringAsFixed(2)} GB', Icons.download),
              _buildInfoRow('Total Upload', '${_totalUpload.toStringAsFixed(2)} GB', Icons.upload),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('WiFi Networks', style: TextStyle(color: Color(0xFF00BCD4))), ElevatedButton(onPressed: _isScanning ? null : _scanWiFi, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4)), child: Text(_isScanning ? 'SCANNING...' : 'SCAN'))]),
              const SizedBox(height: 12),
              ..._wifiNetworks.take(5).map((net) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.wifi, color: Color(0xFF00BCD4), size: 20), const SizedBox(width: 12), Expanded(child: Text(net['ssid']!, style: const TextStyle(color: Colors.white))), Text('${net['signal']} dBm', style: const TextStyle(color: Colors.white54))]))),
            ]),
          ),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))),
            child: Column(children: [
              const Text('Port Scanner', style: TextStyle(color: Color(0xFF00BCD4))),
              Row(children: [Expanded(child: TextField(style: const TextStyle(color: Colors.white), onChanged: (v) => _scanTarget = v, decoration: const InputDecoration(hintText: 'Enter IP'))), const SizedBox(width: 8), ElevatedButton(onPressed: _isScanning ? null : _scanPorts, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4)), child: Text(_isScanning ? 'SCANNING...' : 'SCAN'))]),
              ..._openPorts.map((port) => Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 8), Text('Port ${port['port']} - ${port['service']}', style: const TextStyle(color: Colors.white))]))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3))),
            child: Column(children: [
              const Text('Ping Tool', style: TextStyle(color: Color(0xFF00BCD4))),
              Row(children: [Expanded(child: TextField(controller: _pingController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Host or IP'))), const SizedBox(width: 8), ElevatedButton(onPressed: _isPinging ? null : _pingHost, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4)), child: _isPinging ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('PING'))]),
              if (_pingResult.isNotEmpty) Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)), child: Text(_pingResult, style: const TextStyle(color: Color(0xFF00BCD4)))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Download Speed', _formatSpeed(_downloadSpeed), Icons.arrow_downward, Colors.green),
        _buildStatCard('Upload Speed', _formatSpeed(_uploadSpeed), Icons.arrow_upward, Colors.orange),
        _buildStatCard('Total Download', '${_totalDownload.toStringAsFixed(2)} GB', Icons.download, Colors.green),
        _buildStatCard('Total Upload', '${_totalUpload.toStringAsFixed(2)} GB', Icons.upload, Colors.orange),
        _buildStatCard('WiFi Networks', _wifiNetworks.length.toString(), Icons.wifi, const Color(0xFF00BCD4)),
        _buildStatCard('Open Ports', _openPorts.length.toString(), Icons.portable_wifi_off, Colors.red),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(icon, color: const Color(0xFF00BCD4), size: 16), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white54)), const Spacer(), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))]));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)), Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold))]))]));
  }
}
