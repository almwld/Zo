import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeInfo {
  final String id;
  final String name;
  final String description;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isBuiltIn;

  ThemeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.lightTheme,
    required this.darkTheme,
    this.isBuiltIn = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isBuiltIn': isBuiltIn,
  };
}

class TerminalTheme {
  final String name;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color cursorColor;
  final Color selectionColor;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color magenta;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightMagenta;
  final Color brightCyan;
  final Color brightWhite;
  final Color searchHitBackground;
  final Color searchHitForeground;
  final FontWeight fontWeight;

  TerminalTheme({
    required this.name,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.cursorColor,
    required this.selectionColor,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightMagenta,
    required this.brightCyan,
    required this.brightWhite,
    this.searchHitBackground = Colors.yellow,
    this.searchHitForeground = Colors.black,
    this.fontWeight = FontWeight.normal,
  });

  List<Color> get ansiColors => [
    black, red, green, yellow, blue, magenta, cyan, white,
    brightBlack, brightRed, brightGreen, brightYellow,
    brightBlue, brightMagenta, brightCyan, brightWhite,
  ];
}

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  bool _initialized = false;
  String _currentThemeId = 'cyberpunk';
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSize = 14.0;
  String _fontFamily = 'JetBrains Mono';

  final List<ThemeInfo> _availableThemes = [];

  final _themeController = StreamController<String>.broadcast();
  Stream<String> get onThemeChanged => _themeController.stream;

  Future<void> init() async {
    if (_initialized) return;

    _availableThemes.addAll([
      _buildCyberpunkTheme(),
      _buildMatrixTheme(),
      _buildOceanTheme(),
      _buildSunsetTheme(),
      _buildMonochromeTheme(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString('theme_id') ?? 'cyberpunk';
    _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 1];
    _fontSize = prefs.getDouble('font_size') ?? 14.0;
    _fontFamily = prefs.getString('font_family') ?? 'JetBrains Mono';

    _initialized = true;
  }

  ThemeInfo _buildCyberpunkTheme() {
    return ThemeInfo(
      id: 'cyberpunk',
      name: 'Cyberpunk',
      description: 'Neon cyberpunk aesthetic with cyan and magenta highlights',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0221),
        primaryColor: const Color(0xFF00F0FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFFFF00FF),
          surface: Color(0xFF1A0B2E),
          error: Color(0xFFFF0055),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: const Color(0xFF00F0FF),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFFCCFFFF),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A0B2E),
          foregroundColor: Color(0xFF00F0FF),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A0B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 1),
          ),
        ),
      ),
      lightTheme: ThemeData.light(),
    );
  }

  ThemeInfo _buildMatrixTheme() {
    return ThemeInfo(
      id: 'matrix',
      name: 'Matrix',
      description: 'Classic green-on-black terminal inspired by The Matrix',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00FF00),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF00),
          secondary: Color(0xFF00CC00),
          surface: Color(0xFF0A0A0A),
          error: Color(0xFFFF4444),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: const Color(0xFF00FF00),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFF00DD00),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0A),
          foregroundColor: Color(0xFF00FF00),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF0A0A0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF00FF00), width: 0.5),
          ),
        ),
      ),
      lightTheme: ThemeData.light(),
    );
  }

  ThemeInfo _buildOceanTheme() {
    return ThemeInfo(
      id: 'ocean',
      name: 'Ocean',
      description: 'Deep blue ocean-inspired theme with calming tones',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF001830),
        primaryColor: const Color(0xFF44AAFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF44AAFF),
          secondary: Color(0xFF00DDFF),
          surface: Color(0xFF002840),
          error: Color(0xFFFF6B6B),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: const Color(0xFFAADDFF),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFF88BBDD),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002840),
          foregroundColor: Color(0xFF44AAFF),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF002840),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF44AAFF), width: 1),
          ),
        ),
      ),
      lightTheme: ThemeData.light(),
    );
  }

  ThemeInfo _buildSunsetTheme() {
    return ThemeInfo(
      id: 'sunset',
      name: 'Sunset',
      description: 'Warm sunset colors with orange and purple gradients',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A0A00),
        primaryColor: const Color(0xFFFF8844),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8844),
          secondary: Color(0xFFFFAA66),
          surface: Color(0xFF2A1505),
          error: Color(0xFFFF4444),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: const Color(0xFFFFCCAA),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFFDDAA88),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A1505),
          foregroundColor: Color(0xFFFF8844),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2A1505),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFFF8844), width: 1),
          ),
        ),
      ),
      lightTheme: ThemeData.light(),
    );
  }

  ThemeInfo _buildMonochromeTheme() {
    return ThemeInfo(
      id: 'monochrome',
      name: 'Monochrome',
      description: 'Clean black and white minimal design',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFFAAAAAA),
          surface: Color(0xFF111111),
          error: Color(0xFFFF4444),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFFCCCCCC),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF444444), width: 1),
          ),
        ),
      ),
      lightTheme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: _fontSize - 2,
            color: const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Future<void> setTheme(String themeId) async {
    final themeExists = _availableThemes.any((t) => t.id == themeId);
    if (!themeExists) return;

    _currentThemeId = themeId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', themeId);

    _themeController.add(themeId);
  }

  ThemeData get currentTheme {
    final theme = _availableThemes.firstWhere(
      (t) => t.id == _currentThemeId,
      orElse: () => _availableThemes.first,
    );

    if (_themeMode == ThemeMode.light) {
      return theme.lightTheme;
    }

    return theme.darkTheme;
  }

  ThemeData get lightTheme {
    final theme = _availableThemes.firstWhere(
      (t) => t.id == _currentThemeId,
      orElse: () => _availableThemes.first,
    );
    return theme.lightTheme;
  }

  ThemeData get darkTheme {
    final theme = _availableThemes.firstWhere(
      (t) => t.id == _currentThemeId,
      orElse: () => _availableThemes.first,
    );
    return theme.darkTheme;
  }

  ThemeInfo? get currentThemeInfo {
    try {
      return _availableThemes.firstWhere((t) => t.id == _currentThemeId);
    } catch (e) {
      return _availableThemes.isNotEmpty ? _availableThemes.first : null;
    }
  }

  List<ThemeInfo> get availableThemes => List.unmodifiable(_availableThemes);

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    _themeController.add(_currentThemeId);
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(8.0, 32.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', _fontSize);
    _rebuildThemes();
    _themeController.add(_currentThemeId);
  }

  double get fontSize => _fontSize;

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_family', family);
    _rebuildThemes();
    _themeController.add(_currentThemeId);
  }

  String get fontFamily => _fontFamily;

  void _rebuildThemes() {
    _availableThemes.clear();
    _availableThemes.addAll([
      _buildCyberpunkTheme(),
      _buildMatrixTheme(),
      _buildOceanTheme(),
      _buildSunsetTheme(),
      _buildMonochromeTheme(),
    ]);
  }

  Future<void> resetToDefaults() async {
    _currentThemeId = 'cyberpunk';
    _themeMode = ThemeMode.dark;
    _fontSize = 14.0;
    _fontFamily = 'JetBrains Mono';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', _currentThemeId);
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setString('font_family', _fontFamily);

    _rebuildThemes();
    _themeController.add(_currentThemeId);
  }

  Map<String, dynamic> getStatus() {
    return {
      'currentThemeId': _currentThemeId,
      'themeMode': _themeMode.toString().split('.').last,
      'fontSize': _fontSize,
      'fontFamily': _fontFamily,
      'availableThemes': _availableThemes.map((t) => t.toJson()).toList(),
    };
  }

  void dispose() {
    _themeController.close();
  }
}
