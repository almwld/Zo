import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'apps/settings_app.dart';

class ZionDesktop extends StatefulWidget {
  const ZionDesktop({super.key});

  @override
  State<ZionDesktop> createState() => _ZionDesktopState();
}

class _ZionDesktopState extends State<ZionDesktop> {
  String _currentTime = "";
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {"name": "attack", "icon": Icons.flash_on},
    {"name": "defense", "icon": Icons.shield},
    {"name": "analysis", "icon": Icons.analytics},
    {"name": "tools", "icon": Icons.build},
  ];

  final List<Map<String, dynamic>> _apps = [
    {"name": "settings", "icon": Icons.settings, "category": "tools", "screen": const SettingsApp()},
    {"name": "network_scanner", "icon": Icons.network_wifi, "category": "tools", "screen": const NetworkScannerApp()},
    {"name": "wifi_scanner", "icon": Icons.wifi, "category": "tools", "screen": const WiFiScannerApp()},
    {"name": "file_manager", "icon": Icons.folder, "category": "tools", "screen": const FileManagerApp()},
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
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        });
        _updateTime();
      }
    });
  }

  void _openApp(Map<String, dynamic> app) {
    if (app['screen'] != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => app['screen']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final filteredApps = _apps.where((app) => app['category'] == _categories[_selectedIndex]['name']).toList();

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[50],
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              border: Border(bottom: BorderSide(color: theme.primaryColor.withOpacity(0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ZION OS", style: theme.getThemeData().textTheme.titleLarge),
                Row(
                  children: [
                    Icon(Icons.battery_full, color: theme.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Icon(Icons.network_wifi, color: theme.primaryColor, size: 16),
                    const SizedBox(width: 12),
                    Text(_currentTime, style: theme.getThemeData().textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(_categories.length, (index) {
                final isSelected = _selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: theme.primaryColor.withOpacity(isSelected ? 0.8 : 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index]['name'].tr(),
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                return GestureDetector(
                  onTap: () => _openApp(app),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: theme.iconSize,
                          height: theme.iconSize,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(app['icon'], color: theme.primaryColor, size: theme.iconSize * 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          app['name'].tr(),
                          style: theme.getThemeData().textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDockIcon(Icons.terminal, "TERM", theme),
                _buildDockIcon(Icons.folder, "FILES", theme),
                _buildDockIcon(Icons.public, "WEB", theme),
                _buildDockIcon(Icons.settings, "SET", theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockIcon(IconData icon, String label, ThemeProvider theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.5)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: theme.isDarkMode ? Colors.white54 : Colors.black54, fontSize: 9)),
      ],
    );
  }
}
