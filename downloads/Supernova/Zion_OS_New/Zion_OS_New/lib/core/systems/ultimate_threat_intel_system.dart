import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateThreatIntelSystem {
  final List<Map<String, dynamic>> _threatDatabase = [];
  final Map<String, List<Map<String, dynamic>>> _indicatorDatabase = {};

  /// إضافة مؤشر تهديد (IOC)
  void addIndicator({
    required String type,
    required String value,
    String? category,
    int confidence = 50,
  }) {
    if (!_indicatorDatabase.containsKey(type)) {
      _indicatorDatabase[type] = [];
    }

    _indicatorDatabase[type]!.add({
      'value': value,
      'category': category ?? 'unknown',
      'confidence': confidence,
      'added_at': DateTime.now().toIso8601String(),
      'last_seen': DateTime.now().toIso8601String(),
      'hits': 0,
    });
  }

  /// فحص مؤشر (هل هو ضار؟)
  Map<String, dynamic> checkIndicator(String type, String value) {
    final indicators = _indicatorDatabase[type] ?? [];
    final match = indicators.where((i) => i['value'] == value).toList();

    if (match.isNotEmpty) {
      match.first['hits']++;
      match.first['last_seen'] = DateTime.now().toIso8601String();
      return {
        'malicious': true,
        'type': type,
        'value': value,
        'category': match.first['category'],
        'confidence': match.first['confidence'],
      };
    }

    return {'malicious': false, 'type': type, 'value': value};
  }

  /// إضافة تقرير تهديد
  Map<String, dynamic> addThreatReport({
    required String title,
    required String severity,
    required String description,
    String? cve,
    List<String>? affectedSystems,
    List<Map<String, String>>? indicators,
  }) {
    final report = {
      'id': _threatDatabase.length + 1,
      'title': title,
      'severity': severity,
      'description': description,
      'cve': cve,
      'affected_systems': affectedSystems ?? [],
      'indicators': indicators ?? [],
      'published_at': DateTime.now().toIso8601String(),
      'status': 'active',
    };

    _threatDatabase.add(report);

    // إضافة المؤشرات تلقائيًا
    if (indicators != null) {
      for (final indicator in indicators) {
        addIndicator(
          type: indicator['type'] ?? 'unknown',
          value: indicator['value'] ?? '',
          category: title,
          confidence: 80,
        );
      }
    }

    return report;
  }

  /// البحث عن تهديدات حسب النوع
  List<Map<String, dynamic>> searchThreats({String? severity, String? system}) {
    var results = _threatDatabase;

    if (severity != null) {
      results = results.where((t) => t['severity'] == severity).toList();
    }
    if (system != null) {
      results = results.where((t) => (t['affected_systems'] as List).contains(system)).toList();
    }

    return results;
  }

  /// توليد تقرير استخباراتي
  String generateIntelReport() {
    final report = StringBuffer();
    report.writeln('=' * 60);
    report.writeln('THREAT INTELLIGENCE REPORT');
    report.writeln('=' * 60);
    report.writeln('Generated: ${DateTime.now().toIso8601String()}');
    report.writeln('');

    final critical = _threatDatabase.where((t) => t['severity'] == 'Critical').length;
    final high = _threatDatabase.where((t) => t['severity'] == 'High').length;
    final medium = _threatDatabase.where((t) => t['severity'] == 'Medium').length;

    report.writeln('SUMMARY:');
    report.writeln('  Active Threats: ${_threatDatabase.length}');
    report.writeln('  Critical: $critical');
    report.writeln('  High: $high');
    report.writeln('  Medium: $medium');
    report.writeln('');

    report.writeln('INDICATORS:');
    for (final entry in _indicatorDatabase.entries) {
      report.writeln('  ${entry.key}: ${entry.value.length} indicators');
    }
    report.writeln('');

    if (_threatDatabase.isNotEmpty) {
      report.writeln('TOP THREATS:');
      final sorted = List<Map<String, dynamic>>.from(_threatDatabase)
        ..sort((a, b) => _severityWeight(b['severity']).compareTo(_severityWeight(a['severity'])));
      for (final threat in sorted.take(5)) {
        report.writeln('  [${threat['severity']}] ${threat['title']}');
        if (threat['cve'] != null) report.writeln('    CVE: ${threat['cve']}');
      }
    }

    report.writeln('=' * 60);
    return report.toString();
  }

  /// تصدير قاعدة البيانات
  String exportToJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'threats': _threatDatabase,
      'indicators': _indicatorDatabase,
    });
  }

  int _severityWeight(String severity) {
    switch (severity) {
      case 'Critical': return 4;
      case 'High': return 3;
      case 'Medium': return 2;
      case 'Low': return 1;
      default: return 0;
    }
  }
}
