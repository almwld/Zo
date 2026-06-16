import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrivacyHubApp extends StatefulWidget {
  const PrivacyHubApp({super.key});

  @override
  State<PrivacyHubApp> createState() => _PrivacyHubAppState();
}

class _PrivacyHubAppState extends State<PrivacyHubApp> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Permissions', 'Data', 'Tracking', 'Tools'];
  
  List<Map<String, dynamic>> _permissions = [];
  List<Map<String, dynamic>> _sensitiveData = [];
  List<Map<String, dynamic>> _trackers = [];
  bool _vpnEnabled = false;
  bool _adBlockEnabled = true;
  bool _doNotTrack = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _permissions = [
      {'name': 'Camera', 'icon': Icons.camera, 'status': 'Granted', 'color': 0xFF4CAF50},
      {'name': 'Microphone', 'icon': Icons.mic, 'status': 'Granted', 'color': 0xFF4CAF50},
      {'name': 'Location', 'icon': Icons.location_on, 'status': 'Granted', 'color': 0xFF4CAF50},
      {'name': 'Storage', 'icon': Icons.storage, 'status': 'Granted', 'color': 0xFF4CAF50},
      {'name': 'Contacts', 'icon': Icons.contacts, 'status': 'Denied', 'color': 0xFFF44336},
      {'name': 'SMS', 'icon': Icons.sms, 'status': 'Denied', 'color': 0xFFF44336},
    ];
    _sensitiveData = [
      {'type': 'Passwords', 'count': 12, 'risk': 'High', 'color': 0xFFF44336},
      {'type': 'Credit Cards', 'count': 3, 'risk': 'Critical', 'color': 0xFFD32F2F},
      {'type': 'Personal Info', 'count': 25, 'risk': 'Medium', 'color': 0xFFFF9800},
      {'type': 'Location History', 'count': 156, 'risk': 'Medium', 'color': 0xFFFF9800},
      {'type': 'Browser History', 'count': 845, 'risk': 'Low', 'color': 0xFF4CAF50},
    ];
    _trackers = [
      {'name': 'Google Analytics', 'blocked': true, 'type': 'Analytics'},
      {'name': 'Facebook Pixel', 'blocked': true, 'type': 'Social'},
      {'name': 'DoubleClick', 'blocked': true, 'type': 'Advertising'},
      {'name': 'Cloudflare', 'blocked': false, 'type': 'CDN'},
    ];
  }

  void _togglePermission(int index) {
    setState(() {
      _permissions[index]['status'] = _permissions[index]['status'] == 'Granted' ? 'Denied' : 'Granted';
    });
  }

  void _toggleTracker(int index) {
    setState(() {
      _trackers[index]['blocked'] = !_trackers[index]['blocked'];
    });
  }

  void _clearBrowsingData() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Clear Browsing Data', style: TextStyle(color: Color(0xFF00BCD4))),
      content: const Text('Clear history, cookies, and cache?', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data cleared'), backgroundColor: Color(0xFF00BCD4))); }, child: const Text('Clear', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Privacy Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(onTap: (i) => setState(() => _selectedTab = i), labelColor: const Color(0xFF00BCD4), unselectedLabelColor: Colors.white54, indicatorColor: const Color(0xFF00BCD4), tabs: _tabs.map((tab) => Tab(text: tab)).toList()),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [_buildPermissionsTab(), _buildDataTab(), _buildTrackingTab(), _buildToolsTab()],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _permissions.length,
      itemBuilder: (ctx, i) {
        final perm = _permissions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(perm['color']).withOpacity(0.3))),
          child: Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: Color(perm['color']).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(perm['icon'], color: Color(perm['color']), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(perm['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(perm['status'], style: TextStyle(color: Color(perm['color']), fontSize: 11))])),
            Switch(value: perm['status'] == 'Granted', onChanged: (_) => _togglePermission(i), activeColor: Colors.green),
          ]),
        );
      },
    );
  }

  Widget _buildDataTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensitiveData.length,
      itemBuilder: (ctx, i) {
        final data = _sensitiveData[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(data['color']).withOpacity(0.3))),
          child: Row(children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(color: Color(data['color']).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(_getDataTypeIcon(data['type']), color: Color(data['color']), size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['type'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('${data['count']} items', style: const TextStyle(color: Colors.white54, fontSize: 11))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(data['color']).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(data['risk'], style: TextStyle(color: Color(data['color']), fontSize: 10))),
          ]),
        );
      },
    );
  }

  Widget _buildTrackingTab() {
    return Column(
      children: [
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            SwitchListTile(title: const Text('VPN Protection', style: TextStyle(color: Colors.white)), subtitle: const Text('Secure your connection', style: TextStyle(color: Colors.white54)), value: _vpnEnabled, onChanged: (v) => setState(() => _vpnEnabled = v), activeColor: const Color(0xFF00BCD4)),
            SwitchListTile(title: const Text('Ad Blocking', style: TextStyle(color: Colors.white)), subtitle: const Text('Block advertisements', style: TextStyle(color: Colors.white54)), value: _adBlockEnabled, onChanged: (v) => setState(() => _adBlockEnabled = v), activeColor: const Color(0xFF00BCD4)),
            SwitchListTile(title: const Text('Do Not Track', style: TextStyle(color: Colors.white)), subtitle: const Text('Request websites not to track you', style: TextStyle(color: Colors.white54)), value: _doNotTrack, onChanged: (v) => setState(() => _doNotTrack = v), activeColor: const Color(0xFF00BCD4)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _trackers.length,
            itemBuilder: (ctx, i) {
              final t = _trackers[i];
              return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(t['type'], style: const TextStyle(color: Colors.white54, fontSize: 11))])), Switch(value: t['blocked'], onChanged: (_) => _toggleTracker(i), activeColor: const Color(0xFF00BCD4))]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolCard('Clear Browsing Data', Icons.delete_sweep, 'Delete history, cookies, cache', _clearBrowsingData),
        _buildToolCard('Privacy Scan', Icons.security, 'Scan for privacy risks', () {}),
        _buildToolCard('Data Breach Check', Icons.warning, 'Check if your data was leaked', () {}),
        _buildToolCard('Secure Delete', Icons.delete_forever, 'Permanently delete files', () {}),
      ],
    );
  }

  Widget _buildToolCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF00BCD4), size: 24)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11))])), const Icon(Icons.chevron_right, color: Color(0xFF00BCD4))]),
      ),
    );
  }

  IconData _getDataTypeIcon(String type) {
    switch (type) {
      case 'Passwords': return Icons.vpn_key;
      case 'Credit Cards': return Icons.credit_card;
      case 'Personal Info': return Icons.person;
      case 'Location History': return Icons.location_on;
      case 'Browser History': return Icons.history;
      default: return Icons.data_usage;
    }
  }
}
