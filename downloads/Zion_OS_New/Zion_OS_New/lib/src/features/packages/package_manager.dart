import 'package:flutter/material.dart';
import 'dart:io';

class PackageManager extends StatefulWidget {
  const PackageManager({super.key});

  @override
  State<PackageManager> createState() => _PackageManagerState();
}

class _PackageManagerState extends State<PackageManager> {
  List<Map<String, String>> _packages = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await Process.run('dpkg', ['-l']);
      final lines = result.stdout.toString().split('\n');
      
      _packages = lines.where((l) => l.startsWith('ii')).map((line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        return {
          'name': parts.length > 1 ? parts[1] : 'unknown',
          'version': parts.length > 2 ? parts[2] : 'unknown',
          'description': parts.length > 3 ? parts.sublist(3).join(' ') : '',
        };
      }).toList();
    } catch (_) {
      _packages = [
        {'name': 'zion-core', 'version': '3.1.0', 'description': 'Core system'},
        {'name': 'zion-network', 'version': '3.1.0', 'description': 'Network tools'},
        {'name': 'zion-crypto', 'version': '3.1.0', 'description': 'Crypto tools'},
      ];
    }
    
    setState(() => _isLoading = false);
  }

  List<Map<String, String>> get _filteredPackages {
    if (_searchController.text.isEmpty) return _packages;
    return _packages.where((p) => 
      p['name']!.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Package Manager'),
        backgroundColor: Colors.indigo.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search packages...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredPackages.length,
                    itemBuilder: (ctx, i) => Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.archive, color: Colors.indigo),
                        title: Text(_filteredPackages[i]['name']!, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${_filteredPackages[i]['version']}\n${_filteredPackages[i]['description']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
