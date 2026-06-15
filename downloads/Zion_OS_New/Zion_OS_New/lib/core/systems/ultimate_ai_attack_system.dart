import 'dart:math';
import 'dart:convert';

class UltimateAiAttackSystem {
  final Map<String, List<Map<String, dynamic>>> _knowledgeBase = {};
  final Map<String, double> _successRates = {};
  final List<Map<String, dynamic>> _learningHistory = [];
  int _totalAttacks = 0;

  /// تدريب النظام على بيانات الهجمات السابقة
  void train(Map<String, dynamic> attackResult) {
    final targetType = attackResult['target_type'] ?? 'unknown';
    final attackType = attackResult['attack_type'] ?? 'unknown';
    final success = attackResult['success'] == true;

    if (!_knowledgeBase.containsKey(targetType)) {
      _knowledgeBase[targetType] = [];
    }

    _knowledgeBase[targetType]!.add({
      'attack': attackType,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final key = '${targetType}_$attackType';
    _successRates[key] = (_successRates[key] ?? 0.5) * 0.7 + (success ? 0.3 : 0.0);
    _totalAttacks++;
  }

  /// التنبؤ بأفضل هجوم لهدف معين
  Map<String, dynamic> predictBestAttack(String targetType, List<String> availableAttacks) {
    final predictions = <Map<String, dynamic>>[];

    for (final attack in availableAttacks) {
      final key = '${targetType}_$attack';
      final baseRate = _successRates[key] ?? 0.5;
      final confidence = baseRate + (Random().nextDouble() * 0.1);

      predictions.add({
        'attack': attack,
        'confidence': confidence,
        'based_on_data': _knowledgeBase.containsKey(targetType),
      });
    }

    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    return predictions.isNotEmpty ? predictions.first : {'attack': availableAttacks.first, 'confidence': 0.5};
  }

  /// تحليل نمط الهدف وتحديد نقاط ضعفه
  Map<String, dynamic> analyzeTarget(String target) {
    final analysis = <String, dynamic>{
      'target': target,
      'estimated_os': _estimateOS(target),
      'suggested_attacks': <String>[],
      'risk_assessment': _assessRisk(target),
    };

    // تحليل المنافذ المفتوحة لتحديد نوع الهدف
    final lastOctet = int.tryParse(target.split('.').last) ?? 0;

    if (lastOctet < 30) {
      analysis['target_type'] = 'windows_server';
      analysis['suggested_attacks'] = ['SMB exploit', 'RDP brute force', 'PowerShell reverse shell'];
    } else if (lastOctet < 80) {
      analysis['target_type'] = 'linux_server';
      analysis['suggested_attacks'] = ['SSH brute force', 'web exploit', 'FTP exploit'];
    } else if (lastOctet < 150) {
      analysis['target_type'] = 'web_server';
      analysis['suggested_attacks'] = ['SQL injection', 'XSS', 'directory traversal'];
    } else {
      analysis['target_type'] = 'network_device';
      analysis['suggested_attacks'] = ['default credentials', 'firmware exploit', 'SNMP attack'];
    }

    return analysis;
  }

  /// توليد استراتيجية هجوم متكاملة
  List<Map<String, dynamic>> generateAttackPlan(String target) {
    final analysis = analyzeTarget(target);
    final plan = <Map<String, dynamic>>[];

    // المرحلة 1: الاستطلاع
    plan.add({'phase': 'recon', 'action': 'port_scan', 'target': target, 'priority': 'high'});
    plan.add({'phase': 'recon', 'action': 'service_detection', 'target': target, 'priority': 'high'});

    // المرحلة 2: الهجوم
    for (final attack in analysis['suggested_attacks']) {
      plan.add({'phase': 'attack', 'action': attack, 'target': target, 'priority': 'medium'});
    }

    // المرحلة 3: ما بعد الاستغلال
    plan.add({'phase': 'post_exploit', 'action': 'establish_persistence', 'target': target, 'priority': 'medium'});
    plan.add({'phase': 'post_exploit', 'action': 'exfiltrate_data', 'target': target, 'priority': 'low'});
    plan.add({'phase': 'post_exploit', 'action': 'cover_tracks', 'target': target, 'priority': 'low'});

    return plan;
  }

  /// تحسين الهجمات عبر التعلم
  void optimizeFromHistory() {
    for (final entry in _learningHistory) {
      train(entry);
    }
  }

  /// إضافة إلى سجل التعلم
  void logLearning(String target, String attack, bool success) {
    _learningHistory.add({
      'target': target,
      'attack': attack,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// الحصول على إحصائيات النظام
  Map<String, dynamic> getStats() {
    return {
      'total_attacks': _totalAttacks,
      'known_targets': _knowledgeBase.length,
      'top_attacks': _getTopAttacks(5),
    };
  }

  String _estimateOS(String target) {
    final lastOctet = int.tryParse(target.split('.').last) ?? 0;
    if (lastOctet < 30) return 'Windows Server';
    if (lastOctet < 80) return 'Linux Server';
    if (lastOctet < 150) return 'Web Server';
    return 'Network Device';
  }

  String _assessRisk(String target) {
    if (target.contains('.gov') || target.contains('.mil')) return 'HIGH - Government/Military target';
    if (target.contains('.bank') || target.contains('finance')) return 'HIGH - Financial target';
    return 'MEDIUM - Standard target';
  }

  List<Map<String, dynamic>> _getTopAttacks(int limit) {
    final sorted = _successRates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => {'attack': e.key, 'success_rate': e.value}).toList();
  }
}
