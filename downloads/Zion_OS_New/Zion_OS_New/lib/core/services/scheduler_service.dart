import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulerService extends ChangeNotifier {
  static final SchedulerService _instance = SchedulerService._internal();
  factory SchedulerService() => _instance;
  SchedulerService._internal();
  
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _alerts = [];
  Timer? _checkTimer;
  
  Future<void> init() async {
    await _loadTasks();
    await _loadAlerts();
    _startChecker();
  }
  
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('scheduled_tasks');
    if (tasksJson != null) {
      try {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
      } catch (_) {}
    }
    
    if (_tasks.isEmpty) {
      _tasks = [
        {'id': '1', 'name': 'System Scan', 'time': '09:00', 'days': 'Mon,Wed,Fri', 'active': true, 'type': 'security'},
        {'id': '2', 'name': 'Backup', 'time': '23:00', 'days': 'Daily', 'active': true, 'type': 'backup'},
        {'id': '3', 'name': 'Cache Clean', 'time': '02:00', 'days': 'Sun', 'active': false, 'type': 'maintenance'},
      ];
      await _saveTasks();
    }
  }
  
  Future<void> _loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getString('alerts');
    if (alertsJson != null) {
      try {
        _alerts = List<Map<String, dynamic>>.from(jsonDecode(alertsJson));
      } catch (_) {}
    }
  }
  
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduled_tasks', jsonEncode(_tasks));
  }
  
  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alerts', jsonEncode(_alerts));
  }
  
  void _startChecker() {
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTasks();
    });
  }
  
  void _checkTasks() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (final task in _tasks) {
      if (task['active'] && task['time'] == currentTime) {
        _addAlert('Task: ${task['name']}', 'Scheduled task is running', 'info');
      }
    }
  }
  
  void addTask(String name, String time, String days, String type) {
    final newTask = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'time': time,
      'days': days,
      'active': true,
      'type': type,
    };
    _tasks.add(newTask);
    _saveTasks();
    notifyListeners();
    _addAlert('Task Added', 'New task "$name" has been scheduled', 'success');
  }
  
  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      _tasks[index]['active'] = !_tasks[index]['active'];
      _saveTasks();
      notifyListeners();
    }
  }
  
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t['id'] == id);
    _saveTasks();
    notifyListeners();
  }
  
  void _addAlert(String title, String message, String severity) {
    final newAlert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };
    _alerts.insert(0, newAlert);
    if (_alerts.length > 100) _alerts = _alerts.sublist(0, 100);
    _saveAlerts();
    notifyListeners();
  }
  
  void markAlertAsRead(String id) {
    final index = _alerts.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      _alerts[index]['read'] = true;
      _saveAlerts();
      notifyListeners();
    }
  }
  
  void markAllAlertsRead() {
    for (var alert in _alerts) {
      alert['read'] = true;
    }
    _saveAlerts();
    notifyListeners();
  }
  
  void clearAlerts() {
    _alerts.clear();
    _saveAlerts();
    notifyListeners();
  }
  
  void deleteAlert(String id) {
    _alerts.removeWhere((a) => a['id'] == id);
    _saveAlerts();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getTasks() => List.from(_tasks);
  List<Map<String, dynamic>> getAlerts() => List.from(_alerts);
  List<Map<String, dynamic>> getUnreadAlerts() => _alerts.where((a) => !a['read']).toList();
  int getUnreadCount() => _alerts.where((a) => !a['read']).length;
  
  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

// Helper for JSON encoding
String jsonEncode(List<Map<String, dynamic>> data) {
  return data.toString();
}

List<Map<String, dynamic>> jsonDecode(String data) {
  return [];
}
