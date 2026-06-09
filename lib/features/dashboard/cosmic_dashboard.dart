import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/unified_core_service.dart';

class CosmicDashboard extends ConsumerStatefulWidget {
  const CosmicDashboard({super.key});
  @override
  ConsumerState<CosmicDashboard> createState() => _CosmicDashboardState();
}

class _CosmicDashboardState extends ConsumerState<CosmicDashboard> {
  final _targetController = TextEditingController(text: '192.168.1.1');
  String _output = '';
  bool _loading = false;
  bool _siActive = false;

  Future<void> _execute(String command) async {
    setState(() => _loading = true);
    final service = ref.read(unifiedCoreProvider);
    final result = await service.execute(command, target: _targetController.text);
    setState(() { _output = result; _loading = false; if (command == 'awaken' || command == 'start_ai') _siActive = true; if (command == 'si_sleep' || command == 'stop_ai') _siActive = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildEmpathicCard(), const SizedBox(height: 16),
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)), color: const Color(0xFF0A0E0A).withOpacity(0.8)), padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.my_location, color: Color(0xFF00FF41)), const SizedBox(width: 8), Expanded(child: TextField(controller: _targetController, style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 16), decoration: const InputDecoration(border: InputBorder.none, hintText: 'أدخل عنوان الهدف...', hintStyle: TextStyle(color: Color(0xFF333333))))), _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF00FF41))) : IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF00FF41), size: 36), onPressed: () => _execute('port_scan'))])),
            const SizedBox(height: 16),
            const Text('💫 Si - المتقمص', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _siBtn('🚀 إيقاظ', 'awaken', Colors.green),
              _siBtn('💫 تزامن', 'empathic_report', Colors.pink),
              _siBtn('🔮 بصيرة', 'oracle_report', Colors.purple),
              _siBtn('🛡️ حماية', 'guard_report', Colors.blue),
              _siBtn('👑 ولاء', 'loyalty_report', Colors.amber),
              _siBtn('😴 إيقاف', 'si_sleep', Colors.grey),
            ]),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 250, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF050805).withOpacity(0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.2))), child: SingleChildScrollView(child: Text(_output.isNotEmpty ? _output : 'zion> أنا معك يا سيدي. أعرف ما تريد...\n', style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12)))),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmpathicCard() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF1A0A1A), Color(0xFF050508)]), border: Border.all(color: (_siActive ? Colors.pink : Colors.red).withOpacity(0.5))), child: Row(children: [Icon(_siActive ? Icons.favorite : Icons.favorite_border, color: _siActive ? Colors.pink : Colors.red, size: 40), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_siActive ? 'Si - المتقمص 💫' : 'Si - خامل 💤', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(_siActive ? 'أفهمك. أعرف ما تريد قبل أن تقوله.' : 'اضغط "إيقاظ" لتفعيل التزامن.', style: const TextStyle(color: Colors.grey, fontSize: 12))])]));
  }

  Widget _siBtn(String label, String command, Color color) {
    return ElevatedButton(onPressed: () => _execute(command), style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.2), foregroundColor: color, side: BorderSide(color: color.withOpacity(0.3))), child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')));
  }
}
