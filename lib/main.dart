import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/core/theme/theme_manager.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/lock/lock_screen.dart';
import 'src/features/desktop/responsive_desktop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  final themeManager = ThemeManager();
  await themeManager.loadSettings();
  
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;
  
  if (isFirstLaunch) {
    await prefs.setBool('first_launch', false);
  }
  
  runApp(ZionOS(isFirstLaunch: isFirstLaunch, themeManager: themeManager));
}

class ZionOS extends StatelessWidget {
  final bool isFirstLaunch;
  final ThemeManager themeManager;
  const ZionOS({super.key, required this.isFirstLaunch, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion OS v3.3',
      debugShowCheckedModeBanner: false,
      theme: themeManager.getTheme(),
      initialRoute: isFirstLaunch ? '/onboarding' : '/lock',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/lock': (context) => const LockScreen(),
        '/home': (context) => const ResponsiveDesktop(),
        '/file_manager': (context) => const AdvancedFileManager(),
        '/browser': (context) => const AdvancedBrowser(),
      },
    );
  }
}
