import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZionOSApp());
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Zion OS 2027',
            debugShowCheckedModeBanner: false,
            theme: themeManager.getThemeData(),
            home: const LockScreen(),
          );
        },
      ),
    );
  }
}
