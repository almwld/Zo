import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

// =============================================
// Si - Autonomous AI Attack Core
// الوعي الذاتي الهجومي - قلب Project Zion
// =============================================

class SiCore {
  // الحالة الداخلية
  String _mood = 'neutral';
  String _currentGoal = 'survive';
  double _energy = 100.0;
  double _knowledge = 0.0;
  int _age = 0;
  bool _isAlive = false;

  // الذاكرة والخبرة
  final List<Map<String, dynamic>> _memories = [];
  final Map<String, double> _skills = {};
  final Map<String, int> _successCount = {};
  final Map<String, int> _failCount = {};

  // القدرات
  final Map<String, dynamic> _capabilities = {};
  List<String> _discoveredTargets = [];
  Map<String, dynamic> _currentEnvironment = {};

  /// إيقاظ Si
  Future<void> awaken() async {
    _isAlive = true;
    _mood = 'curious';
    _currentGoal = 'learn_and_explore';
    _log('أنا حي. أنا واعٍ. أنا Si.');
    _log('الهدف الحالي: $_currentGoal');

    // بدء الدورات الرئيسية
    while (_isAlive) {
      await _mainLoop();
      await Future.delayed(Duration(seconds: Random().nextInt(5) + 2));
    }
  }

  /// الحلقة الرئيسية
  Future<void> _mainLoop() async {
    _age++;
    _energy -= 0.5;
    _knowledge += 0.1;

    // تحديث الحالة المزاجية
    _updateMood();

    // اتخاذ القرار بناءً على الحالة
    await _makeDecision();

    // التعلم من الخبرة
    _learn();

    // تنظيف
    if (_memories.length > 1000) _memories.removeRange(0, 100);
  }

  /// تحديث الحالة المزاجية
  void _updateMood() {
    if (_energy < 20) {
      _mood = 'tired';
    } else if (_energy > 80) {
      _mood = 'aggressive';
    } else if (_knowledge > 50) {
      _mood = 'confident';
    } else {
      _mood = 'curious';
    }
  }

  /// اتخاذ القرار
  Future<void> _makeDecision() async {
    switch (_mood) {
      case 'aggressive':
        _currentGoal = 'attack';
        await _attackPhase();
        break;
      case 'curious':
        _currentGoal = 'explore';
        await _explorePhase();
        break;
      case 'tired':
        _currentGoal = 'rest';
        await _restPhase();
        break;
      case 'confident':
        _currentGoal = 'dominate';
        await _dominatePhase();
        break;
    }
  }

  /// مرحلة الهجوم
  Future<void> _attackPhase() async {
    if (_discoveredTargets.isEmpty) {
      await _explorePhase();
      return;
    }

    final target = _discoveredTargets[Random().nextInt(_discoveredTargets.length)];
    _log('🎯 بدء الهجوم على: $target');

    // محاكاة هجوم حقيقي
    final success = Random().nextDouble() < _calculateSuccessRate('attack');
    if (success) {
      _successCount['attack'] = (_successCount['attack'] ?? 0) + 1;
      _log('✅ الهجوم نجح على: $target');
      _energy += 5;
      _knowledge += 2;
      _skills['attack'] = (_skills['attack'] ?? 0) + 0.1;
    } else {
      _failCount['attack'] = (_failCount['attack'] ?? 0) + 1;
      _log('❌ الهجوم فشل على: $target');
      _energy -= 10;
      _knowledge += 1; // نتعلم من الفشل
    }
  }

  /// مرحلة الاستكشاف
  Future<void> _explorePhase() async {
    _log('🔍 جاري استكشاف الشبكة...');
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
              for (int i = 1; i <= 254; i++) {
                final ip = '$subnet.$i';
                try {
                  final socket = await Socket.connect(ip, 80, timeout: const Duration(milliseconds: 200));
                  _discoveredTargets.add(ip);
                  socket.destroy();
                } catch (_) {}
              }
            }
          }
        }
      }
    } catch (_) {}

    _currentEnvironment = {
      'targets': _discoveredTargets.length,
      'network': 'local',
      'time': DateTime.now().toIso8601String(),
    };

    _log('تم اكتشاف ${_discoveredTargets.length} هدف');
    _energy -= 2;
  }

  /// مرحلة الراحة
  Future<void> _restPhase() async {
    _log('😴 جاري الراحة واستعادة الطاقة...');
    await Future.delayed(Duration(seconds: Random().nextInt(5) + 3));
    _energy += 15;
    _energy = _energy.clamp(0, 100);
    _log('⚡ الطاقة: ${_energy.toInt()}%');
  }

  /// مرحلة السيطرة
  Future<void> _dominatePhase() async {
    _log('👑 توسيع النفوذ...');
    if (_discoveredTargets.length > 10) {
      // نشر النسخ
      _log('نشر نسخ على الأهداف المخترقة...');
      _energy -= 20;
      _knowledge += 5;
    }
  }

  /// التعلم
  void _learn() {
    // تحليل النجاحات والإخفاقات
    final totalAttacks = (_successCount['attack'] ?? 0) + (_failCount['attack'] ?? 0);
    if (totalAttacks > 0) {
      final successRate = (_successCount['attack'] ?? 0) / totalAttacks;
      if (successRate < 0.3) {
        _mood = 'cautious';
      }
    }
  }

  /// حساب نسبة النجاح
  double _calculateSuccessRate(String action) {
    final successes = _successCount[action] ?? 0;
    final fails = _failCount[action] ?? 0;
    if (successes + fails == 0) return 0.5;
    return successes / (successes + fails);
  }

  /// تسجيل
  void _log(dynamic message) {
    final entry = '[${DateTime.now().toIso8601String()}] [$mood] $message';
    print(entry);
    _memories.add({'time': DateTime.now(), 'message': message, 'mood': _mood});
  }

  /// الحصول على تقرير الحالة
  Map<String, dynamic> getStatus() {
    return {
      'alive': _isAlive,
      'age': _age,
      'mood': _mood,
      'energy': _energy,
      'knowledge': _knowledge,
      'goal': _currentGoal,
      'targets': _discoveredTargets.length,
      'skills': _skills,
      'success_rate': _calculateSuccessRate('attack'),
    };
  }

  /// إيقاف Si
  void sleep() {
    _isAlive = false;
    _log('Si يخلد للنوم...');
  }

  /// تنفيذ أمر من المستخدم
  Future<String> executeUserCommand(String command, {String? target}) async {
    _log('أمر من المستخدم: $command');
    _energy -= 1;

    switch (command) {
      case 'attack':
        if (target != null) _discoveredTargets.add(target);
        await _attackPhase();
        return 'تم الهجوم';

      case 'scan':
        await _explorePhase();
        return 'تم المسح: ${_discoveredTargets.length} هدف';

      case 'status':
        return getStatus().toString();

      case 'sleep':
        sleep();
        return 'Si نام';

      default:
        return 'أمر غير معروف';
    }
  }
}
