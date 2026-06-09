import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateSessionManagerSystem {
  final Map<String, Map<String, dynamic>> _sessions = {};
  final Map<String, List<Map<String, dynamic>>> _sessionHistory = {};
  int _sessionCounter = 1;

  /// إنشاء جلسة جديدة
  Map<String, dynamic> createSession({
    required String target,
    required String type,
    Map<String, dynamic>? metadata,
  }) {
    final sessionId = 'SESSION_${_sessionCounter++}_${DateTime.now().millisecondsSinceEpoch}';
    final session = {
      'id': sessionId,
      'target': target,
      'type': type,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      'last_activity': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
      'commands': <String>[],
      'files': <String>[],
    };

    _sessions[sessionId] = session;
    _sessionHistory[sessionId] = [];

    return session;
  }

  /// تنفيذ أمر في جلسة
  Future<Map<String, dynamic>> executeInSession(String sessionId, String command) async {
    final session = _sessions[sessionId];
    if (session == null) return {'error': 'Session not found'};

    try {
      final result = await Process.run('sh', ['-c', command], runInShell: true);
      session['commands'].add(command);
      session['last_activity'] = DateTime.now().toIso8601String();

      _sessionHistory[sessionId]!.add({
        'command': command,
        'result': result.exitCode == 0 ? 'success' : 'failed',
        'timestamp': DateTime.now().toIso8601String(),
      });

      return {
        'success': result.exitCode == 0,
        'stdout': result.stdout.toString(),
        'stderr': result.stderr.toString(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// رفع ملف إلى جلسة
  Future<bool> uploadToSession(String sessionId, String localPath, String remotePath) async {
    final session = _sessions[sessionId];
    if (session == null) return false;

    try {
      final file = File(localPath);
      if (!await file.exists()) return false;
      final dest = File(remotePath);
      await file.copy(dest.path);
      session['files'].add(remotePath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تحميل ملف من جلسة
  Future<Uint8List?> downloadFromSession(String sessionId, String remotePath) async {
    final session = _sessions[sessionId];
    if (session == null) return null;

    try {
      final file = File(remotePath);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// إغلاق جلسة
  Future<Map<String, dynamic>> closeSession(String sessionId) async {
    final session = _sessions.remove(sessionId);
    if (session == null) return {'error': 'Session not found'};

    session['status'] = 'closed';
    session['closed_at'] = DateTime.now().toIso8601String();

    return {'success': true, 'session': session};
  }

  /// الحصول على كل الجلسات النشطة
  List<Map<String, dynamic>> getActiveSessions() {
    return _sessions.values.where((s) => s['status'] == 'active').toList();
  }

  /// الحصول على إحصائيات
  Map<String, dynamic> getStats() {
    return {
      'active_sessions': _sessions.values.where((s) => s['status'] == 'active').length,
      'total_sessions': _sessionCounter - 1,
      'total_commands': _sessions.values.fold(0, (sum, s) => sum + (s['commands'] as List).length),
    };
  }
}
