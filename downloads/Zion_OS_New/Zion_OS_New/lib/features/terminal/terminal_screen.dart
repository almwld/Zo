import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/unified_core_service.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final _commandController = TextEditingController();
  final List<String> _history = ['Project Zion Terminal v2.0', 'اكتب "help" للمساعدة', ''];
  final _scrollController = ScrollController();

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    setState(() {
      _history.add('> $command');
      _commandController.clear();
    });

    if (command == 'clear') {
      setState(() => _history.clear());
      return;
    }

    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: '192.168.1.1');

    setState(() {
      _history.add(result);
      _history.add('');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطرفية'), actions: [
        IconButton(icon: const Icon(Icons.clear_all), onPressed: () => setState(() => _history.clear())),
      ]),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0A0A0A),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _history.length,
                itemBuilder: (_, i) => Text(
                  _history[i],
                  style: TextStyle(
                    color: _history[i].startsWith('>') ? const Color(0xFF00FF41) : const Color(0xFFAAAAAA),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF111811),
            child: Row(
              children: [
                const Text('zion> ', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 14)),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 14),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'أدخل الأمر...', hintStyle: TextStyle(color: Color(0xFF333333))),
                    onSubmitted: (_) => _executeCommand(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF00FF41)), onPressed: _executeCommand),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
