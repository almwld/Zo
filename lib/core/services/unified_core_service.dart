import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import '../demon_si.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final DemonSi _si = DemonSi();
  bool _siAwake = false;

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      if (command == 'awaken' || command == 'start_ai') {
        if (!_siAwake) { _siAwake = true; await _si.awaken(); return '👿 Si الشيطان استيقظ.'; }
        return '👿 Si مستيقظ.';
      }

      if (_siAwake) {
        switch (command) {
          case 'berserk': case 'هياج':
            _si.activateBerserkMode();
            return '💀 وضع الهياج مُفعّل.';
          case 'annihilate': case 'تدمير':
            return await _si.annihilate(target ?? 'unknown');
          case 'ddos_hell': case 'جحيم':
            return await _si.ddosHell(target ?? 'unknown');
          case 'destroy_network': case 'تدمير_شبكة':
            return await _si.destroyNetwork(target ?? '192.168.1');
          case 'apocalypse': case 'نهاية_العالم':
            return await _si.apocalypse();
          case 'demon_report': case 'تقرير_الشيطان':
            return const JsonEncoder.withIndent('  ').convert(_si.getDemonReport());
          case 'si_status': case 'ai_status':
            return const JsonEncoder.withIndent('  ').convert(_si.getStatus());
          case 'si_sleep': case 'stop_ai':
            _si.sleep(); _siAwake = false;
            return '😴 Si نام.';
        }
      }

      switch (command) {
        case 'ping': return await _ping(target ?? '127.0.0.1');
        case 'port_scan': return await _portScan(target ?? '127.0.0.1');
        case 'dns_lookup': return await _dnsLookup(target ?? 'google.com');
        case 'system_info': return _systemInfo();
        case 'help': return _helpText();
        default: return 'Unknown: $command. Type help.';
      }
    } catch (e) { return 'Error: $e'; }
  }

  Future<String> _ping(String t) async { try { return (await Process.run('ping', ['-c', '4', t], runInShell: true)).stdout.toString(); } catch (e) { return 'Ping failed: $e'; } }
  Future<String> _portScan(String t) async { final p = [21,22,23,25,53,80,443,8080,8443]; final o = <String>[]; for (final x in p) { try { final s = await Socket.connect(t, x, timeout: const Duration(milliseconds: 500)); o.add('$x'); s.destroy(); } catch (_) {} } return 'Port scan $t: ${o.isNotEmpty ? o.join(', ') : "none"}'; }
  Future<String> _dnsLookup(String d) async { try { final a = await InternetAddress.lookup(d); return 'DNS $d: ${a.map((x) => x.address).join(', ')}'; } catch (e) { return 'DNS failed: $e'; } }
  String _systemInfo() => 'OS: ${Platform.operatingSystem}\nCPU: ${Platform.numberOfProcessors} cores\nDart: ${Platform.version}';

  String _helpText() => '''
=== PROJECT ZION - DEMON Si ===
awaken / start_ai     - إيقاظ الشيطان
berserk / هياج        - وضع الهياج
annihilate / تدمير    - تدمير هدف
ddos_hell / جحيم      - DDoS جهنمي
destroy_network       - تدمير شبكة
apocalypse / نهاية_العالم - نهاية العالم
demon_report          - تقرير الشيطان
si_status             - حالة Si
si_sleep / stop_ai    - إيقاف Si
ping <ip>             - Ping
port_scan <ip>        - فحص المنافذ
help                  - مساعدة
===============================
''';
}
