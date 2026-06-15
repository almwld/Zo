import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/theme_manager.dart';

class BatteryCenter extends StatefulWidget {
  const BatteryCenter({super.key});

  @override
  State<BatteryCenter> createState() => _BatteryCenterState();
}

class _BatteryCenterState extends State<BatteryCenter> {
  final ThemeManager _themeManager = ThemeManager();
  late Timer _batteryTimer;
  
  // مقاييس البطارية
  int _batteryLevel = 85;
  bool _isCharging = true;
  int _batteryHealth = 92;
  int _batteryTemperature = 35;
  int _batteryVoltage = 3900;
  int _batteryCurrent = 1200;
  int _cycleCount = 342;
  String _batteryTechnology = 'Li-ion';
  DateTime _manufactureDate = DateTime(2023, 6, 15);
  
  // إحصائيات الاستخدام
  double _averageUsagePerHour = 8.5;
  double _screenOnTime = 2.5;
  double _remainingTime = 5.2;
  List<double> _usageHistory = [];
  
  // أوضاع الطاقة
  String _currentMode = 'Balanced';
  final List<String> _powerModes = ['Power Saver', 'Balanced', 'Performance', 'Ultimate'];
  
  // تطبيقات مستهلكة للطاقة
  List<Map<String, dynamic>> _powerHogs = [];

  @override
  void initState() {
    super.initState();
    _loadUsageHistory();
    _loadPowerHogs();
    _startBatterySimulation();
  }

  void _loadUsageHistory() {
    for (int i = 0; i < 24; i++) {
      _usageHistory.add(5 + Random().nextDouble() * 15);
    }
  }

  void _loadPowerHogs() {
    _powerHogs = [
      {'name': 'SI Agent', 'usage': 28, 'icon': Icons.psychology, 'color': Colors.purple},
      {'name': 'Network Scanner', 'usage': 22, 'icon': Icons.network_check, 'color': Colors.cyan},
      {'name': 'Web Browser', 'usage': 18, 'icon': Icons.public, 'color': Colors.blue},
      {'name': 'Terminal', 'usage': 12, 'icon': Icons.terminal, 'color': Colors.green},
      {'name': 'File Manager', 'usage': 8, 'icon': Icons.folder, 'color': Colors.orange},
      {'name': 'Background Services', 'usage': 12, 'icon': Icons.settings, 'color': Colors.grey},
    ];
  }

  void _startBatterySimulation() {
    _batteryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isCharging && _batteryLevel > 0) {
        setState(() {
          _batteryLevel = (_batteryLevel - 1).clamp(0, 100);
          _remainingTime = (_batteryLevel / _averageUsagePerHour).clamp(0, 24);
        });
      }
      if (mounted) setState(() {});
    });
  }

  void _setPowerMode(String mode) {
    setState(() {
      _currentMode = mode;
      switch (mode) {
        case 'Power Saver':
          _averageUsagePerHour = 5.5;
          break;
        case 'Balanced':
          _averageUsagePerHour = 8.5;
          break;
        case 'Performance':
          _averageUsagePerHour = 12.5;
          break;
        case 'Ultimate':
          _averageUsagePerHour = 15.5;
          break;
      }
      _remainingTime = (_batteryLevel / _averageUsagePerHour).clamp(0, 24);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Power mode changed to: $mode')),
    );
  }

  Color _getBatteryColor() {
    if (_batteryLevel <= 15) return Colors.red;
    if (_batteryLevel <= 30) return Colors.orange;
    if (_batteryLevel <= 60) return Colors.yellow;
    return Colors.green;
  }

  String _getBatteryStatus() {
    if (_isCharging) return 'Charging';
    if (_batteryLevel <= 15) return 'Critical';
    if (_batteryLevel <= 30) return 'Low';
    if (_batteryLevel <= 60) return 'Medium';
    return 'Good';
  }

  String _formatTime(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  @override
  void dispose() {
    _batteryTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Battery & Power Center'),
        backgroundColor: theme.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildBatteryCard()),
          SliverToBoxAdapter(child: _buildPowerModesCard()),
          SliverToBoxAdapter(child: _buildBatteryStatsCard()),
          SliverToBoxAdapter(child: _buildPowerHogsCard()),
          SliverToBoxAdapter(child: _buildUsageChart()),
        ],
      ),
    );
  }

  Widget _buildBatteryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade900, Colors.black],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.battery_full, color: _getBatteryColor(), size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_batteryLevel%',
                      style: TextStyle(color: _getBatteryColor(), fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getBatteryStatus(),
                      style: TextStyle(color: _getBatteryColor()),
                    ),
                    Text(
                      _isCharging ? '⚡ Charging' : '🔋 ${_formatTime(_remainingTime)} remaining',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _batteryLevel / 100,
            backgroundColor: Colors.grey.shade800,
            color: _getBatteryColor(),
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerModesCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Power Modes', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: _powerModes.map((mode) => Expanded(
              child: GestureDetector(
                onTap: () => _setPowerMode(mode),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _currentMode == mode ? _themeManager.currentTheme.accent : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      mode,
                      style: TextStyle(
                        color: _currentMode == mode ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Battery Stats', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(),
          _buildStatRow('Health', '$_batteryHealth%', Colors.green),
          _buildStatRow('Temperature', '$_batteryTemperature°C', _batteryTemperature > 40 ? Colors.red : Colors.orange),
          _buildStatRow('Voltage', '${_batteryVoltage}mV', Colors.blue),
          _buildStatRow('Current', '${_batteryCurrent}mA', Colors.cyan),
          _buildStatRow('Cycle Count', '$_cycleCount', Colors.purple),
          _buildStatRow('Technology', _batteryTechnology, Colors.grey),
          _buildStatRow('Manufactured', '${_manufactureDate.month}/${_manufactureDate.year}', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPowerHogsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Power Consumption by App', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(),
          ..._powerHogs.map((app) => ListTile(
            leading: Icon(app['icon'], color: app['color']),
            title: Text(app['name'], style: const TextStyle(color: Colors.white)),
            trailing: Text('${app['usage']}%', style: TextStyle(color: app['color'], fontWeight: FontWeight.bold)),
            subtitle: LinearProgressIndicator(
              value: app['usage'] / 100,
              backgroundColor: Colors.grey.shade800,
              color: app['color'],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    final maxUsage = _usageHistory.reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last 24 Hours Usage', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _usageHistory.length,
              itemBuilder: (ctx, i) {
                final height = (_usageHistory[i] / maxUsage) * 120;
                return Container(
                  width: 25,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: _themeManager.currentTheme.accent,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${i}', style: const TextStyle(color: Colors.grey, fontSize: 8)),
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
