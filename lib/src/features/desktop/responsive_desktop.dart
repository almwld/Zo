import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/responsive_helper.dart';
import '../settings/main_settings.dart';
import '../wifi/zion_wifi_panel.dart';
import '../si/si_control_panel.dart';
import '../windows/zion_file_manager.dart';
import '../windows/zion_browser.dart';
import '../windows/zion_text_editor.dart';
import '../network/network_analyzer.dart';
import '../system/process_manager.dart';
import '../system/system_monitor.dart';
import '../security/vulnerability_scanner.dart';
import '../reports/report_generator.dart';
import '../packages/package_manager.dart';
import '../logs/log_viewer.dart';
import '../scheduler/task_scheduler.dart';
import '../storage/disk_usage_analyzer.dart';
import '../backup/backup_manager.dart';
import '../exploits/exploit_database.dart';
import '../payloads/payload_generator.dart';
import '../qr/qr_scanner.dart';
import '../../../cosmic_terminal.dart';

class ResponsiveDesktop extends StatefulWidget {
  const ResponsiveDesktop({super.key});

  @override
  State<ResponsiveDesktop> createState() => _ResponsiveDesktopState();
}

class _ResponsiveDesktopState extends State<ResponsiveDesktop> {
  final List<DesktopWindow> _windows = [];
  int _nextWindowId = 1;
  DateTime _currentTime = DateTime.now();
  bool _menuOpen = false;
  int? _draggingWindowId;
  Offset? _dragStart;
  late Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  void _openWindow(String title, Widget content, {Size? size}) {
    final screenSize = MediaQuery.of(context).size;
    final defaultSize = Size(
      ResponsiveHelper.getWindowWidth(context, 850),
      ResponsiveHelper.getWindowHeight(context, 650),
    );
    
    setState(() {
      _windows.add(DesktopWindow(
        id: _nextWindowId++,
        title: title,
        content: content,
        position: Offset(
          50 + (_windows.length % 5) * 30,
          50 + (_windows.length % 5) * 30,
        ),
        size: size ?? defaultSize,
        isMinimized: false,
        isMaximized: false,
      ));
    });
  }

  void _closeWindow(int id) {
    setState(() => _windows.removeWhere((w) => w.id == id));
  }

  void _minimizeWindow(int id) {
    setState(() {
      final index = _windows.indexWhere((w) => w.id == id);
      if (index != -1) _windows[index].isMinimized = true;
    });
  }

  void _restoreWindow(int id) {
    setState(() {
      final index = _windows.indexWhere((w) => w.id == id);
      if (index != -1) _windows[index].isMinimized = false;
    });
  }

  void _maximizeWindow(int id) {
    setState(() {
      final index = _windows.indexWhere((w) => w.id == id);
      if (index != -1) {
        _windows[index].isMaximized = !_windows[index].isMaximized;
        if (_windows[index].isMaximized) {
          _windows[index].savedSize = _windows[index].size;
          _windows[index].savedPosition = _windows[index].position;
          _windows[index].size = Size(
            MediaQuery.of(context).size.width - 40,
            MediaQuery.of(context).size.height - 100,
          );
          _windows[index].position = Offset.zero;
        } else {
          _windows[index].size = _windows[index].savedSize;
          _windows[index].position = _windows[index].savedPosition;
        }
      }
    });
  }

  void _bringToFront(int id) {
    final index = _windows.indexWhere((w) => w.id == id);
    if (index != -1 && index != _windows.length - 1) {
      setState(() {
        final window = _windows.removeAt(index);
        _windows.add(window);
      });
    }
  }

  void _startDragging(int id, Offset startPosition) {
    _draggingWindowId = id;
    _dragStart = startPosition;
  }

  void _updateDragging(Offset newPosition) {
    if (_draggingWindowId != null && _dragStart != null) {
      final index = _windows.indexWhere((w) => w.id == _draggingWindowId);
      if (index != -1 && !_windows[index].isMaximized) {
        setState(() {
          _windows[index].position += newPosition - _dragStart!;
          _dragStart = newPosition;
        });
      }
    }
  }

