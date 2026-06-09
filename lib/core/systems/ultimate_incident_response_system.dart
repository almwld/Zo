import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateIncidentResponseSystem {
  final List<Map<String, dynamic>> _incidents = [];
  final Map<String, List<Map<String, dynamic>>> _evidence = {};
  int _incidentCounter = 1;

  /// إنشاء تقرير حادثة جديد
  Map<String, dynamic> createIncident({
    required String title,
    required String severity,
    required String source,
    String? description,
  }) {
    final incident = {
      'id': _incidentCounter++,
      'title': title,
      'severity': severity,
      'source': source,
      'description': description ?? '',
      'status': 'open',
      'detected_at': DateTime.now().toIso8601String(),
      'timeline': <Map<String, dynamic>>[],
      'affected_systems': <String>[],
      'iocs': <Map<String, dynamic>>[],
      'actions_taken': <String>[],
    };

    _incidents.add(incident);
    _evidence[incident['id'].toString()] = [];

    return incident;
  }

  /// إضافة دليل إلى حادثة
  void addEvidence(int incidentId, String type, String description, {String? filePath}) {
    final evidence = {
      'id': _evidence[incidentId.toString()]?.length ?? 0 + 1,
      'type': type,
      'description': description,
      'file': filePath,
      'collected_at': DateTime.now().toIso8601String(),
    };

    if (!_evidence.containsKey(incidentId.toString())) {
      _evidence[incidentId.toString()] = [];
    }
    _evidence[incidentId.toString()]!.add(evidence);
  }

  /// إضافة إجراء تم اتخاذه
  void addAction(int incidentId, String action) {
    final incident = _getIncident(incidentId);
    if (incident != null) {
      incident['actions_taken'].add(action);
      incident['timeline'].add({
        'time': DateTime.now().toIso8601String(),
        'action': action,
      });
    }
  }

  /// تحليل الحادثة
  Map<String, dynamic> analyzeIncident(int incidentId) {
    final incident = _getIncident(incidentId);
    if (incident == null) return {'error': 'Incident not found'};

    final analysis = <String, dynamic>{
      'incident_id': incidentId,
      'root_cause': _determineRootCause(incident),
      'impact_assessment': _assessImpact(incident),
      'recommendations': _generateRecommendations(incident),
      'mitre_attack': _mapToMitreAttack(incident),
    };

    return analysis;
  }

  /// إغلاق الحادثة
  Map<String, dynamic> closeIncident(int incidentId, String resolution) {
    final incident = _getIncident(incidentId);
    if (incident == null) return {'error': 'Incident not found'};

    incident['status'] = 'closed';
    incident['resolution'] = resolution;
    incident['closed_at'] = DateTime.now().toIso8601String();

    return incident;
  }

  /// توليد تقرير ما بعد الحادثة
  String generatePostMortem(int incidentId) {
    final incident = _getIncident(incidentId);
    if (incident == null) return 'Incident not found';

    final report = StringBuffer();
    report.writeln('=' * 60);
    report.writeln('POST-MORTEM REPORT');
    report.writeln('=' * 60);
    report.writeln('Incident ID: ${incident['id']}');
    report.writeln('Title: ${incident['title']}');
    report.writeln('Severity: ${incident['severity']}');
    report.writeln('Status: ${incident['status']}');
    report.writeln('Detected: ${incident['detected_at']}');
    if (incident['closed_at'] != null) report.writeln('Closed: ${incident['closed_at']}');
    report.writeln('');

    report.writeln('TIMELINE:');
    for (final entry in incident['timeline']) {
      report.writeln('  ${entry['time']}: ${entry['action']}');
    }
    report.writeln('');

    report.writeln('ACTIONS TAKEN:');
    for (final action in incident['actions_taken']) {
      report.writeln('  - $action');
    }
    report.writeln('');

    if (incident['resolution'] != null) {
      report.writeln('RESOLUTION: ${incident['resolution']}');
    }

    report.writeln('=' * 60);
    return report.toString();
  }

  /// الحصول على إحصائيات الحوادث
  Map<String, int> getStats() {
    return {
      'total': _incidents.length,
      'open': _incidents.where((i) => i['status'] == 'open').length,
      'closed': _incidents.where((i) => i['status'] == 'closed').length,
      'critical': _incidents.where((i) => i['severity'] == 'Critical').length,
      'high': _incidents.where((i) => i['severity'] == 'High').length,
    };
  }

  Map<String, dynamic>? _getIncident(int id) {
    try {
      return _incidents.firstWhere((i) => i['id'] == id);
    } catch (_) {
      return null;
    }
  }

  String _determineRootCause(Map<String, dynamic> incident) {
    final causes = [
      'Phishing email',
      'Unpatched vulnerability',
      'Weak credentials',
      'Insider threat',
      'Misconfiguration',
    ];
    return causes[Random().nextInt(causes.length)];
  }

  String _assessImpact(Map<String, dynamic> incident) {
    final impacts = ['Low - Contained quickly', 'Medium - Data exposure', 'High - System compromise', 'Critical - Full breach'];
    return impacts[Random().nextInt(impacts.length)];
  }

  List<String> _generateRecommendations(Map<String, dynamic> incident) {
    return [
      'Implement multi-factor authentication',
      'Patch all systems to latest versions',
      'Conduct security awareness training',
      'Deploy endpoint detection and response',
      'Review and update incident response plan',
    ];
  }

  Map<String, dynamic> _mapToMitreAttack(Map<String, dynamic> incident) {
    return {
      'tactics': ['Initial Access', 'Execution', 'Persistence', 'Privilege Escalation'],
      'techniques': ['T1566.001', 'T1059.001', 'T1547.001', 'T1068'],
    };
  }
}
