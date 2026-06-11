import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

class TerminalApp extends StatefulWidget {
  const TerminalApp({super.key});

  @override
  State<TerminalApp> createState() => _TerminalAppState();
}

class _TerminalAppState extends State<TerminalApp> with TickerProviderStateMixin {
  // المحتوى
  final TextEditingController _commandController = TextEditingController();
  final List<Map<String, dynamic>> _output = [];
  final ScrollController _scrollController = ScrollController();
  String _currentDir = '';
  String _userName = 'zion';
  String _hostName = 'zion-os';
  
  // حالة التطبيق
  bool _isProcessing = false;
  bool _isConnected = true;
  int _commandHistoryIndex = -1;
  List<String> _commandHistory = [];
  
  // تأثيرات
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  
  // الإعدادات
  double _fontSize = 14.0;
  String _fontFamily = 'monospace';
  bool _showLineNumbers = false;
  bool _autoCopy = true;

  @override
  void initState() {
    super.initState();
    _initTerminal();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _initTerminal() async {
    await _loadSettings();
    _updatePath();
    _updateUserHost();
    _addWelcomeMessage();
  }

  Future<void> _loadSettings() async {
    // تحميل الإعدادات المحفوظة
  }

  void _updatePath() {
    try {
      final result = Process.runSync('pwd', [], runInShell: true);
      if (result.exitCode == 0) {
        _currentDir = result.stdout.toString().trim();
      }
    } catch (_) {
      _currentDir = '~';
    }
  }

  void _updateUserHost() {
    try {
      final userResult = Process.runSync('whoami', [], runInShell: true);
      if (userResult.exitCode == 0) {
        _userName = userResult.stdout.toString().trim();
      }
      final hostResult = Process.runSync('hostname', [], runInShell: true);
      if (hostResult.exitCode == 0) {
        _hostName = hostResult.stdout.toString().trim();
      }
    } catch (_) {}
  }

  void _addWelcomeMessage() {
    _addOutput('╔══════════════════════════════════════════════════════════════════╗', 'info');
    _addOutput('║                    ZION OS TERMINAL v4.0                          ║', 'info');
    _addOutput('╠══════════════════════════════════════════════════════════════════╣', 'info');
    _addOutput('║  🔐 System: Secure Shell                                        ║', 'info');
    _addOutput('║  🚀 Performance: Optimized                                       ║', 'info');
    _addOutput('║  🛡️ Security: Active                                             ║', 'info');
    _addOutput('╠══════════════════════════════════════════════════════════════════╣', 'info');
    _addOutput('║  Commands:                                                       ║', 'info');
    _addOutput('║  • help     - Show this message                                 ║', 'info');
    _addOutput('║  • clear    - Clear screen                                      ║', 'info');
    _addOutput('║  • pwd      - Show current directory                            ║', 'info');
    _addOutput('║  • ls       - List files                                        ║', 'info');
    _addOutput('║  • cd [dir] - Change directory                                  ║', 'info');
    _addOutput('╚══════════════════════════════════════════════════════════════════╝', 'info');
    _addOutput('', '');
    _addOutput('Type "help" for available commands', 'prompt');
  }

  void _addOutput(String text, String type) {
    setState(() {
      _output.add({
        'text': text,
        'type': type,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    // إضافة إلى السجل
    _commandHistory.add(command);
    _commandHistoryIndex = _commandHistory.length;
    
    // عرض الأمر المدخل
    _addOutput('${_getPrompt()} $command', 'command');
    _commandController.clear();
    setState(() => _isProcessing = true);

    // معالجة الأوامر المدمجة
    if (await _handleBuiltInCommand(command)) {
      setState(() => _isProcessing = false);
      return;
    }

    // تنفيذ الأمر
    try {
      final result = await Process.run('sh', ['-c', command], workingDirectory: _currentDir, runInShell: true);
      if (result.stdout.toString().isNotEmpty) {
        _addOutput(result.stdout.toString().trim(), 'output');
      }
      if (result.stderr.toString().isNotEmpty) {
        _addOutput(result.stderr.toString().trim(), 'error');
      }
      _updatePath();
    } catch (e) {
      _addOutput('Command not found: $command', 'error');
    }

    setState(() => _isProcessing = false);
  }

  Future<bool> _handleBuiltInCommand(String command) async {
    switch (command.toLowerCase()) {
      case 'help':
        _showHelp();
        return true;
      case 'clear':
      case 'cls':
        setState(() => _output.clear());
        _addWelcomeMessage();
        return true;
      case 'pwd':
        _addOutput(_currentDir, 'output');
        return true;
      case 'whoami':
        _addOutput(_userName, 'output');
        return true;
      case 'hostname':
        _addOutput(_hostName, 'output');
        return true;
      case 'date':
        _addOutput(DateTime.now().toString(), 'output');
        return true;
      case 'history':
        _showHistory();
        return true;
      case 'theme':
        _showThemeMenu();
        return true;
      case 'info':
        _showSystemInfo();
        return true;
      default:
        if (command.startsWith('cd ')) {
          await _changeDirectory(command.substring(3).trim());
          return true;
        }
        return false;
    }
  }

  Future<void> _changeDirectory(String path) async {
    final newDir = path.startsWith('/') ? path : '$_currentDir/$path';
    try {
      final dir = Directory(newDir);
      if (await dir.exists()) {
        _currentDir = dir.path;
        _addOutput('Changed to: $_currentDir', 'success');
      } else {
        _addOutput('Directory not found: $path', 'error');
      }
    } catch (_) {
      _addOutput('Invalid directory: $path', 'error');
    }
  }

  void _showHelp() {
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('📖  ZION OS TERMINAL HELP', 'info');
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('', '');
    _addOutput('  🖥️  SYSTEM COMMANDS:', 'title');
    _addOutput('     help      - Display this help message', 'output');
    _addOutput('     clear     - Clear the terminal screen', 'output');
    _addOutput('     exit      - Exit terminal', 'output');
    _addOutput('     info      - Show system information', 'output');
    _addOutput('', '');
    _addOutput('  📁  FILE NAVIGATION:', 'title');
    _addOutput('     pwd       - Show current directory', 'output');
    _addOutput('     ls        - List directory contents', 'output');
    _addOutput('     cd [dir]  - Change directory', 'output');
    _addOutput('', '');
    _addOutput('  🔧  UTILITIES:', 'title');
    _addOutput('     date      - Show current date and time', 'output');
    _addOutput('     whoami    - Show current user', 'output');
    _addOutput('     hostname  - Show system hostname', 'output');
    _addOutput('     history   - Show command history', 'output');
    _addOutput('     theme     - Change terminal theme', 'output');
    _addOutput('', '');
    _addOutput('  🌐  NETWORK COMMANDS:', 'title');
    _addOutput('     ping [host]     - Ping a host', 'output');
    _addOutput('     netstat         - Show network statistics', 'output');
    _addOutput('     ifconfig        - Show network interfaces', 'output');
    _addOutput('', '');
    _addOutput('  🔒  SECURITY COMMANDS:', 'title');
    _addOutput('     encrypt [text]  - Encrypt text', 'output');
    _addOutput('     hash [text]     - Generate MD5 hash', 'output');
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
  }

  void _showHistory() {
    if (_commandHistory.isEmpty) {
      _addOutput('No commands in history', 'info');
      return;
    }
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('📜  COMMAND HISTORY', 'info');
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    for (var i = 0; i < _commandHistory.length; i++) {
      _addOutput('  ${(i + 1).toString().padLeft(3)}  ${_commandHistory[i]}', 'output');
    }
  }

  void _showSystemInfo() {
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('💻  SYSTEM INFORMATION', 'info');
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('  OS:        Zion OS v4.0', 'output');
    _addOutput('  Kernel:    Linux 5.10', 'output');
    _addOutput('  Shell:     ZSH 5.8', 'output');
    _addOutput('  Terminal:  Zion Terminal v2.0', 'output');
    _addOutput('  User:      $_userName', 'output');
    _addOutput('  Host:      $_hostName', 'output');
    _addOutput('  Directory: $_currentDir', 'output');
  }

  void _showThemeMenu() {
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('🎨  TERMINAL THEMES', 'info');
    _addOutput('═══════════════════════════════════════════════════════════════', 'info');
    _addOutput('  1.  Default (Dark)', 'output');
    _addOutput('  2.  Matrix Green', 'output');
    _addOutput('  3.  Neon Blue', 'output');
    _addOutput('  4.  Cyberpunk Pink', 'output');
    _addOutput('  5.  Retro Amber', 'output');
    _addOutput('', '');
    _addOutput('Use: theme [1-5] to apply', 'prompt');
  }

  String _getPrompt() {
    return '┌─[$_userName@$_hostName]─[$_currentDir]\n└─\\$ ';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _previousCommand() {
    if (_commandHistory.isEmpty) return;
    if (_commandHistoryIndex > 0) {
      _commandHistoryIndex--;
      _commandController.text = _commandHistory[_commandHistoryIndex];
      _commandController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commandController.text.length),
      );
    }
  }

  void _nextCommand() {
    if (_commandHistory.isEmpty) return;
    if (_commandHistoryIndex < _commandHistory.length - 1) {
      _commandHistoryIndex++;
      _commandController.text = _commandHistory[_commandHistoryIndex];
      _commandController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commandController.text.length),
      );
    } else {
      _commandHistoryIndex = _commandHistory.length;
      _commandController.clear();
    }
  }

  void _copyLastOutput() {
    if (_output.isNotEmpty) {
      final lastOutput = _output.lastWhere(
        (o) => o['type'] == 'output',
        orElse: () => {'text': ''},
      );
      if (lastOutput['text'].isNotEmpty) {
        Clipboard.setData(ClipboardData(text: lastOutput['text']));
        _addOutput('📋 Copied to clipboard', 'success');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFF00BCD4), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('ZION TERMINAL', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isConnected ? 'CONNECTED' : 'OFFLINE',
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.red,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
            onPressed: _copyLastOutput,
            tooltip: 'Copy last output',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF00BCD4)),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Clear History'), value: 'clear'),
              const PopupMenuItem(child: Text('Export Logs'), value: 'export'),
              const PopupMenuItem(child: Text('Settings'), value: 'settings'),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                setState(() => _output.clear());
                _addWelcomeMessage();
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/eye_of_horus.svg'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
            opacity: 0.06,
          ),
        ),
        child: Column(
          children: [
            // شريط الحالة المتقدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.black.withOpacity(0.8),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Color(0xFF00BCD4), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentDir,
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 11, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _userName,
                    style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(width: 4),
                  const Text('@', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    _hostName,
                    style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            // مخرجات الطرفية
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _output.length,
                  itemBuilder: (context, index) {
                    final item = _output[index];
                    return _buildOutputLine(item['text'], item['type']);
                  },
                ),
              ),
            ),
            // شريط الإدخال المتطور
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _blinkAnimation,
                    builder: (context, child) {
                      return Text(
                        '❯',
                        style: TextStyle(
                          color: const Color(0xFF00BCD4).withOpacity(_blinkAnimation.value),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      focusNode: FocusNode(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,
                        fontFamily: _fontFamily,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter command...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _executeCommand(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  if (_isProcessing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BCD4)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Color(0xFF00BCD4), size: 18),
                    onPressed: _previousCommand,
                    tooltip: 'Previous command',
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Color(0xFF00BCD4), size: 18),
                    onPressed: _nextCommand,
                    tooltip: 'Next command',
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF00BCD4), size: 18),
                    onPressed: _executeCommand,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputLine(String text, String type) {
    Color color;
    FontWeight weight = FontWeight.normal;
    
    switch (type) {
      case 'command':
        color = const Color(0xFF00BCD4);
        weight = FontWeight.bold;
        break;
      case 'error':
        color = Colors.red;
        break;
      case 'success':
        color = Colors.green;
        break;
      case 'title':
        color = const Color(0xFF00BCD4);
        weight = FontWeight.bold;
        break;
      case 'info':
        color = Colors.white54;
        break;
      case 'prompt':
        color = const Color(0xFF00BCD4);
        break;
      default:
        color = Colors.white70;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: _fontSize,
          fontWeight: weight,
        ),
      ),
    );
  }
}