  void _stopDragging() {
    _draggingWindowId = null;
    _dragStart = null;
  }

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildBackground(),
              _buildDesktopIcons(),
              ..._windows.where((w) => !w.isMinimized).map((w) => _buildWindow(w)),
              if (_menuOpen) _buildStartMenu(),
              _buildTaskbar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00FF41), Colors.black],
        ),
      ),
      child: Center(
        child: Text(
          'ZION OS\nv3.3',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getFontSize(context, 48),
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Color(0xFF00FF41), blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopIcons() {
    final icons = [
      {'icon': Icons.terminal, 'label': 'Terminal', 'widget': const CosmicTerminal(), 'color': Colors.green},
      {'icon': Icons.wifi, 'label': 'WiFi', 'widget': const ZionWifiPanel(), 'color': Colors.blue},
      {'icon': Icons.psychology, 'label': 'SI Agent', 'widget': const SIControlPanel(), 'color': Colors.purple},
      {'icon': Icons.folder, 'label': 'Files', 'widget': const ZionFileManager(), 'color': Colors.orange},
      {'icon': Icons.public, 'label': 'Browser', 'widget': const ZionBrowser(), 'color': Colors.teal},
      {'icon': Icons.edit, 'label': 'Editor', 'widget': const ZionTextEditor(), 'color': Colors.pink},
      {'icon': Icons.settings, 'label': 'Settings', 'widget': const MainSettings(), 'color': Colors.grey},
    ];

    final iconSize = ResponsiveHelper.getIconSize(context);
    final gridColumns = ResponsiveHelper.getDesktopGridColumns(context);

    return Positioned.fill(
      child: Padding(
        padding: ResponsiveHelper.getDesktopPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.getFontSize(context, 40)),
            Wrap(
              spacing: ResponsiveHelper.getFontSize(context, 30),
              runSpacing: ResponsiveHelper.getFontSize(context, 30),
              children: icons.map((icon) => _DesktopIcon(
                icon: icon['icon'] as IconData,
                label: icon['label'] as String,
                color: icon['color'] as Color,
                iconSize: iconSize,
                onTap: () => _openWindow(icon['label'] as String, icon['widget'] as Widget),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindow(DesktopWindow w) {
    return Positioned(
      left: w.position.dx.clamp(0, MediaQuery.of(context).size.width - 100),
      top: w.position.dy.clamp(0, MediaQuery.of(context).size.height - 100),
      child: GestureDetector(
        onTap: () => _bringToFront(w.id),
        onPanStart: (details) => _startDragging(w.id, details.localPosition),
        onPanUpdate: (details) => _updateDragging(details.localPosition),
        onPanEnd: (_) => _stopDragging(),
        child: Container(
          width: w.isMaximized ? MediaQuery.of(context).size.width - 40 : w.size.width,
          height: w.isMaximized ? MediaQuery.of(context).size.height - 100 : w.size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(w.isMaximized ? 0 : 12),
            border: Border.all(color: const Color(0xFF00FF41), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildTitleBar(w),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(w.isMaximized ? 0 : 12),
                  bottomRight: Radius.circular(w.isMaximized ? 0 : 12),
                ),
                child: w.content,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(DesktopWindow w) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF41).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(w.isMaximized ? 0 : 12),
          topRight: Radius.circular(w.isMaximized ? 0 : 12),
        ),
        border: Border(bottom: BorderSide(color: const Color(0xFF00FF41).withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildWindowButton(Colors.red, () => _closeWindow(w.id)),
              const SizedBox(width: 8),
              _buildWindowButton(Colors.amber, () => _minimizeWindow(w.id)),
              const SizedBox(width: 8),
              _buildWindowButton(Colors.green, () => _maximizeWindow(w.id)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              w.title,
              style: const TextStyle(color: Color(0xFF00FF41), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white),
            onPressed: () => _closeWindow(w.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowButton(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }

  Widget _buildStartMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.terminal, 'title': 'Terminal', 'widget': const CosmicTerminal(), 'color': Colors.green},
      {'icon': Icons.wifi, 'title': 'WiFi', 'widget': const ZionWifiPanel(), 'color': Colors.blue},
      {'icon': Icons.psychology, 'title': 'SI Agent', 'widget': const SIControlPanel(), 'color': Colors.purple},
      {'icon': Icons.folder, 'title': 'File Manager', 'widget': const ZionFileManager(), 'color': Colors.orange},
      {'icon': Icons.public, 'title': 'Browser', 'widget': const ZionBrowser(), 'color': Colors.teal},
      {'icon': Icons.edit, 'title': 'Editor', 'widget': const ZionTextEditor(), 'color': Colors.pink},
      {'icon': Icons.settings, 'title': 'Settings', 'widget': const MainSettings(), 'color': Colors.grey},
      const {'icon': Icons.exit_to_app, 'title': 'Exit', 'color': Colors.red},
    ];

    return Positioned(
      bottom: 70,
      left: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: ResponsiveHelper.isMobile(context) ? 250 : 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00FF41)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF00FF41),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.black)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zion User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('zion@os', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              ...menuItems.map((item) => ListTile(
                leading: Icon(item['icon'] as IconData, color: item['color'] as Color? ?? const Color(0xFF00FF41)),
                title: Text(item['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () {
                  _toggleMenu();
                  if (item['title'] == 'Exit') {
                    Navigator.pop(context);
                  } else {
                    _openWindow(item['title'] as String, item['widget'] as Widget);
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskbar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: ResponsiveHelper.isMobile(context) ? 40 : 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border(top: BorderSide(color: const Color(0xFF00FF41).withOpacity(0.3))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                width: ResponsiveHelper.isMobile(context) ? 50 : 60,
                height: ResponsiveHelper.isMobile(context) ? 40 : 50,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00FF41), Colors.black])),
                child: Icon(Icons.menu, color: Colors.white, size: ResponsiveHelper.isMobile(context) ? 20 : 24),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _windows.map((w) => GestureDetector(
                    onTap: () => w.isMinimized ? _restoreWindow(w.id) : _bringToFront(w.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: ResponsiveHelper.isMobile(context) ? 40 : 50,
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Center(
                        child: Text(
                          w.title,
                          style: TextStyle(color: Colors.white, fontSize: ResponsiveHelper.isMobile(context) ? 10 : 12),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            _buildSystemTray(),
            _buildClock(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemTray() {
    final iconSize = ResponsiveHelper.isMobile(context) ? 14 : 18;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.battery_full, color: Colors.white, size: iconSize),
          SizedBox(width: ResponsiveHelper.isMobile(context) ? 4 : 8),
          Icon(Icons.wifi, color: Colors.white, size: iconSize),
          SizedBox(width: ResponsiveHelper.isMobile(context) ? 4 : 8),
          Icon(Icons.volume_up, color: Colors.white, size: iconSize),
        ],
      ),
    );
  }

  Widget _buildClock() {
    final fontSize = ResponsiveHelper.isMobile(context) ? 10 : 12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatTime(_currentTime), style: TextStyle(color: Colors.white, fontSize: fontSize)),
          Text(_formatDate(_currentTime), style: TextStyle(color: Colors.white70, fontSize: fontSize - 2)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  String _formatDate(DateTime time) => '${time.day}/${time.month}/${time.year}';
}

class _DesktopIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final VoidCallback onTap;

  const _DesktopIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1),
            ),
            child: Icon(icon, color: color, size: iconSize * 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: iconSize * 0.15),
          ),
        ],
      ),
    );
  }
}

class DesktopWindow {
  final int id;
  final String title;
  final Widget content;
  Offset position;
  Size size;
  Size savedSize;
  Offset savedPosition;
  bool isMinimized;
  bool isMaximized;

  DesktopWindow({
    required this.id,
    required this.title,
    required this.content,
    required this.position,
    required this.size,
    required this.isMinimized,
    required this.isMaximized,
  }) : savedSize = size, savedPosition = position;
}
