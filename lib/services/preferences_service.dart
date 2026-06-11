import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesService extends ChangeNotifier {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // إعدادات الثيم
  String _themeColor = 'Cyan';
  bool _isDarkMode = true;
  final List<String> _availableColors = ['Cyan', 'Blue', 'Purple', 'Green', 'Orange', 'Pink'];

  // إعدادات اللغة
  String _languageCode = 'ar';

  // إعدادات الخط
  double _fontScale = 1.0;

  // إعدادات الأيقونات
  double _iconSize = 55.0;
  bool _showAppNames = true;

  // إعدادات الخلفية
  String _wallpaperPath = 'assets/images/default_wallpaper.jpg';
  double _wallpaperBlur = 0.0;

  // Getters
  String get themeColor => _themeColor;
  bool get isDarkMode => _isDarkMode;
  List<String> get availableColors => _availableColors;
  String get languageCode => _languageCode;
  double get fontScale => _fontScale;
  double get iconSize => _iconSize;
  bool get showAppNames => _showAppNames;
  String get wallpaperPath => _wallpaperPath;
  double get wallpaperBlur => _wallpaperBlur;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    _themeColor = _prefs.getString('theme_color') ?? 'Cyan';
    _isDarkMode = _prefs.getBool('is_dark_mode') ?? true;
    _languageCode = _prefs.getString('language_code') ?? 'ar';
    _fontScale = _prefs.getDouble('font_scale') ?? 1.0;
    _iconSize = _prefs.getDouble('icon_size') ?? 55.0;
    _showAppNames = _prefs.getBool('show_app_names') ?? true;
    _wallpaperPath = _prefs.getString('wallpaper_path') ?? 'assets/images/default_wallpaper.jpg';
    _wallpaperBlur = _prefs.getDouble('wallpaper_blur') ?? 0.0;
    
    notifyListeners();
  }

  Future<void> setThemeColor(String color) async {
    _themeColor = color;
    await _prefs.setString('theme_color', color);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    await _prefs.setString('language_code', code);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _prefs.setDouble('font_scale', scale);
    notifyListeners();
  }

  Future<void> setIconSize(double size) async {
    _iconSize = size;
    await _prefs.setDouble('icon_size', size);
    notifyListeners();
  }

  Future<void> setShowAppNames(bool show) async {
    _showAppNames = show;
    await _prefs.setBool('show_app_names', show);
    notifyListeners();
  }

  Future<void> setWallpaper(String path) async {
    _wallpaperPath = path;
    await _prefs.setString('wallpaper_path', path);
    notifyListeners();
  }

  Future<void> setWallpaperBlur(double blur) async {
    _wallpaperBlur = blur;
    await _prefs.setDouble('wallpaper_blur', blur);
    notifyListeners();
  }

  Future<void> changePin(String newPin) async {
    await _secureStorage.write(key: 'user_pin', value: newPin);
  }

  Future<String?> getCurrentPin() async {
    return await _secureStorage.read(key: 'user_pin');
  }
}
