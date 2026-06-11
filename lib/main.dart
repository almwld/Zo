import 'package:flutter/material.dart';
import 'screens/lock_screen.dart';

void main() {
  runApp(const ZionOSApp());
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion OS 2027',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00BCD4),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4)),
      ),
      home: const LockScreen(),
    );
  }
}
