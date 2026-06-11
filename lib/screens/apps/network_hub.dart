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
  
  final List<Map<String, dynamic>> _tabs = [
    {'name': 'Monitor', 'icon': Icons.analytics},
    {'name': 'Scanner', 'icon': Icons.scanner},
    {'name': 'Tools', 'icon': Icons.build},
    {'name': 'Stats', 'icon': Icons.bar_chart},
  ];
  
  // Network Stats
  List<FlSpot> _downloadSpots = [];
  List<FlSpot> _uploadSpots = [];
  Timer? _monitorTimer;
  int _dataPoint = 0;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  double _totalDownload = 0;
  double _totalUpload = 0;
  String _currentIP = '';
  String _currentSSID = '';
  
  // Scan Results
  List<Map<String, String>> _wifiNetworks = [];
  List<Map<String, String>> _openPorts = [];
  bool _isScanning = false;
  String _scanTarget = '';
  
  // Tools
  final TextEditingController _pingHost = TextEditingController(text: '8.8.8.8');
  String _pingResult = '';
  bool _isPinging = false;
  
  final TextEditingController _dnsHost = TextEditingController(text: 'google.com');
  String _dnsResult = '';
  bool _isDnsLookup = false;

  @override
  void initState() {
    super.initState();
    _initData();
    _startMonitoring();
    _getNetworkInfo();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _initData() {
    for (int i = 0; i < 20; i++) {
      _downloadSpots.add(FlSpot(i.toDouble(), 0));
      _uploadSpots.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateNetworkStats();
      _updateHistory();
      setState(() {});
    });
  }

  void _updateNetworkStats() {
    setState(() {
      _downloadSpeed = 0.5 + (DateTime.now().second % 50) / 10;
      _uploadSpeed = 0.2 + (DateTime.now().millisecond % 30) / 10;
      _totalDownload += _downloadSpeed / 10;
      _totalUpload += _uploadSpeed / 10;
    });
  }

  void _updateHistory() {
    _dataPoint++;
    _downloadSpots.add(FlSpot(_dataPoint.toDouble(), _downloadSpeed));
    _uploadSpots.add(FlSpot(_dataPoint.toDouble(), _uploadSpeed));
    
    if (_downloadSpots.length > 20) _downloadSpots.removeAt(0);
    if (_uploadSpots.length > 20) _uploadSpots.removeAt(0);
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
    setState(() {
      _isScanning = true;
      _wifiNetworks.clear();
    });
    
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
    
    setState(() {
      _isScanning = true;
      _openPorts.clear();
    });
    
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
    final host = _pingHost.text.trim();
    if (host.isEmpty) return;
    
    setState(() {
      _isPinging = true;
      _pingResult = 'Pinging $host...';
    });
    
    try {
      final result = await Process.run('ping', ['-c', '3', '-W', '2', host], runInShell: true);
      final times = RegExp(r'time=(\d+\.?\d*) ms').allMatches(result.stdout.toString());
      if (times.isNotEmpty) {
        final avgTime = times.map((m) => double.parse(m.group(1)!)).reduce((a, b) => a + b) / times.length;
        setState(() => _pingResult = '✅ $host - ${avgTime.toStringAsFixed(1)} ms');
      } else {
        setState(() => _pingResult = '❌ $host is not reachable');
      }
    } catch (_) {
      setState(() => _pingResult = '❌ Ping failed');
    }
    setState(() => _isPinging = false);
  }

  Future<void> _dnsLookup() async {
    final host = _dnsHost.text.trim();
    if (host.isEmpty) return;
    
    setState(() {
      _isDnsLookup = true;
      _dnsResult = 'Looking up $host...';
    });
    
    try {
      final result = await Process.run('nslookup', [host], runInShell: true);
      setState(() => _dnsResult = result.stdout.toString().substring(0, 500));
    } catch (_) {
      setState(() => _dnsResult = 'DNS lookup failed');
    }
    setState(() => _isDnsLookup = false);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: _tabs.map((tab) => Tab(icon: Icon(tab['icon']), text: tab['name'])).toList(),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildMonitorTab(),
          _buildScannerTab(),
          _buildToolsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildMonitorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Speed Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpeedItem('Download', _formatSpeed(_downloadSpeed), Icons.arrow_downward, Colors.green),
                _buildSpeedItem('Upload', _formatSpeed(_uploadSpeed), Icons.arrow_upward, Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Traffic Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live Traffic', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text('Down', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_upward, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text('Up', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(spots: _downloadSpots, isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false)),
                        LineChartBarData(spots: _uploadSpots, isCurved: true, color: Colors.orange, barWidth: 2, dotData: const FlDotData(show: false)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Total Data
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTotalItem('Download', '${_totalDownload.toStringAsFixed(2)} GB', Icons.download, Colors.green),
                _buildTotalItem('Upload', '${_totalUpload.toStringAsFixed(2)} GB', Icons.upload, Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Connection Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildInfoRow('Connected to', _currentSSID.isNotEmpty ? _currentSSID : 'Not connected', Icons.wifi),
                _buildInfoRow('IP Address', _currentIP.isNotEmpty ? _currentIP : '0.0.0.0', Icons.ip),
              ],
            ),
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
          // WiFi Scanner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('WiFi Networks', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _isScanning ? null : _scanWiFi,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                      child: Text(_isScanning ? 'SCANNING...' : 'SCAN'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_wifiNetworks.isEmpty && !_isScanning)
                  const Center(child: Text('No networks found', style: TextStyle(color: Colors.white38))),
                ..._wifiNetworks.take(5).map((net) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, color: Color(0xFF00BCD4), size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(net['ssid']!, style: const TextStyle(color: Colors.white))),
                      Text('${net['signal']} dBm', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Port Scanner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Port Scanner', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => _scanTarget = v,
                        decoration: const InputDecoration(
                          hintText: 'Enter IP',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isScanning ? null : _scanPorts,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                      child: Text(_isScanning ? 'SCANNING...' : 'SCAN'),
                    ),
                  ],
                ),
                if (_openPorts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._openPorts.map((port) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text('Port ${port['port']} - ${port['service']}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
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
          // Ping Tool
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Ping Tool', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pingHost,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Host or IP',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isPinging ? null : _pingHost,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                      child: _isPinging ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('PING'),
                    ),
                  ],
                ),
                if (_pingResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                      child: Text(_pingResult, style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace')),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // DNS Lookup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('DNS Lookup', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dnsHost,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Domain',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isDnsLookup ? null : _dnsLookup,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                      child: _isDnsLookup ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('LOOKUP'),
                    ),
                  ],
                ),
                if (_dnsResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                      child: SelectableText(_dnsResult, style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace', fontSize: 11)),
                    ),
                  ),
              ],
            ),
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
        _buildStatCard('Active Networks', _wifiNetworks.length.toString(), Icons.wifi, const Color(0xFF00BCD4)),
        _buildStatCard('Open Ports', _openPorts.length.toString(), Icons.portable_wifi_off, Colors.red),
      ],
    );
  }

  Widget _buildSpeedItem(String label, String speed, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 8),
      Text(speed, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }

  Widget _buildTotalItem(String label, String total, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(total, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ]);
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00BCD4), size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}
