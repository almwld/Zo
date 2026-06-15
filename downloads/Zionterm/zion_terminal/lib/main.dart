// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Main Entry Point - نقطة الدخول                          ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: Advanced Bilingual Terminal Emulator                          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'terminal/terminal_emulator.dart';
import 'terminal/terminal_session.dart';
import 'terminal/terminal_history.dart';
import 'terminal/terminal_colors.dart';
import 'services/language_manager.dart';
import 'services/theme_manager.dart';
import 'ui/terminal_screen.dart';
import 'ai/ai_assistant.dart';
import 'packages/package_manager.dart';
import 'distros/distro_manager.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    void main() - نقطة الدخول الرئيسية
///                    Main Entry Point
/// ═══════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'arabic';
  final savedTheme = prefs.getString('theme') ?? 'cyberCyan';

  await LanguageManager.loadLanguage(
    savedLang == 'english' ? AppLanguage.english : AppLanguage.arabic,
  );

  ThemeManager.setTheme(savedTheme);

  runApp(const ZionTerminalApp());
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    ZionTerminalApp - التطبيق الرئيسي
///                    Main Application Widget
/// ═══════════════════════════════════════════════════════════════════════════

class ZionTerminalApp extends StatelessWidget {
  const ZionTerminalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TerminalSession()),
        ChangeNotifierProvider(create: (_) => TerminalHistory()),
        ChangeNotifierProvider(create: (_) => AIAssistant()),
        ChangeNotifierProvider(create: (_) => PackageManager()),
        ChangeNotifierProvider(create: (_) => DistroManager()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: LanguageManager.t('app_name'),
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.currentTheme,
            locale: LanguageManager.currentLanguage == AppLanguage.arabic
                ? const Locale('ar', 'SA')
                : const Locale('en', 'US'),
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            home: const TerminalScreen(),
          );
        },
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    ThemeNotifier - مدير حالة الثيمات
///                    Theme State Management
/// ═══════════════════════════════════════════════════════════════════════════

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = ThemeManager.cyberCyanTheme;

  ThemeData get currentTheme => _currentTheme;

  void setTheme(String themeName) {
    _currentTheme = ThemeManager.getTheme(themeName);
    notifyListeners();
  }

  void toggleTheme() {
    final themes = ['cyberCyan', 'matrixGreen', 'darkBlue', 'neonPurple', 'bloodRed'];
    final currentIndex = themes.indexWhere(
      (t) => _currentTheme.primaryColor == ThemeManager.getTheme(t).primaryColor,
    );
    final nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    ThemeManager - مدير الثيمات الثابت
///                    Static Theme Manager
/// ═══════════════════════════════════════════════════════════════════════════

class ThemeManager {
  static String _currentThemeName = 'cyberCyan';
  static SharedPreferences? _prefs;

  static const Color cyberCyan = Color(0xFF00BCD4);
  static const Color matrixGreen = Color(0xFF00FF41);
  static const Color darkBlue = Color(0xFF2196F3);
  static const Color neonPurple = Color(0xFF9C27B0);
  static const Color bloodRed = Color(0xFFF44336);

  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);

  static ThemeData cyberCyanTheme = _buildTheme(cyberCyan);
  static ThemeData matrixGreenTheme = _buildTheme(matrixGreen);
  static ThemeData darkBlueTheme = _buildTheme(darkBlue);
  static ThemeData neonPurpleTheme = _buildTheme(neonPurple);
  static ThemeData bloodRedTheme = _buildTheme(bloodRed);

  static String get currentThemeName => _currentThemeName;

  static Future<void> setTheme(String themeName) async {
    _currentThemeName = themeName;
    _prefs = await SharedPreferences.getInstance();
    await _prefs?.setString('theme', themeName);
  }

  static ThemeData get currentTheme => getTheme(_currentThemeName);

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

  static ThemeData _buildTheme(Color primaryColor) {
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
        iconTheme: IconThemeData(color: primaryColor),
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
        headlineSmall: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 16,
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
        bodySmall: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 8,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bloodRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: primaryColor.withOpacity(0.5)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          color: textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primaryColor.withOpacity(0.3),
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          color: textPrimary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: lib/main.dart
// ═══════════════════════════════════════════════════════════════════════════