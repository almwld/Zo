import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_manager.dart';
import '../../widgets/glassmorphism.dart';

class SurfaceDesktop extends StatefulWidget {
  const SurfaceDesktop({super.key});

  @override
  State<SurfaceDesktop> createState() => _SurfaceDesktopState();
}

class _SurfaceDesktopState extends State<SurfaceDesktop> with TickerProviderStateMixin {
  final ThemeManager _themeManager = ThemeManager();
  final List<DesktopWindow> _windows = [];
  final List<DesktopIcon> _desktopIcons = [];
  int _nextWindowId = 1;
  DateTime _currentTime = DateTime.now();
  bool _showStartMenu = false;
  late AnimationController _startMenuController;
  late Animation<double> _startMenuAnimation;
  int _activeWorkspace = 0;
  final int _workspaceCount = 4;

  @override
  void initState() {
    super.initState();
    _loadDesktopIcons();
    _startMenuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _startMenuAnimation = CurvedAnimation(parent: _startMenuController, curve: Curves.easeOutBack);
    _updateTime();
    _loadWindowPositions();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
        _updateTime();
      }
    });
  }

  void _loadDesktopIcons() {
    _desktopIcons.addAll([
      DesktopIcon('Terminal', Icons.terminal, Colors.green, () => _openWindow('Terminal', const Placeholder())),
      DesktopIcon('Files', Icons.folder, Colors.blue, () => _openWindow('Files', const Placeholder())),
      DesktopIcon('Browser', Icons.public, Colors.orange, () => _openWindow('Browser', const Placeholder())),
      DesktopIcon('Settings', Icons.settings, Colors.grey, () => _openWindow('Settings', const Placeholder())),
    ]);
  }

  Future<void> _loadWindowPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('window_positions');
    if (saved != null) {
      // استعادة مواقع النوافذ المحفوظة
    }
  }

  void _openWindow(String title, Widget content, {Size size = const Size(800, 600)}) {
    setState(() {
      _windows.add(DesktopWindow(
        id: _nextWindowId++,
        title: title,
        content: content,
        position: Offset(50 + (_windows.length % 5) * 30, 50 + (_windows.length % 5) * 30),
        size: size,
        isMinimized: false,
        isMaximized: false,
      ));
    });
    _saveWindowPositions();
  }

  void _saveWindowPositions() async {
    final prefs = await SharedPreferences.getInstance();
    // حفظ مواقع النوافذ
  }

  void _closeWindow(int id) {
    setState(() {
      _windows.removeWhere((w) => w.id == id);
    });
    _saveWindowPositions();
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
          _windows[index].size = const Size(double.infinity, double.infinity);
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
    // بدء السحب
  }

  void _updateDragging(Offset newPosition) {
    // تحديث موضع النافذة أثناء السحب
  }

  void _stopDragging() {
    // إيقاف السحب
  }

  void _toggleStartMenu() {
    setState(() {
      _showStartMenu = !_showStartMenu;
      if (_showStartMenu) {
        _startMenuController.forward();
      } else {
        _startMenuController.reverse();
      }
    });
  }

  void _switchWorkspace(int index) {
    setState(() => _activeWorkspace = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // خلفية Matrix Rain
          _buildMatrixBackground(),
          
          // أيقونات سطح المكتب
          _buildDesktopIcons(),
          
          // النوافذ المفتوحة
          ..._windows.where((w) => !w.isMinimized).map((w) => _buildWindow(w)),
          
          // قائمة ابدأ
          if (_showStartMenu) _buildStartMenu(),
          
          // شريط المهام
          _buildTaskbar(),
        ],
      ),
    );
  }

  Widget _buildMatrixBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [_themeManager.currentTheme.accent.withOpacity(0.15), _themeManager.currentTheme.background],
        ),
      ),
      child: const Center(
        child: Text(
          'ZION OS\nv3.3',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDesktopIcons() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Wrap(
              spacing: 30,
              runSpacing: 30,
              children: _desktopIcons.map((icon) => _DesktopIconWidget(icon: icon)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindow(DesktopWindow w) {
    return Positioned(
      left: w.position.dx,
      top: w.position.dy,
      child: GestureDetector(
        onTap: () => _bringToFront(w.id),
        child: GlassmorphicContainer(
          borderRadius: 12,
          child: Container(
            width: w.isMaximized ? MediaQuery.of(context).size.width - 40 : w.size.width,
            height: w.isMaximized ? MediaQuery.of(context).size.height - 100 : w.size.height,
            child: Column(
              children: [
                _buildTitleBar(w),
                Expanded(child: w.content),
              ],
            ),
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
        color: _themeManager.currentTheme.accent.withOpacity(0.1),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: _themeManager.currentTheme.accent.withOpacity(0.3))),
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
              style: TextStyle(color: _themeManager.currentTheme.accent, fontSize: 12),
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
    return Positioned(
      bottom: 60,
      left: 10,
      child: ScaleTransition(
        scale: _startMenuAnimation,
        child: GlassmorphicContainer(
          borderRadius: 12,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStartMenuItem(Icons.terminal, 'Terminal', () {}),
                _buildStartMenuItem(Icons.folder, 'File Manager', () {}),
                _buildStartMenuItem(Icons.public, 'Browser', () {}),
                _buildStartMenuItem(Icons.settings, 'Settings', () {}),
                const Divider(color: Colors.white24),
                _buildStartMenuItem(Icons.power_settings_new, 'Shutdown', () => Navigator.pop(context), isDanger: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : _themeManager.currentTheme.accent),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.red : Colors.white)),
      onTap: () {
        _toggleStartMenu();
        onTap();
      },
    );
  }

  Widget _buildTaskbar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _themeManager.currentTheme.background.withOpacity(0.9),
          border: Border(top: BorderSide(color: _themeManager.currentTheme.accent.withOpacity(0.3))),
        ),
        child: Row(
          children: [
            // زر ابدأ
            GestureDetector(
              onTap: _toggleStartMenu,
              child: Container(
                width: 60, height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_themeManager.currentTheme.accent, _themeManager.currentTheme.background]),
                ),
                child: Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),
            
            // مساحات العمل
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_workspaceCount, (i) => GestureDetector(
                    onTap: () => _switchWorkspace(i),
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _activeWorkspace == i ? _themeManager.currentTheme.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${i + 1}', style: TextStyle(color: _activeWorkspace == i ? Colors.black : Colors.white)),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            
            // النوافذ المفتوحة
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _windows.map((w) => GestureDetector(
                    onTap: () => w.isMinimized ? _restoreWindow(w.id) : _bringToFront(w.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Center(
                        child: Text(
                          w.title,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            
            // أيقونات النظام والساعة
            _buildSystemTray(),
            _buildClock(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemTray() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: const [
          Icon(Icons.battery_full, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Icon(Icons.wifi, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Icon(Icons.volume_up, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildClock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatTime(_currentTime), style: const TextStyle(color: Colors.white, fontSize: 12)),
          Text(_formatDate(_currentTime), style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  String _formatDate(DateTime time) => '${time.day}/${time.month}/${time.year}';
}

class DesktopIcon {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DesktopIcon(this.label, this.icon, this.color, this.onTap);
}

class _DesktopIconWidget extends StatelessWidget {
  final DesktopIcon icon;

  const _DesktopIconWidget({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: icon.onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: icon.color, width: 1),
            ),
            child: Icon(icon.icon, color: icon.color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(icon.label, style: TextStyle(color: Colors.white70, fontSize: 11)),
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
