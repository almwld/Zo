import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/theme_manager.dart';

class HardwareCenter extends StatefulWidget {
  const HardwareCenter({super.key});

  @override
  State<HardwareCenter> createState() => _HardwareCenterState();
}

class _HardwareCenterState extends State<HardwareCenter> {
  final ThemeManager _themeManager = ThemeManager();
  late Timer _hardwareTimer;
  
  // معلومات الجهاز
  String _deviceModel = 'Zion Device';
  String _manufacturer = 'Unknown';
  String _androidVersion = '13';
  String _kernelVersion = '5.10.';
  String _buildNumber = 'ZION.240601';
  
  // المعالج
  String _cpuArch = 'ARMv8-A';
  int _cpuCores = 8;
  int _cpuMaxFreq = 2800;
  int _cpuCurrentFreq = 1200;
  int _cpuUsage = 25;
  List<double> _cpuCoreUsage = [15, 22, 18, 30, 25, 20, 28, 32];
  
  // الذاكرة
  int _totalRam = 8192;
  int _usedRam = 3240;
  int _availableRam = 4952;
  
  // التخزين
  int _totalStorage = 128;
  int _usedStorage = 64;
  int _availableStorage = 64;
  
  // المستشعرات
  List<Map<String, dynamic>> _sensors = [];
  Map<String, dynamic> _sensorReadings = {};
  
  // الشاشة
  double _brightness = 0.7;
  int _refreshRate = 60;
  String _resolution = '1080 x 2400';
  double _screenSize = 6.5;
  
  // الشبكة
  String _wifiName = 'Zion_Network';
  int _wifiStrength = 85;
  String _ipAddress = '192.168.1.100';
  String _macAddress = 'AA:BB:CC:DD:EE:FF';

  @override
  void initState() {
    super.initState();
    _loadSensors();
    _startHardwareMonitoring();
  }

  void _loadSensors() {
    _sensors = [
      {'name': 'Accelerometer', 'status': 'Active', 'icon': Icons.speed, 'color': Colors.cyan},
      {'name': 'Gyroscope', 'status': 'Active', 'icon': Icons.rotate_right, 'color': Colors.green},
      {'name': 'Magnetometer', 'status': 'Active', 'icon': Icons.explore, 'color': Colors.purple},
      {'name': 'Proximity', 'status': 'Active', 'icon': Icons.touch_app, 'color': Colors.orange},
      {'name': 'Light Sensor', 'status': 'Active', 'icon': Icons.wb_sunny, 'color': Colors.yellow},
      {'name': 'Fingerprint', 'status': 'Active', 'icon': Icons.fingerprint, 'color': Colors.blue},
    ];
    
    _sensorReadings = {
      'Accelerometer': 'x:0.2, y:9.8, z:0.1',
      'Gyroscope': 'x:0.0, y:0.0, z:0.0',
      'Magnetometer': 'x:25.3, y:-12.7, z:48.2',
      'Proximity': '5.0 cm',
      'Light Sensor': '320 lux',
    };
  }

