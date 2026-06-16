import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

/// شاشة الطرفية الرئيسية - تستخدم PtyManager عبر MethodChannel
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  static const platform = MethodChannel('com.zion.terminal/pty');
  
  String _output = '';
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  Timer? _readTimer;

  @override
  void initState() {
    super.initState();
    _connectPty();
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    _disconnectPty();
    super.dispose();
  }

  Future<void> _connectPty() async {
    try {
      final result = await platform.invokeMethod('open', {
        'rows': 30,
        'cols': 80,
        'shell': '/system/bin/sh',
      });
      _isConnected = result == true;
      if (_isConnected) {
        _startReading();
        setState(() {
          _output = '🖥️ Zion Terminal\n';
          _output += '═' * 40 + '\n';
          _output += '✅ جاهز للاستخدام\n';
          _output += '═' * 40 + '\n';
        });
      }
    } catch (e) {
      setState(() {
        _output = '❌ خطأ في الاتصال: $e\n';
      });
    }
  }

  void _startReading() {
    _readTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      try {
        final data = await platform.invokeMethod('read');
        if (data != null && data.toString().isNotEmpty) {
          setState(() {
            _output += data.toString();
          });
          _scrollToBottom();
        }
      } catch (e) {
        // تجاهل الأخطاء المؤقتة
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _disconnectPty() async {
    try {
      await platform.invokeMethod('close');
      _isConnected = false;
    } catch (e) {
      // تجاهل
    }
  }

  void _sendCommand(String command) {
    if (command.isEmpty) return;
    
    setState(() {
      _output += '\$ $command\n';
    });
    
    try {
      platform.invokeMethod('write', {'data': '$command\n'});
    } catch (e) {
      setState(() {
        _output += '❌ خطأ: $e\n';
      });
    }
    
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // شريط الحالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.terminal, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Zion Terminal',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isConnected ? 'متصل' : 'غير متصل',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor.withOpacity(0.5), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // منطقة الإخراج
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  _output,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isDark ? Colors.greenAccent : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          
          // شريط الإدخال
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const Text('\$ ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'اكتب الأمر...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: _sendCommand,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: primaryColor,
                  onPressed: () => _sendCommand(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
