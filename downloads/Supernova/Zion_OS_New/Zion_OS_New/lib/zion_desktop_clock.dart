import 'package:flutter/material.dart';
import 'dart:async';

class ZionDesktopClock extends StatefulWidget {
  const ZionDesktopClock({super.key});

  @override
  State<ZionDesktopClock> createState() => _ZionDesktopClockState();
}

class _ZionDesktopClockState extends State<ZionDesktopClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final day = _now.day.toString().padLeft(2, '0');
    final month = _now.month.toString().padLeft(2, '0');
    final year = _now.year.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$hour:$minute:$second',
          style: const TextStyle(
            color: Color(0xFF00FF41),
            fontSize: 48,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Color(0xFF00FF41), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$day/$month/$year',
          style: const TextStyle(
            color: Color(0xFF00FF41),
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
