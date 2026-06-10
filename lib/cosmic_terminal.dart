import 'package:flutter/material.dart';

class CosmicTerminal extends StatefulWidget {
  const CosmicTerminal({super.key});

  @override
  State<CosmicTerminal> createState() => _CosmicTerminalState();
}

class _CosmicTerminalState extends State<CosmicTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _lines = [];
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('🔥 Zion OS v3.0 - Cosmic Terminal');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('');
    _addLine('Available commands: help, clear, exit, scan, attack, status');
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
  }

  void _addLine(String text) {
    setState(() => _lines.add(text));
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
    
    // استخدام concat لتجنب مشكلة $
    final prompt = 'zion@os:~$ ';
    _addLine('$prompt${command.trim()}');
    _inputController.clear();
    setState(() => _isExecuting = true);

    await Future.delayed(const Duration(milliseconds: 500));
    
    final cmd = command.trim().toLowerCase();
    
    if (cmd == 'help') {
      _addLine('');
      _addLine('Available commands:');
      _addLine('  help     - Show this help');
      _addLine('  clear    - Clear screen');
      _addLine('  exit     - Close terminal');
      _addLine('  scan     - Scan network');
      _addLine('  attack   - Execute attack');
      _addLine('  status   - Show system status');
      _addLine('');
    } else if (cmd == 'clear') {
      setState(() => _lines.clear());
      _addLine('Screen cleared');
    } else if (cmd == 'exit') {
      Navigator.pop(context);
    } else if (cmd == 'scan') {
      _addLine('Scanning network...');
      await Future.delayed(const Duration(seconds: 2));
      _addLine('Found: 3 devices online');
    } else if (cmd == 'attack') {
      _addLine('Executing attack...');
      await Future.delayed(const Duration(seconds: 2));
      _addLine('Attack completed successfully!');
    } else if (cmd == 'status') {
      _addLine('');
      _addLine('System Status:');
      _addLine('  Version: Zion OS v3.0');
      _addLine('  Tools: 1000+');
      _addLine('  Status: Ready');
      _addLine('');
    } else {
      _addLine('Command not found: $cmd. Type "help" for available commands.');
    }
    
    setState(() => _isExecuting = false);
    _addLine('');
  }

  @override
  Widget build(BuildContext context) {
    final promptText = 'zion@os:~$ ';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade900, Colors.black]),
              border: Border(bottom: BorderSide(color: Colors.green.shade700)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text('COSMIC TERMINAL', style: TextStyle(color: Colors.green.shade400, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_isExecuting) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _lines.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SelectableText(_lines[index], style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(top: BorderSide(color: Colors.green.shade700)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(promptText, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter command...', hintStyle: TextStyle(color: Colors.grey)),
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
