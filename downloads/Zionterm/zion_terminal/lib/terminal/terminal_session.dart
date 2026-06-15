// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Session - جلسة الطرفية                        ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: إدارة جلسات الطرفية المتعددة                                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'dart:async';
import 'package:flutter/material.dart';
import 'terminal_emulator.dart';
import 'terminal_history.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalSession - جلسة طرفية
///                    Terminal Session Manager
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalSession extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الأساسية
  // ═══════════════════════════════════════════════════════════════════════

  final int id;
  String name;
  final TerminalEmulator emulator;
  final TerminalHistory history;

  bool isActive = true;
  bool isRunning = false;
  DateTime? startTime;
  DateTime? lastActivity;

  String currentWorkingDirectory = '/home/user';
  String? currentUser;

  final List<String> _environmentVars = [];
  final Map<String, String> _localEnvironment = {};

  StreamSubscription? _outputSubscription;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المستمعين
  // ═══════════════════════════════════════════════════════════════════════

  void Function(String)? onOutput;
  void Function(String)? onError;
  void Function()? onExit;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  // ═══════════════════════════════════════════════════════════════════════

  TerminalSession({
    required this.id,
    this.name = 'Session',
    int rows = 24,
    int columns = 80,
  })  : emulator = TerminalEmulator(rows: rows, columns: columns),
        history = TerminalHistory() {
    _initialize();
  }

  void _initialize() {
    startTime = DateTime.now();
    lastActivity = startTime;

    emulator.onOutput = (text) {
      _handleOutput(text);
    };

    emulator.onResize = (rows, cols) {
      notifyListeners();
    };

    _environmentVars.addAll([
      'TERM=xterm-256color',
      'COLORTERM=truecolor',
      'LANG=en_US.UTF-8',
      'PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
      'HOME=/home/user',
      'USER=user',
      'SHELL=/bin/bash',
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      العمليات الأساسية
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> start() async {
    if (isRunning) return;

    isRunning = true;
    isActive = true;
    lastActivity = DateTime.now();

    emulator.write('\x1B[1;32m'); // أخضر
    emulator.write('Zion OS Terminal v1.0.0\n');
    emulator.write('\x1B[0m'); // إعادة تعيين
    emulator.write('\x1B[32m'); // أخضر
    emulator.write('$currentUser@zion-os');
    emulator.write('\x1B[0m'); // أبيض
    emulator.write(':');
    emulator.write('\x1B[34m'); // أزرق
    emulator.write(currentWorkingDirectory);
    emulator.write('\x1B[0m'); // أبيض
    emulator.write('\$ ');
  }

  void stop() {
    isRunning = false;
    _outputSubscription?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!isRunning && isActive) {
      start();
    }
  }

  void close() {
    stop();
    isActive = false;
    emulator.dispose();
    _outputSubscription?.cancel();
    onExit?.call();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تنفيذ الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  void executeCommand(String command) {
    if (!isRunning) return;

    lastActivity = DateTime.now();

    emulator.write(command);
    emulator.write('\r\n');

    history.addCommand(command);
    notifyListeners();
  }

  void write(String text) {
    if (!isRunning) return;
    emulator.write(text);
    lastActivity = DateTime.now();
    notifyListeners();
  }

  void _handleOutput(String text) {
    onOutput?.call(text);
    history.addOutput(text);
    lastActivity = DateTime.now();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدارة الدليل
  // ═══════════════════════════════════════════════════════════════════════

  void setWorkingDirectory(String path) {
    currentWorkingDirectory = path;
    _updatePrompt();
  }

  String getWorkingDirectory() {
    return currentWorkingDirectory;
  }

  void _updatePrompt() {
    // تحديث موجه الطرفية
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      متغيرات البيئة
  // ═══════════════════════════════════════════════════════════════════════

  String getEnvironment(String key) {
    if (_localEnvironment.containsKey(key)) {
      return _localEnvironment[key]!;
    }
    for (final env in _environmentVars) {
      final parts = env.split('=');
      if (parts[0] == key && parts.length > 1) {
        return parts.sublist(1).join('=');
      }
    }
    return '';
  }

  void setEnvironment(String key, String value) {
    _localEnvironment[key] = value;
  }

  void unsetEnvironment(String key) {
    _localEnvironment.remove(key);
  }

  Map<String, String> getAllEnvironment() {
    final env = <String, String>{};
    for (final e in _environmentVars) {
      final parts = e.split('=');
      if (parts.length > 1) {
        env[parts[0]] = parts.sublist(1).join('=');
      }
    }
    env.addAll(_localEnvironment);
    return env;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تغيير الحجم
  // ═══════════════════════════════════════════════════════════════════════

  void resize(int rows, int columns) {
    emulator.resize(rows, columns);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      لوحة المفاتيح
  // ═══════════════════════════════════════════════════════════════════════

  void sendKey(LogicalKeyboardKey key, bool ctrl, bool alt, bool shift) {
    if (!isRunning) return;

    String sequence = '';

    if (ctrl && key.keyId >= 0x61 && key.keyId <= 0x7a) {
      // Ctrl+A to Ctrl+Z
      sequence = String.fromCharCode(key.keyId - 0x60);
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      sequence = '\r';
    } else if (key == LogicalKeyboardKey.backspace) {
      sequence = '\x7f';
    } else if (key == LogicalKeyboardKey.tab) {
      sequence = '\t';
    } else if (key == LogicalKeyboardKey.escape) {
      sequence = '\x1B';
    } else if (key == LogicalKeyboardKey.arrowUp) {
      sequence = '\x1B[A';
    } else if (key == LogicalKeyboardKey.arrowDown) {
      sequence = '\x1B[B';
    } else if (key == LogicalKeyboardKey.arrowRight) {
      sequence = '\x1B[C';
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      sequence = '\x1B[D';
    } else if (key == LogicalKeyboardKey.home) {
      sequence = '\x1B[H';
    } else if (key == LogicalKeyboardKey.end) {
      sequence = '\x1B[F';
    } else if (key == LogicalKeyboardKey.pageUp) {
      sequence = '\x1B[5~';
    } else if (key == LogicalKeyboardKey.pageDown) {
      sequence = '\x1B[6~';
    } else if (key == LogicalKeyboardKey.insert) {
      sequence = '\x1B[2~';
    } else if (key == LogicalKeyboardKey.delete) {
      sequence = '\x1B[3~';
    } else if (alt) {
      sequence = '\x1B${key.keyLabel}';
    }

    if (sequence.isNotEmpty) {
      write(sequence);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      المعلومات
  // ═══════════════════════════════════════════════════════════════════════

  Duration get uptime {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime!);
  }

  Duration get idleTime {
    if (lastActivity == null) return Duration.zero;
    return DateTime.now().difference(lastActivity!);
  }

  int get scrollbackLineCount => emulator.screen.scrollbackLineCount;

  String get sessionInfo {
    return '''
Session: $name (ID: $id)
Status: ${isRunning ? 'Running' : 'Stopped'}
Uptime: ${uptime.inHours}h ${uptime.inMinutes.remainder(60)}m
Directory: $currentWorkingDirectory
''';
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    SessionManager - مدير الجلسات
// ═══════════════════════════════════════════════════════════════════════════

class SessionManager extends ChangeNotifier {
  final List<TerminalSession> _sessions = [];
  int _nextId = 1;
  TerminalSession? _activeSession;

  List<TerminalSession> get sessions => List.unmodifiable(_sessions);
  TerminalSession? get activeSession => _activeSession;
  int get sessionCount => _sessions.length;

  TerminalSession createSession({String? name, int rows = 24, int columns = 80}) {
    final session = TerminalSession(
      id: _nextId++,
      name: name ?? 'Session $_nextId',
      rows: rows,
      columns: columns,
    );
    _sessions.add(session);
    session.onExit = () => removeSession(session.id);
    notifyListeners();
    return session;
  }

  void removeSession(int id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) {
      _activeSession = _sessions.isNotEmpty ? _sessions.last : null;
    }
    notifyListeners();
  }

  void setActiveSession(int id) {
    final session = _sessions.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Session not found'),
    );
    _activeSession = session;
    notifyListeners();
  }

  TerminalSession? getSession(int id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void closeAllSessions() {
    for (final session in _sessions) {
      session.close();
    }
    _sessions.clear();
    _activeSession = null;
    notifyListeners();
  }
}