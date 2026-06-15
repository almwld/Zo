import 'package:flutter/material.dart';
import 'dart:async';
import 'zion_desktop_clock.dart';

class ZionLockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const ZionLockScreen({super.key, required this.onUnlock});

  @override
  State<ZionLockScreen> createState() => _ZionLockScreenState();
}

class _ZionLockScreenState extends State<ZionLockScreen> with TickerProviderStateMixin {
  final TextEditingController _passCtrl = TextEditingController();
  bool _wrongPassword = false;
  int _attempts = 0;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _tryUnlock() {
    if (_passCtrl.text == 'zion' || _passCtrl.text == 'root' || _passCtrl.text == 'admin') {
      widget.onUnlock();
    } else {
      setState(() {
        _wrongPassword = true;
        _attempts++;
      });
      _shakeCtrl.forward().then((_) => _shakeCtrl.reverse());
      _passCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // خلفية Matrix Rain
          Positioned.fill(
            child: CustomPaint(
              painter: LockScreenMatrixPainter(),
            ),
          ),
          // المحتوى
          Center(
            child: AnimatedBuilder(
              animation: _shakeAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_wrongPassword ? 10 * _shakeAnim.value : 0, 0),
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FF41), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.5), blurRadius: 15)],
                    ),
                    child: const Center(
                      child: Text('Z', style: TextStyle(color: Color(0xFF00FF41), fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Zion Linux', style: TextStyle(color: Color(0xFF00FF41), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  const SizedBox(height: 32),
                  // الساعة
                  const ZionDesktopClock(),
                  const SizedBox(height: 32),
                  // حقل كلمة المرور
                  Container(
                    width: 250,
                    child: TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 18, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        hintStyle: TextStyle(color: const Color(0xFF00FF41).withOpacity(0.3), fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _wrongPassword ? Colors.red : const Color(0xFF00FF41)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _wrongPassword ? Colors.red : const Color(0xFF00FF41), width: 2),
                        ),
                        prefixIcon: Icon(Icons.lock, color: _wrongPassword ? Colors.red : const Color(0xFF00FF41)),
                      ),
                      onSubmitted: (_) => _tryUnlock(),
                    ),
                  ),
                  if (_wrongPassword) ...[
                    const SizedBox(height: 12),
                    Text(
                      'كلمة المرور غير صحيحة (${_attempts}/3)',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // زر فتح القفل
                  ElevatedButton.icon(
                    onPressed: _tryUnlock,
                    icon: const Icon(Icons.lock_open, color: Colors.black),
                    label: const Text('فتح القفل', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF41),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LockScreenMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00FF41).withOpacity(0.1);
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0) % size.width;
      final y = ((i * 23 + DateTime.now().millisecond * 0.01 * i) % size.height);
      final char = String.fromCharCode(0x0600 + (i % 36));
      final tp = TextPainter(text: TextSpan(text: char, style: TextStyle(color: paint.color, fontSize: 14)), textDirection: TextDirection.rtl);
      tp.layout();
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
