import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/theme_manager.dart';

class VoiceCenter extends StatefulWidget {
  const VoiceCenter({super.key});

  @override
  State<VoiceCenter> createState() => _VoiceCenterState();
}

class _VoiceCenterState extends State<VoiceCenter> {
  final ThemeManager _themeManager = ThemeManager();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _responseText = '';
  List<String> _commandHistory = [];
  final List<String> _commands = [
    'open terminal', 'open browser', 'open files', 'open settings',
    'scan network', 'check status', 'lock screen', 'help',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
  }

  void _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _processCommand(_recognizedText);
        });
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _processCommand(String command) {
    final cmd = command.toLowerCase().trim();
    _commandHistory.insert(0, cmd);
    if (_commandHistory.length > 10) _commandHistory.removeLast();

    if (cmd.contains('terminal') || cmd.contains('طرفية')) {
      _responseText = 'Opening Terminal...';
      Navigator.pushNamed(context, '/terminal');
    } else if (cmd.contains('browser') || cmd.contains('متصفح')) {
      _responseText = 'Opening Browser...';
      Navigator.pushNamed(context, '/browser');
    } else if (cmd.contains('files') || cmd.contains('ملفات')) {
      _responseText = 'Opening File Manager...';
      Navigator.pushNamed(context, '/file_manager');
    } else if (cmd.contains('settings') || cmd.contains('إعدادات')) {
      _responseText = 'Opening Settings...';
      Navigator.pushNamed(context, '/settings');
    } else if (cmd.contains('scan') || cmd.contains('مسح')) {
      _responseText = 'Starting network scan...';
      // تنفيذ المسح
    } else if (cmd.contains('status') || cmd.contains('حالة')) {
      _responseText = 'System is operational. All services running.';
    } else if (cmd.contains('lock') || cmd.contains('قفل')) {
      _responseText = 'Locking screen...';
      Navigator.pushReplacementNamed(context, '/lock');
    } else if (cmd.contains('help') || cmd.contains('مساعدة')) {
      _responseText = 'Available commands: ${_commands.join(", ")}';
    } else {
      _responseText = 'Command not recognized. Try: ${_commands.take(3).join(", ")}';
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Voice Control Center'),
        backgroundColor: theme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // حالة الميكروفون
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: _isListening ? Colors.red : theme.accent,
                  width: 3,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: _isListening ? Colors.red : theme.accent,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isListening ? 'Listening...' : 'Tap to speak',
              style: TextStyle(color: _isListening ? Colors.red : theme.accent),
            ),
            const SizedBox(height: 40),
            
            // النص المتعرف عليه
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recognized:', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _recognizedText.isEmpty ? '...' : _recognizedText,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // الرد
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.accent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Response:', style: TextStyle(color: theme.accent)),
                  const SizedBox(height: 8),
                  Text(
                    _responseText.isEmpty ? 'Awaiting command...' : _responseText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // الأوامر المتاحة
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Commands:', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _commands.length,
                        itemBuilder: (ctx, i) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _commands[i],
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // سجل الأوامر
            Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Command History', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _commandHistory.length,
                      itemBuilder: (ctx, i) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _commandHistory[i],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
