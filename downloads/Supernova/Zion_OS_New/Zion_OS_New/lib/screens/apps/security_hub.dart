import 'package:flutter/material.dart';
import '../../core/services/root_service.dart';

class SecurityHubApp extends StatefulWidget {
  const SecurityHubApp({super.key});

  @override
  State<SecurityHubApp> createState() => _SecurityHubAppState();
}

class _SecurityHubAppState extends State<SecurityHubApp> {
  final RootService _rootService = RootService();
  Map<String, dynamic> _rootStatus = {};
  bool _isLoadingRoot = false;

  @override
  void initState() {
    super.initState();
    _loadRootStatus();
  }

  Future<void> _loadRootStatus() async {
    setState(() => _isLoadingRoot = true);
    _rootStatus = await _rootService.getRootStatus();
    setState(() => _isLoadingRoot = false);
  }

  Future<void> _requestRoot() async {
    setState(() => _isLoadingRoot = true);
    final granted = await _rootService.requestRootAccess();
    await _loadRootStatus();
    setState(() => _isLoadingRoot = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted ? '✅ Root access granted' : '❌ Root access denied'),
          backgroundColor: granted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Security Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader(Icons.security, 'Root Access'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(_rootStatus['available'] == true ? Icons.check_circle : Icons.error, color: _rootStatus['available'] == true ? Colors.green : Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_rootStatus['message'] ?? 'Checking...', style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_rootStatus['available'] == true && _rootStatus['granted'] == false)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _requestRoot,
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Grant Root Access'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                      ),
                    ),
                  if (_rootStatus['granted'] == true)
                    const Text('✅ Root privileges active', style: TextStyle(color: Colors.green)),
                  if (_rootStatus['available'] == false)
                    const Text('Device is not rooted', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(Icons.privacy_tip, 'Privacy'),
            _buildInfoTile('App Permissions', 'Manage app permissions', () {}),
            _buildInfoTile('Data Encryption', 'AES-256 active', () {}),
            _buildInfoTile('Secure Delete', 'Permanently delete files', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF00BCD4)),
        onTap: onTap,
      ),
    );
  }
}
