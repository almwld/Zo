import 'package:flutter/material.dart';
import 'dart:io';
import 'core/arsenal/zion_net.dart';
import 'core/arsenal/zion_crack.dart';
import 'core/arsenal/zion_exploit.dart';
import 'core/arsenal/zion_web.dart';
import 'core/arsenal/zion_wireless.dart';
import 'core/arsenal/zion_mitm.dart';
import 'core/arsenal/zion_forensics.dart';

class CosmicTerminal extends StatefulWidget {
  const CosmicTerminal({super.key});

  @override
  State<CosmicTerminal> createState() => _CosmicTerminalState();
}

class _CosmicTerminalState extends State<CosmicTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalLine> _lines = [];
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('🔥 Zion OS v1.0 - Cosmic Terminal');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('');
    _addLine('📡 NETWORK COMMANDS:');
    _addLine('  portscan <target> <ports>     - Scan ports (e.g., portscan 192.168.1.1 80,443)');
    _addLine('  ping <target>                 - Ping target');
    _addLine('  dns <domain>                  - DNS lookup');
    _addLine('  traceroute <target>           - Trace route');
    _addLine('  osdetect <target>             - Detect operating system');
    _addLine('  whois <domain>                - WHOIS lookup');
    _addLine('  geoip <ip>                    - GeoIP location');
    _addLine('');
    _addLine('🔐 CRACKING COMMANDS:');
    _addLine('  crack <hash> <type>           - Crack hash (md5/sha1/sha256)');
    _addLine('  base64 <text>                 - Decode Base64');
    _addLine('  caesar <text> <shift>         - Caesar cipher');
    _addLine('  xor <text> <key>              - XOR cipher');
    _addLine('');
    _addLine('💀 EXPLOIT COMMANDS:');
    _addLine('  exploit <target> <name>       - Run exploit (eternalblue/log4shell)');
    _addLine('  vulnscan <target>             - Scan vulnerabilities');
    _addLine('');
    _addLine('🌐 WEB COMMANDS:');
    _addLine('  sqli <url> <param>            - SQL injection test');
    _addLine('  xss <url> <param>             - XSS test');
    _addLine('  lfi <url>                     - LFI test');
    _addLine('  dirbrute <url>                - Directory brute force');
    _addLine('');
    _addLine('📡 WIRELESS COMMANDS:');
    _addLine('  wifiscan                      - Scan WiFi networks');
    _addLine('  wificrack <bssid>             - Crack WiFi (if vulnerable)');
    _addLine('');
    _addLine('🕵️ FORENSICS COMMANDS:');
    _addLine('  metadata <file>               - Extract file metadata');
    _addLine('  strings <file>                - Extract strings from file');
    _addLine('');
    _addLine('⚙️ SYSTEM COMMANDS:');
    _addLine('  help                          - Show this help');
    _addLine('  clear                         - Clear screen');
    _addLine('  exit                          - Close terminal');
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('Ready. Type "help" for commands.');
    _addLine('');
  }

  void _addLine(String text, {bool isError = false, bool isCommand = false}) {
    setState(() {
      _lines.add(TerminalLine(
        text: text,
        isError: isError,
        isCommand: isCommand,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeCommand(String command) async {
    if (command.trim().isEmpty) return;
    
    _addLine('zion@local:~$ $command', isCommand: true);
    _inputController.clear();
    setState(() => _isExecuting = true);
    
    final parts = command.trim().split(' ');
    final cmd = parts[0].toLowerCase();
    final args = parts.sublist(1);
    
    try {
      String result = '';
      
      switch (cmd) {
        // ==================== NETWORK COMMANDS ====================
        case 'portscan':
          if (args.length < 2) {
            result = 'Usage: portscan <target> <ports> (e.g., portscan 192.168.1.1 80,443)';
          } else {
            final target = args[0];
            final ports = args[1].split(',').map((p) => int.parse(p)).toList();
            final openPorts = await ZionNet.portScan(target, ports);
            result = 'Open ports: ${openPorts.join(", ")}';
          }
          break;
          
        case 'ping':
          if (args.isEmpty) {
            result = 'Usage: ping <target>';
          } else {
            result = await ZionNet.ping(args[0]);
          }
          break;
          
        case 'dns':
          if (args.isEmpty) {
            result = 'Usage: dns <domain>';
          } else {
            final ips = await ZionNet.dnsLookup(args[0]);
            result = 'IP addresses: ${ips.join(", ")}';
          }
          break;
          
        case 'traceroute':
          if (args.isEmpty) {
            result = 'Usage: traceroute <target>';
          } else {
            final hops = await ZionNet.traceroute(args[0]);
            result = hops.map((h) => '${h['ttl']}: ${h['ip']} (${h['time_ms']}ms)').join('\n');
          }
          break;
          
        case 'osdetect':
          if (args.isEmpty) {
            result = 'Usage: osdetect <target>';
          } else {
            result = await ZionNet.detectOS(args[0]);
          }
          break;
          
        case 'whois':
          if (args.isEmpty) {
            result = 'Usage: whois <domain>';
          } else {
            final whois = await ZionNet.whoisLookup(args[0]);
            result = whois['raw'] ?? 'No data';
          }
          break;
          
        case 'geoip':
          if (args.isEmpty) {
            result = 'Usage: geoip <ip>';
          } else {
            final geo = await ZionNet.geoipLookup(args[0]);
            result = 'Location: Lat ${geo['lat']}, Lon ${geo['lon']}';
          }
          break;
          
        // ==================== CRACKING COMMANDS ====================
        case 'crack':
          if (args.length < 2) {
            result = 'Usage: crack <hash> <type> (md5/sha1/sha256)';
          } else {
            final cracked = await ZionCrack.crackHash(args[0], args[1]);
            result = cracked != null ? 'Password: $cracked' : 'Hash not found in wordlist';
          }
          break;
          
        case 'base64':
          if (args.isEmpty) {
            result = 'Usage: base64 <text>';
          } else {
            final decoded = await ZionCrack.base64Decode(args[0]);
            result = decoded ?? 'Invalid Base64';
          }
          break;
          
        case 'caesar':
          if (args.length < 2) {
            result = 'Usage: caesar <text> <shift>';
          } else {
            final cipher = await ZionCrack.caesarCipher(args[0], int.parse(args[1]));
            result = cipher ?? 'Failed';
          }
          break;
          
        case 'xor':
          if (args.length < 2) {
            result = 'Usage: xor <text> <key>';
          } else {
            final key = args[1].codeUnitAt(0);
            final resultBytes = <int>[];
            for (var i = 0; i < args[0].length; i++) {
              resultBytes.add(args[0].codeUnitAt(i) ^ key);
            }
            result = String.fromCharCodes(resultBytes);
          }
          break;
          
        // ==================== EXPLOIT COMMANDS ====================
        case 'exploit':
          if (args.length < 2) {
            result = 'Usage: exploit <target> <name> (eternalblue/log4shell/heartbleed/shellshock)';
          } else {
            final exploited = await ZionExploit.runExploit(args[0], args[1]);
            result = exploited ? '✅ Exploit successful!' : '❌ Target not vulnerable';
          }
          break;
          
        case 'vulnscan':
          if (args.isEmpty) {
            result = 'Usage: vulnscan <target>';
          } else {
            final vulns = await ZionExploit.scanVulnerabilities(args[0]);
            result = vulns.entries.map((e) => '${e.key}: ${e.value ? "VULNERABLE" : "Safe"}').join('\n');
          }
          break;
          
        // ==================== WEB COMMANDS ====================
        case 'sqli':
          if (args.length < 2) {
            result = 'Usage: sqli <url> <parameter>';
          } else {
            final vulnerable = await ZionWeb.sqlInjectionTest(args[0], args[1]);
            result = vulnerable ? '✅ Vulnerable to SQL injection!' : '❌ Not vulnerable';
          }
          break;
          
        case 'xss':
          if (args.length < 2) {
            result = 'Usage: xss <url> <parameter>';
          } else {
            final vulnerable = await ZionWeb.xssTest(args[0], args[1]);
            result = vulnerable ? '✅ Vulnerable to XSS!' : '❌ Not vulnerable';
          }
          break;
          
        case 'lfi':
          if (args.isEmpty) {
            result = 'Usage: lfi <url>';
          } else {
            final vulnerable = await ZionWeb.lfiTest(args[0]);
            result = vulnerable ? '✅ Vulnerable to LFI!' : '❌ Not vulnerable';
          }
          break;
          
        case 'dirbrute':
          if (args.isEmpty) {
            result = 'Usage: dirbrute <url>';
          } else {
            final dirs = await ZionWeb.dirBrute(args[0], 'admin,login,wp-admin,backup,config');
            result = dirs.isNotEmpty ? 'Found: ${dirs.join(", ")}' : 'No directories found';
          }
          break;
          
        // ==================== WIRELESS COMMANDS ====================
        case 'wifiscan':
          final networks = await ZionWireless.scanNetworks();
          result = networks.isNotEmpty 
              ? networks.map((n) => 'SSID: ${n.ssid} (${n.bssid}) - Signal: ${n.signalStrength}dBm').join('\n')
              : 'No networks found';
          break;
          
        case 'wificrack':
          if (args.isEmpty) {
            result = 'Usage: wificrack <bssid>';
          } else {
            final wps = await ZionWireless.checkWPS(args[0]);
            result = wps.wpsEnabled ? 'WPS enabled - possible crack' : 'WPS disabled';
          }
          break;
          
        // ==================== FORENSICS COMMANDS ====================
        case 'metadata':
          if (args.isEmpty) {
            result = 'Usage: metadata <file_path>';
          } else {
            final metadata = await ZionForensics.extractMetadata(args[0]);
            result = metadata.entries.map((e) => '${e.key}: ${e.value}').join('\n');
          }
          break;
          
        case 'strings':
          if (args.isEmpty) {
            result = 'Usage: strings <file_path>';
          } else {
            final strings = await ZionForensics.carveFiles(args[0]);
            result = strings.take(20).join('\n');
          }
          break;
          
        // ==================== SYSTEM COMMANDS ====================
        case 'help':
          result = '''
═══════════════════════════════════════════════════════════════
🔥 ZION OS - COSMIC TERMINAL COMMANDS
═══════════════════════════════════════════════════════════════

📡 NETWORK:
  portscan <target> <ports>     - Scan ports
  ping <target>                 - Ping target
  dns <domain>                  - DNS lookup
  traceroute <target>           - Trace route
  osdetect <target>             - Detect OS
  whois <domain>                - WHOIS lookup
  geoip <ip>                    - GeoIP location

🔐 CRACKING:
  crack <hash> <type>           - Crack hash (md5/sha1/sha256)
  base64 <text>                 - Decode Base64
  caesar <text> <shift>         - Caesar cipher
  xor <text> <key>              - XOR cipher

💀 EXPLOIT:
  exploit <target> <name>       - Run exploit
  vulnscan <target>             - Scan vulnerabilities

🌐 WEB:
  sqli <url> <param>            - SQL injection
  xss <url> <param>             - XSS test
  lfi <url>                     - LFI test
  dirbrute <url>                - Directory brute force

📡 WIRELESS:
  wifiscan                      - Scan WiFi networks
  wificrack <bssid>             - Crack WiFi (if vulnerable)

🕵️ FORENSICS:
  metadata <file>               - Extract metadata
  strings <file>                - Extract strings

⚙️ SYSTEM:
  help                          - Show help
  clear                         - Clear screen
  exit                          - Close terminal
═══════════════════════════════════════════════════════════════
''';
          break;
          
        case 'clear':
          setState(() => _lines.clear());
          _addLine('Screen cleared');
          break;
          
        case 'exit':
        case 'quit':
          Navigator.pop(context);
          break;
          
        default:
          result = 'Command not found: $cmd. Type "help" for available commands.';
      }
      
      _addLine(result);
    } catch (e) {
      _addLine('Error: $e', isError: true);
    } finally {
      setState(() => _isExecuting = false);
      _addLine('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.black],
              ),
              border: Border(bottom: BorderSide(color: Colors.green.shade700)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'COSMIC TERMINAL',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (_isExecuting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                  ),
              ],
            ),
          ),
          
          // Terminal Output
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _lines.length,
              itemBuilder: (context, index) {
                final line = _lines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: SelectableText(
                    line.text,
                    style: TextStyle(
                      color: line.isError ? Colors.red.shade400 : (line.isCommand ? Colors.green.shade400 : Colors.white),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(top: BorderSide(color: Colors.green.shade700)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'zion@local:~$ ',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter command...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: _executeCommand,
                    enabled: !_isExecuting,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TerminalLine {
  final String text;
  final bool isError;
  final bool isCommand;
  final DateTime timestamp;

  TerminalLine({
    required this.text,
    this.isError = false,
    this.isCommand = false,
    required this.timestamp,
  });
}

  // ==================== أوامر WiFi ====================
  
  case 'wifiscan':
    _addLine('📡 Scanning for networks...');
    final networks = await ZionWiFi().scanAllNetworks();
    if (networks.isEmpty) {
      result = 'No networks found';
    } else {
      result = 'Found ${networks.length} networks:\n';
      for (final n in networks) {
        result += '  ${n.ssid.isNotEmpty ? n.ssid : "<hidden>"} (${n.bssid}) - ${n.security} - ${n.signalStrength}dBm\n';
      }
    }
    break;
    
  case 'hidden':
    _addLine('🕵️ Searching for hidden networks...');
    final hidden = await ZionWiFi().discoverHiddenNetworks();
    if (hidden.isEmpty) {
      result = 'No hidden networks found';
    } else {
      result = 'Found ${hidden.length} hidden networks:\n';
      for (final h in hidden) {
        result += '  ${h.hiddenSSID} → ${h.realSSID} (${h.bssid})\n';
      }
    }
    break;
    
  case 'wps':
    if (args.isEmpty) {
      result = 'Usage: wps <BSSID>\nExample: wps 00:11:22:33:44:55';
    } else {
      _addLine('🎯 Attacking WPS on ${args[0]}...');
      final wpsResult = await ZionWiFi().attackWPS(args[0]);
      if (wpsResult.success) {
        result = '✅ WPS PIN found: ${wpsResult.pin}\n🔑 Connected: ${wpsResult.connected}\n⏱️ Attempts: ${wpsResult.attempts}\n⏱️ Duration: ${wpsResult.duration.inSeconds}s';
      } else {
        result = '❌ WPS attack failed after ${wpsResult.attempts} attempts';
      }
    }
    break;
    
  case 'pmkid':
    if (args.isEmpty) {
      result = 'Usage: pmkid <BSSID>\nExample: pmkid 00:11:22:33:44:55';
    } else {
      _addLine('🔓 Attacking PMKID on ${args[0]}...');
      final pmkidResult = await ZionWiFi().attackPMKID(args[0]);
      if (pmkidResult.success) {
        result = '✅ PMKID captured: ${pmkidResult.pmkid}\n🔑 Password: ${pmkidResult.password}\n⏱️ Duration: ${pmkidResult.duration.inSeconds}s';
      } else {
        result = '❌ PMKID attack failed: ${pmkidResult.error}';
      }
    }
    break;
    
  case 'wifite':
    if (args.isEmpty) {
      result = 'Usage: wifite <BSSID>\nExample: wifite 00:11:22:33:44:55';
    } else {
      _addLine('💀 Starting full Wifite-style attack on ${args[0]}...');
      final attackResult = await ZionWiFi().fullAttack(args[0]);
      if (attackResult.success) {
        result = '✅ ATTACK SUCCESSFUL!\n🔑 Password: ${attackResult.password}\n⏱️ Duration: ${attackResult.duration.inSeconds}s\n📊 Steps: ${attackResult.steps.keys.join(", ")}';
      } else {
        result = '❌ Attack failed after ${attackResult.duration.inSeconds}s\nNo password found for ${args[0]}';
      }
    }
    break;

  // ==================== أوامر WiFi الحقيقية ====================
  
  case 'wifireal':
    if (args.isEmpty) {
      result = 'Usage: wifireal <BSSID> [router_ip]\nExample: wifireal 00:11:22:33:44:55 192.168.1.1';
    } else {
      final target = args[0];
      final routerIp = args.length > 1 ? args[1] : null;
      _addLine('🎯 Starting real attack on $target...');
      final attackResult = await ZionWiFiReal().fullAttack(target, routerIp: routerIp);
      if (attackResult.success) {
        result = '✅ SUCCESS!\n🔑 Password: ${attackResult.password}\n📡 Method: ${attackResult.method}\n⏱️ Duration: ${attackResult.duration.inSeconds}s';
      } else {
        result = '❌ FAILED after ${attackResult.duration.inSeconds}s\nNo password found';
      }
    }
    break;
    
  case 'routerhack':
    if (args.isEmpty) {
      result = 'Usage: routerhack <router_ip>\nExample: routerhack 192.168.1.1';
    } else {
      _addLine('🏠 Hacking router ${args[0]}...');
      final routerResult = await ZionWiFiReal().hackRouterDefaultCredentials(args[0]);
      if (routerResult.success) {
        result = '✅ Router hacked!\n👤 Username: ${routerResult.username}\n🔑 Password: ${routerResult.password}\n📶 WiFi Password: ${routerResult.wifiPassword}\n⏱️ Duration: ${routerResult.duration.inSeconds}s';
      } else {
        result = '❌ Failed to hack router after ${routerResult.attempts} attempts';
      }
    }
    break;
    
  case 'wpsreal':
    if (args.isEmpty) {
      result = 'Usage: wpsreal <BSSID>\nExample: wpsreal 00:11:22:33:44:55';
    } else {
      _addLine('🔑 Trying WPS PIN attack on ${args[0]}...');
      final wpsResult = await ZionWiFiReal().hackWPSPin(args[0]);
      if (wpsResult.success) {
        result = '✅ WPS PIN found: ${wpsResult.pin}\n⏱️ Duration: ${wpsResult.duration.inSeconds}s\n📊 Attempts: ${wpsResult.attempts}';
      } else {
        result = '❌ WPS attack failed after ${wpsResult.attempts} attempts';
      }
    }
    break;
    
  case 'eviltwin':
    if (args.isEmpty) {
      result = 'Usage: eviltwin <SSID>\nExample: eviltwin MyWiFi';
    } else {
      final ssid = args.join(' ');
      _addLine('🎭 Starting Evil Twin attack on "$ssid"...');
      _addLine('⚠️ A fake hotspot will be created. Wait for victim to connect.');
      final evilResult = await ZionWiFiReal().evilTwinAttack(ssid);
      if (evilResult.success) {
        result = '✅ Victim connected!\n🔑 Captured password: ${evilResult.capturedPassword}\n⏱️ Duration: ${evilResult.duration.inSeconds}s';
      } else {
        result = '❌ Evil Twin attack failed: ${evilResult.error}';
      }
    }
    break;
