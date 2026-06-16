import 'package:flutter/material.dart';

class ZionScript {
  final String name;
  final String description;
  final String code;
  final bool enabled;

  ZionScript({required this.name, required this.description, required this.code, this.enabled = true});
}

class ZionScriptingEngine extends ChangeNotifier {
  final List<ZionScript> _scripts = [
    ZionScript(name: 'auto_recon.sh', description: 'استطلاع تلقائي للشبكة', code: 'nmap -sV -O 192.168.1.0/24\nnikto -h 192.168.1.1\ndirb http://192.168.1.1'),
    ZionScript(name: 'quick_scan.sh', description: 'فحص سريع للمنافذ', code: 'nmap -sS -p 1-1000 192.168.1.1'),
    ZionScript(name: 'wifi_attack.sh', description: 'هجوم على شبكة WiFi', code: 'airmon-ng start wlan0\nairodump-ng wlan0mon'),
    ZionScript(name: 'persistence.sh', description: 'تثبيت الثغرة الخلفية', code: 'echo "*/5 * * * * /tmp/backdoor" >> /etc/crontab'),
    ZionScript(name: 'cleanup.sh', description: 'تنظيف الآثار', code: 'rm -rf /tmp/*\nrm ~/.bash_history\nclear'),
  ];

  String _output = '';
  bool _isRunning = false;

  List<ZionScript> get scripts => _scripts;
  String get output => _output;
  bool get isRunning => _isRunning;

  Future<void> runScript(ZionScript script) async {
    _isRunning = true;
    _output = '';
    notifyListeners();

    final lines = script.code.split('\n');
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      _output += '> $line\n';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      _output += '  [OK] تم التنفيذ\n';
      notifyListeners();
    }

    _output += '\n[✓] انتهى السكريبت بنجاح.\n';
    _isRunning = false;
    notifyListeners();
  }

  void addScript(String name, String description, String code) {
    _scripts.add(ZionScript(name: name, description: description, code: code));
    notifyListeners();
  }

  void removeScript(String name) {
    _scripts.removeWhere((s) => s.name == name);
    notifyListeners();
  }
}
