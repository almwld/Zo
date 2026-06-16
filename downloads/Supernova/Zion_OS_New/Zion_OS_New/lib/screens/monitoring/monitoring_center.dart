import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'dart:async';

class MonitoringCenter extends StatefulWidget {
  const MonitoringCenter({super.key});

  @override
  State<MonitoringCenter> createState() => _MonitoringCenterState();
}

class _MonitoringCenterState extends State<MonitoringCenter> {
  double _cpuUsage = 0.0;
  double _ramUsage = 0.0;
  double _batteryLevel = 0.0;
  double _networkSpeed = 0.0;
  double _diskUsage = 0.0;
  double _temperature = 0.0;
  
  List<FlSpot> _cpuHistory = [];
  List<FlSpot> _ramHistory = [];
  Timer? _timer;
  int _dataPoint = 0;

  @override
  void initState() {
    super.initState();
    _initData();
    _startMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initData() {
    for (int i = 0; i < 20; i++) {
      _cpuHistory.add(FlSpot(i.toDouble(), 0));
      _ramHistory.add(FlSpot(i.toDouble(), 0));
    }
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateStats();
      _updateHistory();
      setState(() {});
    });
  }

  void _updateStats() {
    _cpuUsage = _getCPUUsage();
    _ramUsage = _getRAMUsage();
    _batteryLevel = _getBatteryLevel();
    _networkSpeed = _getNetworkSpeed();
    _diskUsage = _getDiskUsage();
    _temperature = _getTemperature();
  }

  void _updateHistory() {
    _dataPoint++;
    _cpuHistory.add(FlSpot(_dataPoint.toDouble(), _cpuUsage));
    _ramHistory.add(FlSpot(_dataPoint.toDouble(), _ramUsage));
    
    if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
    if (_ramHistory.length > 20) _ramHistory.removeAt(0);
  }

  double _getCPUUsage() {
    try {
      final result = Process.runSync('top', ['-bn1'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'CPU:\s*(\d+)%').firstMatch(output);
      if (match != null) return double.parse(match.group(1)!) / 100;
    } catch (_) {}
    return 0.3 + (DateTime.now().millisecond % 50) / 100;
  }

  double _getRAMUsage() {
    try {
      final result = Process.runSync('free', [], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final total = double.parse(parts[1]);
          final used = double.parse(parts[2]);
          return used / total;
        }
      }
    } catch (_) {}
    return 0.5;
  }

  double _getBatteryLevel() {
    try {
      final result = Process.runSync('dumpsys', ['battery'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'level: (\d+)').firstMatch(output);
      if (match != null) return double.parse(match.group(1)!) / 100;
    } catch (_) {}
    return 0.75;
  }

  double _getNetworkSpeed() {
    return (DateTime.now().millisecond % 100) / 100;
  }

  double _getDiskUsage() {
    try {
      final result = Process.runSync('df', ['/data'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 5) {
          final used = double.parse(parts[2]);
          final total = double.parse(parts[3]);
          return used / total;
        }
      }
    } catch (_) {}
    return 0.6;
  }

  double _getTemperature() {
    try {
      final result = Process.runSync('cat', ['/sys/class/thermal/thermal_zone0/temp'], runInShell: true);
      final temp = double.parse(result.stdout.toString().trim()) / 1000;
      return temp;
    } catch (_) {}
    return 35 + (DateTime.now().millisecond % 10);
  }

  Color _getStatusColor(double value, bool isInverse) {
    if (isInverse) {
      if (value > 80) return Colors.green;
      if (value > 50) return Colors.orange;
      return Colors.red;
    } else {
      if (value < 30) return Colors.green;
      if (value < 60) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Monitoring Center', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: () => _updateStats(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard('CPU', '${(_cpuUsage * 100).toStringAsFixed(1)}%', Icons.memory, _getStatusColor(_cpuUsage * 100, false)),
                _buildStatCard('RAM', '${(_ramUsage * 100).toStringAsFixed(1)}%', Icons.ram, _getStatusColor(_ramUsage * 100, false)),
                _buildStatCard('Battery', '${(_batteryLevel * 100).toStringAsFixed(1)}%', Icons.battery_full, _getStatusColor(_batteryLevel * 100, true)),
                _buildStatCard('Disk', '${(_diskUsage * 100).toStringAsFixed(1)}%', Icons.storage, _getStatusColor(_diskUsage * 100, false)),
                _buildStatCard('Network', '${(_networkSpeed * 100).toStringAsFixed(1)} Mbps', Icons.speed, const Color(0xFF00BCD4)),
                _buildStatCard('Temp', '${_temperature.toStringAsFixed(1)}°C', Icons.thermostat, const Color(0xFF00BCD4)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // CPU Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CPU Usage History', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _cpuHistory,
                            isCurved: true,
                            color: const Color(0xFF00BCD4),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // RAM Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RAM Usage History', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _ramHistory,
                            isCurved: true,
                            color: const Color(0xFF00BCD4),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Gauge Indicators
            Row(
              children: [
                Expanded(child: _buildGaugeCard('CPU', _cpuUsage)),
                const SizedBox(width: 12),
                Expanded(child: _buildGaugeCard('RAM', _ramUsage)),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(child: _buildGaugeCard('Storage', _diskUsage)),
                const SizedBox(width: 12),
                Expanded(child: _buildGaugeCard('Battery', _batteryLevel)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), Colors.black],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildGaugeCard(String title, double value) {
    final percentage = (value * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(percentage, title == 'Battery')),
                  strokeWidth: 6,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
