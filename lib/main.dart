import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/lock/lock_screen.dart';
import 'src/features/desktop/glass_desktop.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;
  
  if (isFirstLaunch) {
    await prefs.setBool('first_launch', false);
  }
  
  runApp(ZionOS(isFirstLaunch: isFirstLaunch));
}

class ZionOS extends StatelessWidget {
  final bool isFirstLaunch;
  const ZionOS({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion OS v3.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
      ),
      initialRoute: isFirstLaunch ? '/onboarding' : '/lock',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/lock': (context) => const LockScreen(),
        '/home': (context) => const GlassDesktop(),
      },
    );
  }
}
