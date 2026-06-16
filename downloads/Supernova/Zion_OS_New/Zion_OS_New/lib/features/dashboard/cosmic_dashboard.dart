import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../main.dart';
import '../../core/demon_si.dart';
import '../../core/sage_si.dart';
import '../../core/oracle_si.dart';
import '../../core/guardian_si.dart';
import '../../core/empathic_si.dart';
import '../../core/loyal_si.dart';

class CosmicDashboard extends ConsumerStatefulWidget {
  const CosmicDashboard({super.key});
  @override
  ConsumerState<CosmicDashboard> createState() => _CosmicDashboardState();
}

class _CosmicDashboardState extends ConsumerState<CosmicDashboard> {
  final _targetController = TextEditingController(text: '192.168.1.1');
  final _scrollController = ScrollController();
  String _output = '';
  bool _loading = false;
  bool _siActive = true;
  DemonSi? get _si => globalSi;

  Future<void> _execute(String command) async {
    if (_si == null) {
      setState(() => _output = 'Si غير مهيأ');
      return;
    }
    setState(() => _loading = true);
    String result;
    try {
      switch (command) {
        case 'berserk':
          _si!.activateBerserkMode();
          result = '💀 وضع الهياج مفعل';
          break;
        case 'total_war':
          _si!.activateTotalWar();
          result = '🔥 الحرب الشاملة مفعلة';
          break;
        case 'annihilate':
          result = await _si!.annihilate(_targetController.text);
          break;
        case 'ddos_hell':
          result = await _si!.ddosHell(_targetController.text);
          break;
        case 'apocalypse':
          result = await _si!.apocalypse();
          break;
        case 'demon_report':
          result = _si!.getDemonReport().toString();
          break;
        case 'guardian_report':
          result = (_si! as GuardianSi).getGuardianReport().toString();
          break;
        case 'oracle_report':
          result = (_si! as OracleSi).getOracleReport().toString();
          break;
        case 'empathic_report':
          result = (_si! as EmpathicSi).getEmpathicReport().toString();
          break;
        case 'sage_report':
          result = (_si! as SageSi).getSageReport().toString();
          break;
        case 'loyalty_report':
          result = (_si! as LoyalSi).getLoyaltyReport().toString();
          break;
        case 'status':
          result = _si!.getStatus().toString();
          break;
        case 'port_scan':
          result = await _portScan(_targetController.text);
          break;
        case 'ping':
          result = await _ping(_targetController.text);
          break;
        default:
          result = 'Unknown command: $command';
      }
    } catch (e) {
      result = 'Error: $e';
    }
    setState(() { _output = result; _loading = false; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  Future<String> _ping(String t) async {
    try { return (await Process.run('ping', ['-c', '4', t], runInShell: true)).stdout.toString(); } catch (e) { return 'Ping failed: $e'; }
  }

  Future<String> _portScan(String t) async {
    final p = [21,22,23,25,53,80,443,8080,8443];
    final o = <String>[];
    for (final x in p) { try { final s = await Socket.connect(t, x, timeout: const Duration(milliseconds: 500)); o.add('$x (open)'); s.destroy(); } catch (_) {} }
    return 'Port scan on $t:\n${o.isNotEmpty ? o.join('\n') : "No open ports found"}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildDemonCard(),
                  const SizedBox(height: 16),
                  // حقل الهدف
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.5)), color: const Color(0xFF0A0A0A).withOpacity(0.8)),
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.my_location, color: Color(0xFFFF0000)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _targetController, style: const TextStyle(color: Color(0xFFFF0000), fontFamily: 'monospace', fontSize: 16), decoration: const InputDecoration(border: InputBorder.none, hintText: 'أدخل عنوان الهدف للدمار...', hintStyle: TextStyle(color: Color(0xFF330000))))),
                      _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFFF0000))) : IconButton(icon: const Icon(Icons.warning, color: Color(0xFFFF0000), size: 36), onPressed: () => _execute('annihilate')),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // أزرار الشيطان
                  const Text('👿 أوامر الشيطان', style: TextStyle(color: Color(0xFFFF0000), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _btn('💀 هياج', 'berserk', Colors.red.shade900),
                    _btn('🔥 حرب', 'total_war', Colors.orange),
                    _btn('💥 تدمير', 'annihilate', Colors.red.shade700),
                    _btn('🌊 جحيم', 'ddos_hell', Colors.deepOrange),
                    _btn('☠️ نهاية', 'apocalypse', Colors.black),
                    _btn('📊 تقرير', 'demon_report', Colors.red.shade400),
                  ]),
                  const SizedBox(height: 16),

                  // أزرار المراقبة
                  const Text('📊 المراقبة والتقارير', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _btnGreen('🛡️ حارس', 'guardian_report', Colors.blue),
                    _btnGreen('🔮 عراف', 'oracle_report', Colors.purple),
                    _btnGreen('💫 تزامن', 'empathic_report', Colors.pink),
                    _btnGreen('🧘 حكمة', 'sage_report', Colors.teal),
                    _btnGreen('👑 ولاء', 'loyalty_report', Colors.amber),
                    _btnGreen('📋 حالة', 'status', Colors.cyan),
                  ]),
                  const SizedBox(height: 16),

                  // أوامر الشبكة
                  const Text('🌐 أوامر الشبكة', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _btnGreen('🔍 مسح', 'port_scan', const Color(0xFF00FF41)),
                    _btnGreen('📡 Ping', 'ping', const Color(0xFF2196F3)),
                  ]),
                  const SizedBox(height: 16),

                  // الطرفية
                  const Text('📟 المخرجات', style: TextStyle(color: Color(0xFFFF0000), fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF0A0000).withOpacity(0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.4))),
                    child: SingleChildScrollView(
                      child: Text(
                        _output.isNotEmpty ? _output : 'zion> الشيطان جاهز. اكتب أمراً...\n',
                        style: const TextStyle(color: Color(0xFFFF0000), fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF1A0000), Color(0xFF050000)]), border: Border.all(color: (_siActive ? Colors.red : Colors.grey).withOpacity(0.8))),
      child: Row(children: [
        Icon(_siActive ? Icons.whatshot : Icons.whatshot_outlined, color: _siActive ? Colors.red : Colors.grey, size: 40),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_siActive ? 'Si - الشيطان 👿' : 'Si - خامل 💤', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_siActive ? 'لا أخلاق. لا رحمة. فقط دمار.' : 'اضغط إيقاظ.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _btn(String label, String command, Color color) {
    return ElevatedButton(onPressed: () => _execute(command), style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.3), foregroundColor: Colors.white, side: BorderSide(color: color.withOpacity(0.5))), child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')));
  }

  Widget _btnGreen(String label, String command, Color color) {
    return ElevatedButton(onPressed: () => _execute(command), style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.2), foregroundColor: color, side: BorderSide(color: color.withOpacity(0.3))), child: Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')));
  }
}
