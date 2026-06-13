import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:io';

class FloatingRadarChart extends StatefulWidget {
  final VoidCallback onClose;
  const FloatingRadarChart({super.key, required this.onClose});

  @override
  State<FloatingRadarChart> createState() => _FloatingRadarChartState();
}

class _FloatingRadarChartState extends State<FloatingRadarChart> {
  Offset _position = Offset.zero;
  double _width = 280;
  double _height = 280;
  
  Map<String, double> _metrics = {
    'CPU': 0.0, 'RAM': 0.0, 'Storage': 0.0, 'Battery': 0.0,
    'Network': 0.0, 'Temp': 0.0, 'Processes': 0.0, 'Uptime': 0.0,
    'Disk I/O': 0.0, 'GPU': 0.0, 'Security': 0.0, 'Performance': 0.0,
  };
  
  final List<String> _titles = [
    'CPU', 'RAM', 'Storage', 'Battery', 'Network', 'Temp',
    'Processes', 'Uptime', 'Disk I/O', 'GPU', 'Security', 'Performance'
  ];
  
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _position = Offset(
      MediaQuery.of(context).size.width - _width - 20,
      MediaQuery.of(context).size.height - _height - 100,
    );
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      _updateMetrics();
      setState(() {});
    });
  }

  void _updateMetrics() {
    setState(() {
      _metrics['CPU'] = 0.3 + (DateTime.now().millisecond % 50) / 100;
      _metrics['RAM'] = 0.45;
      _metrics['Storage'] = 0.6;
      _metrics['Battery'] = 0.75;
      _metrics['Network'] = 0.2 + (DateTime.now().second % 80) / 100;
      _metrics['Temp'] = 0.45;
      _metrics['Processes'] = 0.5;
      _metrics['Uptime'] = 0.1;
      _metrics['Disk I/O'] = 0.15 + (DateTime.now().millisecond % 30) / 100;
      _metrics['GPU'] = 0.2 + (DateTime.now().second % 50) / 100;
      _metrics['Security'] = 0.85;
      _metrics['Performance'] = 0.7;
      
      for (var key in _metrics.keys) {
        _metrics[key] = _metrics[key]!.clamp(0.0, 1.0);
      }
    });
  }

  List<RadarEntry> _getRadarEntries() {
    return _titles.map((title) => RadarEntry(value: _metrics[title] ?? 0.0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                    _position = Offset(
                      _position.dx.clamp(0, MediaQuery.of(context).size.width - _width),
                      _position.dy.clamp(0, MediaQuery.of(context).size.height - _height - 50),
                    );
                  });
                },
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.radar, color: Color(0xFF00BCD4), size: 18),
                      const SizedBox(width: 8),
                      const Text('Radar Monitor', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() { _width = 48; _height = 48; }),
                        child: const Icon(Icons.minimize, color: Color(0xFF00BCD4), size: 18),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Icon(Icons.close, color: Color(0xFF00BCD4), size: 18),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _width = (_width * details.scale).clamp(120.0, 500.0);
                      _height = (_height * details.scale).clamp(120.0, 500.0);
                    });
                  },
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          fillColor: const Color(0xFF00BCD4).withOpacity(0.2),
                          borderColor: const Color(0xFF00BCD4),
                          borderWidth: 1.5,
                          entryRadius: 3,
                          dataEntries: _getRadarEntries(),
                        ),
                      ],
                      radarBorderData: const BorderSide(color: Color(0xFF00BCD4), width: 1),
                      titlePositionPercentageOffset: 1.1,
                      getTitle: (index, angle) => RadarChartTitle(text: _titles[index], angle: angle),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
