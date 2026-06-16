import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';

class BatteryPopup extends StatefulWidget {
  final VoidCallback onClose;
  const BatteryPopup({super.key, required this.onClose});

  @override
  State<BatteryPopup> createState() => _BatteryPopupState();
}

class _BatteryPopupState extends State<BatteryPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: prefs.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('معلومات البطارية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: prefs.isDarkMode ? Colors.white : Colors.black)),
                  IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.battery_full, size: 60, color: Colors.green),
                    SizedBox(height: 8),
                    Text('85%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('الشحن: 3.9V • 35°C'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
