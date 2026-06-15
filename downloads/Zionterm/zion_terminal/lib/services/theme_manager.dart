// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Theme Manager - مدير الثيمات                            ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: إدارة ثيمات الطرفية المختلفة                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    ThemeManager - مدير الثيمات
///                    Theme Manager
/// ═══════════════════════════════════════════════════════════════════════════

class ThemeManager {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الألوان الأساسية
  // ═══════════════════════════════════════════════════════════════════════

  static const Color cyberCyan = Color(0xFF00BCD4);
  static const Color matrixGreen = Color(0xFF00FF41);
  static const Color darkBlue = Color(0xFF2196F3);
  static const Color neonPurple = Color(0xFF9C27B0);
  static const Color bloodRed = Color(0xFFF44336);

  // ═══════════════════════════════════════════════════════════════════════
  //                      ألوان الخلفية
  // ═══════════════════════════════════════════════════════════════════════

  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);

  // ═══════════════════════════════════════════════════════════════════════
  //                      الثيمات المحددة
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get cyberCyanTheme => _buildTheme(cyberCyan, 'cyberCyan');
  static ThemeData get matrixGreenTheme => _buildTheme(matrixGreen, 'matrixGreen');
  static ThemeData get darkBlueTheme => _buildTheme(darkBlue, 'darkBlue');
  static ThemeData get neonPurpleTheme => _buildTheme(neonPurple, 'neonPurple');
  static ThemeData get bloodRedTheme => _buildTheme(bloodRed, 'bloodRed');

  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الثابتة
  // ═══════════════════════════════════════════════════════════════════════

  static String _currentThemeName = 'cyberCyan';
  static SharedPreferences? _prefs;
  static const String _themeKey = 'theme';

  static ThemeData _currentTheme = cyberCyanTheme;

  // ═══════════════════════════════════════════════════════════════════════
  //                      جلب الثيم
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get currentTheme => _currentTheme;
  static String get currentThemeName => _currentThemeName;

  static ThemeData getTheme(String name) {
    switch (name) {
      case 'cyberCyan':
        return cyberCyanTheme;
      case 'matrixGreen':
        return matrixGreenTheme;
      case 'darkBlue':
        return darkBlueTheme;
      case 'neonPurple':
        return neonPurpleTheme;
      case 'bloodRed':
        return bloodRedTheme;
      default:
        return cyberCyanTheme;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تعيين الثيم
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> setTheme(String themeName) async {
    _currentThemeName = themeName;
    _currentTheme = getTheme(themeName);

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_themeKey, themeName);
  }

  static Future<void> loadSavedTheme() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedTheme = _prefs!.getString(_themeKey) ?? 'cyberCyan';
    await setTheme(savedTheme);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      بناء الثيم
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData _buildTheme(Color primaryColor, String themeName) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor.withOpacity(0.7),
        surface: surfaceDark,
        error: bloodRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconTheme: IconThemeData(color: primaryColor),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      قائمة الثيمات
  // ═══════════════════════════════════════════════════════════════════════

  static List<ThemeInfo> get allThemes => [
    ThemeInfo(
      name: 'cyberCyan',
      displayName: 'Cyber Cyan',
      displayNameAr: 'سماوي سيبراني',
      color: cyberCyan,
      description: 'ثيم أزرق سماوي متوهج',
      descriptionAr: 'A glowing cyan blue theme',
    ),
    ThemeInfo(
      name: 'matrixGreen',
      displayName: 'Matrix Green',
      displayNameAr: 'أخضر ماتريكس',
      color: matrixGreen,
      description: 'ثيم أخضر على نمط فيلم ماتريكس',
      descriptionAr: 'Matrix-style green terminal theme',
    ),
    ThemeInfo(
      name: 'darkBlue',
      displayName: 'Dark Blue',
      displayNameAr: 'أزرق داكن',
      color: darkBlue,
      description: 'ثيم أزرق داكن وأنيق',
      descriptionAr: 'Elegant dark blue theme',
    ),
    ThemeInfo(
      name: 'neonPurple',
      displayName: 'Neon Purple',
      displayNameAr: 'بنفسجي نيون',
      color: neonPurple,
      description: 'ثيم بنفسجي نيون متوهج',
      descriptionAr: 'Glowing neon purple theme',
    ),
    ThemeInfo(
      name: 'bloodRed',
      displayName: 'Blood Red',
      displayNameAr: 'أحمر دموي',
      color: bloodRed,
      description: 'ثيم أحمر داكن ومكثف',
      descriptionAr: 'Dark and intense red theme',
    ),
  ];

  static ThemeInfo? getThemeInfo(String name) {
    try {
      return allThemes.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }

  static ThemeInfo get currentThemeInfo => getThemeInfo(_currentThemeName) ?? allThemes.first;
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    ThemeInfo - معلومات الثيم
///                    Theme Information
/// ═══════════════════════════════════════════════════════════════════════════

class ThemeInfo {
  final String name;
  final String displayName;
  final String displayNameAr;
  final Color color;
  final String description;
  final String descriptionAr;

  const ThemeInfo({
    required this.name,
    required this.displayName,
    required this.displayNameAr,
    required this.color,
    required this.description,
    required this.descriptionAr,
  });

  String getDisplayName({bool arabic = false}) {
    return arabic ? displayNameAr : displayName;
  }

  String getDescription({bool arabic = false}) {
    return arabic ? descriptionAr : description;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: theme_manager.dart
// ═══════════════════════════════════════════════════════════════════════════