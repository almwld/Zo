import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/scheduler_service.dart';

class AlertsSchedulerCenter extends StatefulWidget {
  const AlertsSchedulerCenter({super.key});

  @override
  State<AlertsSchedulerCenter> createState() => _AlertsSchedulerCenterState();
}

class _AlertsSchedulerCenterState extends State<AlertsSchedulerCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskTimeController = TextEditingController();
  String _selectedDays = 'Daily';
  String _selectedType = 'security';
  
  final List<String> _dayOptions = ['Daily', 'Mon,Wed,Fri', 'Tue,Thu', 'Weekends', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _typeOptions = ['security', 'backup', 'maintenance', 'scan', 'custom'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskTimeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addTask(SchedulerService service) {
    if (_taskNameController.text.isEmpty || _taskTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task name and time'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    service.addTask(
      _taskNameController.text,
      _taskTimeController.text,
      _selectedDays,
      _selectedType,
    );
    
    _taskNameController.clear();
    _taskTimeController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added successfully'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchedulerService>(
      builder: (context, service, child) {
        final tasks = service.getTasks();
        final alerts = service.getAlerts();
        final unreadCount = service.getUnreadCount();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Alerts & Scheduler', style: TextStyle(color: Color(0xFF00BCD4))),
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Color(0xFF00BCD4)),
                    onPressed: () => _tabController.animateTo(1),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00BCD4),
              unselectedLabelColor: Colors.white54,
              indicatorColor: const Color(0xFF00BCD4),
              tabs: const [
                Tab(icon: Icon(Icons.schedule), text: 'Tasks'),
                Tab(icon: Icon(Icons.notifications_active), text: 'Alerts'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(service, tasks),
              _buildAlertsTab(service, alerts),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTasksTab(SchedulerService service, List<Map<String, dynamic>> tasks) {
    return Column(
      children: [
        // Add Task Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const Text('Schedule New Task', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _taskNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taskTimeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Time (HH:MM)',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDays,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Color(0xFF00BCD4)),
                decoration: const InputDecoration(
                  labelText: 'Days',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
                items: _dayOptions.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (v) => setState(() => _selectedDays = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Color(0xFF00BCD4)),
                decoration: const InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
                items: _typeOptions.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addTask(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tasks List
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('No scheduled tasks', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: task['active'] 
                              ? const Color(0xFF00BCD4).withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                        ),
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
                            child: Icon(
                              _getTypeIcon(task['type']),
                              color: const Color(0xFF00BCD4),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('${task['time']} • ${task['days']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch(
                            value: task['active'],
                            onChanged: (_) => service.toggleTask(task['id']),
                            activeColor: const Color(0xFF00BCD4),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => service.deleteTask(task['id']),
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
  
  Widget _buildAlertsTab(SchedulerService service, List<Map<String, dynamic>> alerts) {
    return Column(
      children: [
        if (alerts.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: service.markAllAlertsRead,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark all read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: const Color(0xFF00BCD4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: service.clearAlerts,
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Clear all'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: alerts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('No alerts', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Dismissible(
                      key: Key(alert['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => service.deleteAlert(alert['id']),
                      child: GestureDetector(
                        onTap: () => service.markAlertAsRead(alert['id']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: alert['read']
                                ? Colors.white.withOpacity(0.03)
                                : _getSeverityColor(alert['severity']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getSeverityColor(alert['severity']).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getSeverityIcon(alert['severity']),
                                color: _getSeverityColor(alert['severity']),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(alert['title'], style: TextStyle(color: _getSeverityColor(alert['severity']), fontWeight: FontWeight.bold)),
                                    Text(alert['message'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text(_formatDate(alert['timestamp']), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                  ],
                                ),
                              ),
                              if (!alert['read'])
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(alert['severity']),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'security': return Icons.security;
      case 'backup': return Icons.backup;
      case 'maintenance': return Icons.build;
      case 'scan': return Icons.scanner;
      default: return Icons.schedule;
    }
  }
  
  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'success': return Icons.check_circle;
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      default: return Icons.info;
    }
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'success': return Colors.green;
      case 'warning': return Colors.orange;
      case 'error': return Colors.red;
      default: return const Color(0xFF00BCD4);
    }
  }
  
  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
