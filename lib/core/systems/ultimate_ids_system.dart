import 'dart:async';
import 'dart:io';
import 'dart:convert';

class UltimateIdsSystem {
  final List<Map<String, dynamic>> _alerts = [];
  final Map<String, int> _scanCounters = {};
  bool _isMonitoring = false;

  /// بدء المراقبة
  void startMonitoring() {
    _isMonitoring = true;
  }

  /// تحليل حزمة والكشف عن التهديدات
  Map<String, dynamic>? analyzePacket(Map<String, dynamic> packet) {
    if (!_isMonitoring) return null;

    // كشف SYN Flood
    if (packet['protocol'] == 'TCP' && packet['flags'] != null && (packet['flags'] as List).contains('SYN') && !(packet['flags'] as List).contains('ACK')) {
      final srcIp = packet['src_ip'];
      _scanCounters[srcIp] = (_scanCounters[srcIp] ?? 0) + 1;
      if (_scanCounters[srcIp]! > 100) {
        return _createAlert('SYN Flood Attack', srcIp, 'Critical');
      }
    }

    // كشف Port Scan
    if (packet['protocol'] == 'TCP' && packet['flags'] != null && (packet['flags'] as List).contains('SYN')) {
      final srcIp = packet['src_ip'];
      final dstPort = packet['dst_port'];
      final key = '$srcIp:$dstPort';
      _scanCounters[key] = (_scanCounters[key] ?? 0) + 1;
      if (_scanCounters.values.where((v) => v > 10).length > 20) {
        return _createAlert('Port Scan Detected', srcIp, 'High');
      }
    }

    // كشف SQL Injection
    if (packet['protocol'] == 'TCP' && packet['dst_port'] == 80 || packet['dst_port'] == 443) {
      final payload = packet['payload']?.toString() ?? '';
      if (_hasSqlPatterns(payload)) {
        return _createAlert('SQL Injection Attempt', packet['src_ip'], 'Critical');
      }
    }

    return null;
  }

  /// إنشاء تنبيه
  Map<String, dynamic> _createAlert(String type, String source, String severity) {
    final alert = {
      'type': type,
      'source': source,
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _alerts.add(alert);
    return alert;
  }

  bool _hasSqlPatterns(String payload) {
    final patterns = [
      r'(\bUNION\b|\bSELECT\b|\bDROP\b|\bINSERT\b)',
      r"' OR '1'='1",
      r'" OR "1"="1',
    ];
    return patterns.any((p) => RegExp(p, caseSensitive: false).hasMatch(payload));
  }

  /// الحصول على التنبيهات
  List<Map<String, dynamic>> getAlerts({String? severity}) {
    if (severity != null) {
      return _alerts.where((a) => a['severity'] == severity).toList();
    }
    return _alerts;
  }

  Map<String, dynamic> getStats() {
    return {
      'total_alerts': _alerts.length,
      'critical': _alerts.where((a) => a['severity'] == 'Critical').length,
      'high': _alerts.where((a) => a['severity'] == 'High').length,
    };
  }
}
