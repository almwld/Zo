import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/preferences_service.dart';

class ResponsiveDesktop extends StatefulWidget {
  const ResponsiveDesktop({super.key});

  @override
  State<ResponsiveDesktop> createState() => _ResponsiveDesktopState();
}

class _ResponsiveDesktopState extends State<ResponsiveDesktop> {
  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    
    return Scaffold(
      backgroundColor: prefs.isDarkMode ? Colors.black : Colors.grey[100],
      body: Column(
        children: [
          // Top Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: prefs.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              border: Border(
                bottom: BorderSide(
                  color: prefs.isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo and Start Menu
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.cyan, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Z',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Zion OS',
                      style: TextStyle(
                        fontSize: 18 * prefs.fontScale,
                        fontWeight: FontWeight.bold,
                        color: prefs.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                
                // Time and Battery
                Row(
                  children: [
                    Icon(
                      Icons.battery_full,
                      color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('HH:mm').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14 * prefs.fontScale,
                        color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Desktop Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Categories
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryButton('ATTACK', Colors.red, prefs),
                        const SizedBox(width: 20),
                        _buildCategoryButton('DEFENSE', Colors.blue, prefs),
                        const SizedBox(width: 20),
                        _buildCategoryButton('ANALYSIS', Colors.green, prefs),
                        const SizedBox(width: 20),
                        _buildCategoryButton('TOOLS', Colors.orange, prefs),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Message
                  Text(
                    'مرحباً بك في Zion OS',
                    style: TextStyle(
                      fontSize: 24 * prefs.fontScale,
                      fontWeight: FontWeight.bold,
                      color: prefs.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'نظام تشغيل متكامل للأمن والاختراق',
                    style: TextStyle(
                      fontSize: 14 * prefs.fontScale,
                      color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Dock
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: prefs.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: prefs.isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDockIcon(Icons.terminal, 'Terminal', prefs),
                const SizedBox(width: 20),
                _buildDockIcon(Icons.wifi, 'WiFi', prefs),
                const SizedBox(width: 20),
                _buildDockIcon(Icons.security, 'Security', prefs),
                const SizedBox(width: 20),
                _buildDockIcon(Icons.settings, 'Settings', prefs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, Color color, PreferencesService prefs) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(title),
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14 * prefs.fontScale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockIcon(IconData icon, String label, PreferencesService prefs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
        ),
        if (prefs.showAppNames)
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * prefs.fontScale,
              color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'ATTACK': return Icons.bug_report;
      case 'DEFENSE': return Icons.shield;
      case 'ANALYSIS': return Icons.analytics;
      case 'TOOLS': return Icons.build;
      default: return Icons.apps;
    }
  }
}
