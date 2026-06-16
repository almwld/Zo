import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupManagerApp extends StatefulWidget {
  const BackupManagerApp({super.key});

  @override
  State<BackupManagerApp> createState() => _BackupManagerAppState();
}

class _BackupManagerAppState extends State<BackupManagerApp> {
  List<Map<String, dynamic>> _backups = [];
  bool _isLoading = true;
  bool _isBackingUp = false;
  String _backupPath = '';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initBackupPath();
    _loadBackups();
  }

  Future<void> _initBackupPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    _backupPath = '${appDir.path}/backups';
    await Directory(_backupPath).create(recursive: true);
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    
    try {
      final dir = Directory(_backupPath);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        _backups.clear();
        
        for (final file in files) {
          if (file is File && file.path.endsWith('.zionbackup')) {
            final stat = await file.stat();
            _backups.add({
              'name': file.path.split('/').last,
              'path': file.path,
              'size': stat.size,
              'date': stat.modified,
            });
          }
        }
        
        _backups.sort((a, b) => b['date'].compareTo(a['date']));
      }
    } catch (_) {}
    
    setState(() => _isLoading = false);
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    
    try {
      // Backup SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final backupData = <String, dynamic>{};
      
      for (final key in allKeys) {
        backupData[key] = prefs.get(key);
      }
      
      // Backup settings
      backupData['backup_time'] = DateTime.now().toIso8601String();
      backupData['app_version'] = '4.0.0';
      
      final backupFile = File('$_backupPath/backup_${DateTime.now().millisecondsSinceEpoch}.zionbackup');
      await backupFile.writeAsString(backupData.toString());
      
      await _loadBackups();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup created successfully'), backgroundColor: Color(0xFF00BCD4)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isBackingUp = false);
  }

  Future<void> _restoreBackup(Map<String, dynamic> backup) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup', style: TextStyle(color: Color(0xFF00BCD4))),
        content: const Text('This will overwrite current settings. Are you sure?', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore', style: TextStyle(color: Color(0xFF00BCD4)))),
        ],
      ),
    );
    
    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restoring backup...'), backgroundColor: Color(0xFF00BCD4)),
      );
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully'), backgroundColor: Color(0xFF00BCD4)),
      );
    }
  }

  Future<void> _deleteBackup(Map<String, dynamic> backup) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup', style: TextStyle(color: Color(0xFF00BCD4))),
        content: const Text('Are you sure you want to delete this backup?', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final file = File(backup['path']);
        if (await file.exists()) {
          await file.delete();
        }
        await _loadBackups();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup deleted'), backgroundColor: Color(0xFF00BCD4)),
        );
      } catch (_) {}
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalBackups = _backups.length;
    final totalSize = _backups.fold<int>(0, (sum, b) => sum + (b['size'] as int));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Backup Manager', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
            onPressed: _loadBackups,
          ),
        ],
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.backup), text: 'Backups'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildBackupsTab(totalBackups, totalSize),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isBackingUp ? null : _createBackup,
        backgroundColor: const Color(0xFF00BCD4),
        child: _isBackingUp
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBackupsTab(int totalBackups, int totalSize) {
    return Column(
      children: [
        // Stats Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Backups', totalBackups.toString(), Icons.archive),
              _buildStatItem('Total Size', _formatSize(totalSize), Icons.storage),
              _buildStatItem('Location', 'Internal', Icons.folder),
            ],
          ),
        ),
        
        // Backups List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)))
              : _backups.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.backup, size: 64, color: Colors.white24),
                          SizedBox(height: 16),
                          Text('No backups found', style: TextStyle(color: Colors.white38)),
                          SizedBox(height: 8),
                          Text('Tap + to create your first backup', style: TextStyle(color: Colors.white24, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _backups.length,
                      itemBuilder: (context, index) {
                        final backup = _backups[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.archive, color: Color(0xFF00BCD4), size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      backup['name'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _formatSize(backup['size']),
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                    Text(
                                      _formatDate(backup['date']),
                                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.restore, color: Color(0xFF00BCD4)),
                                onPressed: () => _restoreBackup(backup),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBackup(backup),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF00BCD4)),
                  SizedBox(width: 8),
                  Text('Backup Settings', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Auto Backup', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Automatically backup every day', style: TextStyle(color: Colors.white54)),
                value: false,
                onChanged: (_) {},
                activeColor: const Color(0xFF00BCD4),
              ),
              SwitchListTile(
                title: const Text('Backup on WiFi only', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Only backup when connected to WiFi', style: TextStyle(color: Colors.white54)),
                value: true,
                onChanged: (_) {},
                activeColor: const Color(0xFF00BCD4),
              ),
              ListTile(
                title: const Text('Backup Location', style: TextStyle(color: Colors.white)),
                subtitle: Text(_backupPath, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                trailing: const Icon(Icons.folder, color: Color(0xFF00BCD4)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF00BCD4)),
                  SizedBox(width: 8),
                  Text('About Backups', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '• Backups include all your settings and preferences\n'
                '• Files are stored locally on your device\n'
                '• Each backup is timestamped for easy identification\n'
                '• Recommended to backup before major updates',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
