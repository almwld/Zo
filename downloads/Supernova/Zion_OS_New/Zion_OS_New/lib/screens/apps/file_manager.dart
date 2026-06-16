import 'package:flutter/material.dart';
import 'dart:io';

class FileManagerApp extends StatefulWidget {
  const FileManagerApp({super.key});

  @override
  State<FileManagerApp> createState() => _FileManagerAppState();
}

class _FileManagerAppState extends State<FileManagerApp> {
  String _currentPath = '/sdcard';
  List<FileSystemEntity> _items = [];
  List<FileSystemEntity> _selectedItems = [];
  bool _isLoading = true;
  bool _showHidden = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
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
      } else {
        setState(() {
          _errorMessage = 'Directory does not exist';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot access directory: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateTo(String path) {
    setState(() {
      _currentPath = path;
      _selectedItems.clear();
    });
    _loadItems();
  }

  void _goBack() {
    final parent = Directory(_currentPath).parent.path;
    if (parent != _currentPath) {
      _navigateTo(parent);
    }
  }

  void _toggleSelection(FileSystemEntity item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData _getFileIcon(FileSystemEntity item) {
    if (item is Directory) return Icons.folder;
    final name = item.path.split('/').last.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.gif')) return Icons.image;
    if (name.endsWith('.mp4') || name.endsWith('.avi')) return Icons.video_file;
    if (name.endsWith('.mp3') || name.endsWith('.wav')) return Icons.audiotrack;
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.txt') || name.endsWith('.dart')) return Icons.description;
    if (name.endsWith('.apk')) return Icons.android;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _showHidden 
        ? _items 
        : _items.where((item) => !item.path.split('/').last.startsWith('.')).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_currentPath.split('/').last, style: const TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00BCD4)),
            onPressed: () => setState(() => _showHidden = !_showHidden),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: _loadItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Path Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black.withOpacity(0.8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Color(0xFF00BCD4), size: 18),
                  onPressed: _goBack,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _currentPath,
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withOpacity(0.1),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ),
          
          // File List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
                : displayItems.isEmpty
                    ? const Center(child: Text('Empty folder', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          final isDirectory = item is Directory;
                          final name = item.path.split('/').last;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(_getFileIcon(item), color: isDirectory ? const Color(0xFF00BCD4) : Colors.white54, size: 28),
                              title: Text(name, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: !isDirectory
                                  ? FutureBuilder(
                                      future: item.stat(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text(_formatSize(snapshot.data!.size), style: const TextStyle(color: Colors.white38, fontSize: 10));
                                        }
                                        return const SizedBox();
                                      },
                                    )
                                  : null,
                              onTap: () {
                                if (isDirectory) {
                                  _navigateTo(item.path);
                                }
                              },
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
