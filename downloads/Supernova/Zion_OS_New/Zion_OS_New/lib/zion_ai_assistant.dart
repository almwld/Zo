import 'package:flutter/material.dart';
import 'dart:async';

class AICommand {
  final String query;
  final String response;
  final String action;

  AICommand({required this.query, required this.response, required this.action});
}

class ZionAIAssistant extends ChangeNotifier {
  final List<Map<String, dynamic>> _conversation = [];
  bool _isProcessing = false;
  bool _voiceEnabled = false;
  String _currentLanguage = 'ar';

  final List<AICommand> _knownCommands = [
    AICommand(query: 'امسح الشبكة', response: 'جاري فحص الشبكة المحلية...', action: 'nmap -sP 192.168.1.0/24'),
    AICommand(query: 'افحص المنافذ', response: 'جاري فحص المنافذ المفتوحة...', action: 'nmap -sV -p 1-1000'),
    AICommand(query: 'اختبر الاختراق', response: 'جاري تشغيل Metasploit...', action: 'msfconsole -q -x "version; exit"'),
    AICommand(query: 'فحص SQL', response: 'جاري فحص ثغرات SQL...', action: 'sqlmap --batch --dbs'),
    AICommand(query: 'حالة النظام', response: 'جاري جمع معلومات النظام...', action: 'sysinfo'),
    AICommand(query: 'نظف الآثار', response: 'جاري تنظيف السجلات...', action: 'cleanup'),
    AICommand(query: 'شفر الملفات', response: 'جاري تشفير الملفات...', action: 'encrypt'),
    AICommand(query: 'افتح VPN', response: 'جاري الاتصال بـ VPN...', action: 'vpn_connect'),
  ];

  List<Map<String, dynamic>> get conversation => _conversation;
  bool get isProcessing => _isProcessing;
  bool get voiceEnabled => _voiceEnabled;

  void toggleVoice() { _voiceEnabled = !_voiceEnabled; notifyListeners(); }

  Future<void> ask(String query) async {
    _conversation.add({'role': 'user', 'text': query, 'time': DateTime.now()});
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    String response = 'لم أفهم طلبك. حاول استخدام أوامر مثل: امسح الشبكة، افحص المنافذ، اختبر الاختراق، فحص SQL، حالة النظام، نظف الآثار، شفر الملفات، افتح VPN';
    String? action;

    for (final cmd in _knownCommands) {
      if (query.contains(cmd.query)) {
        response = cmd.response;
        action = cmd.action;
        break;
      }
    }

    _conversation.add({'role': 'ai', 'text': response, 'time': DateTime.now(), 'action': action});
    _isProcessing = false;
    notifyListeners();
  }

  void clearConversation() {
    _conversation.clear();
    notifyListeners();
  }
}
