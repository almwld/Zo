import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Zion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(color: Colors.black),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.green),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
