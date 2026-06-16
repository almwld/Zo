import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();
  
  String? _backupPath;
  
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _backupPath = '${appDir.path}/backups';
    await Directory(_backupPath!).create(recursive: true);
  }
  
  Future<Map<String, dynamic>> createBackup(String backupName) async {
    final result = <String, dynamic>{
      'success': false,
      'path': null,
      'size': 0,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final backupData = <String, dynamic>{};
      
      for (final key in allKeys) {
        final value = prefs.get(key);
        backupData[key] = value;
      }
      
      final backupFile = File('$_backupPath/${backupName}_${DateTime.now().millisecondsSinceEpoch}.zionbackup');
      await backupFile.writeAsString(jsonEncode(backupData));
      
      final stats = await backupFile.stat();
      
      result['success'] = true;
      result['path'] = backupFile.path;
      result['size'] = stats.size;
      result['name'] = backupName;
      
      await _addToBackupHistory(backupName, backupFile.path, stats.size);
      
    } catch (e) {
      result['error'] = e.toString();
    }
    
    return result;
  }
  
  Future<Map<String, dynamic>> restoreBackup(String backupPath) async {
    final result = <String, dynamic>{
      'success': false,
      'restored_items': 0,
    };
    
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        result['error'] = 'Backup file not found';
        return result;
      }
      
      final content = await backupFile.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      
      final prefs = await SharedPreferences.getInstance();
      int restored = 0;
      
      for (final entry in backupData.entries) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value);
        } else if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value);
        } else if (entry.value is double) {
          await prefs.setDouble(entry.key, entry.value);
        }
        restored++;
      }
      
      result['success'] = true;
      result['restored_items'] = restored;
      
    } catch (e) {
      result['error'] = e.toString();
    }
    
    return result;
  }
  
  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    final backups = <Map<String, dynamic>>[];
    final historyFile = File('$_backupPath/backup_history.json');
    
    if (await historyFile.exists()) {
      try {
        final content = await historyFile.readAsString();
        final history = jsonDecode(content) as List;
        backups.addAll(history.map((b) => b as Map<String, dynamic>));
      } catch (_) {}
    }
    
    return backups.reversed.toList();
  }
  
  Future<void> _addToBackupHistory(String name, String path, int size) async {
    final historyFile = File('$_backupPath/backup_history.json');
    List<Map<String, dynamic>> history = [];
    
    if (await historyFile.exists()) {
      try {
        final content = await historyFile.readAsString();
        history = List<Map<String, dynamic>>.from(jsonDecode(content));
      } catch (_) {}
    }
    
    history.add({
      'name': name,
      'path': path,
      'size': size,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (history.length > 20) {
      history = history.sublist(history.length - 20);
    }
    
    await historyFile.writeAsString(jsonEncode(history));
  }
  
  Future<void> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      
      final historyFile = File('$_backupPath/backup_history.json');
      if (await historyFile.exists()) {
        final content = await historyFile.readAsString();
        final history = List<Map<String, dynamic>>.from(jsonDecode(content));
        history.removeWhere((b) => b['path'] == path);
        await historyFile.writeAsString(jsonEncode(history));
      }
    } catch (_) {}
  }
  
  Future<Map<String, dynamic>> getBackupStats() async {
    final history = await getBackupHistory();
    int totalSize = 0;
    for (final backup in history) {
      totalSize += backup['size'] as int;
    }
    
    return {
      'total_backups': history.length,
      'total_size': totalSize,
      'last_backup': history.isNotEmpty ? history.first['timestamp'] : null,
    };
  }
  
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
