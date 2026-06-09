import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import 'live_network_monitor.dart';
import 'connection_info_service.dart';
import 'kali_chroot_service.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final LiveNetworkMonitor _monitor = LiveNetworkMonitor();
  final ConnectionInfoService _connectionInfo = ConnectionInfoService();

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      // ============ أوامر كالي لينكس ============
      if (command.startsWith('kali_') || command.startsWith('nmap') || command.startsWith('sqlmap') || command.startsWith('msf') || command.startsWith('hydra') || command.startsWith('aircrack')) {
        final kaliAvailable = await KaliChrootService.isKaliAvailable();
        if (!kaliAvailable) return 'Kali Linux chroot not found at ${KaliChrootService._chrootPath}';

        switch (command) {
          case 'kali_check':
            return 'Kali Linux is available and ready.';
          case 'kali_nmap':
            return await KaliChrootService.runNmap(target ?? '127.0.0.1', args: options?['args'] ?? '-sV');
          case 'kali_sqlmap':
            return await KaliChrootService.runSqlmap(target ?? 'http://localhost');
          case 'kali_msf':
            return await KaliChrootService.runMetasploit(options?['commands'] ?? 'version');
          case 'kali_hydra':
            return await KaliChrootService.runHydra(target ?? '127.0.0.1', options?['service'] ?? 'ssh', options?['wordlist'] ?? '/usr/share/wordlists/rockyou.txt', options?['username'] ?? 'root');
          case 'kali_aircrack':
            return await KaliChrootService.runAircrack(options?['cap'] ?? '/tmp/capture.cap', options?['wordlist'] ?? '/usr/share/wordlists/rockyou.txt');
          case 'kali_shell':
            final result = await KaliChrootService.execute(options?['cmd'] ?? 'uname -a');
            return result['stdout'] ?? result['stderr'] ?? 'Error';
          default:
            // إذا كان الأمر يبدأ بـ "nmap" مباشرة
            if (command.startsWith('nmap')) {
              return await KaliChrootService.runNmap(target ?? '127.0.0.1', args: command.substring(4).trim());
            }
            return 'Unknown Kali command';
        }
      }

      // ============ مراقبة الشبكة ============
      switch (command) {
        case 'net_start': await _monitor.start(); return 'Network monitoring started.';
        case 'net_stop': _monitor.stop(); return 'Network monitoring stopped.';
        case 'net_connections':
          return _monitor.getActiveConnections().take(10).map((c) => '${c['protocol']} ${c['local_address']} -> ${c['foreign_address']} [${c['state']}]').join('\n');
        case 'net_stats':
          return _monitor.getConnectionStats().entries.map((e) => '${e.key}: ${e.value}').join('\n');
        case 'net_top':
          return _monitor.getTopConnections().take(5).map((t) => '${t['address']}: ${t['count']}').join('\n');
      }

      // ============ معلومات الاتصال ============
      switch (command) {
        case 'ip_local': return 'Local IP: ${await _connectionInfo.getLocalIP()}';
        case 'ip_public': return 'Public IP: ${await _connectionInfo.getPublicIP()}';
        case 'network_info': return (await _connectionInfo.getNetworkInfo()).toString();
        case 'ping_test': final p = await _connectionInfo.pingTest(); return 'Ping ${p['host']}: ${p['avg_time_ms']}ms avg';
      }

      // ============ أوامر الشبكة الأساسية ============
      switch (command) {
        case 'ping': return await _ping(target ?? '127.0.0.1');
        case 'port_scan': return await _portScan(target ?? '127.0.0.1');
        case 'dns_lookup': return await _dnsLookup(target ?? 'google.com');
        case 'http_headers': return await _httpHeaders(target ?? 'http://google.com');
        case 'ssl_check': return await _sslCheck(target ?? 'google.com');
        case 'system_info': return _systemInfo();
      }

      if (command == 'help') return _helpText();

      return 'Unknown: $command. Type help.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> _ping(String t) async {
    try { return (await Process.run('ping', ['-c', '4', t], runInShell: true)).stdout.toString(); } catch (e) { return 'Ping failed: $e'; }
  }

  Future<String> _portScan(String t) async {
    final p = [21, 22, 23, 25, 53, 80, 443, 8080, 8443];
    final o = <String>[];
    for (final x in p) {
      try { final s = await Socket.connect(t, x, timeout: const Duration(milliseconds: 500)); o.add('$x'); s.destroy(); } catch (_) {}
    }
    return 'Port scan $t: ${o.isNotEmpty ? o.join(', ') : "none"}';
  }

  Future<String> _dnsLookup(String d) async {
    try { final a = await InternetAddress.lookup(d); return 'DNS $d: ${a.map((x) => x.address).join(', ')}'; } catch (e) { return 'DNS failed: $e'; } }
  }

  Future<String> _httpHeaders(String url) async {
    try {
      final c = HttpClient(); final r = await c.getUrl(Uri.parse(url)); final res = await r.close();
      final buf = StringBuffer(); res.headers.forEach((k, v) => buf.writeln('$k: ${v.join(', ')}'));
      return 'HTTP Headers for $url:\n$buf';
    } catch (e) { return 'HTTP failed: $e'; }
  }

  Future<String> _sslCheck(String host) async {
    try {
      final s = await SecureSocket.connect(host, 443, timeout: const Duration(seconds: 5));
      final cert = s.peerCertificate; s.destroy();
      return cert != null ? 'SSL Valid: ${cert.subject}\nUntil: ${cert.endValidity}' : 'No certificate';
    } catch (e) { return 'SSL failed: $e'; }
  }

  String _systemInfo() => 'OS: ${Platform.operatingSystem}\nCPU: ${Platform.numberOfProcessors} cores\nDart: ${Platform.version}';

  String _helpText() => '''
=== PROJECT ZION - KALI EDITION ===
Kali Commands:
  kali_check       - Check if Kali is available
  kali_nmap <ip>   - Run Nmap
  kali_sqlmap <url>- Run Sqlmap
  kali_msf         - Run Metasploit
  kali_hydra       - Run Hydra
  kali_aircrack    - Run Aircrack-ng
  kali_shell <cmd> - Execute shell command

Network Monitor:
  net_start/stop, net_connections, net_stats, net_top

Network Tools:
  ping, port_scan, dns_lookup, http_headers, ssl_check, system_info
===================================
''';
}
