import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class FileManagerApp extends StatefulWidget {
  const FileManagerApp({super.key});

  @override
  State<FileManagerApp> createState() => _FileManagerAppState();
}

class _FileManagerAppState extends State<FileManagerApp> {
  String _currentPath = '/storage/emulated/0';
  List<FileSystemEntity> _items = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      _hasPermission = result.isGranted;
    } else {
      _hasPermission = true;
    }
    if (_hasPermission) _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final dir = Directory(_currentPath);
      if (await dir.exists()) {
        final items = await dir.list().toList();
        items.sort((a, b) {
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.split('/').last.compareTo(b.path.split('/').last);
        });
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateTo(String path) {
    setState(() {
      _currentPath = path;
      _loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[50],
        appBar: AppBar(
          title: Text('File Manager', style: TextStyle(color: theme.primaryColor)),
          backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              const Text('مطلوب صلاحية التخزين', style: TextStyle(color: Colors.white38)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                child: const Text('منح الصلاحية', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(_currentPath.split('/').last, style: TextStyle(color: theme.primaryColor)),
        backgroundColor: theme.isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryColor),
            onPressed: _loadItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isDir = item is Directory;
                return ListTile(
                  leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file, color: theme.primaryColor),
                  title: Text(item.path.split('/').last, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
                  onTap: () {
                    if (isDir) _navigateTo(item.path);
                  },
                );
              },
            ),
    );
  }
}
