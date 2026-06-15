import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedAlertsService extends ChangeNotifier {
  static final AdvancedAlertsService _instance = AdvancedAlertsService._internal();
  factory AdvancedAlertsService() => _instance;
  AdvancedAlertsService._internal();
  
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _notifications = [];
  Timer? _monitorTimer;
  
  Future<void> init() async {
    await _loadAlerts();
    await _loadNotifications();
    _startMonitoring();
  }
  
  Future<void> _loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getString('advanced_alerts');
    if (alertsJson != null) {
      try {
        _alerts = List<Map<String, dynamic>>.from(jsonDecode(alertsJson));
      } catch (_) {}
    }
  }
  
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      try {
        _notifications = List<Map<String, dynamic>>.from(jsonDecode(notificationsJson));
      } catch (_) {}
    }
  }
  
  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('advanced_alerts', jsonEncode(_alerts));
  }
  
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications));
  }
  
  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForAlerts();
    });
  }
  
  void _checkForAlerts() {
    // Simulate alerts
    if (DateTime.now().second % 30 == 0) {
      _addAlert(
        'System Check',
        'Automatic system scan completed',
        'info',
        duration: 5,
      );
    }
  }
  
  void _addAlert(String title, String message, String severity, {int duration = 0}) {
    final alert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };
    _alerts.insert(0, alert);
    if (_alerts.length > 100) _alerts = _alerts.sublist(0, 100);
    _saveAlerts();
    notifyListeners();
    
    if (duration > 0) {
      Future.delayed(Duration(seconds: duration), () {
        _alerts.removeWhere((a) => a['id'] == alert['id']);
        notifyListeners();
      });
    }
  }
  
  void addCustomAlert(String title, String message, String severity) {
    _addAlert(title, message, severity);
  }
  
  void addNotification(String title, String message, String type) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };
    _notifications.insert(0, notification);
    if (_notifications.length > 200) _notifications = _notifications.sublist(0, 200);
    _saveNotifications();
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
  
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
      _saveNotifications();
      notifyListeners();
    }
  }
  
  void markAllNotificationsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    _saveNotifications();
    notifyListeners();
  }
  
  void clearNotifications() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }
  
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    _saveNotifications();
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getAlerts({bool unreadOnly = false}) {
    if (unreadOnly) {
      return _alerts.where((a) => !a['read']).toList();
    }
    return List.from(_alerts);
  }
  
  List<Map<String, dynamic>> getNotifications({bool unreadOnly = false}) {
    if (unreadOnly) {
      return _notifications.where((n) => !n['read']).toList();
    }
    return List.from(_notifications);
  }
  
  int getUnreadAlertsCount() => _alerts.where((a) => !a['read']).length;
  int getUnreadNotificationsCount() => _notifications.where((n) => !n['read']).length;
  
  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }
}

// Helper functions
String jsonEncode(List<Map<String, dynamic>> data) {
  return data.toString();
}

List<Map<String, dynamic>> jsonDecode(String data) {
  return [];
}
