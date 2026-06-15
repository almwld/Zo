import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/notification_service.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'all';
  
  final List<String> _filterOptions = ['all', 'info', 'success', 'warning', 'error', 'security'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final allNotifications = notificationService.getNotifications();
    final unreadNotifications = notificationService.getNotifications(unreadOnly: true);
    
    List<Map<String, dynamic>> filteredNotifications = allNotifications;
    if (_filterType != 'all') {
      filteredNotifications = allNotifications.where((n) => n['type'] == _filterType).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF00BCD4)),
            const SizedBox(width: 8),
            const Text('Notification Center', style: TextStyle(color: Color(0xFF00BCD4))),
            if (notificationService.getUnreadCount() > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${notificationService.getUnreadCount()}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF00BCD4)),
            onPressed: () => notificationService.markAllAsRead(),
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Color(0xFF00BCD4)),
            onPressed: () => notificationService.clearAll(),
            tooltip: 'Clear all',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filterOptions.map((filter) {
                final isSelected = _filterType == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF00BCD4),
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterType = filter),
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFF00BCD4),
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(color: Color(0xFF00BCD4), height: 1),
          
          // Notifications list
          Expanded(
            child: _tabController.index == 0
                ? _buildNotificationList(filteredNotifications, notificationService)
                : _buildNotificationList(unreadNotifications, notificationService),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationList(List<Map<String, dynamic>> notifications, NotificationService service) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final type = NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == notification['type'],
          orElse: () => NotificationType.info,
        );
        final isUnread = !notification['read'];
        
        return Dismissible(
          key: Key(notification['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => service.removeNotification(notification['id']),
          child: GestureDetector(
            onTap: () => service.markAsRead(notification['id']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnread 
                    ? type.getColor().withOpacity(0.1)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnread 
                      ? type.getColor().withOpacity(0.5)
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: type.getColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(type.getIcon(), color: type.getColor(), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: TextStyle(
                            color: isUnread ? type.getColor() : Colors.white,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'],
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification['timestamp']),
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (!notification['read'])
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: type.getColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${diff.inDays ~/ 7} weeks ago';
  }
}
