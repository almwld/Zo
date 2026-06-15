import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/wm/window_manager.dart';
import 'zion_browser.dart';
import 'zion_file_manager.dart';
import 'zion_text_editor.dart';
import 'zion_system_monitor.dart';
import 'zion_desktop_icons.dart';

class ZionAppLauncher extends StatelessWidget {
  const ZionAppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E0A),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1A3A1A))),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'ابحث عن تطبيق...',
                hintStyle: TextStyle(color: const Color(0xFF00FF41).withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF41)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A3A1A))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00FF41))),
              ),
            ),
          ),
          // قائمة التطبيقات
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _AppCategory(title: 'أدوات النظام'),
                _AppItem(icon: Icons.terminal, name: 'الطرفية', onTap: () => _openApp(context, 'Terminal', const KaliTerminalWindow(), 600, 400)),
                _AppItem(icon: Icons.folder, name: 'مدير الملفات', onTap: () => _openApp(context, 'Files', const ZionFileManager(), 600, 400)),
                _AppItem(icon: Icons.edit, name: 'محرر النصوص', onTap: () => _openApp(context, 'Editor', const ZionTextEditor(), 600, 450)),
                _AppItem(icon: Icons.language, name: 'متصفح Zion', onTap: () => _openApp(context, 'Browser', const ZionBrowser(), 800, 500)),
                _AppItem(icon: Icons.monitor, name: 'مراقب النظام', onTap: () => _openApp(context, 'Monitor', const ZionSystemMonitor(), 350, 400)),
                const SizedBox(height: 16),
                _AppCategory(title: 'أدوات Kali Linux'),
                _AppItem(icon: Icons.travel_explore, name: 'Nmap', onTap: () => _openApp(context, 'Nmap', const KaliTerminalWindow(initialCommand: 'nmap --help'), 600, 400)),
                _AppItem(icon: Icons.bug_report, name: 'Metasploit', onTap: () => _openApp(context, 'MSF', const KaliTerminalWindow(initialCommand: 'msfconsole -q -x "version; exit"'), 700, 450)),
                _AppItem(icon: Icons.storage, name: 'SQLmap', onTap: () => _openApp(context, 'SQLmap', const KaliTerminalWindow(initialCommand: 'sqlmap --help'), 600, 400)),
                _AppItem(icon: Icons.lock, name: 'Hydra', onTap: () => _openApp(context, 'Hydra', const KaliTerminalWindow(initialCommand: 'hydra -h'), 600, 400)),
                _AppItem(icon: Icons.wifi, name: 'Aircrack-ng', onTap: () => _openApp(context, 'Aircrack', const KaliTerminalWindow(initialCommand: 'aircrack-ng --help'), 600, 400)),
                _AppItem(icon: Icons.search, name: 'Nikto', onTap: () => _openApp(context, 'Nikto', const KaliTerminalWindow(initialCommand: 'nikto -Help'), 600, 400)),
                _AppItem(icon: Icons.folder_open, name: 'Dirb', onTap: () => _openApp(context, 'Dirb', const KaliTerminalWindow(initialCommand: 'dirb'), 500, 400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openApp(BuildContext context, String title, Widget content, double width, double height) {
    context.read<WindowManager>().open(title, content, width: width, height: height);
  }
}

class _AppCategory extends StatelessWidget {
  final String title;
  const _AppCategory({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}

class _AppItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final VoidCallback onTap;
  const _AppItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF41), size: 22),
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: const Color(0xFF00FF41).withOpacity(0.1),
      onTap: onTap,
    );
  }
}
