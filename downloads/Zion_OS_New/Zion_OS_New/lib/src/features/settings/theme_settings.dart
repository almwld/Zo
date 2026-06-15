import 'package:flutter/material.dart';
import '../../core/theme/theme_manager.dart';
import '../../widgets/glassmorphism.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  final ThemeManager _themeManager = ThemeManager();
  late AppTheme _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = _themeManager.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معاينة الثيم الحالي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_themeManager.currentTheme.accent, _themeManager.currentTheme.background],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Preview', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _themeManager.getGlassDecoration(),
                    child: const Column(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text('Sample Card', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // قائمة الثيمات
            const Text('Select Theme', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: AppTheme.values.length,
              itemBuilder: (ctx, i) {
                final theme = AppTheme.values[i];
                final isSelected = _selectedTheme == theme;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTheme = theme);
                    _themeManager.setTheme(theme);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? theme.accent : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme.name,
                          style: TextStyle(color: isSelected ? theme.accent : Colors.white70, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // إعدادات إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                    value: _themeManager.darkMode,
                    onChanged: (v) {
                      setState(() => _themeManager.setDarkMode(v));
                    },
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  ListTile(
                    title: const Text('Blur Intensity', style: TextStyle(color: Colors.white)),
                    subtitle: Slider(
                      value: _themeManager.blurIntensity,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      onChanged: (v) => _themeManager.setBlurIntensity(v),
                    ),
                    trailing: Text('${_themeManager.blurIntensity.toInt()}px', style: const TextStyle(color: Colors.cyan)),
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
