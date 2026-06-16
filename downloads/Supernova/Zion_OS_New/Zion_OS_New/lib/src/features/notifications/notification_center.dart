import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../core/theme/theme_manager.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final ThemeManager _themeManager = ThemeManager();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  List<NotificationItem> _notifications = [];
  List<NotificationItem> _filteredNotifications = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _showFloating = true;
  int _unreadCount = 0;

  final List<String> _filters = ['All', 'System', 'Security', 'App', 'Message', 'Alert'];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSampleNotifications();
    _startAutoGenerate();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    
    tz.initializeTimeZones();
  }

  void _loadSampleNotifications() {
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'System Ready',
        message: 'Zion OS is fully operational',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'System',
        priority: 'Normal',
        isRead: false,
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      NotificationItem(
        id: '2',
        title: 'Security Alert',
        message: 'Unusual network activity detected',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: 'Security',
        priority: 'High',
        isRead: false,
        icon: Icons.warning,
        color: Colors.red,
      ),
      NotificationItem(
        id: '3',
        title: 'SI Agent Active',
        message: 'AI monitoring started on local network',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'System',
        priority: 'Normal',
        isRead: true,
        icon: Icons.psychology,
        color: Colors.purple,
      ),
      NotificationItem(
        id: '4',
        title: 'New Message',
        message: 'You have a new message from system',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'Message',
        priority: 'Low',
        isRead: true,
        icon: Icons.message,
        color: Colors.blue,
      ),
      NotificationItem(
        id: '5',
        title: 'App Update Available',
        message: 'Version 3.3.1 is ready to install',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'App',
        priority: 'Medium',
        isRead: false,
        icon: Icons.update,
        color: Colors.orange,
      ),
    ];
    _applyFilter();
    _updateUnreadCount();
    setState(() => _isLoading = false);
  }

  void _startAutoGenerate() {
    Future.delayed(const Duration(seconds: 10), () {
      _generateRandomNotification();
      _startAutoGenerate();
    });
  }

  void _generateRandomNotification() {
    final types = ['System', 'Security', 'App', 'Message', 'Alert'];
    final randomType = types[DateTime.now().millisecondsSinceEpoch % types.length];
    
    final newNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _getRandomTitle(randomType),
      message: _getRandomMessage(randomType),
      timestamp: DateTime.now(),
      type: randomType,
      priority: _getRandomPriority(),
      isRead: false,
      icon: _getIconForType(randomType),
      color: _getColorForType(randomType),
    );
    
    setState(() {
      _notifications.insert(0, newNotification);
      _applyFilter();
      _updateUnreadCount();
    });
    
    _showFloatingNotification(newNotification);
  }

  String _getRandomTitle(String type) {
    switch (type) {
      case 'System': return 'System Update';
      case 'Security': return 'Security Threat Detected';
      case 'App': return 'App Update';
      case 'Message': return 'New Message';
      case 'Alert': return 'System Alert';
      default: return 'Notification';
    }
  }

  String _getRandomMessage(String type) {
    switch (type) {
      case 'System': return 'System performance optimized';
      case 'Security': return 'Suspicious activity detected';
      case 'App': return 'New version available';
      case 'Message': return 'You have a new notification';
      case 'Alert': return 'Check system status';
      default: return 'New notification';
    }
  }

  String _getRandomPriority() {
    final priorities = ['Low', 'Normal', 'High', 'Critical'];
    return priorities[DateTime.now().millisecondsSinceEpoch % priorities.length];
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'System': return Icons.android;
      case 'Security': return Icons.security;
      case 'App': return Icons.apps;
      case 'Message': return Icons.message;
      case 'Alert': return Icons.warning;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'System': return Colors.blue;
      case 'Security': return Colors.red;
      case 'App': return Colors.orange;
      case 'Message': return Colors.green;
      case 'Alert': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Future<void> _showFloatingNotification(NotificationItem item) async {
    if (!_showFloating) return;
    
    const android = AndroidNotificationDetails(
      'zion_channel',
      'Zion Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      item.title,
      item.message,
      details,
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
      }
      _applyFilter();
      _updateUnreadCount();
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
      _applyFilter();
      _updateUnreadCount();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      _applyFilter();
      _updateUnreadCount();
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
      _applyFilter();
      _updateUnreadCount();
    });
  }

  void _clearRead() {
    setState(() {
      _notifications.removeWhere((n) => n.isRead);
      _applyFilter();
      _updateUnreadCount();
    });
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredNotifications = _notifications;
    } else {
      _filteredNotifications = _notifications.where((n) => n.type == _selectedFilter).toList();
    }
    setState(() {});
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Medium': return Colors.yellow;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notification Center'),
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        backgroundColor: theme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _clearRead,
            tooltip: 'Clear read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, color: Colors.grey, size: 64),
                            SizedBox(height: 16),
                            Text('No notifications', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (ctx, i) {
                          final notification = _filteredNotifications[i];
                          return Dismissible(
                            key: Key(notification.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteNotification(notification.id),
                            child: GestureDetector(
                              onTap: () => _markAsRead(notification.id),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: notification.isRead ? Colors.grey.shade900 : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                  border: notification.priority == 'Critical'
                                      ? Border.all(color: Colors.red, width: 1)
                                      : notification.priority == 'High'
                                          ? Border.all(color: Colors.orange, width: 1)
                                          : null,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: notification.color.withOpacity(0.2),
                                    child: Icon(notification.icon, color: notification.color),
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      color: notification.isRead ? Colors.white70 : Colors.white,
                                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    notification.message,
                                    style: const TextStyle(color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatTime(notification.timestamp),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                      if (notification.priority != 'Normal')
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(notification.priority).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            notification.priority,
                                            style: TextStyle(
                                              color: _getPriorityColor(notification.priority),
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Switch(
        value: _showFloating,
        onChanged: (v) => setState(() => _showFloating = v),
        activeColor: _themeManager.currentTheme.accent,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (ctx, i) {
          final filter = _filters[i];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.grey.shade800,
              selectedColor: _themeManager.currentTheme.accent,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final String priority;
  bool isRead;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}
