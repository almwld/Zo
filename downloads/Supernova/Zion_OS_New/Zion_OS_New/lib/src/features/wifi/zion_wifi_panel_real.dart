import 'package:flutter/material.dart';
import '../../core/arsenal/zion_wifi_real.dart';

class ZionWiFiRealPanel extends StatefulWidget {
  const ZionWiFiRealPanel({super.key});

  @override
  State<ZionWiFiRealPanel> createState() => _ZionWiFiRealPanelState();
}

class _ZionWiFiRealPanelState extends State<ZionWiFiRealPanel> {
  final ZionWiFiReal _wifi = ZionWiFiReal();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _routerIpController = TextEditingController();
  
  bool _isAttacking = false;
  String _attackLog = '';
  FullAttackResult? _lastResult;
  
  Future<void> _startAttack() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter BSSID (e.g., 00:11:22:33:44:55)')),
      );
      return;
    }
    
    setState(() {
      _isAttacking = true;
      _attackLog = '🎯 Starting full attack on $target...\n';
      _lastResult = null;
    });
    
    final routerIp = _routerIpController.text.trim().isNotEmpty 
        ? _routerIpController.text.trim() 
        : null;
    
    final result = await _wifi.fullAttack(target, routerIp: routerIp);
    
    setState(() {
      _lastResult = result;
      _attackLog += '\n';
      _attackLog += '═══════════════════════════════════════\n';
      _attackLog += result.success 
          ? '✅ ATTACK SUCCESSFUL!\n'
          : '❌ ATTACK FAILED!\n';
      _attackLog += '═══════════════════════════════════════\n';
      _attackLog += '🔑 Password: ${result.password ?? "Not found"}\n';
      _attackLog += '📡 Method: ${result.method}\n';
      _attackLog += '⏱️ Duration: ${result.duration.inSeconds} seconds\n';
      
      if (result.steps.containsKey('wps')) {
        final wps = result.steps['wps'] as WPSHackResult;
        _attackLog += '\n📊 WPS Attack: ${wps.attempts} attempts\n';
      }
      if (result.steps.containsKey('router')) {
        final router = result.steps['router'] as RouterHackResult;
        _attackLog += '\n🏠 Router Attack: ${router.attempts} attempts\n';
      }
      
      _isAttacking = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ZionWiFi - Real Attack Platform'),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Target input
            TextField(
              controller: _targetController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target BSSID (e.g., 00:11:22:33:44:55)',
                labelStyle: TextStyle(color: Colors.deepPurple),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
              ),
            ),
            const SizedBox(height: 12),
            
            // Router IP (optional)
            TextField(
              controller: _routerIpController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Router IP (optional, e.g., 192.168.1.1)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Attack button
            ElevatedButton(
              onPressed: _isAttacking ? null : _startAttack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                _isAttacking ? 'ATTACKING...' : 'START FULL ATTACK',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            
            // Attack log
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _attackLog,
                    style: const TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // إضافة أزرار للاستراتيجيات الجديدة
  
  Widget _buildStrategyButtons() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StrategyButton(
              label: '🔑 WPS PIN',
              color: Colors.blue,
              onTap: () => _runSingleAttack('wps'),
            ),
            _StrategyButton(
              label: '🏠 Router Default',
              color: Colors.green,
              onTap: () => _runSingleAttack('router'),
            ),
            _StrategyButton(
              label: '🎭 Evil Twin',
              color: Colors.purple,
              onTap: () => _runSingleAttack('eviltwin'),
            ),
            _StrategyButton(
              label: '💣 CVE Exploits',
              color: Colors.red,
              onTap: () => _runSingleAttack('exploits'),
            ),
            _StrategyButton(
              label: '🧠 AI Guesser',
              color: Colors.orange,
              onTap: () => _runSingleAttack('ai'),
            ),
            _StrategyButton(
              label: '👤 Guest Network',
              color: Colors.teal,
              onTap: () => _runSingleAttack('guest'),
            ),
            _StrategyButton(
              label: '🔌 UPnP',
              color: Colors.indigo,
              onTap: () => _runSingleAttack('upnp'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StrategyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _StrategyButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
