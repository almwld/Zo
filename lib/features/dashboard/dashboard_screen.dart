import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/unified_core_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _targetController = TextEditingController(text: '127.0.0.1');
  String _output = 'Project Zion Ready.\nType "help" for commands.\n';
  bool _loading = false;
  bool _aiActive = false;

  Future<void> _execute(String command) async {
    setState(() => _loading = true);
    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: _targetController.text);
    setState(() { _output = result; _loading = false; });
    if (command == 'start_ai') setState(() => _aiActive = true);
    if (command == 'stop_ai') setState(() => _aiActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Project Zion', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.black,
        actions: [
          if (_aiActive)
            const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.circle, color: Colors.green, size: 12)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _targetController,
              style: const TextStyle(color: Colors.green, fontFamily: 'monospace'),
              decoration: const InputDecoration(labelText: 'Target', labelStyle: TextStyle(color: Colors.green), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(color: Colors.green),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output, style: const TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _btn('AI On', 'start_ai', Colors.green),
              _btn('AI Off', 'stop_ai', Colors.red),
              _btn('Status', 'ai_status', Colors.blue),
              _btn('Full', 'full_mission', Colors.orange),
              _btn('Stealth', 'stealth_on', Colors.purple),
              _btn('OSINT', 'osint', Colors.cyan),
              _btn('Help', 'help', Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, String command, Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.8)),
      onPressed: () => _execute(command),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    ),
  );
}
