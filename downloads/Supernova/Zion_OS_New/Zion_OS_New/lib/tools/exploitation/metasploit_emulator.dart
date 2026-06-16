import 'dart:math';

class MetasploitEmulator {
  final List<Map<String, dynamic>> _sessions = [];
  int _sessionId = 1;

  /// قائمة الحمولات (Payloads)
  static final List<Map<String, dynamic>> payloads = [
    {'name': 'windows/meterpreter/reverse_tcp', 'platform': 'Windows', 'type': 'shell'},
    {'name': 'linux/x86/meterpreter/reverse_tcp', 'platform': 'Linux', 'type': 'shell'},
    {'name': 'android/meterpreter/reverse_tcp', 'platform': 'Android', 'type': 'shell'},
    {'name': 'php/meterpreter_reverse_tcp', 'platform': 'Multi', 'type': 'shell'},
    {'name': 'cmd/unix/reverse_python', 'platform': 'Unix', 'type': 'shell'},
  ];

  /// قائمة الاستغلالات (Exploits)
  static final List<Map<String, dynamic>> exploits = [
    {'name': 'exploit/multi/handler', 'type': 'listener'},
    {'name': 'exploit/windows/smb/ms17_010_eternalblue', 'type': 'remote'},
    {'name': 'exploit/unix/ftp/vsftpd_234_backdoor', 'type': 'remote'},
    {'name': 'exploit/multi/http/struts2_code_exec', 'type': 'remote'},
    {'name': 'exploit/linux/http/dlink_rce', 'type': 'remote'},
    {'name': 'exploit/windows/rdp/cve_2019_0708_bluekeep', 'type': 'remote'},
  ];

  /// محاكاة استغلال ثغرة
  Future<Map<String, dynamic>> exploit(String target, String exploitName, {int port = 80}) async {
    final success = Random().nextDouble() < 0.7; // محاكاة نسبة نجاح 70%
    
    if (success) {
      final session = {
        'id': _sessionId++,
        'target': target,
        'port': port,
        'type': 'meterpreter',
        'platform': _getPlatform(target),
        'connected': true,
        'time': DateTime.now().toIso8601String(),
      };
      _sessions.add(session);
      return {'success': true, 'session': session};
    }
    
    return {'success': false, 'error': 'Exploit failed against $target'};
  }

  /// الحصول على الجلسات النشطة
  List<Map<String, dynamic>> getSessions() => _sessions;

  /// إغلاق جلسة
  void closeSession(int id) {
    _sessions.removeWhere((s) => s['id'] == id);
  }

  /// تنفيذ أمر في جلسة
  Future<String> executeCommand(int sessionId, String command) async {
    final session = _sessions.firstWhere((s) => s['id'] == sessionId, orElse: () => {});
    if (session.isEmpty) return 'Session not found';

    switch (command) {
      case 'sysinfo':
        return _generateSysInfo(session['platform']);
      case 'ipconfig':
        return _generateIpConfig();
      case 'screenshot':
        return 'Screenshot captured and saved.';
      case 'keyscan_start':
        return 'Keylogger started.';
      case 'hashdump':
        return _generateHashDump();
      default:
        return 'Command executed: $command';
    }
  }

  /// إنشاء مستمع (Listener)
  String createListener(String payload, {int port = 4444}) {
    return 'Listener started on 0.0.0.0:$port\nPayload: $payload\nWaiting for connections...';
  }

  String _getPlatform(String target) {
    // محاكاة بسيطة: بناءً على رقم IP
    final lastOctet = int.tryParse(target.split('.').last) ?? 0;
    if (lastOctet < 50) return 'Windows';
    if (lastOctet < 150) return 'Linux';
    return 'Unknown';
  }

  String _generateSysInfo(String platform) {
    return '''
Computer        : TARGET-PC
OS              : $platform
Architecture    : x64
System Language : en_US
Domain          : WORKGROUP
Logged On Users : 2
''';
  }

  String _generateIpConfig() {
    return '''
Ethernet adapter Ethernet0:
   IPv4 Address : 192.168.1.100
   Subnet Mask  : 255.255.255.0
   Default Gateway : 192.168.1.1
''';
  }

  String _generateHashDump() {
    return '''
Administrator:500:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
User:1001:aad3b435b51404eeaad3b435b51404ee:64f12cddaa88057e06a81b54e73b949b:::
''';
  }
}
