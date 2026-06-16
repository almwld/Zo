import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/theme_manager.dart';

class SecurityCenter extends StatefulWidget {
  const SecurityCenter({super.key});

  @override
  State<SecurityCenter> createState() => _SecurityCenterState();
}

class _SecurityCenterState extends State<SecurityCenter> {
  final ThemeManager _themeManager = ThemeManager();
  late Timer _securityTimer;
  
  // درجة الأمان
  int _securityScore = 85;
  List<String> _securityIssues = [];
  List<String> _securityRecommendations = [];
  
  // الحماية
  bool _firewallEnabled = true;
  bool _realTimeProtection = true;
  bool _stealthMode = false;
  bool _appSandbox = true;
  bool _networkEncryption = true;
  bool _antiMalware = true;
  
  // التهديدات
  List<Map<String, dynamic>> _recentThreats = [];
  int _totalThreatsBlocked = 234;
  int _criticalThreats = 3;
  
  // كلمات المرور
  bool _strongPassword = true;
  int _passwordStrength = 85;
  List<String> _savedPasswords = [];
  
  // الأذونات
  List<Map<String, dynamic>> _appPermissions = [];

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
    _loadThreats();
    _loadPermissions();
    _startSecurityMonitoring();
  }

  void _loadSecurityData() {
    _securityIssues = [
      '⚠️ Debug mode is enabled',
      '⚠️ USB debugging is active',
      '✅ Biometric authentication is set up',
    ];
    
    _securityRecommendations = [
      'Enable stealth mode for better privacy',
      'Run security scan weekly',
      'Update security patches',
    ];
    
    _savedPasswords = [
      '******** (LastPass)',
      '******** (Google)',
      '******** (GitHub)',
    ];
  }

  void _loadThreats() {
    _recentThreats = [
      {'name': 'Port Scan Detected', 'source': '192.168.1.105', 'severity': 'Medium', 'time': '5 min ago', 'blocked': true},
      {'name': 'Brute Force Attempt', 'source': '10.0.0.25', 'severity': 'High', 'time': '12 min ago', 'blocked': true},
      {'name': 'Malware Download', 'source': 'unknown', 'severity': 'Critical', 'time': '1 hour ago', 'blocked': true},
      {'name': 'Suspicious Connection', 'source': '45.33.22.11', 'severity': 'Low', 'time': '2 hours ago', 'blocked': false},
    ];
  }

  void _loadPermissions() {
    _appPermissions = [
      {'app': 'Zion OS', 'permissions': 12, 'risk': 'Low', 'color': Colors.green},
      {'app': 'Network Scanner', 'permissions': 8, 'risk': 'Medium', 'color': Colors.orange},
      {'app': 'File Manager', 'permissions': 6, 'risk': 'Low', 'color': Colors.green},
      {'app': 'Web Browser', 'permissions': 10, 'risk': 'Medium', 'color': Colors.orange},
    ];
  }

  void _startSecurityMonitoring() {
    _securityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final random = Random();
      if (random.nextDouble() > 0.8) {
        _addRandomThreat();
      }
      if (mounted) setState(() {});
    });
  }

  void _addRandomThreat() {
    final threats = [
      {'name': 'Suspicious Activity', 'source': 'Unknown', 'severity': 'Medium'},
      {'name': 'Port Scan', 'source': '192.168.1.${Random().nextInt(254)}', 'severity': 'Low'},
      {'name': 'Brute Force', 'source': '10.0.0.${Random().nextInt(254)}', 'severity': 'High'},
    ];
    final threat = threats[Random().nextInt(threats.length)];
    
    setState(() {
      _recentThreats.insert(0, {
        ...threat,
        'time': 'Just now',
        'blocked': Random().nextDouble() > 0.2,
      });
      if (_recentThreats.length > 10) _recentThreats.removeLast();
      _totalThreatsBlocked++;
    });
  }

  void _runSecurityScan() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Security Scan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for threats...', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.grey.shade900,
      ),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      setState(() {
        _securityScore = 92;
        _securityIssues = [
          '✅ Debug mode is disabled',
          '✅ USB debugging is disabled',
          '✅ Biometric authentication is set up',
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security scan completed! Score: 92%')),
      );
    });
  }

  void _toggleStealthMode() {
    setState(() => _stealthMode = !_stealthMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_stealthMode ? 'Stealth Mode ON' : 'Stealth Mode OFF')),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        backgroundColor: Colors.grey.shade900,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Change', style: TextStyle(color: Colors.green))),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Medium': return Colors.yellow;
      default: return Colors.blue;
    }
  }

  @override
  void dispose() {
    _securityTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Security Center'),
        backgroundColor: theme.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSecurityScoreCard()),
          SliverToBoxAdapter(child: _buildProtectionToggles()),
          SliverToBoxAdapter(child: _buildRecentThreats()),
          SliverToBoxAdapter(child: _buildSecurityIssues()),
          SliverToBoxAdapter(child: _buildPermissionsCard()),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade900, Colors.orange.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Security Score', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _securityScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.green,
                ),
              ),
              Text('$_securityScore%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _runSecurityScan,
                  icon: const Icon(Icons.security),
                  label: const Text('SCAN'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('HISTORY'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionToggles() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Protection', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(),
          SwitchListTile(
            title: const Text('Firewall', style: TextStyle(color: Colors.white)),
            value: _firewallEnabled,
            onChanged: (v) => setState(() => _firewallEnabled = v),
            secondary: const Icon(Icons.firewall),
          ),
          SwitchListTile(
            title: const Text('Real-time Protection', style: TextStyle(color: Colors.white)),
            value: _realTimeProtection,
            onChanged: (v) => setState(() => _realTimeProtection = v),
            secondary: const Icon(Icons.timer),
          ),
          SwitchListTile(
            title: const Text('Stealth Mode', style: TextStyle(color: Colors.white)),
            value: _stealthMode,
            onChanged: (_) => _toggleStealthMode(),
            secondary: const Icon(Icons.visibility_off),
          ),
          SwitchListTile(
            title: const Text('App Sandbox', style: TextStyle(color: Colors.white)),
            value: _appSandbox,
            onChanged: (v) => setState(() => _appSandbox = v),
            secondary: const Icon(Icons.sandbox),
          ),
          SwitchListTile(
            title: const Text('Network Encryption', style: TextStyle(color: Colors.white)),
            value: _networkEncryption,
            onChanged: (v) => setState(() => _networkEncryption = v),
            secondary: const Icon(Icons.lock),
          ),
          SwitchListTile(
            title: const Text('Anti-Malware', style: TextStyle(color: Colors.white)),
            value: _antiMalware,
            onChanged: (v) => setState(() => _antiMalware = v),
            secondary: const Icon(Icons.bug_report),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentThreats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent Threats', style: TextStyle(color: Colors.white, fontSize: 18)),
              const Spacer(),
              Text('Blocked: $_totalThreatsBlocked', style: const TextStyle(color: Colors.green)),
            ],
          ),
          const Divider(),
          ..._recentThreats.map((threat) => ListTile(
            dense: true,
            leading: Icon(
              threat['blocked'] ? Icons.check_circle : Icons.warning,
              color: threat['blocked'] ? Colors.green : Colors.orange,
            ),
            title: Text(threat['name'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('Source: ${threat['source']} • ${threat['time']}', style: const TextStyle(color: Colors.grey)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getSeverityColor(threat['severity']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(threat['severity'], style: TextStyle(color: _getSeverityColor(threat['severity']))),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSecurityIssues() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Issues', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(),
          ..._securityIssues.map((issue) => ListTile(
            dense: true,
            leading: Icon(
              issue.contains('✅') ? Icons.check_circle : Icons.warning,
              color: issue.contains('✅') ? Colors.green : Colors.orange,
            ),
            title: Text(issue, style: const TextStyle(color: Colors.white)),
          )),
          const SizedBox(height: 8),
          const Text('Recommendations', style: TextStyle(color: Colors.white, fontSize: 16)),
          ..._securityRecommendations.map((rec) => ListTile(
            dense: true,
            leading: const Icon(Icons.lightbulb, color: Colors.yellow),
            title: Text(rec, style: const TextStyle(color: Colors.white70)),
          )),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App Permissions', style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(),
          ..._appPermissions.map((app) => ListTile(
            dense: true,
            leading: Icon(Icons.apps, color: app['color']),
            title: Text(app['app'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('${app['permissions']} permissions', style: const TextStyle(color: Colors.grey)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: app['risk'] == 'Low' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(app['risk'], style: TextStyle(color: app['risk'] == 'Low' ? Colors.green : Colors.orange)),
            ),
          )),
        ],
      ),
    );
  }
}
