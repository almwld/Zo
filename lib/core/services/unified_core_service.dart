import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import 'live_network_monitor.dart';
import 'connection_info_service.dart';
import '../demon_si.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final LiveNetworkMonitor _monitor = LiveNetworkMonitor();
  final ConnectionInfoService _connectionInfo = ConnectionInfoService();
  final DemonSi _si = DemonSi();
  bool _siAwake = false;

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      // ============ أوامر Si الشيطان ============
      if (command == 'awaken' || command == 'start_ai') {
        if (!_siAwake) { _siAwake = true; await _si.awaken(); return '👿 Si الشيطان استيقظ.'; }
        return '👿 Si مستيقظ بالفعل.';
      }
      if (_siAwake) {
        switch (command) {
          case 'berserk': case 'هياج': _si.activateBerserkMode(); return '💀 وضع الهياج مُفعّل.';
          case 'annihilate': case 'تدمير': return await _si.annihilate(target ?? 'unknown');
          case 'ddos_hell': case 'جحيم': return await _si.ddosHell(target ?? 'unknown');
          case 'destroy_network': case 'تدمير_شبكة': return await _si.destroyNetwork(target ?? '192.168.1');
          case 'apocalypse': case 'نهاية_العالم': return await _si.apocalypse();
          case 'demon_report': case 'تقرير_الشيطان': return const JsonEncoder.withIndent('  ').convert(_si.getDemonReport());
          case 'si_status': case 'ai_status': return const JsonEncoder.withIndent('  ').convert(_si.getStatus());
          case 'si_sleep': case 'stop_ai': _si.sleep(); _siAwake = false; return '😴 Si نام.';
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

      // ============ مساعدة ============
      if (command == 'help') return _helpText();

      return 'Unknown: $command. Type help.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ============ دوال الشبكة ============
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
=== PROJECT ZION ===
👿 Si Commands:
  awaken/start_ai    - Wake Demon Si
  berserk/هياج       - Berserk Mode
  annihilate/تدمير   - Annihilate Target
  ddos_hell/جحيم     - DDoS Hell
  destroy_network    - Destroy Network
  apocalypse         - Apocalypse
  demon_report       - Demon Report
  si_status/ai_status- Si Status
  si_sleep/stop_ai   - Sleep Si

📡 Network Monitor:
  net_start/stop     - Start/Stop Monitor
  net_connections    - Active Connections
  net_stats          - Connection Stats
  net_top            - Top Connections

🌐 Network Tools:
  ping <ip>          - Ping
  port_scan <ip>     - Port Scan
  dns_lookup <d>     - DNS Lookup
  http_headers <url> - HTTP Headers
  ssl_check <host>   - SSL Check
  ip_local/public    - IP Addresses
  network_info       - Network Details
  ping_test          - Speed Test
  system_info        - System Info
====================
''';
}
