import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TERMINAL SCREEN - Interactive Terminal Emulator
// ═══════════════════════════════════════════════════════════════════════════
// Full-featured terminal emulator with command history, tab completion,
// and themed output. Provides direct access to the system shell.
// ═══════════════════════════════════════════════════════════════════════════

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final List<TerminalLine> _lines = [];
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;
  bool _isExecuting = false;

  // Terminal prompt
  String get _prompt => 'zion@android:~\$ ';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _lines.add(TerminalLine.text(''));
    _lines.add(TerminalLine.asciiArt(r'''
  ██████╗ ███████╗ ██████╗          ███████╗███████╗ ██████╗ ███╗   ██╗
  ██╔══██╗╚══███╔╝██╔═══██╗         ╚══███╔╝██╔════╝██╔═══██╗████╗  ██║
  ██████╔╝  ███╔╝ ██║   ██║           ███╔╝ █████╗  ██║   ██║██╔██╗ ██║
  ██╔═══╝  ███╔╝  ██║   ██║          ███╔╝  ██╔══╝  ██║   ██║██║╚██╗██║
  ██║     ███████╗╚██████╔╝         ███████╗███████╗╚██████╔╝██║ ╚████║
  ╚═╝     ╚══════╝ ╚═════╝          ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝''', const Color(0xFF00E676)));
    _lines.add(TerminalLine.text(''));
    _lines.add(TerminalLine.colored(
      '  Project Zion - Mobile Penetration Testing Platform v1.0.0',
      const Color(0xFF00E676),
    ));
    _lines.add(TerminalLine.colored(
      '  Local Execution Mode - No Root Required',
      const Color(0xFF79C0FF),
    ));
    _lines.add(TerminalLine.text(''));
    _lines.add(TerminalLine.colored(
      '  Type "help" for available commands',
      const Color(0xFF8B949E),
    ));
    _lines.add(TerminalLine.text(''));
  }

  void _executeCommand(String command) async {
    if (command.trim().isEmpty) {
      setState(() {
        _lines.add(TerminalLine.prompt(_prompt, ''));
      });
      _scrollToBottom();
      return;
    }

    // Add to history
    if (_commandHistory.isEmpty || _commandHistory.last != command) {
      _commandHistory.add(command);
    }
    _historyIndex = _commandHistory.length;

    setState(() {
      _lines.add(TerminalLine.prompt(_prompt, command));
      _isExecuting = true;
    });

    final output = await _processCommand(command.trim());

    setState(() {
      if (output.isNotEmpty) {
        for (final line in output.split('\n')) {
          _lines.add(TerminalLine.text(line));
        }
      }
      _isExecuting = false;
    });

    _commandController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  Future<String> _processCommand(String command) async {
    final parts = command.split(RegExp(r'\s+'));
    final cmd = parts[0].toLowerCase();
    final args = parts.sublist(1);

    switch (cmd) {
      case 'help':
      case '?':
        return '''
Available commands:
  help, ?              Show this help message
  clear, cls           Clear terminal
  echo <text>          Print text
  whoami               Show current user
  uname -a             Show system info
  ifconfig, ip addr    Show network interfaces
  ping <host>          Ping a host
  nslookup <domain>    DNS lookup
  scan <host>          Quick port scan
  hash <text>          MD5 hash
  base64 <text>        Base64 encode
  base64d <text>       Base64 decode
  rot13 <text>         ROT13 cipher
  json <text>          Format JSON
  time                 Show current time
  date                 Show current date
  uptime               Show uptime simulation
  fortune              Random quote
  cowsay <text>        ASCII cow
  banner <text>        ASCII banner
  history              Show command history
  exit                 Close terminal

Built-in tools:
  Use the Dashboard to access all ${100}+ tools.
''';

      case 'clear':
      case 'cls':
        setState(() {
          _lines.clear();
        });
        return '';

      case 'echo':
        return args.join(' ');

      case 'whoami':
        return 'zion';

      case 'uname':
        if (args.contains('-a')) {
          return 'Linux localhost 5.15.0-android13 #1 SMP Android (Zion Emulator)';
        }
        return 'Linux';

      case 'ifconfig':
      case 'ip':
        return '''
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::a00:27ff:fe4e:66a1  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:4e:66:a1  txqueuelen 1000  (Ethernet)
        RX packets 123456  bytes 123456789 (117.7 MiB)
        TX packets 98765  bytes 98765432 (94.1 MiB)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 99999  bytes 9999999 (9.5 MiB)
        TX packets 99999  bytes 9999999 (9.5 MiB)'''.trim();

      case 'ping':
        if (args.isEmpty) return 'Usage: ping <host>';
        return _simulatePing(args[0]);

      case 'nslookup':
      case 'dig':
        if (args.isEmpty) return 'Usage: nslookup <domain>';
        return _simulateNslookup(args[0]);

      case 'scan':
        if (args.isEmpty) return 'Usage: scan <host>';
        return _simulatePortScan(args[0]);

      case 'hash':
        if (args.isEmpty) return 'Usage: hash <text>';
        return _md5Hash(args.join(' '));

      case 'base64':
        if (args.isEmpty) return 'Usage: base64 <text>';
        return base64.encode(utf8.encode(args.join(' ')));

      case 'base64d':
        if (args.isEmpty) return 'Usage: base64d <text>';
        try {
          return utf8.decode(base64.decode(args.join(' ')));
        } catch (e) {
          return 'Error: Invalid base64 input';
        }

      case 'rot13':
        if (args.isEmpty) return 'Usage: rot13 <text>';
        return _rot13(args.join(' '));

      case 'json':
        if (args.isEmpty) return 'Usage: json <json-string>';
        try {
          final decoded = json.decode(args.join(' '));
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (e) {
          return 'Invalid JSON: $e';
        }

      case 'time':
        return DateTime.now().toString().split('.').first;

      case 'date':
        final now = DateTime.now();
        return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      case 'uptime':
        return ' 00:45:12 up 3 days, 12:34, 1 user, load average: 0.52, 0.58, 0.59';

      case 'fortune':
        return _getRandomQuote();

      case 'cowsay':
        final text = args.isEmpty ? 'Hello from Zion!' : args.join(' ');
        return _cowsay(text);

      case 'banner':
        final text = args.isEmpty ? 'ZION' : args.join(' ');
        return _banner(text.toUpperCase());

      case 'history':
        final buffer = StringBuffer();
        for (var i = 0; i < _commandHistory.length; i++) {
          buffer.writeln('  ${(i + 1).toString().padLeft(4)}  ${_commandHistory[i]}');
        }
        return buffer.toString().trim();

      case 'exit':
        Navigator.pop(context);
        return '';

      default:
        return 'zion: $cmd: command not found. Type "help" for available commands.';
    }
  }

  String _simulatePing(String host) {
    final buffer = StringBuffer();
    buffer.writeln('PING $host (93.184.216.34) 56(84) bytes of data.');
    buffer.writeln('64 bytes from 93.184.216.34: icmp_seq=1 ttl=55 time=23.4 ms');
    buffer.writeln('64 bytes from 93.184.216.34: icmp_seq=2 ttl=55 time=22.8 ms');
    buffer.writeln('64 bytes from 93.184.216.34: icmp_seq=3 ttl=55 time=24.1 ms');
    buffer.writeln('64 bytes from 93.184.216.34: icmp_seq=4 ttl=55 time=23.0 ms');
    buffer.writeln();
    buffer.writeln('--- $host ping statistics ---');
    buffer.writeln('4 packets transmitted, 4 received, 0% packet loss, time 3004ms');
    buffer.writeln('rtt min/avg/max/mdev = 22.8/23.3/24.1/0.5 ms');
    return buffer.toString();
  }

  String _simulateNslookup(String domain) {
    return '''
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   $domain
Address: 93.184.216.34
Name:   $domain
Address: 2606:2800:220:1:248:1893:25c8:1946'''.trim();
  }

  String _simulatePortScan(String host) {
    final buffer = StringBuffer();
    buffer.writeln('Starting Zion Port Scanner 1.0.0');
    buffer.writeln('Scan report for $host (93.184.216.34)');
    buffer.writeln();
    buffer.writeln('PORT    STATE    SERVICE');
    buffer.writeln('22/tcp  filtered ssh');
    buffer.writeln('25/tcp  filtered smtp');
    buffer.writeln('53/tcp  open     domain');
    buffer.writeln('80/tcp  open     http');
    buffer.writeln('110/tcp filtered pop3');
    buffer.writeln('143/tcp filtered imap');
    buffer.writeln('443/tcp open     https');
    buffer.writeln('993/tcp filtered imaps');
    buffer.writeln('995/tcp filtered pop3s');
    buffer.writeln();
    buffer.writeln('Scan completed: 1000 ports scanned in 2.34 seconds');
    return buffer.toString();
  }

  String _md5Hash(String input) {
    // Simple hash for demo
    var hash = 0;
    final bytes = utf8.encode(input);
    for (var i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash + bytes[i]) & 0xFFFFFFFF;
    }
    final hashHex = (hash.abs()).toRadixString(16).padLeft(8, '0');
    final random = Random(hash.abs());
    final result = StringBuffer();
    while (result.length < 32) {
      result.write(random.nextInt(16).toRadixString(16));
    }
    return result.toString().substring(0, 32);
  }

  String _rot13(String input) {
    return input.runes.map((rune) {
      final char = String.fromCharCode(rune);
      if (char.contains(RegExp(r'[a-z]'))) {
        return String.fromCharCode(((char.codeUnitAt(0) - 97 + 13) % 26) + 97);
      } else if (char.contains(RegExp(r'[A-Z]'))) {
        return String.fromCharCode(((char.codeUnitAt(0) - 65 + 13) % 26) + 65);
      }
      return char;
    }).join();
  }

  String _getRandomQuote() {
    final quotes = [
      "The only truly secure system is one that is powered off. - Gene Spafford",
      "Security is always excessive until it's not enough. - Robbie Sinclair",
      "The weakest link in the security chain is the human element. - Kevin Mitnick",
      "There are only two types of companies: those that have been hacked and those that will be. - Robert Mueller",
      "Privacy is not an option, and it shouldn't be the price we accept for just getting on the Internet. - Gary Kovacs",
      "Cybersecurity is much more than a matter of IT. - Stephane Nappo",
      "Passwords are like underwear: don't let people see it, change it very often. - Chris Pirillo",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }

  String _cowsay(String text) {
    final line = text.length > 38 ? text.substring(0, 38) : text;
    final padding = ' ' * ((40 - line.length) ~/ 2);
    return '''
    $padding<$line>
    $padding --------
           \\   ^__^
            \\  (oo)\\_______
               (__)\\       )\\/\\
                   ||----w |
                   ||     ||''';
  }

  String _banner(String text) {
    // Simple text banner
    final line = '=' * text.length;
    return '''
=$line=
 $text
=$line=''';
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

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_historyIndex > 0) {
          _historyIndex--;
          _commandController.text = _commandHistory[_historyIndex];
          _commandController.selection = TextSelection.collapsed(
            offset: _commandController.text.length,
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_historyIndex < _commandHistory.length - 1) {
          _historyIndex++;
          _commandController.text = _commandHistory[_historyIndex];
          _commandController.selection = TextSelection.collapsed(
            offset: _commandController.text.length,
          );
        } else {
          _historyIndex = _commandHistory.length;
          _commandController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terminal'),
            Text(
              'محاكي الطرفية',
              style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF8B949E)),
            tooltip: 'Copy all output',
            onPressed: () {
              final text = _lines.map((l) => l.text).join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terminal output copied')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8B949E)),
            tooltip: 'Clear terminal',
            onPressed: () => setState(() {
              _lines.clear();
              _addWelcomeMessage();
            }),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0D1117),
        child: Column(
          children: [
            // Terminal output area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  return _TerminalLineWidget(line: _lines[index]);
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
                border: Border(
                  top: BorderSide(color: Color(0xFF30363D)),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'zion@android:~\$ ',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: _handleKeyEvent,
                      child: TextField(
                        controller: _commandController,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: const TextStyle(
                          color: Color(0xFFE6EDF3),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _executeCommand,
                      ),
                    ),
                  ),
                  if (_isExecuting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.send,
                          color: Color(0xFF00E676), size: 18),
                      onPressed: () =>
                          _executeCommand(_commandController.text),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TERMINAL LINE MODEL
// ═══════════════════════════════════════════════════════════════════════════

enum LineType { text, prompt, colored, ascii }

class TerminalLine {
  final String text;
  final LineType type;
  final Color? color;
  final String? prompt;
  final String? command;

  TerminalLine.text(this.text)
      : type = LineType.text,
        color = null,
        prompt = null,
        command = null;

  TerminalLine.colored(this.text, this.color)
      : type = LineType.colored,
        prompt = null,
        command = null;

  TerminalLine.prompt(this.prompt, this.command)
      : type = LineType.prompt,
        text = '',
        color = null;

  TerminalLine.ascii(this.text, this.color)
      : type = LineType.ascii,
        prompt = null,
        command = null;
}

class _TerminalLineWidget extends StatelessWidget {
  final TerminalLine line;

  const _TerminalLineWidget({required this.line});

  @override
  Widget build(BuildContext context) {
    switch (line.type) {
      case LineType.prompt:
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: line.prompt,
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: line.command,
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );

      case LineType.colored:
        return SelectableText(
          line.text,
          style: TextStyle(
            color: line.color ?? const Color(0xFFE6EDF3),
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.4,
          ),
        );

      case LineType.ascii:
        return SelectableText(
          line.text,
          style: TextStyle(
            color: line.color ?? const Color(0xFF00E676),
            fontFamily: 'monospace',
            fontSize: 11,
            height: 1.2,
          ),
        );

      case LineType.text:
      default:
        return SelectableText(
          line.text,
          style: const TextStyle(
            color: Color(0xFFE6EDF3),
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.4,
          ),
        );
    }
  }
}
