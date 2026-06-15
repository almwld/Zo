import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();
  
  String _currentPath = '/sdcard';
  List<FileSystemEntity> _items = [];
  List<FileSystemEntity> _selectedItems = [];
  
  Future<void> init() async {
    _currentPath = '/sdcard';
    await loadItems();
  }
  
  Future<void> loadItems() async {
    final dir = Directory(_currentPath);
    if (await dir.exists()) {
      _items = await dir.list().toList();
      _items.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.split('/').last.compareTo(b.path.split('/').last);
      });
    }
  }
  
  Future<void> navigateTo(String path) async {
    _currentPath = path;
    await loadItems();
  }
  
  Future<void> goBack() async {
    final parent = Directory(_currentPath).parent.path;
    if (parent != _currentPath) {
      await navigateTo(parent);
    }
  }
  
  Future<void> createFolder(String name) async {
    final newDir = Directory('$_currentPath/$name');
    if (!await newDir.exists()) {
      await newDir.create();
      await loadItems();
    }
  }
  
  Future<void> deleteItems(List<FileSystemEntity> items) async {
    for (final item in items) {
      try {
        if (item is Directory) {
          await item.delete(recursive: true);
        } else {
          await item.delete();
        }
      } catch (_) {}
    }
    await loadItems();
    _selectedItems.clear();
  }
  
  Future<void> renameItem(FileSystemEntity item, String newName) async {
    final newPath = '${Directory(item.path).parent.path}/$newName';
    await item.rename(newPath);
    await loadItems();
  }
  
  Future<Map<String, dynamic>> getFileInfo(FileSystemEntity item) async {
    final stat = await item.stat();
    return {
      'name': item.path.split('/').last,
      'path': item.path,
      'size': stat.size,
      'modified': stat.modified,
      'isDirectory': item is Directory,
    };
  }
  
  Future<String> readTextFile(File file) async {
    return await file.readAsString();
  }
  
  Future<void> writeTextFile(File file, String content) async {
    await file.writeAsString(content);
  }
  
  String get currentPath => _currentPath;
  List<FileSystemEntity> get items => _items;
  List<FileSystemEntity> get selectedItems => _selectedItems;
  
  void toggleSelection(FileSystemEntity item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
  }
  
  void clearSelection() {
    _selectedItems.clear();
  }
  
  bool get isSelecting => _selectedItems.isNotEmpty;
  
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  IconData getFileIcon(String filename) {
    if (filename.endsWith('.jpg') || filename.endsWith('.png') || filename.endsWith('.gif')) {
      return Icons.image;
    } else if (filename.endsWith('.mp4') || filename.endsWith('.avi')) {
      return Icons.video_file;
    } else if (filename.endsWith('.mp3') || filename.endsWith('.wav')) {
      return Icons.audiotrack;
    } else if (filename.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (filename.endsWith('.txt') || filename.endsWith('.dart') || filename.endsWith('.json')) {
      return Icons.description;
    } else if (filename.endsWith('.apk')) {
      return Icons.android;
    } else if (filename.endsWith('.zip') || filename.endsWith('.rar')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }
}
