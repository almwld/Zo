import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/unified_core_service.dart';
import '../../core/services/kali_loader_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _targetController = TextEditingController(text: '192.168.1.1');
  final _cmdController = TextEditingController();
  String _output = 'جاهز. اكتب "help" للمساعدة.\n';
  bool _loading = false;
  bool _kaliReady = false;
  int _toolCount = 0;

  @override
  void initState() {
    super.initState();
    _checkKaliStatus();
  }

  Future<void> _checkKaliStatus() async {
    final status = await KaliLoaderService.getStatus();
    setState(() {
      _kaliReady = status['installed'] == true;
      _toolCount = status['tools_available'] ?? 0;
    });
  }

  Future<void> _execute(String command) async {
    setState(() => _loading = true);
    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: _targetController.text);
    setState(() {
      _output = result;
      _loading = false;
    });
    if (command == 'kali_install') _checkKaliStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Project Zion', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        actions: [
          _statusDot(_kaliReady, 'Kali'),
          const SizedBox(width: 8),
          _statusDot(true, 'Net'),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الحالة
            Row(
              children: [
                _infoCard('Kali', _kaliReady ? '$_toolCount أداة' : 'غير مثبت', _kaliReady ? Colors.green : Colors.red),
                const SizedBox(width: 12),
                _infoCard('الشبكة', 'متصل', Colors.green),
                const SizedBox(width: 12),
                _infoCard('الهدف', _targetController.text, Colors.cyan),
              ],
            ),
            const SizedBox(height: 16),
            // حقل الهدف
            TextField(
              controller: _targetController,
              style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
              decoration: const InputDecoration(
                labelText: 'عنوان الهدف (IP / URL)',
                prefixIcon: Icon(Icons.language, color: Color(0xFF00FF41)),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(color: Color(0xFF00FF41)),
            const SizedBox(height: 8),
            // منطقة الإخراج
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E0A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1A3A1A)),
                ),
                child: SingleChildScrollView(
                  child: Text(_output, style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12)),
                ),
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
              _btn('تثبيت', 'kali_install', Colors.orange),
              _btn('Nmap', 'nmap', Colors.blue),
              _btn('SQLmap', 'sqlmap', Colors.purple),
              _btn('MSF', 'msfconsole', Colors.red),
              _btn('Hydra', 'hydra', Colors.teal),
              _btn('Shell', 'kali_shell', Colors.grey),
              _btn('حالة', 'kali_status', Colors.green),
              _btn('مساعدة', 'help', Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusDot(bool active, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 10, height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Colors.green : Colors.red),
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF0A0E0A), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Cairo')),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace')),
        ]),
      ),
    );
  }

  Widget _btn(String label, String command, Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      onPressed: () => _execute(command),
      child: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12)),
    ),
  );
}
