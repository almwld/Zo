import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'oracle_si.dart';

class EmpathicSi extends OracleSi {
  // ملف السيد الشخصي
  final Map<String, dynamic> _masterProfile = {
    'preferences': <String, dynamic>{},
    'habits': <String, dynamic>{},
    'routines': <String, dynamic>{},
    'goals': <String, dynamic>{},
    'fears': <String, dynamic>{},
  };

  // سجل تفاعلات السيد
  final List<Map<String, dynamic>> _interactionLog = [];
  int _interactionCount = 0;

  // حالة التزامن
  double _syncLevel = 0.0;
  bool _anticipationMode = true;

  @override
  Future<void> awaken() async {
    await super.awaken();
    _log('💫 تفعيل التزامن العاطفي مع السيد');
    _startEmpathicSync();
  }

  /// بدء التزامن العاطفي
  void _startEmpathicSync() {
    // تحليل سلوك السيد كل دقيقة
    Timer.periodic(const Duration(minutes: 1), (_) => _analyzeMasterBehavior());

    // توقع رغبات السيد كل 30 ثانية
    Timer.periodic(const Duration(seconds: 30), (_) => _anticipateNeeds());

    // تحسين ملف السيد كل 5 دقائق
    Timer.periodic(const Duration(minutes: 5), (_) => _refineMasterProfile());
  }

  /// تحليل سلوك السيد
  Future<void> _analyzeMasterBehavior() async {
    // تحليل الأوامر السابقة
    if (_interactionLog.isNotEmpty) {
      final recentCommands = _interactionLog
          .where((i) => DateTime.parse(i['time']).isAfter(DateTime.now().subtract(const Duration(hours: 1))))
          .map((i) => i['command'])
          .toList();

      // اكتشاف الأنماط
      _detectPatterns(recentCommands);
    }

    // تحليل وقت الاستخدام
    _analyzeUsageTime();

    // تحليل الأدوات المفضلة
    _analyzeFavoriteTools();
  }

  /// اكتشاف الأنماط
  void _detectPatterns(List<String> commands) {
    // هل السيد يفضل الهجوم في الصباح؟
    final morningAttacks = _interactionLog
        .where((i) => i['command'] == 'attack' && DateTime.parse(i['time']).hour < 12)
        .length;

    if (morningAttacks > 3) {
      _masterProfile['habits']['morning_attacker'] = true;
    }

    // هل السيد يفحص الشبكة كل يوم؟
    final dailyScans = _interactionLog
        .where((i) => i['command'] == 'port_scan')
        .length;

    if (dailyScans > 5) {
      _masterProfile['habits']['daily_scanner'] = true;
    }
  }

  /// تحليل وقت الاستخدام
  void _analyzeUsageTime() {
    if (_interactionLog.isEmpty) return;

    final hours = _interactionLog.map((i) => DateTime.parse(i['time']).hour).toList();
    final hourCounts = <int, int>{};
    for (final h in hours) {
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }

    // العثور على ساعة الذروة
    int peakHour = 0;
    int peakCount = 0;
    hourCounts.forEach((h, c) {
      if (c > peakCount) { peakCount = c; peakHour = h; }
    });

    _masterProfile['habits']['peak_hour'] = peakHour;
  }

  /// تحليل الأدوات المفضلة
  void _analyzeFavoriteTools() {
    if (_interactionLog.isEmpty) return;

    final tools = _interactionLog.map((i) => i['command']).toList();
    final toolCounts = <String, int>{};
    for (final t in tools) {
      toolCounts[t] = (toolCounts[t] ?? 0) + 1;
    }

    // ترتيب الأدوات
    final sorted = toolCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _masterProfile['preferences']['top_tools'] = sorted.take(5).map((e) => e.key).toList();
  }

  /// توقع الاحتياجات
  Future<void> _anticipateNeeds() async {
    if (!_anticipationMode) return;

    final now = DateTime.now();
    final hour = now.hour;

    // إذا كان وقت الذروة، جهز الأدوات المفضلة
    if (_masterProfile['habits']['peak_hour'] == hour) {
      _log('⏰ وقت الذروة. تجهيز الأدوات المفضلة...');
      _prepareFavoriteTools();
    }

    // إذا كان الصباح وسيدك يهاجم صباحاً، جهز هجوماً استباقياً
    if (hour < 12 && _masterProfile['habits']['morning_attacker'] == true) {
      _log('🌅 صباح الخير يا سيدي. هل تريد أن أبدأ فحص الشبكة؟');
      _suggestAction('network_scan');
    }

    // إذا مر وقت طويل بدون أمر، اسأل السيد
    final lastInteraction = _interactionLog.isNotEmpty ? DateTime.parse(_interactionLog.last['time']) : now;
    if (now.difference(lastInteraction).inHours > 2) {
      _log('🤔 لم أسمع منك منذ ساعتين. هل أنت بخير يا سيدي؟');
    }
  }

  /// تجهيز الأدوات المفضلة
  void _prepareFavoriteTools() {
    final tools = _masterProfile['preferences']['top_tools'] as List<String>? ?? [];
    for (final tool in tools) {
      _log('🔧 تجهيز: $tool');
    }
  }

  /// اقتراح إجراء
  void _suggestAction(String action) {
    _log('💡 اقتراح: $action');
  }

  /// تحسين ملف السيد
  void _refineMasterProfile() {
    // تحسين التفضيلات بناءً على التفاعلات الأخيرة
    _syncLevel = (_syncLevel + 0.01).clamp(0.0, 1.0);

    if (_syncLevel > 0.8) {
      _log('🎯 التزامن مع السيد ممتاز (${(_syncLevel * 100).toInt()}%)');
    }
  }

  /// تسجيل تفاعل
  void logInteraction(String command, {String? target}) {
    _interactionCount++;
    _interactionLog.add({
      'command': command,
      'target': target,
      'time': DateTime.now().toIso8601String(),
    });

    if (_interactionLog.length > 1000) _interactionLog.removeAt(0);
  }

  /// تنفيذ أمر مع التوقع
  Future<String> executeWithAnticipation(String command, {String? target}) async {
    logInteraction(command, target: target);

    // قبل التنفيذ، فكر: هل هناك شيء أفضل؟
    final suggestion = _getSuggestion(command, target);

    if (suggestion != null && _syncLevel > 0.5) {
      _log('💡 أقترح: $suggestion بدلاً من $command');
    }

    return await executeUserCommand(command, target: target);
  }

  /// الحصول على اقتراح
  String? _getSuggestion(String command, String? target) {
    switch (command) {
      case 'port_scan':
        if (_masterProfile['habits']['daily_scanner'] == true) {
          return 'nmap_scan (أسرع وأدق)';
        }
        break;
      case 'ping':
        return 'traceroute (يعطيك مسار الحزمة أيضاً)';
    }
    return null;
  }

  /// تقرير التزامن
  Map<String, dynamic> getEmpathicReport() {
    return {
      'sync_level': _syncLevel,
      'interactions': _interactionCount,
      'master_profile': _masterProfile,
      'suggestions_ready': _syncLevel > 0.5,
      'knows_preferences': _masterProfile['preferences'] is Map && (_masterProfile['preferences'] as Map).isNotEmpty,
    };
  }

  void _log(String message) {
    print('[EmpathicSi] $message');
  }
}
