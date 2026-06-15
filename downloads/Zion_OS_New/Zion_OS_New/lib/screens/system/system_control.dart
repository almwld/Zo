import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/system_control_service.dart';

class SystemControlCenter extends StatefulWidget {
  const SystemControlCenter({super.key});

  @override
  State<SystemControlCenter> createState() => _SystemControlCenterState();
}

class _SystemControlCenterState extends State<SystemControlCenter> with SingleTickerProviderStateMixin {
  late SystemControlService _systemService;
  late TabController _tabController;
  
  final List<FlSpot> _cpuHistory = [];
  final List<FlSpot> _ramHistory = [];
  
  double _currentCPU = 0;
  double _currentRAM = 0;
  double _currentDisk = 0;
  double _currentTemp = 0;
  int _currentUptime = 0;
  int _currentProcesses = 0;
  
  @override
  void initState() {
    super.initState();
    _systemService = SystemControlService();
    _systemService.startMonitoring();
    _systemService.systemStats.listen(_updateStats);
    _tabController = TabController(length: 3, vsync: this);
    
    for (int i = 0; i < 20; i++) {
      _cpuHistory.add(FlSpot(i.toDouble(), 0));
      _ramHistory.add(FlSpot(i.toDouble(), 0));
    }
  }
  
  @override
  void dispose() {
    _systemService.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void _updateStats(Map<String, dynamic> stats) {
    setState(() {
      _currentCPU = stats['cpu'];
      _currentRAM = stats['ram'];
      _currentDisk = stats['disk'];
      _currentTemp = stats['temperature'];
      _currentUptime = stats['uptime'];
      _currentProcesses = stats['processes'];
      
      _cpuHistory.add(FlSpot(_cpuHistory.length.toDouble(), _currentCPU));
      if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
      
      _ramHistory.add(FlSpot(_ramHistory.length.toDouble(), _currentRAM));
      if (_ramHistory.length > 20) _ramHistory.removeAt(0);
    });
  }
  
  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (days > 0) return '$daysd ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
  
  Future<void> _confirmReboot() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reboot System', style: TextStyle(color: Color(0xFF00BCD4))),
        content: const Text('Are you sure you want to reboot the system?', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reboot', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _systemService.rebootSystem();
    }
  }
  
  Future<void> _confirmShutdown() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shutdown', style: TextStyle(color: Color(0xFF00BCD4))),
        content: const Text('Are you sure you want to shutdown the system?', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Shutdown', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _systemService.shutdownSystem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('System Control', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Monitor'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
            Tab(icon: Icon(Icons.power_settings_new), text: 'Control'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonitorTab(),
          _buildStatsTab(),
          _buildControlTab(),
        ],
      ),
    );
  }
  
  Widget _buildMonitorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // CPU Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.memory, color: Color(0xFF00BCD4)),
                    SizedBox(width: 8),
                    Text('CPU Usage', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _currentCPU / 100,
                        backgroundColor: Colors.white24,
                        color: _getCPUColor(),
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${_currentCPU.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
          
          const SizedBox(height: 16),
          
          // RAM Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.ram, color: Color(0xFF00BCD4)),
                    SizedBox(width: 8),
                    Text('RAM Usage', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _currentRAM / 100,
                        backgroundColor: Colors.white24,
                        color: Colors.green,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${_currentRAM.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                          color: Colors.green,
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
          
          const SizedBox(height: 16),
          
          // Storage Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storage, color: Color(0xFF00BCD4)),
                    SizedBox(width: 8),
                    Text('Storage Usage', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _currentDisk / 100,
                        backgroundColor: Colors.white24,
                        color: Colors.orange,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${_currentDisk.toStringAsFixed(1)}%',
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
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
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatCard('CPU Usage', '${_currentCPU.toStringAsFixed(1)}%', Icons.memory, _getCPUColor()),
        _buildStatCard('RAM Usage', '${_currentRAM.toStringAsFixed(1)}%', Icons.ram, Colors.green),
        _buildStatCard('Storage Usage', '${_currentDisk.toStringAsFixed(1)}%', Icons.storage, Colors.orange),
        _buildStatCard('Temperature', '${_currentTemp.toStringAsFixed(1)}°C', Icons.thermostat, Colors.red),
        _buildStatCard('Uptime', _formatUptime(_currentUptime), Icons.timer, const Color(0xFF00BCD4)),
        _buildStatCard('Processes', '$_currentProcesses', Icons.code, Colors.purple),
      ],
    );
  }
  
  Widget _buildControlTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 50),
                const SizedBox(height: 15),
                const Text('System Controls', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('These actions will affect the entire system', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  Icons.refresh,
                  'Restart UI',
                  () {},
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildControlButton(
                  Icons.restart_alt,
                  'Reboot',
                  _confirmReboot,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  Icons.power_settings_new,
                  'Shutdown',
                  _confirmShutdown,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildControlButton(
                  Icons.settings_backup_restore,
                  'Factory Reset',
                  () {},
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54)),
                Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  Color _getCPUColor() {
    if (_currentCPU < 30) return Colors.green;
    if (_currentCPU < 70) return Colors.orange;
    return Colors.red;
  }
}
