import 'package:flutter/material.dart';

class TerminalSettings extends StatefulWidget {
  const TerminalSettings({super.key});

  @override
  State<TerminalSettings> createState() => _TerminalSettingsState();
}

class _TerminalSettingsState extends State<TerminalSettings> {
  bool _showLineNumbers = true;
  bool _autoComplete = true;
  bool _syntaxHighlighting = true;
  int _fontSize = 14;
  String _fontFamily = 'JetBrainsMono';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('إعدادات الطرفية'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('إظهار أرقام الأسطر'),
            value: _showLineNumbers,
            onChanged: (v) => setState(() => _showLineNumbers = v),
          ),
          SwitchListTile(
            title: const Text('الإكمال التلقائي'),
            value: _autoComplete,
            onChanged: (v) => setState(() => _autoComplete = v),
          ),
          SwitchListTile(
            title: const Text('تمييز الصيغة'),
            value: _syntaxHighlighting,
            onChanged: (v) => setState(() => _syntaxHighlighting = v),
          ),
          ListTile(
            title: const Text('حجم الخط'),
            subtitle: Slider(
              value: _fontSize.toDouble(),
              min: 8,
              max: 24,
              divisions: 16,
              label: '$_fontSize',
              onChanged: (v) => setState(() => _fontSize = v.toInt()),
            ),
          ),
          ListTile(
            title: const Text('نوع الخط'),
            trailing: DropdownButton<String>(
              value: _fontFamily,
              items: const [
                DropdownMenuItem(value: 'JetBrainsMono', child: Text('JetBrains Mono')),
                DropdownMenuItem(value: 'monospace', child: Text('Monospace')),
                DropdownMenuItem(value: 'Courier', child: Text('Courier')),
              ],
              onChanged: (v) => setState(() => _fontFamily = v!),
            ),
          ),
        ],
      ),
    );
  }
}
