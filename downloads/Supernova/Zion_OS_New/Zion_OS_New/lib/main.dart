import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'services/preferences_service.dart';
import 'lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PreferencesService().init();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar', 'SA'),
      startLocale: const Locale('ar', 'SA'),
      useFallbackTranslations: true,
      child: const ZionOSApp(),
    ),
  );
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesService()),
      ],
      child: Consumer<PreferencesService>(
        builder: (context, prefs, _) {
          final isArabic = EasyLocalization.of(context)?.locale.languageCode == 'ar';
          
          return MaterialApp(
            title: 'Zion OS',
            debugShowCheckedModeBanner: false,
            themeMode: prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            darkTheme: _buildTheme(true, prefs),
            theme: _buildTheme(false, prefs),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const LockScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(bool isDark, PreferencesService prefs) {
    Color primaryColor = _getColorFromName(prefs.themeColor);
    
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18 * prefs.fontScale,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 14 * prefs.fontScale),
        bodyMedium: TextStyle(fontSize: 12 * prefs.fontScale),
        titleLarge: TextStyle(fontSize: 18 * prefs.fontScale, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name) {
      case 'Cyan': return Colors.cyan;
      case 'Blue': return Colors.blue;
      case 'Purple': return Colors.purple;
      case 'Green': return Colors.green;
      case 'Orange': return Colors.orange;
      case 'Pink': return Colors.pink;
      default: return Colors.cyan;
    }
  }
}
