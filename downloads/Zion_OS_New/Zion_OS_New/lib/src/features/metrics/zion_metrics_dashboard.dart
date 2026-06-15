import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ZionMetricsDashboard extends StatefulWidget {
  const ZionMetricsDashboard({super.key});

  @override
  State<ZionMetricsDashboard> createState() => _ZionMetricsDashboardState();
}

class _ZionMetricsDashboardState extends State<ZionMetricsDashboard> with SingleTickerProviderStateMixin {
  late Timer _timer;
  
  // مقاييس CPU
  double _cpuUsage = 0.0;
  double _cpuTemp = 0.0;
  int _cpuCores = 8;
  
  // مقاييس AI
  double _aiConfidence = 0.0;
  int _aiPredictions = 0;
  double _neuralActivity = 0.0;
  
  // مقاييس الاختراق
  int _activeAttacks = 0;
  int _successfulAttacks = 0;
  int _failedAttacks = 0;
  double _attackSuccessRate = 0.0;
  
  // مقاييس الهجمات
  int _totalPackets = 0;
  int _interceptedPackets = 0;
  int _vulnerabilitiesFound = 0;
  
  // ألوان متحركة
  final Random _random = Random();
  Color _primaryColor = Colors.green;
  Color _secondaryColor = Colors.cyan;

  @override
  void initState() {
    super.initState();
    _startMetricsSimulation();
    _animateColors();
  }

  void _startMetricsSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        // محاكاة CPU
        _cpuUsage = 20 + _random.nextDouble() * 60;
        _cpuTemp = 35 + _cpuUsage * 0.5;
        
        // محاكاة AI
        _aiConfidence = 0.6 + _random.nextDouble() * 0.35;
        _aiPredictions += _random.nextInt(5);
        _neuralActivity = _random.nextDouble();
        
        // محاكاة الاختراق
        if (_random.nextDouble() > 0.7) {
          _activeAttacks = _random.nextInt(10);
          if (_random.nextDouble() > 0.6) {
            _successfulAttacks++;
          } else {
            _failedAttacks++;
          }
        }
        _attackSuccessRate = _successfulAttacks + _failedAttacks > 0 
            ? _successfulAttacks / (_successfulAttacks + _failedAttacks) * 100 
            : 0;
        
        // محاكاة الهجمات
        _totalPackets += _random.nextInt(100);
        _interceptedPackets += _random.nextInt(50);
        if (_random.nextDouble() > 0.8) {
          _vulnerabilitiesFound++;
        }
      });
    });
  }

  void _animateColors() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        final hue = (_primaryColor.hue + 1) % 360;
        _primaryColor = HSLColor.fromAHSL(1, hue, 0.8, 0.5).toColor();
        _secondaryColor = HSLColor.fromAHSL(1, (hue + 120) % 360, 0.8, 0.5).toColor();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor.withOpacity(0.1), Colors.black],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Zion Metrics Dashboard'),
              backgroundColor: Colors.transparent,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryColor, _secondaryColor],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, size: 60, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          'Real-time Attack Analytics',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  _buildMetricCard('CPU Usage', '${_cpuUsage.toStringAsFixed(1)}%', Icons.memory, _cpuUsage / 100, Colors.cyan, 'Temperature: ${_cpuTemp.toStringAsFixed(1)}°C'),
                  _buildMetricCard('AI Confidence', '${(_aiConfidence * 100).toStringAsFixed(1)}%', Icons.psychology, _aiConfidence, Colors.purple, 'Predictions: $_aiPredictions'),
                  _buildMetricCard('Neural Activity', '${(_neuralActivity * 100).toStringAsFixed(1)}%', Icons.bubble_chart, _neuralActivity, Colors.pink, 'Active neurons'),
                  _buildMetricCard('Active Attacks', '$_activeAttacks', Icons.flash_on, _activeAttacks / 10, Colors.red, 'Ongoing operations'),
                  _buildMetricCard('Success Rate', '${_attackSuccessRate.toStringAsFixed(1)}%', Icons.check_circle, _attackSuccessRate / 100, Colors.green, 'Successful: $_successfulAttacks'),
                  _buildMetricCard('Vulnerabilities', '$_vulnerabilitiesFound', Icons.bug_report, _vulnerabilitiesFound / 100, Colors.orange, 'New discoveries'),
                  _buildMetricCard('Packet Analysis', '${_interceptedPackets}', Icons.network_check, _interceptedPackets / 1000, Colors.blue, 'Total: $_totalPackets'),
                  _buildMetricCard('Attack Efficiency', '${(_attackSuccessRate * 0.8).toStringAsFixed(1)}%', Icons.speed, (_attackSuccessRate * 0.8) / 100, Colors.teal, 'Real-time score'),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAttackTimeline(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, double progress, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: Colors.grey.shade800, color: color),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAttackTimeline() {
    final timelineData = List.generate(20, (index) {
      final time = DateTime.now().subtract(Duration(minutes: index));
      final intensity = _random.nextDouble();
      return TimelinePoint(time: time, intensity: intensity);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: Colors.cyan),
              SizedBox(width: 8),
              Text('Attack Timeline', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timelineData.length,
              itemBuilder: (ctx, i) {
                final point = timelineData[i];
                return Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 4,
                          height: 100 * point.intensity,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(point.intensity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${point.time.minute}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
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

class TimelinePoint {
  final DateTime time;
  final double intensity;
  TimelinePoint({required this.time, required this.intensity});
}
