import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/wm/window_manager.dart';
import 'zion_taskbar.dart';
import 'zion_desktop_icons.dart';
import 'zion_desktop_clock.dart';
import 'zion_system_monitor.dart';
import 'zion_notifications.dart';
import 'dart:math';

class ZionDesktop extends StatelessWidget {
  const ZionDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const ZionWallpaper(),
                // الساعة في أعلى اليمين
                Positioned(
                  top: 20,
                  right: 20,
                  child: const ZionDesktopClock(),
                ),
                // مراقب النظام في أسفل اليمين
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E0A).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                    ),
                    child: const ZionSystemMonitor(),
                  ),
                ),
                // أيقونات سطح المكتب
                Positioned(top: 20, left: 20, child: DesktopIconWidget(icon: Icons.terminal, label: 'الطرفية', kaliCommand: '')),
                Positioned(top: 20, left: 100, child: DesktopIconWidget(icon: Icons.travel_explore, label: 'Nmap', kaliCommand: 'nmap --help')),
                Positioned(top: 100, left: 20, child: DesktopIconWidget(icon: Icons.bug_report, label: 'Metasploit', kaliCommand: 'msfconsole -q -x "version; exit"')),
                Positioned(top: 100, left: 100, child: DesktopIconWidget(icon: Icons.storage, label: 'SQLmap', kaliCommand: 'sqlmap --help')),
                Positioned(top: 180, left: 20, child: DesktopIconWidget(icon: Icons.lock, label: 'Hydra', kaliCommand: 'hydra -h')),
                Positioned(top: 180, left: 100, child: DesktopIconWidget(icon: Icons.wifi, label: 'Aircrack', kaliCommand: 'aircrack-ng --help')),
                // النوافذ
                Consumer<WindowManager>(
                  builder: (context, wm, child) {
                    return Stack(
                      children: wm.windows.map((window) {
                        return Positioned(
                          left: window.isMaximized ? 0 : window.x,
                          top: window.isMaximized ? 0 : window.y,
                          width: window.isMaximized ? MediaQuery.of(context).size.width : window.width,
                          height: window.isMaximized ? MediaQuery.of(context).size.height - 36 : window.height,
                          child: _ZionWindowFrame(window: window),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const ZionTaskbar(),
        ],
      ),
    );
  }
}

class _ZionWindowFrame extends StatelessWidget {
  final ZionWindow window;
  const _ZionWindowFrame({required this.window});

  @override
  Widget build(BuildContext context) {
    final wm = context.read<WindowManager>();
    return GestureDetector(
      onTap: () => wm.setActive(window.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E0A),
          border: Border.all(color: wm.activeWindowId == window.id ? const Color(0xFF00FF41) : const Color(0xFF1A3A1A), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: wm.activeWindowId == window.id ? const Color(0xFF00FF41).withOpacity(0.2) : const Color(0xFF1A3A1A),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
              child: Row(
                children: [
                  _WindowButton(color: Colors.red, onTap: () => wm.close(window.id)),
                  const SizedBox(width: 4),
                  _WindowButton(color: Colors.orange, onTap: () => wm.minimize(window.id)),
                  const SizedBox(width: 4),
                  _WindowButton(color: Colors.green, onTap: () => wm.maximize(window.id)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(window.title, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 12, fontFamily: 'monospace'))),
                  GestureDetector(onPanUpdate: (details) => wm.updatePosition(window.id, details.delta.dx, details.delta.dy), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.drag_indicator, color: Color(0xFF00FF41), size: 14))),
                ],
              ),
            ),
            Expanded(child: window.content),
            GestureDetector(onPanUpdate: (details) => wm.updateSize(window.id, details.delta.dx, details.delta.dy), child: Container(height: 8, color: Colors.transparent, child: const Center(child: Icon(Icons.drag_indicator, color: Color(0xFF00FF41), size: 12)))),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _WindowButton({required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 12, height: 12, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(shape: BoxShape.circle, color: color)));
}

class ZionWallpaper extends StatefulWidget {
  const ZionWallpaper({super.key});
  @override
  State<ZionWallpaper> createState() => _ZionWallpaperState();
}

class _ZionWallpaperState extends State<ZionWallpaper> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _ctrl, builder: (context, child) => CustomPaint(painter: MatrixRainPainter(_ctrl.value), size: MediaQuery.of(context).size));
}

class MatrixRainPainter extends CustomPainter {
  final double time;
  final List<_RainColumn> _columns = [];
  final Random _random = Random();
  MatrixRainPainter(this.time) { if (_columns.isEmpty) for (int i = 0; i < 100; i++) _columns.add(_RainColumn(_random)); }
  @override
  void paint(Canvas canvas, Size size) { final paint = Paint(); for (final col in _columns) { col.update(time, size.height); for (final char in col.chars) { paint.color = const Color(0xFF00FF41).withOpacity(char.opacity); final tp = TextPainter(text: TextSpan(text: char.char, style: TextStyle(color: paint.color, fontSize: 12, fontFamily: 'monospace')), textDirection: TextDirection.ltr); tp.layout(); tp.paint(canvas, Offset(col.x, char.y)); } } }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RainColumn {
  final double x; final double speed; final List<_RainChar> chars = []; final Random _random;
  _RainColumn(this._random) : x = _random.nextDouble() * 1000, speed = _random.nextDouble() * 2 + 1 { for (int i = 0; i < _random.nextInt(20) + 5; i++) chars.add(_RainChar(_random, -_random.nextDouble() * 800)); }
  void update(double time, double maxHeight) { for (final char in chars) { char.y += speed; char.opacity = (0.05 + 0.15 * (char.y / maxHeight)).clamp(0.02, 0.2); if (char.y > maxHeight) { char.y = 0; char.char = 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي'[_random.nextInt(36)]; } } }
}

class _RainChar { double y; double opacity; String char; _RainChar(Random random, this.y) : opacity = 0.05 + random.nextDouble() * 0.15, char = 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي'[random.nextInt(36)]; }
