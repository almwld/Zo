import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/power_service.dart';

class PowerCenter extends StatefulWidget {
  const PowerCenter({super.key});

  @override
  State<PowerCenter> createState() => _PowerCenterState();
}

class _PowerCenterState extends State<PowerCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<FlSpot> _cpuHistory = [];
  final List<FlSpot> _ramHistory = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initHistory();
  }
  
  void _initHistory() {
    for (int i = 0; i < 20; i++) {
      _cpuHistory.add(FlSpot(i.toDouble(), 0));
      _ramHistory.add(FlSpot(i.toDouble(), 0));
    }
  }
  
  void _updateHistory(PowerService service) {
    if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
    if (_ramHistory.length > 20) _ramHistory.removeAt(0);
    _cpuHistory.add(FlSpot(_cpuHistory.length.toDouble(), service.cpuUsage));
    _ramHistory.add(FlSpot(_ramHistory.length.toDouble(), service.ramUsage));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PowerService>(
      builder: (context, service, child) {
        _updateHistory(service);
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Power & Performance', style: TextStyle(color: Color(0xFF00BCD4))),
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
                Tab(icon: Icon(Icons.battery_full), text: 'Power'),
                Tab(icon: Icon(Icons.speed), text: 'Performance'),
                Tab(icon: Icon(Icons.insights), text: 'Stats'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPowerTab(service),
              _buildPerformanceTab(service),
              _buildStatsTab(service),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPowerTab(PowerService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Battery Gauge
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [service.getBatteryColor().withOpacity(0.2), Colors.black],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: service.getBatteryColor().withOpacity(0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: service.batteryLevel / 100,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(service.getBatteryColor()),
                        strokeWidth: 12,
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          service.batteryState == BatteryState.charging 
                              ? Icons.battery_charging_full 
                              : Icons.battery_full,
                          color: service.getBatteryColor(),
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${service.batteryLevel}%',
                          style: TextStyle(
                            color: service.getBatteryColor(),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          service.getBatteryStatusText(),
                          style: TextStyle(color: service.getBatteryColor(), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Power Modes
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Power Modes', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        'Power Save',
                        Icons.battery_saver,
                        service.isPowerSaveMode,
                        () => service.setPowerSaveMode(true),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildModeCard(
                        'Performance',
                        Icons.rocket,
                        service.isPerformanceMode,
                        () => service.setPerformanceMode(true),
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Battery Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Status', service.getBatteryStatusText(), service.getBatteryColor()),
                _buildInfoRow('Temperature', '${service.temperature.toStringAsFixed(1)}°C', Colors.white54),
                _buildInfoRow('Technology', 'Li-Po', Colors.white54),
                _buildInfoRow('Health', 'Good', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceTab(PowerService service) {
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
                        value: service.cpuUsage / 100,
                        backgroundColor: Colors.white24,
                        color: Colors.blue,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${service.cpuUsage.toStringAsFixed(1)}%',
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
                        value: service.ramUsage / 100,
                        backgroundColor: Colors.white24,
                        color: Colors.green,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${service.ramUsage.toStringAsFixed(1)}%',
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
                          color: const Color(0xFF4CAF50),
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
                        value: service.diskUsage / 100,
                        backgroundColor: Colors.white24,
                        color: Colors.orange,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${service.diskUsage.toStringAsFixed(1)}%',
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
  
  Widget _buildStatsTab(PowerService service) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatCard('CPU', '${service.cpuUsage.toStringAsFixed(1)}%', Icons.memory, Colors.blue),
        _buildStatCard('RAM', '${service.ramUsage.toStringAsFixed(1)}%', Icons.ram, Colors.green),
        _buildStatCard('Storage', '${service.diskUsage.toStringAsFixed(1)}%', Icons.storage, Colors.orange),
        _buildStatCard('Temperature', '${service.temperature.toStringAsFixed(1)}°C', Icons.thermostat, Colors.red),
        _buildStatCard('Battery', '${service.batteryLevel}%', Icons.battery_full, service.getBatteryColor()),
        _buildStatCard('Mode', service.isPerformanceMode ? 'Performance' : (service.isPowerSaveMode ? 'Power Save' : 'Balanced'), Icons.settings, const Color(0xFF00BCD4)),
      ],
    );
  }
  
  Widget _buildModeCard(String title, IconData icon, bool isActive, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? color : Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : Colors.white54, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: isActive ? color : Colors.white54, fontWeight: FontWeight.bold)),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('ACTIVE', style: TextStyle(fontSize: 8)),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
}