  void _startHardwareMonitoring() {
    final random = Random();
    _hardwareTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _cpuUsage = 10 + random.nextInt(50);
        _cpuCurrentFreq = 800 + random.nextInt(2000);
        _usedRam = 2000 + random.nextInt(4000);
        _availableRam = _totalRam - _usedRam;
        
        for (int i = 0; i < _cpuCoreUsage.length; i++) {
          _cpuCoreUsage[i] = 5 + random.nextInt(60).toDouble();
        }
      });
    });
  }

  void _setBrightness(double value) {
    setState(() => _brightness = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Brightness set to ${(value * 100).toInt()}%')),
    );
  }

  void _testSensor(String sensor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Testing $sensor sensor...')),
    );
  }

  @override
  void dispose() {
    _hardwareTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Hardware & Sensors'),
        backgroundColor: theme.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildDeviceInfoCard()),
          SliverToBoxAdapter(child: _buildCpuCard()),
          SliverToBoxAdapter(child: _buildMemoryCard()),
          SliverToBoxAdapter(child: _buildStorageCard()),
          SliverToBoxAdapter(child: _buildSensorsCard()),
          SliverToBoxAdapter(child: _buildDisplayCard()),
          SliverToBoxAdapter(child: _buildNetworkCard()),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade900, Colors.purple.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.devices, color: Colors.white),
              SizedBox(width: 8),
              Text('Device Information', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(color: Colors.white24),
          _buildInfoRow('Model', _deviceModel),
          _buildInfoRow('Manufacturer', _manufacturer),
          _buildInfoRow('Android Version', _androidVersion),
          _buildInfoRow('Kernel Version', _kernelVersion),
          _buildInfoRow('Build Number', _buildNumber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCpuCard() {
    final avgCoreUsage = _cpuCoreUsage.reduce((a, b) => a + b) / _cpuCoreUsage.length;
    
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
          const Row(
            children: [
              Icon(Icons.memory, color: Colors.cyan),
              SizedBox(width: 8),
              Text('Processor', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          _buildStatRow('Architecture', _cpuArch, Colors.cyan),
          _buildStatRow('Cores', '$_cpuCores', Colors.cyan),
          _buildStatRow('Max Frequency', '${_cpuMaxFreq} MHz', Colors.cyan),
          _buildStatRow('Current Frequency', '${_cpuCurrentFreq} MHz', Colors.green),
          _buildStatRow('Overall Usage', '${_cpuUsage.toStringAsFixed(0)}%', _cpuUsage > 70 ? Colors.red : Colors.green),
          const SizedBox(height: 12),
          const Text('Core Usage', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_cpuCoreUsage.length, (i) => Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Core ${i + 1}', style: const TextStyle(color: Colors.grey)),
                  Text('${_cpuCoreUsage[i].toStringAsFixed(0)}%', style: const TextStyle(color: Colors.cyan)),
                  LinearProgressIndicator(
                    value: _cpuCoreUsage[i] / 100,
                    backgroundColor: Colors.grey.shade700,
                    color: Colors.cyan,
                  ),
                ],
              ),
            )),
          ),
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

  Widget _buildMemoryCard() {
    final usedPercent = _usedRam / _totalRam;
    
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
          const Row(
            children: [
              Icon(Icons.storage, color: Colors.green),
              SizedBox(width: 8),
              Text('Memory (RAM)', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: Colors.white70)),
              Text('${(_totalRam / 1024).toStringAsFixed(1)} GB', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: usedPercent,
            backgroundColor: Colors.grey.shade800,
            color: usedPercent > 0.8 ? Colors.red : Colors.green,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: ${(_usedRam / 1024).toStringAsFixed(1)} GB', style: const TextStyle(color: Colors.white70)),
              Text('Available: ${(_availableRam / 1024).toStringAsFixed(1)} GB', style: const TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    final usedPercent = _usedStorage / _totalStorage;
    
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
          const Row(
            children: [
              Icon(Icons.sd_storage, color: Colors.orange),
              SizedBox(width: 8),
              Text('Storage', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: Colors.white70)),
              Text('$_totalStorage GB', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: usedPercent,
            backgroundColor: Colors.grey.shade800,
            color: usedPercent > 0.8 ? Colors.red : Colors.orange,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: $_usedStorage GB', style: const TextStyle(color: Colors.white70)),
              Text('Free: $_availableStorage GB', style: const TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorsCard() {
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
          const Row(
            children: [
              Icon(Icons.sensors, color: Colors.purple),
              SizedBox(width: 8),
              Text('Sensors', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          ..._sensors.map((sensor) => ListTile(
            dense: true,
            leading: Icon(sensor['icon'], color: sensor['color']),
            title: Text(sensor['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(_sensorReadings[sensor['name']] ?? 'Reading...', style: const TextStyle(color: Colors.grey)),
            trailing: ElevatedButton(
              onPressed: () => _testSensor(sensor['name']),
              style: ElevatedButton.styleFrom(backgroundColor: sensor['color']),
              child: const Text('Test'),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDisplayCard() {
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
          const Row(
            children: [
              Icon(Icons.screen, color: Colors.blue),
              SizedBox(width: 8),
              Text('Display', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          _buildStatRow('Resolution', _resolution, Colors.blue),
          _buildStatRow('Screen Size', '${_screenSize}"', Colors.blue),
          _buildStatRow('Refresh Rate', '$_refreshRate Hz', Colors.blue),
          ListTile(
            title: const Text('Brightness', style: TextStyle(color: Colors.white)),
            subtitle: Slider(
              value: _brightness,
              onChanged: _setBrightness,
              activeColor: Colors.blue,
            ),
            trailing: Text('${(_brightness * 100).toInt()}%', style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard() {
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
          const Row(
            children: [
              Icon(Icons.wifi, color: Colors.cyan),
              SizedBox(width: 8),
              Text('Network', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const Divider(),
          _buildStatRow('WiFi', _wifiName, Colors.cyan),
          _buildStatRow('Signal Strength', '$_wifiStrength%', _wifiStrength > 70 ? Colors.green : Colors.orange),
          _buildStatRow('IP Address', _ipAddress, Colors.cyan),
          _buildStatRow('MAC Address', _macAddress, Colors.cyan),
          LinearProgressIndicator(
            value: _wifiStrength / 100,
            backgroundColor: Colors.grey.shade800,
            color: _wifiStrength > 70 ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }
}
