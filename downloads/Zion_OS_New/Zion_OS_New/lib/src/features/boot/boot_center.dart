import 'package:flutter/material.dart';
import 'dart:io';

class BootCenter extends StatefulWidget {
  const BootCenter({super.key});

  @override
  State<BootCenter> createState() => _BootCenterState();
}

class _BootCenterState extends State<BootCenter> {
  bool _fastBoot = true;
  bool _safeMode = false;
  bool _bootLogging = false;
  String _lastBootTime = 'جاري التحميل...';
  String _bootStatus = 'طبيعي';

  @override
  void initState() {
    super.initState();
    _loadBootInfo();
  }

  Future<void> _loadBootInfo() async {
    try {
      final uptime = await Process.run('cat', ['/proc/uptime'], runInShell: true);
      final uptimeSeconds = double.parse(uptime.stdout.toString().split(' ')[0]);
      final hours = (uptimeSeconds / 3600).toInt();
      final minutes = ((uptimeSeconds % 3600) / 60).toInt();
      setState(() {
        _lastBootTime = '$h ساعة $dقيقة';
      });
    } catch (_) {}
  }

  Future<void> _performReboot() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تشغيل', style: TextStyle(color: Color(0xFF00FF41))),
        content: const Text('هل أنت متأكد من إعادة تشغيل الجهاز؟'),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري إعادة التشغيل...'), backgroundColor: Color(0xFF00FF41)),
              );
            },
            child: const Text('تأكيد', style: TextStyle(color: Color(0xFF00FF41))),
          ),
        ],
      ),
    );
  }

  Future<void> _performShutdown() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيقاف تشغيل', style: TextStyle(color: Color(0xFF00FF41))),
        content: const Text('هل أنت متأكد من إيقاف تشغيل الجهاز؟'),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري الإيقاف...'), backgroundColor: Color(0xFF00FF41)),
              );
            },
            child: const Text('تأكيد', style: TextStyle(color: Color(0xFF00FF41))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('مركز الإقلاع', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // حالة النظام
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00FF41).withOpacity(0.1), Colors.black],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.power_settings_new, color: Color(0xFF00FF41), size: 40),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حالة النظام', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('وقت التشغيل: $_lastBootTime', style: const TextStyle(color: Colors.white54)),
                        Text('حالة الإقلاع: $_bootStatus', style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // خيارات الإقلاع
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildSwitchOption('البدء السريع', 'تسريع عملية الإقلاع', _fastBoot, (v) => setState(() => _fastBoot = v)),
                  _buildSwitchOption('الوضع الآمن', 'تشغيل مع الخدمات الأساسية فقط', _safeMode, (v) => setState(() => _safeMode = v)),
                  _buildSwitchOption('تسجيل الإقلاع', 'حفظ سجل عملية الإقلاع', _bootLogging, (v) => setState(() => _bootLogging = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performReboot,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('إعادة تشغيل'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performShutdown,
                    icon: const Icon(Icons.power_off),
                    label: const Text('إيقاف تشغيل'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF00FF41)),
        ],
      ),
    );
  }
}
