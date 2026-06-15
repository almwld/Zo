// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Screen UI - واجهة المستخدم                    ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: واجهة المستخدم لعرض وإدخال الأوامر                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../terminal/terminal_emulator.dart';
import '../terminal/terminal_session.dart';
import '../terminal/terminal_cell.dart';
import '../terminal/terminal_colors.dart';
import '../services/language_manager.dart';
import '../ai/ai_assistant.dart';
import '../packages/package_manager.dart';
import '../distros/distro_manager.dart';
import 'terminal_toolbar.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalScreen - شاشة الطرفية
///                    Terminal Screen UI Widget
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({Key? key}) : super(key: key);

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TerminalEmulator _emulator = TerminalEmulator();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _showToolbar = true;
  String _currentInput = '';
  List<String> _commandHistory = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _emulator.onOutput = _handleOutput;
    _initializeTerminal();
  }

  void _initializeTerminal() {
    _emulator.write('\x1B[1;32m');
    _emulator.write('╔══════════════════════════════════════════════════════════╗\n');
    _emulator.write('║        Welcome to Zion OS Terminal v1.0.0                  ║\n');
    _emulator.write('║        Type "!help" for available commands                ║\n');
    _emulator.write('╚══════════════════════════════════════════════════════════╝\n\n');
    _emulator.write('\x1B[0m');
    _showPrompt();
  }

  void _handleOutput(String text) {
    setState(() {});
  }

  void _showPrompt() {
    final lang = LanguageManager.isArabic ? 'AR' : 'EN';
    _emulator.write('\x1B[32m');
    _emulator.write('$lang:\$ ');
    _emulator.write('\x1B[0m');
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) {
      _showPrompt();
      return;
    }

    _commandHistory.add(command);
    _historyIndex = _commandHistory.length;
    _emulator.write('$command\r\n');

    if (command.startsWith('!')) {
      _handleSpecialCommand(command);
    } else {
      final aiAssistant = context.read<AIAssistant>();
      final translated = aiAssistant.translate(command);

      if (translated != command) {
        _emulator.write('\x1B[36m');
        _emulator.write('  → $translated\n');
        _emulator.write('\x1B[0m');
      }

      _executeSimulatedCommand(translated);
    }

    _showPrompt();
    _inputController.clear();
    _currentInput = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSpecialCommand(String command) {
    final parts = command.split(' ');
    final cmd = parts[0].toLowerCase();

    switch (cmd) {
      case '!help':
        _showHelp();
        break;
      case '!lang':
        _handleLanguageCommand(parts);
        break;
      case '!clear':
      case '!cls':
        _emulator.resetScreen();
        break;
      case '!theme':
        if (parts.length > 1) {
          _emulator.write('Theme changed to: ${parts[1]}\n');
        }
        break;
      case '!distro':
        final distroManager = context.read<DistroManager>();
        _emulator.write(distroManager.processCommand(command));
        break;
      case '!pkg':
        final pkgManager = context.read<PackageManager>();
        _emulator.write(pkgManager.processCommand(command));
        break;
      case '!explain':
        if (parts.length > 1) {
          final ai = context.read<AIAssistant>();
          _emulator.write(ai.explain(parts.sublist(1).join(' ')));
        }
        break;
      default:
        _emulator.write('\x1B[31mUnknown command: $cmd\x1B[0m\n');
    }
  }

  void _handleLanguageCommand(List<String> parts) {
    if (parts.length < 2) {
      _emulator.write('Language: ${LanguageManager.currentLanguageName}\n');
      return;
    }

    final lang = parts[1].toLowerCase();
    LanguageManager.setLanguageByName(lang);

    if (LanguageManager.isArabic) {
      _emulator.write('✅ تم التبديل إلى العربية\n');
    } else {
      _emulator.write('✅ Switched to English\n');
    }

    setState(() {});
  }

  void _showHelp() {
    _emulator.write('''
\x1B[1;33mZion OS Terminal - Available Commands\x1B[0m

\x1B[1;32mBasic Commands:\x1B[0m
  !help          - Show this help
  !clear         - Clear screen
  !lang <ar|en>  - Change language
  !theme <name>  - Change theme

\x1B[1;32mArabic Commands (with AI Translation):\x1B[0m
  اعرض الملفات   → ls -la
  ادخل <مجلد>    → cd <folder>
  احذف <ملف>     → rm <file>
  ابحث عن <شيء>  → grep <something>
''');
  }

  void _executeSimulatedCommand(String command) {
    final parts = command.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return;

    final cmd = parts[0].toLowerCase();

    switch (cmd) {
      case 'ls':
        _simulateLs(parts);
        break;
      case 'pwd':
        _emulator.write('/home/user\n');
        break;
      case 'whoami':
        _emulator.write('user\n');
        break;
      case 'date':
        _emulator.write('${DateTime.now()}\n');
        break;
      case 'echo':
        _emulator.write('${parts.sublist(1).join(' ')}\n');
        break;
      default:
        _emulator.write('\x1B[33mCommand executed: $command\x1B[0m\n');
    }
  }

  void _simulateLs(List<String> parts) {
    final showLong = parts.contains('-l') || parts.contains('-la');

    if (showLong) {
      _emulator.write('total 32\n');
      _emulator.write('drwxr-xr-x  2 user user 4096 Jun 15 12:00 .\n');
      _emulator.write('drwxr-xr-x  8 user user 4096 Jun 15 12:00 ..\n');
      _emulator.write('drwxr-xr-x  4 user user 4096 Jun 15 12:00 documents\n');
      _emulator.write('drwxr-xr-x  4 user user 4096 Jun 15 12:00 downloads\n');
    } else {
      _emulator.write('documents  downloads  readme.txt  scripts\n\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_showToolbar) const TerminalToolbar(),
            Expanded(
              child: GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Container(
                  color: TerminalColors.backgroundDark,
                  child: Column(
                    children: [
                      Expanded(child: _buildTerminalOutput()),
                      _buildInputBar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalOutput() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      child: SelectableText.rich(
        _buildTextSpan(),
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  TextSpan _buildTextSpan() {
    final spans = <TextSpan>[];
    final screen = _emulator.screen;

    for (int row = 0; row < screen.rows; row++) {
      for (int col = 0; col < screen.columns; col++) {
        final cell = screen.getCell(row, col);
        if (cell.character != ' ') {
          spans.add(cell.toTextSpan());
        } else {
          spans.add(const TextSpan(text: ' '));
        }
      }
      spans.add(const TextSpan(text: '\n'));
    }

    return TextSpan(children: spans);
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TerminalColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.terminal,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: LanguageManager.t('messages.ready'),
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                _currentInput = value;
              },
              onSubmitted: _executeCommand,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            onPressed: () => _executeCommand(_currentInput),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _emulator.dispose();
    super.dispose();
  }
}