import 'package:flutter/material.dart';

class AppStore extends StatefulWidget {
  const AppStore({super.key});

  @override
  State<AppStore> createState() => _AppStoreState();
}

class _AppStoreState extends State<AppStore> {
  int _selectedCategory = 0;
  final List<String> _categories = ['الكل', 'الأدوات', 'الألعاب', 'التعليم', 'الأمان'];
  
  final List<Map<String, dynamic>> _apps = [
    {'name': 'Network Scanner', 'category': 'الأدوات', 'icon': Icons.network_wifi, 'rating': 4.8, 'downloads': '10K+', 'installed': true},
    {'name': 'Password Cracker', 'category': 'الأدوات', 'icon': Icons.vpn_key, 'rating': 4.6, 'downloads': '5K+', 'installed': true},
    {'name': 'DDoS Attack', 'category': 'الأدوات', 'icon': Icons.speed, 'rating': 4.5, 'downloads': '3K+', 'installed': false},
    {'name': 'Memory Game', 'category': 'الألعاب', 'icon': Icons.memory, 'rating': 4.9, 'downloads': '15K+', 'installed': false},
    {'name': 'Crypto Course', 'category': 'التعليم', 'icon': Icons.lock, 'rating': 4.7, 'downloads': '2K+', 'installed': false},
    {'name': 'Firewall Pro', 'category': 'الأمان', 'icon': Icons.firewall, 'rating': 4.8, 'downloads': '8K+', 'installed': false},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredApps = _selectedCategory == 0 
        ? _apps 
        : _apps.where((app) => app['category'] == _categories[_selectedCategory]).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('متجر التطبيقات', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF00FF41)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // فئات
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00FF41) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.5)),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : const Color(0xFF00FF41),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          // قائمة التطبيقات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filteredApps.length,
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF41).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(app['icon'], color: const Color(0xFF00FF41), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                Text(' ${app['rating']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(width: 10),
                                const Icon(Icons.download, color: Color(0xFF00FF41), size: 14),
                                Text(' ${app['downloads']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: app['installed'] ? Colors.green : const Color(0xFF00FF41),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          app['installed'] ? 'مثبت' : 'تثبيت',
                          style: TextStyle(color: app['installed'] ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
