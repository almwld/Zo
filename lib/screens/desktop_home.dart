import 'package:flutter/material.dart';

class ZionDesktop extends StatefulWidget {
  const ZionDesktop({super.key});

  @override
  State<ZionDesktop> createState() => _ZionDesktopState();
}

class _ZionDesktopState extends State<ZionDesktop> {
  String _currentTime = "";
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {"name": "ATTACK", "icon": Icons.flash_on},
    {"name": "DEFENSE", "icon": Icons.shield},
    {"name": "ANALYSIS", "icon": Icons.analytics},
    {"name": "TOOLS", "icon": Icons.build},
  ];

  final List<Map<String, dynamic>> _apps = [
    {"name": "TERMINAL", "icon": Icons.terminal, "category": "TOOLS"},
    {"name": "CRYPTO", "icon": Icons.lock, "category": "TOOLS"},
    {"name": "WIFI", "icon": Icons.wifi, "category": "ATTACK"},
    {"name": "EXPLOIT", "icon": Icons.bug_report, "category": "ATTACK"},
    {"name": "CRACKER", "icon": Icons.vpn_key, "category": "ATTACK"},
    {"name": "DDOS", "icon": Icons.speed, "category": "ATTACK"},
    {"name": "DATABASE", "icon": Icons.storage, "category": "ATTACK"},
    {"name": "CLOUD", "icon": Icons.cloud, "category": "ATTACK"},
    {"name": "NETWORK", "icon": Icons.network_wifi, "category": "ANALYSIS"},
    {"name": "FORENSICS", "icon": Icons.search, "category": "ANALYSIS"},
    {"name": "STEALTH", "icon": Icons.visibility_off, "category": "DEFENSE"},
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        });
        _updateTime();
      }
    });
  }

  void _openApp(Map<String, dynamic> app) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${app['name']}...'), backgroundColor: const Color(0xFF00BCD4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _apps.where((app) => app['category'] == _categories[_selectedIndex]['name']).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [const Color(0xFF00BCD4).withOpacity(0.05), Colors.black, Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Top Bar
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                border: Border(bottom: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ZION OS 2027', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_currentTime, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 14)),
                ],
              ),
            ),
            
            // Categories
            Container(
              height: 50,
              margin: const EdgeInsets.all(15),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(isSelected ? 0.8 : 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_categories[index]['icon'], color: const Color(0xFF00BCD4), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                color: const Color(0xFF00BCD4),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // App Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return GestureDetector(
                    onTap: () => _openApp(app),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(app['icon'], color: const Color(0xFF00BCD4), size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app['name'],
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Dock
            Container(
              height: 70,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDockIcon(Icons.terminal, 'TERM'),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.network_wifi, 'NET'),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.wifi, 'WIFI'),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.lock, 'LOCK'),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.visibility_off, 'HIDE'),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.vpn_key, 'KEY'),
                  const SizedBox(width: 15),
                  Container(width: 1, height: 30, color: const Color(0xFF00BCD4).withOpacity(0.3)),
                  const SizedBox(width: 15),
                  _buildDockIcon(Icons.apps, 'APPS'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ],
      ),
    );
  }
}
