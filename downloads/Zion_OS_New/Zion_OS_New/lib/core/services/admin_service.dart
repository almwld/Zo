import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService extends ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();
  
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _permissions = [];
  List<Map<String, dynamic>> _systemLogs = [];
  bool _maintenanceMode = false;
  
  Future<void> init() async {
    await _loadUsers();
    await _loadPermissions();
    await _loadSystemLogs();
  }
  
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('admin_users');
    if (usersJson != null) {
      try {
        _users = List<Map<String, dynamic>>.from(jsonDecode(usersJson));
      } catch (_) {}
    }
    
    if (_users.isEmpty) {
      _users = [
        {'id': '1', 'username': 'admin', 'role': 'Administrator', 'permissions': 'full', 'active': true},
        {'id': '2', 'username': 'operator', 'role': 'Operator', 'permissions': 'limited', 'active': true},
        {'id': '3', 'username': 'viewer', 'role': 'Viewer', 'permissions': 'readonly', 'active': false},
      ];
      await _saveUsers();
    }
  }
  
  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    const permsJson = prefs.getString('admin_permissions');
    if (permsJson != null) {
      try {
        _permissions = List<Map<String, dynamic>>.from(jsonDecode(permsJson));
      } catch (_) {}
    }
    
    if (_permissions.isEmpty) {
      _permissions = [
        {'id': '1', 'name': 'Full Access', 'level': 100, 'description': 'Complete system access'},
        {'id': '2', 'name': 'Limited Access', 'level': 50, 'description': 'Limited functionality access'},
        {'id': '3', 'name': 'Read Only', 'level': 10, 'description': 'View only access'},
      ];
      await _savePermissions();
    }
  }
  
  Future<void> _loadSystemLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString('system_logs');
    if (logsJson != null) {
      try {
        _systemLogs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));
      } catch (_) {}
    }
  }
  
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_users', jsonEncode(_users));
  }
  
  Future<void> _savePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_permissions', jsonEncode(_permissions));
  }
  
  Future<void> _saveSystemLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('system_logs', jsonEncode(_systemLogs));
  }
  
  void addSystemLog(String action, String user, String details) {
    final log = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'user': user,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _systemLogs.insert(0, log);
    if (_systemLogs.length > 500) _systemLogs = _systemLogs.sublist(0, 500);
    _saveSystemLogs();
    notifyListeners();
  }
  
  Future<void> addUser(String username, String role, String permissions, bool active) async {
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': username,
      'role': role,
      'permissions': permissions,
      'active': active,
    };
    _users.add(newUser);
    await _saveUsers();
    addSystemLog('User Added', 'admin', 'Added user: $username');
    notifyListeners();
  }
  
  Future<void> updateUser(String id, bool active) async {
    final index = _users.indexWhere((u) => u['id'] == id);
    if (index != -1) {
      _users[index]['active'] = active;
      await _saveUsers();
      addSystemLog('User Updated', 'admin', 'Updated user: ${_users[index]['username']}');
      notifyListeners();
    }
  }
  
  Future<void> deleteUser(String id) async {
    final user = _users.firstWhere((u) => u['id'] == id);
    _users.removeWhere((u) => u['id'] == id);
    await _saveUsers();
    addSystemLog('User Deleted', 'admin', 'Deleted user: ${user['username']}');
    notifyListeners();
  }
  
  void setMaintenanceMode(bool enabled) {
    _maintenanceMode = enabled;
    addSystemLog('Maintenance Mode', 'admin', enabled ? 'Enabled' : 'Disabled');
    notifyListeners();
  }
  
  Future<void> clearSystemLogs() async {
    _systemLogs.clear();
    await _saveSystemLogs();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getUsers() => List.from(_users);
  List<Map<String, dynamic>> getPermissions() => List.from(_permissions);
  List<Map<String, dynamic>> getSystemLogs({int? limit}) {
    if (limit != null) {
      return _systemLogs.take(limit).toList();
    }
    return List.from(_systemLogs);
  }
  
  bool get maintenanceMode => _maintenanceMode;
  
  Map<String, dynamic> getSystemStats() {
    return {
      'total_users': _users.length,
      'active_users': _users.where((u) => u['active']).length,
      'total_logs': _systemLogs.length,
      'maintenance_mode': _maintenanceMode,
    };
  }
}

// Helper functions
String jsonEncode(List<Map<String, dynamic>> data) {
  return data.toString();
}

List<Map<String, dynamic>> jsonDecode(String data) {
  return [];
}
