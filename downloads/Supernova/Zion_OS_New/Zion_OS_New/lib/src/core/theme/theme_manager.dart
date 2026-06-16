import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  matrix('Matrix', Color(0xFF00FF41), Color(0xFF000000)),
  cyberpunk('Cyberpunk', Color(0xFFFF00FF), Color(0xFF0D0D0D)),
  ocean('Ocean Deep', Color(0xFF00BFFF), Color(0xFF001F3F)),
  bloodMoon('Blood Moon', Color(0xFFFF4500), Color(0xFF1A0000)),
  goldPhoenix('Gold Phoenix', Color(0xFFFFD700), Color(0xFF1A1A00)),
  royalPurple('Royal Purple', Color(0xFF9B59B6), Color(0xFF1A0F2E)),
  arcticFrost('Arctic Frost', Color(0xFF00FFFF), Color(0xFF001F1F)),
  sunset('Sunset', Color(0xFFFF6B35), Color(0xFF331A00)),
  midnight('Midnight', Color(0xFF6A0DAD), Color(0xFF0A0A2A)),
  forest('Forest', Color(0xFF228B22), Color(0xFF0A2A0A)),
  lava('Lava', Color(0xFFFF4500), Color(0xFF2A0A00)),
  emerald('Emerald', Color(0xFF50C878), Color(0xFF003322));

  final String name;
  final Color accent;
  final Color background;
  const AppTheme(this.name, this.accent, this.background);
}

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  AppTheme _currentTheme = AppTheme.matrix;
  bool _darkMode = true;
  double _blurIntensity = 10.0;
  double _cornerRadius = 12.0;

  AppTheme get currentTheme => _currentTheme;
  bool get darkMode => _darkMode;
  double get blurIntensity => _blurIntensity;
  double get cornerRadius => _cornerRadius;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme');
    if (themeName != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppTheme.matrix,
      );
    }
    _darkMode = prefs.getBool('dark_mode') ?? true;
    _blurIntensity = prefs.getDouble('blur_intensity') ?? 10.0;
    _cornerRadius = prefs.getDouble('corner_radius') ?? 12.0;
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> setBlurIntensity(double value) async {
    _blurIntensity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('blur_intensity', value);
  }

  ThemeData getTheme() {
    final baseTheme = _darkMode ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: _currentTheme.accent,
      hintColor: _currentTheme.accent,
      scaffoldBackgroundColor: _currentTheme.background,
      cardColor: _darkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cornerRadius)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _currentTheme.background,
        elevation: 0,
        titleTextStyle: TextStyle(color: _currentTheme.accent, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: _darkMode ? Colors.white : Colors.black87),
        bodyMedium: TextStyle(color: _darkMode ? Colors.white70 : Colors.black54),
      ),
      iconTheme: IconThemeData(color: _currentTheme.accent),
    );
  }

  BoxDecoration getGlassDecoration() {
    return BoxDecoration(
      color: _currentTheme.background.withOpacity(0.3),
      borderRadius: BorderRadius.circular(_cornerRadius),
      border: Border.all(color: _currentTheme.accent.withOpacity(0.3)),
    );
  }
}
