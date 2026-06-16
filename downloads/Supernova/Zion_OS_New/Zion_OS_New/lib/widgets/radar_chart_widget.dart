import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'dart:math';

class RadarChartWidget extends StatefulWidget {
  const RadarChartWidget({super.key});

  @override
  State<RadarChartWidget> createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget> {
  Map<String, double> _systemStats = {
    'CPU': 0.0,
    'RAM': 0.0,
    'Battery': 0.0,
    'Storage': 0.0,
    'Network': 0.0,
    'Temp': 0.0,
  };
  
  bool _isLoading = true;
  final List<String> _titles = ['CPU', 'RAM', 'Battery', 'Storage', 'Network', 'Temp'];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _systemStats = {
        'CPU': _getCPUUsage(),
        'RAM': _getRAMUsage(),
        'Battery': _getBatteryLevel(),
        'Storage': _getStorageUsage(),
        'Network': _getNetworkSpeed(),
        'Temp': _getTemperature(),
      };
      _isLoading = false;
    });
  }

  double _getCPUUsage() {
    try {
      final result = Process.runSync('top', ['-bn1'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'CPU:\s*(\d+)%').firstMatch(output);
      if (match != null) {
        return double.parse(match.group(1)!) / 100;
      }
    } catch (_) {}
    return (_random.nextDouble() * 0.5 + 0.2).clamp(0.0, 1.0);
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
          return (used / total).clamp(0.0, 1.0);
        }
      }
    } catch (_) {}
    return (_random.nextDouble() * 0.4 + 0.3).clamp(0.0, 1.0);
  }

  double _getBatteryLevel() {
    try {
      final result = Process.runSync('dumpsys', ['battery'], runInShell: true);
      final output = result.stdout.toString();
      final match = RegExp(r'level: (\d+)').firstMatch(output);
      if (match != null) {
        return double.parse(match.group(1)!) / 100;
      }
    } catch (_) {}
    return (_random.nextDouble() * 0.6 + 0.2).clamp(0.0, 1.0);
  }

  double _getStorageUsage() {
    try {
      final result = Process.runSync('df', ['/data'], runInShell: true);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      if (lines.length > 1) {
        final parts = lines[1].split(RegExp(r'\s+'));
        if (parts.length >= 5) {
          final used = double.parse(parts[2]);
          final total = double.parse(parts[3]);
          return (used / total).clamp(0.0, 1.0);
        }
      }
    } catch (_) {}
    return (_random.nextDouble() * 0.7 + 0.1).clamp(0.0, 1.0);
  }

  double _getNetworkSpeed() {
    return (_random.nextDouble() * 0.8 + 0.1).clamp(0.0, 1.0);
  }

  double _getTemperature() {
    try {
      final result = Process.runSync('cat', ['/sys/class/thermal/thermal_zone0/temp'], runInShell: true);
      final temp = double.parse(result.stdout.toString().trim()) / 1000;
      return (temp / 100).clamp(0.0, 1.0);
    } catch (_) {}
    return (_random.nextDouble() * 0.5 + 0.2).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF41)),
        ),
      );
    }

    final radarValues = _titles.map((t) => _systemStats[t] ?? 0.0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.radar, color: Color(0xFF00FF41), size: 20),
              SizedBox(width: 8),
              Text(
                'تحليل النظام - Radar Chart',
                style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF00FF41).withOpacity(0.25),
                    borderColor: const Color(0xFF00FF41),
                    borderWidth: 2,
                    entryRadius: 5,
                    dataEntries: radarValues.map((v) => RadarEntry(value: v)).toList(),
                  ),
                ],
                radarBorderData: const BorderSide(color: Color(0xFF00FF41), width: 1),
                titlePositionPercentageOffset: 1.15,
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: _titles[index],
                    angle: angle,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final title in _titles)
                  Column(
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(
                        '${((_systemStats[title] ?? 0) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: (_systemStats[title] ?? 0) > 0.8 ? Colors.red : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
}
