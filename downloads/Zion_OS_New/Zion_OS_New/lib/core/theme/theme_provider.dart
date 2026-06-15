import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  // الثيم الليلي (داكن)
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00BCD4),
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    dividerColor: Colors.grey[800],
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF00BCD4),
      surface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF00BCD4)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // الثيم النهاري (فاتح)
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00838F),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey[100],
    dividerColor: Colors.grey[300],
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00838F),
      secondary: Color(0xFF00BCD4),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      foregroundColor: Colors.black87,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF00838F)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
  );
}
