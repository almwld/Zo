import 'dart:math';

class UltimateDeepLearningEngine {
  final Map<String, List<double>> _weights = {};
  final List<Map<String, dynamic>> _trainingData = [];
  final Map<String, double> _successRates = {};
  bool _isTrained = false;

  /// إضافة بيانات تدريب
  void addTrainingData(String targetType, String attackType, bool success, Map<String, dynamic> features) {
    _trainingData.add({
      'target_type': targetType,
      'attack_type': attackType,
      'success': success,
      'features': features,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // تحديث معدلات النجاح
    final key = '${targetType}_$attackType';
    final currentRate = _successRates[key] ?? 0.5;
    _successRates[key] = currentRate * 0.8 + (success ? 0.2 : 0.0);
  }

  /// تدريب النموذج
  void train() {
    for (final data in _trainingData) {
      final key = '${data['target_type']}_${data['attack_type']}';
      if (!_weights.containsKey(key)) {
        _weights[key] = List.generate(10, (_) => Random().nextDouble());
      }

      // تحديث الأوزان (محاكاة gradient descent)
      final weights = _weights[key]!;
      for (int i = 0; i < weights.length; i++) {
        weights[i] += (data['success'] == true ? 0.01 : -0.01) * (Random().nextDouble() - 0.5);
        weights[i] = weights[i].clamp(-1.0, 1.0);
      }
    }
    _isTrained = true;
  }

  /// التنبؤ بأفضل هجوم
  Map<String, dynamic> predictBestAttack(String targetType, List<String> availableAttacks) {
    final predictions = <Map<String, dynamic>>[];

    for (final attack in availableAttacks) {
      final key = '${targetType}_$attack';
      final baseRate = _successRates[key] ?? 0.5;
      final weights = _weights[key];

      double confidence = baseRate;
      if (weights != null) {
        confidence += weights.reduce((a, b) => a + b) * 0.1;
        confidence = confidence.clamp(0.0, 1.0);
      }

      predictions.add({
        'attack': attack,
        'confidence': confidence,
        'based_on_data': _successRates.containsKey(key),
      });
    }

    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    return predictions.isNotEmpty ? predictions.first : {'attack': availableAttacks.first, 'confidence': 0.5};
  }

  /// تقييم هدف
  Map<String, dynamic> assessTarget(String target) {
    final features = _extractFeatures(target);
    final vulnerabilities = <String, double>{};

    for (final entry in _successRates.entries) {
      if (entry.key.startsWith(target)) {
        vulnerabilities[entry.key] = entry.value;
      }
    }

    return {
      'target': target,
      'features': features,
      'vulnerability_score': vulnerabilities.isEmpty ? 0.5 : vulnerabilities.values.reduce((a, b) => a + b) / vulnerabilities.length,
      'best_attack': predictBestAttack(target, ['port_scan', 'sql_test', 'http_flood', 'dns_enum']),
    };
  }

  Map<String, dynamic> _extractFeatures(String target) {
    return {
      'has_ports_open': target.contains('.'),
      'is_web_server': target.contains('www') || target.contains('http'),
      'length': target.length,
    };
  }
}
