import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'ultimate_exploit_manager_system.dart';
import 'ultimate_payload_manager_system.dart';

class UltimateUnifiedMetasploitSystem {
  final UltimateExploitManagerSystem _exploits = UltimateExploitManagerSystem();
  final UltimatePayloadManagerSystem _payloads = UltimatePayloadManagerSystem();
  final Map<String, dynamic> _activeSessions = {};
  int _sessionCounter = 1;

  UltimateUnifiedMetasploitSystem() {
    _exploits.initializeDefaultExploits();
    _payloads.initializeDefaultPayloads();
  }

  /// تنفيذ هجوم كامل: استغلال + حمولة
  Future<Map<String, dynamic>> launchAttack({
    required String target,
    required String exploitName,
    required String payloadName,
    String lhost = '127.0.0.1',
    int lport = 4444,
  }) async {
    // 1. توليد الحمولة
    final payload = _payloads.generatePayload(payloadName: payloadName, lhost: lhost, lport: lport);
    if (payload.containsKey('error')) return payload;

    // 2. بدء المستمع
    final listener = await _payloads.startListener(payloadType: payloadName, port: lport, host: lhost);
    if (listener['success'] != true) return listener;

    // 3. تنفيذ الاستغلال
    final exploit = await _exploits.runExploit(exploitName: exploitName, target: target);
    if (exploit['success'] != true) return exploit;

    // 4. إنشاء جلسة
    final session = _createSession(target, exploitName, payloadName);
    exploit['session_id'] = session['id'];

    return {
      'success': true,
      'exploit': exploit,
      'payload': payload,
      'session': session,
    };
  }

  /// إنشاء جلسة
  Map<String, dynamic> _createSession(String target, String exploit, String payload) {
    final sessionId = _sessionCounter++;
    final session = {
      'id': sessionId,
      'target': target,
      'exploit': exploit,
      'payload': payload,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    };
    _activeSessions[sessionId] = session;
    return session;
  }

  /// الحصول على الجلسات النشطة
  List<Map<String, dynamic>> getActiveSessions() => _activeSessions.values.where((s) => s['status'] == 'active').toList();

  /// إغلاق جلسة
  void closeSession(int id) {
    if (_activeSessions.containsKey(id)) {
      _activeSessions[id]['status'] = 'closed';
    }
  }

  Map<String, dynamic> getStats() {
    return {
      'exploits': _exploits.getStats(),
      'payloads': _payloads.getStats(),
      'sessions': _activeSessions.length,
    };
  }
}
