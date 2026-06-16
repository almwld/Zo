import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('settings.appearance'.tr(), [
            _buildSwitchTile('settings.dark_mode'.tr(), prefs.isDarkMode, (v) => prefs.setDarkMode(v), prefs),
            _buildLanguageTile(context, prefs),
          ], prefs),
          _buildSection('settings.security'.tr(), [
            _buildInfoTile('settings.change_pin'.tr(), () => _showChangePinDialog(context, prefs), prefs),
            _buildSwitchTile('settings.biometric'.tr(), prefs.useBiometric, (v) => prefs.setUseBiometric(v), prefs),
          ], prefs),
          _buildSection('settings.about'.tr(), [
            _buildInfoTile('settings.version'.tr(), () {}, prefs, value: '4.5.0'),
            _buildInfoTile('settings.developer'.tr(), () {}, prefs, value: 'Zion Team'),
          ], prefs),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _showResetDialog(context, prefs),
              icon: const Icon(Icons.restore, color: Colors.red),
              label: Text('settings.reset'.tr(), style: const TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, PreferencesService prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, PreferencesService prefs) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontSize: 14 * prefs.fontScale)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.cyan,
      ),
    );
  }

  Widget _buildInfoTile(String title, VoidCallback onTap, PreferencesService prefs, {String value = ''}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14 * prefs.fontScale)),
        trailing: value.isNotEmpty
            ? Text(value, style: TextStyle(color: Colors.cyan, fontSize: 12 * prefs.fontScale))
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, PreferencesService prefs) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('settings.language'.tr(), style: TextStyle(fontSize: 14 * prefs.fontScale)),
        trailing: DropdownButton<String>(
          value: prefs.languageCode,
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (v) {
            if (v != null) {
              prefs.setLanguageCode(v);
              context.setLocale(Locale(v));
            }
          },
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, PreferencesService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings.change_pin'.tr()),
        content: const Text('سيتم إضافة هذه الميزة قريباً'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('common.ok'.tr())),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, PreferencesService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings.reset'.tr()),
        content: Text('settings.reset_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('common.cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              await prefs.resetAllSettings();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('settings.reset_done'.tr())),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );
  }
}
