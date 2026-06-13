import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Color> _themeColors = [const Color(0xFF00BCD4), Colors.cyan, Colors.green, Colors.blue, Colors.purple, Colors.orange];
  final List<String> _colorNames = ['Turquoise', 'Cyan', 'Green', 'Blue', 'Purple', 'Orange'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text('settings', style: const TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('appearance'),
          _buildSwitchTile('dark_mode', themeProvider.isDarkMode, (_) => themeProvider.toggleTheme()),
          _buildColorSelector(themeProvider),
          _buildSliderTile('font_size', themeProvider.fontScale, 0.8, 1.5, (v) => themeProvider.setFontScale(v)),
          _buildSliderTile('icon_size', themeProvider.iconSize, 48, 78, (v) => themeProvider.setIconSize(v)),
          _buildSectionHeader('security'),
          _buildInfoTile('change_pin', () => _showChangePinDialog(themeProvider)),
          const Divider(),
          _buildInfoTile('language', _showLanguageDialog),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Container(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)));
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) => SwitchListTile(title: Text(title), value: value, onChanged: onChanged, activeColor: const Color(0xFF00BCD4));
  Widget _buildSliderTile(String title, double value, double min, double max, Function(double) onChanged) => ListTile(title: Text(title), subtitle: Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: const Color(0xFF00BCD4)), trailing: Text(value.toStringAsFixed(1)));
  Widget _buildInfoTile(String title, VoidCallback onTap) => ListTile(title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap);

  Widget _buildColorSelector(ThemeProvider tp) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('theme_color', style: TextStyle(color: Color(0xFF00BCD4))),
        const SizedBox(height: 8),
        Wrap(spacing: 10, children: List.generate(_themeColors.length, (i) => GestureDetector(
          onTap: () => tp.setPrimaryColor(_themeColors[i]),
          child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _themeColors[i], shape: BoxShape.circle, border: tp.primaryColor == _themeColors[i] ? Border.all(color: Colors.white, width: 2) : null)),
        ))),
      ]),
    );
  }

  void _showChangePinDialog(ThemeProvider tp) {
    final oldCtrl = TextEditingController(), newCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('change_pin'), content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Old PIN'), autofocus: true),
        TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New PIN (4 digits)')),
      ]), actions: [
        TextButton(onPressed: () => Navigator.pop(_), child: Text('cancel')),
        TextButton(onPressed: () async {
          if (await tp.changePin(oldCtrl.text, newCtrl.text)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN changed successfully'), backgroundColor: Color(0xFF00BCD4)));
            Navigator.pop(_);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN'), backgroundColor: Colors.red));
          }
        }, child: Text('save')),
      ],
    ));
  }

  void _showLanguageDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('language'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(title: const Text('العربية'), onTap: () { context.setLocale(const Locale('ar')); Navigator.pop(_); }),
        ListTile(title: const Text('English'), onTap: () { context.setLocale(const Locale('en')); Navigator.pop(_); }),
      ]),
    ));
  }
}

  void _resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    await tp._loadSettings();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All settings reset'), backgroundColor: Color(0xFF00BCD4)));
  }

  // أضف هذا الزر في نهاية القائمة
  ListTile(
    title: const Text('Reset All Settings', style: TextStyle(color: Colors.red)),
    trailing: const Icon(Icons.restore, color: Colors.red),
    onTap: _resetAllSettings,
  ),

  // إضافة ألوان إضافية للثيم
  final List<Color> _extraColors = [
    Colors.pink, Colors.teal, Colors.indigo, Colors.amber, Colors.lime, Colors.deepOrange
  ];

  // إضافة قسم الألوان الإضافية في واجهة اختيار الألوان
  Wrap(
    spacing: 10,
    children: _extraColors.map((color) => GestureDetector(
      onTap: () => themeProvider.setPrimaryColor(color),
      child: Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: themeProvider.primaryColor == color ? Border.all(color: Colors.white, width: 2) : null)),
    )).toList(),
  ),

  // إضافة خيارات الصوت والاهتزاز في قسم السلوك
  Consumer<SoundService>(
    builder: (ctx, ss, _) => Column(
      children: [
        SwitchListTile(title: const Text('Sound Effects'), value: ss.soundEnabled, onChanged: (_) => ss.toggleSound(), activeColor: const Color(0xFF00BCD4)),
        SwitchListTile(title: const Text('Vibration'), value: ss.vibrationEnabled, onChanged: (_) => ss.toggleVibration(), activeColor: const Color(0xFF00BCD4)),
      ],
    ),
  ),
