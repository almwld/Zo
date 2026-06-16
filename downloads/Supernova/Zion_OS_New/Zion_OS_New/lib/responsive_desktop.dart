import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'services/preferences_service.dart';
import 'widgets/battery_popup.dart';
import 'widgets/quick_settings.dart';
import 'screens/settings_screen.dart';

class ResponsiveDesktop extends StatefulWidget {
  const ResponsiveDesktop({super.key});

  @override
  State<ResponsiveDesktop> createState() => _ResponsiveDesktopState();
}

class _ResponsiveDesktopState extends State<ResponsiveDesktop> {
  bool _showBattery = false;
  bool _showQuick = false;

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor: prefs.isDarkMode ? Colors.black : Colors.grey[100],
      body: Stack(
        children: [
          // خلفية مع دعم الصور المخصصة
          Container(
            decoration: BoxDecoration(
              image: prefs.useCustomWallpaper && prefs.wallpaperPath.isNotEmpty
                  ? DecorationImage(image: FileImage(File(prefs.wallpaperPath)), fit: BoxFit.cover)
                  : null,
              color: prefs.isDarkMode ? Colors.black : Colors.grey[100],
            ),
          ),
          Column(
            children: [
              // Top Bar
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: (prefs.isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                  border: Border(bottom: BorderSide(color: prefs.isDarkMode ? Colors.white24 : Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.cyan, Colors.teal]), borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('Z', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)))),
                      const SizedBox(width: 20),
                      Text('Zion OS', style: TextStyle(fontSize: 18 * prefs.fontScale, fontWeight: FontWeight.bold, color: prefs.isDarkMode ? Colors.white : Colors.black)),
                    ]),
                    Row(children: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.wifi, color: prefs.isDarkMode ? Colors.white70 : Colors.black54)),
                      GestureDetector(
                        onTap: () => setState(() { _showBattery = !_showBattery; _showQuick = false; }),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Row(children: [Icon(Icons.battery_full, color: prefs.isDarkMode ? Colors.white70 : Colors.black54), const SizedBox(width: 5), Text('85%', style: TextStyle(fontSize: 12 * prefs.fontScale))])),
                      ),
                      GestureDetector(
                        onTap: () => setState(() { _showQuick = !_showQuick; _showBattery = false; }),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(DateFormat('hh:mm a').format(DateTime.now()), style: TextStyle(fontSize: 12 * prefs.fontScale, color: prefs.isDarkMode ? Colors.white : Colors.black))),
                      ),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _buildCategoryButton('categories.attack'.tr(), Colors.red, prefs, Icons.bug_report),
                        const SizedBox(width: 20),
                        _buildCategoryButton('categories.defense'.tr(), Colors.blue, prefs, Icons.shield),
                        const SizedBox(width: 20),
                        _buildCategoryButton('categories.analysis'.tr(), Colors.green, prefs, Icons.analytics),
                        const SizedBox(width: 20),
                        _buildCategoryButton('categories.tools'.tr(), Colors.orange, prefs, Icons.build),
                      ])),
                      const SizedBox(height: 40),
                      Text('desktop.welcome'.tr(), style: TextStyle(fontSize: 24 * prefs.fontScale, fontWeight: FontWeight.bold, color: prefs.isDarkMode ? Colors.white : Colors.black)),
                      const SizedBox(height: 20),
                      Text('desktop.description'.tr(), style: TextStyle(fontSize: 14 * prefs.fontScale, color: prefs.isDarkMode ? Colors.white70 : Colors.black54)),
                    ],
                  ),
                ),
              ),
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: (prefs.isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                  border: Border(top: BorderSide(color: prefs.isDarkMode ? Colors.white24 : Colors.black12)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildDockIcon(Icons.terminal, 'apps.terminal'.tr(), prefs),
                  const SizedBox(width: 20),
                  _buildDockIcon(Icons.wifi, 'apps.wifi_scanner'.tr(), prefs),
                  const SizedBox(width: 20),
                  _buildDockIcon(Icons.security, 'apps.security_hub'.tr(), prefs),
                  const SizedBox(width: 20),
                  _buildDockIcon(Icons.folder, 'apps.file_manager'.tr(), prefs),
                  const SizedBox(width: 20),
                  _buildDockIcon(Icons.settings, 'apps.settings'.tr(), prefs, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                ]),
              ),
            ],
          ),
          if (_showBattery) Positioned(right: 20, top: 70, child: BatteryPopup(onClose: () => setState(() => _showBattery = false))),
          if (_showQuick) Positioned(right: 20, top: 70, child: QuickSettings(onClose: () => setState(() => _showQuick = false))),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, Color color, PreferencesService prefs, IconData icon) => Container(
    width: 120, height: 120,
    decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: Colors.white), const SizedBox(height: 10), Text(title, style: TextStyle(fontSize: 14 * prefs.fontScale, fontWeight: FontWeight.bold, color: Colors.white))]),
  );

  Widget _buildDockIcon(IconData icon, String label, PreferencesService prefs, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap ?? () {},
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: prefs.isDarkMode ? Colors.white70 : Colors.black54), if (prefs.showAppNames) Text(label, style: TextStyle(fontSize: 10 * prefs.fontScale, color: prefs.isDarkMode ? Colors.white70 : Colors.black54))]),
  );
}
