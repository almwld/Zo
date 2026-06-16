import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> with SingleTickerProviderStateMixin {
  late SettingsService _settings;
  late TabController _tabController;
  
  final List<String> _themeColors = ['Turquoise', 'Cyan', 'Green', 'Blue', 'Purple', 'Orange', 'Red'];
  final List<String> _fontFamilies = ['Default', 'Roboto', 'Open Sans', 'Cairo', 'Orbitron'];
  final List<String> _performanceModes = ['Power Save', 'Balanced', 'Performance', 'Turbo'];
  final List<String> _languages = ['العربية', 'English', 'Français', 'Español'];
  final List<String> _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY/MM/DD'];
  final List<String> _timeFormats = ['24h', '12h'];
  final List<int> _timeoutOptions = [15, 30, 60, 120, 300];

  @override
  void initState() {
    super.initState();
    _settings = SettingsService();
    _settings.init();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Advanced Settings', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Appearance'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            Tab(icon: Icon(Icons.visibility_off), text: 'Privacy'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppearanceTab(),
          _buildSecurityTab(),
          _buildNotificationsTab(),
          _buildPrivacyTab(),
          _buildPerformanceTab(),
        ],
      ),
    );
  }
  
  Widget _buildAppearanceTab() {
    return ListView(
      children: [
        _buildSectionHeader('Theme', Icons.palette),
        _buildThemeSelector(),
        _buildSwitchTile('Dark Mode', _settings.darkMode, (v) => setState(() => _settings.darkMode = v)),
        
        _buildSectionHeader('Typography', Icons.text_fields),
        _buildDropdownTile('Font Family', _settings.fontFamily, _fontFamilies, (v) => setState(() => _settings.fontFamily = v)),
        _buildSliderTile('Font Size', _settings.fontSize, 10, 20, (v) => setState(() => _settings.fontSize = v)),
        
        _buildSectionHeader('Layout', Icons.dashboard),
        _buildSwitchTile('Animations', _settings.animationsEnabled, (v) => setState(() => _settings.animationsEnabled = v)),
        
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildSecurityTab() {
    return ListView(
      children: [
        _buildSectionHeader('Authentication', Icons.fingerprint),
        _buildSwitchTile('Biometric Authentication', _settings.biometricEnabled, (v) => setState(() => _settings.biometricEnabled = v)),
        _buildSwitchTile('Auto Lock', _settings.autoLockEnabled, (v) => setState(() => _settings.autoLockEnabled = v)),
        if (_settings.autoLockEnabled)
          _buildDropdownTile('Auto Lock Timeout', '${_settings.autoLockTimeout} seconds', _timeoutOptions.map((e) => '$e seconds').toList(), (v) {
            final seconds = int.parse(v.split(' ')[0]);
            setState(() => _settings.autoLockTimeout = seconds);
          }),
        
        _buildSectionHeader('Encryption', Icons.encryption),
        _buildSwitchTile('Data Encryption', _settings.encryptionEnabled, (v) => setState(() => _settings.encryptionEnabled = v)),
        
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildNotificationsTab() {
    return ListView(
      children: [
        _buildSectionHeader('Push Notifications', Icons.notifications),
        _buildSwitchTile('Enable Notifications', _settings.pushNotifications, (v) => setState(() => _settings.pushNotifications = v)),
        _buildSwitchTile('Sound', _settings.soundEnabled, (v) => setState(() => _settings.soundEnabled = v)),
        _buildSwitchTile('Vibration', _settings.vibrationEnabled, (v) => setState(() => _settings.vibrationEnabled = v)),
        
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildPrivacyTab() {
    return ListView(
      children: [
        _buildSectionHeader('Privacy Mode', Icons.privacy_tip),
        _buildSwitchTile('Incognito Mode', _settings.incognitoMode, (v) => setState(() => _settings.incognitoMode = v)),
        _buildSwitchTile('Clear History on Exit', _settings.clearHistoryOnExit, (v) => setState(() => _settings.clearHistoryOnExit = v)),
        _buildSwitchTile('Hide Activities', _settings.hideActivities, (v) => setState(() => _settings.hideActivities = v)),
        
        _buildSectionHeader('Data Management', Icons.data_usage),
        _buildInfoTile('Clear Cache', 'Clear temporary files', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared'), backgroundColor: Color(0xFF00BCD4)),
          );
        }),
        _buildInfoTile('Clear All Data', 'Reset all app data', () async {
          final confirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear Data', style: TextStyle(color: Color(0xFF00BCD4))),
              content: const Text('This will clear all app data. Are you sure?', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirmed == true) {
            // Clear all data logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data cleared'), backgroundColor: Color(0xFF00BCD4)),
            );
          }
        }),
        
        const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildPerformanceTab() {
    return ListView(
      children: [
        _buildSectionHeader('Performance Mode', Icons.speed),
        _buildDropdownTile('Mode', _settings.performanceMode, _performanceModes, (v) => setState(() => _settings.performanceMode = v)),
        _buildSwitchTile('Background Processes', _settings.backgroundProcesses, (v) => setState(() => _settings.backgroundProcesses = v)),
        
        _buildSectionHeader('Display Settings', Icons.display_settings),
        _buildDropdownTile('Language', _settings.language, _languages, (v) => setState(() => _settings.language = v)),
        _buildDropdownTile('Date Format', _settings.dateFormat, _dateFormats, (v) => setState(() => _settings.dateFormat = v)),
        _buildDropdownTile('Time Format', _settings.timeFormat, _timeFormats, (v) => setState(() => _settings.timeFormat = v)),
        
        const SizedBox(height: 20),
        
        // Reset Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings', style: TextStyle(color: Color(0xFF00BCD4))),
                  content: const Text('Reset all settings to default values?', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black,
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                await _settings.resetToDefault();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to default'), backgroundColor: Color(0xFF00BCD4)),
                );
              }
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Default'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF00BCD4)),
        ],
      ),
    );
  }
  
  Widget _buildDropdownTile(String title, String value, List<String> items, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          DropdownButton<String>(
            value: value,
            dropdownColor: Colors.black,
            underline: const SizedBox(),
            style: const TextStyle(color: Color(0xFF00BCD4)),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderTile(String title, double value, double min, double max, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text('${value.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFF00BCD4))),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFF00BCD4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme Color', style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: _themeColors.map((color) => GestureDetector(
              onTap: () => setState(() => _settings.themeColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColorFromName(color),
                  shape: BoxShape.circle,
                  border: _settings.themeColor == color
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Color(0xFF00BCD4)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      onTap: onTap,
    );
  }
  
  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'Turquoise': return const Color(0xFF00BCD4);
      case 'Cyan': return Colors.cyan;
      case 'Green': return Colors.green;
      case 'Blue': return Colors.blue;
      case 'Purple': return Colors.purple;
      case 'Orange': return Colors.orange;
      case 'Red': return Colors.red;
      default: return const Color(0xFF00BCD4);
    }
  }
}
