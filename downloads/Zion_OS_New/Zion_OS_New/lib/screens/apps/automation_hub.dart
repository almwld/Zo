import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AutomationHubApp extends StatefulWidget {
  const AutomationHubApp({super.key});

  @override
  State<AutomationHubApp> createState() => _AutomationHubAppState();
}

class _AutomationHubAppState extends State<AutomationHubApp> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Rules', 'Schedules', 'Triggers', 'Logs'];
  
  List<Map<String, dynamic>> _rules = [];
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _triggers = [];
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _rules = [
      {'name': 'Auto Clean', 'condition': 'Storage > 80%', 'action': 'Clean Cache', 'enabled': true, 'color': 0xFF00BCD4},
      {'name': 'Battery Saver', 'condition': 'Battery < 20%', 'action': 'Enable Power Save', 'enabled': true, 'color': 0xFF4CAF50},
      {'name': 'Night Mode', 'condition': 'Time 22:00-06:00', 'action': 'Dark Theme', 'enabled': false, 'color': 0xFF9C27B0},
    ];
    _schedules = [
      {'name': 'Daily Backup', 'time': '02:00', 'days': 'Daily', 'action': 'Backup Data', 'enabled': true},
      {'name': 'Weekly Clean', 'time': 'Sunday 03:00', 'days': 'Weekly', 'action': 'System Clean', 'enabled': true},
    ];
    _triggers = [
      {'name': 'WiFi Connected', 'action': 'Sync Data', 'enabled': true},
      {'name': 'Charging Started', 'action': 'Disable Battery Saver', 'enabled': true},
      {'name': 'Headphones Connected', 'action': 'Open Music', 'enabled': false},
    ];
    _logs = [
      {'action': 'Auto Clean', 'time': '2 hours ago', 'status': 'Success'},
      {'action': 'Daily Backup', 'time': '5 hours ago', 'status': 'Success'},
      {'action': 'Battery Saver', 'time': 'Yesterday', 'status': 'Triggered'},
    ];
  }

  void _toggleRule(int index) {
    setState(() { _rules[index]['enabled'] = !_rules[index]['enabled']; });
  }

  void _toggleSchedule(int index) {
    setState(() { _schedules[index]['enabled'] = !_schedules[index]['enabled']; });
  }

  void _toggleTrigger(int index) {
    setState(() { _triggers[index]['enabled'] = !_triggers[index]['enabled']; });
  }

  void _addRule() {
    final nameCtrl = TextEditingController();
    final condCtrl = TextEditingController();
    final actCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Rule', style: TextStyle(color: Color(0xFF00BCD4))),
      backgroundColor: Colors.black,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Rule Name', labelStyle: TextStyle(color: Color(0xFF00BCD4)))),
        TextField(controller: condCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Condition', labelStyle: TextStyle(color: Color(0xFF00BCD4)))),
        TextField(controller: actCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Action', labelStyle: TextStyle(color: Color(0xFF00BCD4)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: () {
          if (nameCtrl.text.isNotEmpty) {
            setState(() { _rules.add({'name': nameCtrl.text, 'condition': condCtrl.text, 'action': actCtrl.text, 'enabled': true, 'color': 0xFF00BCD4}); });
            Navigator.pop(ctx);
          }
        }, child: const Text('Add', style: TextStyle(color: Color(0xFF00BCD4)))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Automation Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add, color: Color(0xFF00BCD4)), onPressed: _addRule)],
        bottom: TabBar(onTap: (i) => setState(() => _selectedTab = i), labelColor: const Color(0xFF00BCD4), unselectedLabelColor: Colors.white54, indicatorColor: const Color(0xFF00BCD4), tabs: _tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [_buildRulesTab(), _buildSchedulesTab(), _buildTriggersTab(), _buildLogsTab()],
      ),
    );
  }

  Widget _buildRulesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      itemBuilder: (ctx, i) {
        final r = _rules[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(r['color']).withOpacity(0.3))),
          child: Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.rule, color: Color(0xFF00BCD4), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${r['condition']} → ${r['action']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ])),
            Switch(value: r['enabled'], onChanged: (_) => _toggleRule(i), activeColor: const Color(0xFF00BCD4)),
          ]),
        );
      },
    );
  }

  Widget _buildSchedulesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedules.length,
      itemBuilder: (ctx, i) {
        final s = _schedules[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.schedule, color: Color(0xFF00BCD4), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${s['time']} • ${s['days']} → ${s['action']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ])),
            Switch(value: s['enabled'], onChanged: (_) => _toggleSchedule(i), activeColor: const Color(0xFF00BCD4)),
          ]),
        );
      },
    );
  }

  Widget _buildTriggersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _triggers.length,
      itemBuilder: (ctx, i) {
        final t = _triggers[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_active, color: Color(0xFF00BCD4), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(t['action'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ])),
            Switch(value: t['enabled'], onChanged: (_) => _toggleTrigger(i), activeColor: const Color(0xFF00BCD4)),
          ]),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (ctx, i) {
        final l = _logs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(l['status'] == 'Success' ? Icons.check_circle : Icons.warning, color: l['status'] == 'Success' ? Colors.green : Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(l['action'], style: const TextStyle(color: Colors.white))),
            Text(l['time'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        );
      },
    );
  }
}
