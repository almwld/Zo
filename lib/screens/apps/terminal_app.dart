import 'package:flutter/material.dart';
import 'dart:io';

class TerminalApp extends StatefulWidget {
  const TerminalApp({super.key});

  @override
  State<TerminalApp> createState() => _TerminalAppState();
}

class _TerminalAppState extends State<TerminalApp> {
  final TextEditingController _commandController = TextEditingController();
  final List<String> _output = [];
  final ScrollController _scrollController = ScrollController();

  void _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;
    
    setState(() {
      _output.add("\$ $command");
      _commandController.clear();
    });
    
    try {
      final result = await Process.run('sh', ['-c', command], runInShell: true);
      setState(() {
        if (result.stdout.toString().isNotEmpty) {
          _output.add(result.stdout.toString().trim());
        }
        if (result.stderr.toString().isNotEmpty) {
          _output.add("[ERROR] ${result.stderr.toString().trim()}");
        }
      });
    } catch (e) {
      setState(() {
        _output.add("[ERROR] $e");
      });
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Terminal', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _output.length,
                itemBuilder: (context, index) {
                  final line = _output[index];
                  final isCommand = line.startsWith('\$');
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: isCommand ? const Color(0xFF00FF41) : Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text("$", style: TextStyle(color: Color(0xFF00FF41), fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'اكتب الأمر...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _executeCommand(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00FF41)),
                  onPressed: _executeCommand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
