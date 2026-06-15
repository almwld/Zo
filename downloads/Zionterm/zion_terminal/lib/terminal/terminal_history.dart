// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal History - سجل الطرفية                         ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: إدارة سجل أوامر الطرفية والمخرجات                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalHistory - سجل الطرفية
///                    Terminal History Manager
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalHistory extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //                      سجل الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  final List<HistoryEntry> _commandHistory = [];
  final List<HistoryEntry> _outputHistory = [];
  final List<HistoryEntry> _searchHistory = [];

  int _commandHistoryIndex = -1;
  int _maxHistorySize = 1000;
  int _maxOutputSize = 10000;

  // ═══════════════════════════════════════════════════════════════════════
  //                      البحث
  // ═══════════════════════════════════════════════════════════════════════

  String _currentSearchQuery = '';
  int _currentSearchIndex = -1;
  bool _searchCaseSensitive = false;
  bool _searchRegexEnabled = false;

  // ═══════════════════════════════════════════════════════════════════════
  //                      علامات
  // ═══════════════════════════════════════════════════════════════════════

  final Map<String, String> _bookmarks = {};
  final List<String> _commandAliases = [];

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  // ═══════════════════════════════════════════════════════════════════════

  TerminalHistory({
    int maxHistorySize = 1000,
    int maxOutputSize = 10000,
  }) {
    _maxHistorySize = maxHistorySize;
    _maxOutputSize = maxOutputSize;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إضافة السجل
  // ═══════════════════════════════════════════════════════════════════════

  void addCommand(String command) {
    if (command.trim().isEmpty) return;

    final entry = HistoryEntry(
      command: command,
      timestamp: DateTime.now(),
      type: HistoryEntryType.command,
    );

    _commandHistory.add(entry);
    _trimCommandHistory();

    _commandHistoryIndex = _commandHistory.length;
    notifyListeners();
  }

  void addOutput(String output) {
    if (output.isEmpty) return;

    final entry = HistoryEntry(
      command: output,
      timestamp: DateTime.now(),
      type: HistoryEntryType.output,
    );

    _outputHistory.add(entry);
    _trimOutputHistory();
    notifyListeners();
  }

  void _trimCommandHistory() {
    while (_commandHistory.length > _maxHistorySize) {
      _commandHistory.removeAt(0);
    }
  }

  void _trimOutputHistory() {
    while (_outputHistory.length > _maxOutputSize) {
      _outputHistory.removeAt(0);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التنقل في السجل
  // ═══════════════════════════════════════════════════════════════════════

  String? getPreviousCommand() {
    if (_commandHistory.isEmpty) return null;

    if (_commandHistoryIndex > 0) {
      _commandHistoryIndex--;
      return _commandHistory[_commandHistoryIndex].command;
    } else if (_commandHistoryIndex == 0) {
      return _commandHistory[0].command;
    }

    return null;
  }

  String? getNextCommand() {
    if (_commandHistory.isEmpty) return null;

    if (_commandHistoryIndex < _commandHistory.length - 1) {
      _commandHistoryIndex++;
      return _commandHistory[_commandHistoryIndex].command;
    } else if (_commandHistoryIndex == _commandHistory.length - 1) {
      _commandHistoryIndex = _commandHistory.length;
      return '';
    }

    return null;
  }

  void resetHistoryNavigation() {
    _commandHistoryIndex = _commandHistory.length;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      البحث في السجل
  // ═══════════════════════════════════════════════════════════════════════

  List<HistoryEntry> search(String query, {bool caseSensitive = false}) {
    if (query.isEmpty) return [];

    final results = <HistoryEntry>[];
    final searchQuery = caseSensitive ? query : query.toLowerCase();

    for (final entry in _commandHistory) {
      final searchText = caseSensitive ? entry.command : entry.command.toLowerCase();

      if (_searchRegexEnabled) {
        try {
          final regex = RegExp(query, caseSensitive: caseSensitive);
          if (regex.hasMatch(entry.command)) {
            results.add(entry);
          }
        } catch (_) {}
      } else {
        if (searchText.contains(searchQuery)) {
          results.add(entry);
        }
      }
    }

    return results;
  }

  void startSearch(String query, {bool caseSensitive = false, bool regex = false}) {
    _currentSearchQuery = query;
    _searchCaseSensitive = caseSensitive;
    _searchRegexEnabled = regex;
    _currentSearchIndex = 0;
    notifyListeners();
  }

  HistoryEntry? getNextSearchResult() {
    if (_currentSearchQuery.isEmpty) return null;

    final results = search(
      _currentSearchQuery,
      caseSensitive: _searchCaseSensitive,
    );

    if (results.isEmpty) return null;

    if (_currentSearchIndex < results.length - 1) {
      _currentSearchIndex++;
      return results[_currentSearchIndex];
    } else if (_currentSearchIndex == results.length - 1) {
      _currentSearchIndex = 0;
      return results[0];
    }

    return null;
  }

  HistoryEntry? getPreviousSearchResult() {
    if (_currentSearchQuery.isEmpty) return null;

    final results = search(
      _currentSearchQuery,
      caseSensitive: _searchCaseSensitive,
    );

    if (results.isEmpty) return null;

    if (_currentSearchIndex > 0) {
      _currentSearchIndex--;
      return results[_currentSearchIndex];
    } else if (_currentSearchIndex == 0) {
      _currentSearchIndex = results.length - 1;
      return results.last;
    }

    return null;
  }

  void endSearch() {
    _currentSearchQuery = '';
    _currentSearchIndex = -1;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      علامات
  // ═══════════════════════════════════════════════════════════════════════

  void addBookmark(String name, String command) {
    _bookmarks[name] = command;
    notifyListeners();
  }

  void removeBookmark(String name) {
    _bookmarks.remove(name);
    notifyListeners();
  }

  String? getBookmark(String name) {
    return _bookmarks[name];
  }

  List<String> getAllBookmarks() {
    return _bookmarks.keys.toList();
  }

  bool hasBookmark(String name) {
    return _bookmarks.containsKey(name);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      أسماء مستعارة
  // ═══════════════════════════════════════════════════════════════════════

  void addAlias(String name, String command) {
    final existing = _commandAliases.indexWhere((a) => a.startsWith('alias $name='));
    if (existing >= 0) {
      _commandAliases[existing] = 'alias $name=$command';
    } else {
      _commandAliases.add('alias $name=$command');
    }
    notifyListeners();
  }

  void removeAlias(String name) {
    _commandAliases.removeWhere((a) => a.startsWith('alias $name='));
    notifyListeners();
  }

  String? getAlias(String name) {
    for (final alias in _commandAliases) {
      if (alias.startsWith('alias $name=')) {
        return alias.substring('alias $name='.length);
      }
    }
    return null;
  }

  List<String> getAllAliases() {
    return List.unmodifiable(_commandAliases);
  }

  String expandAlias(String command) {
    for (final alias in _commandAliases) {
      if (alias.startsWith('alias ')) {
        final parts = alias.substring('alias '.length).split('=');
        if (parts.length >= 2) {
          final name = parts[0];
          final value = parts.sublist(1).join('=');
          if (command.startsWith('$name ')) {
            return '$value ${command.substring(name.length + 1)}';
          } else if (command == name) {
            return value;
          }
        }
      }
    }
    return command;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      المسح والحذف
  // ═══════════════════════════════════════════════════════════════════════

  void clearCommandHistory() {
    _commandHistory.clear();
    _commandHistoryIndex = -1;
    notifyListeners();
  }

  void clearOutputHistory() {
    _outputHistory.clear();
    notifyListeners();
  }

  void clearAllHistory() {
    clearCommandHistory();
    clearOutputHistory();
    notifyListeners();
  }

  void deleteHistoryEntry(int index, {bool fromCommandHistory = true}) {
    if (fromCommandHistory) {
      if (index >= 0 && index < _commandHistory.length) {
        _commandHistory.removeAt(index);
        notifyListeners();
      }
    } else {
      if (index >= 0 && index < _outputHistory.length) {
        _outputHistory.removeAt(index);
        notifyListeners();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الوصول
  // ═══════════════════════════════════════════════════════════════════════

  List<HistoryEntry> get commandHistory => List.unmodifiable(_commandHistory);
  List<HistoryEntry> get outputHistory => List.unmodifiable(_outputHistory);
  int get commandCount => _commandHistory.length;
  int get outputCount => _outputHistory.length;

  HistoryEntry? getCommandAt(int index) {
    if (index >= 0 && index < _commandHistory.length) {
      return _commandHistory[index];
    }
    return null;
  }

  HistoryEntry? getLastCommand() {
    if (_commandHistory.isNotEmpty) {
      return _commandHistory.last;
    }
    return null;
  }

  String getAllOutput() {
    return _outputHistory.map((e) => e.command).join('');
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الإعدادات
  // ═══════════════════════════════════════════════════════════════════════

  void setMaxHistorySize(int size) {
    _maxHistorySize = size;
    _trimCommandHistory();
    notifyListeners();
  }

  void setMaxOutputSize(int size) {
    _maxOutputSize = size;
    _trimOutputHistory();
    notifyListeners();
  }

  int get maxHistorySize => _maxHistorySize;
  int get maxOutputSize => _maxOutputSize;

  // ═══════════════════════════════════════════════════════════════════════
  //                      التصدير والاستيراد
  // ═══════════════════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return {
      'commandHistory': _commandHistory.map((e) => e.toJson()).toList(),
      'aliases': _commandAliases,
      'bookmarks': _bookmarks,
      'maxHistorySize': _maxHistorySize,
      'maxOutputSize': _maxOutputSize,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    clearAllHistory();

    if (json['commandHistory'] != null) {
      for (final entryJson in json['commandHistory']) {
        _commandHistory.add(HistoryEntry.fromJson(entryJson));
      }
    }

    if (json['aliases'] != null) {
      _commandAliases.addAll(List<String>.from(json['aliases']));
    }

    if (json['bookmarks'] != null) {
      _bookmarks.addAll(Map<String, String>.from(json['bookmarks']));
    }

    _maxHistorySize = json['maxHistorySize'] ?? 1000;
    _maxOutputSize = json['maxOutputSize'] ?? 10000;

    notifyListeners();
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    HistoryEntry - إدخال سجل
///                    History Entry
/// ═══════════════════════════════════════════════════════════════════════════

enum HistoryEntryType {
  command,
  output,
  error,
  system,
}

class HistoryEntry {
  final String command;
  final DateTime timestamp;
  final HistoryEntryType type;
  final String? workingDirectory;
  final int? exitCode;

  HistoryEntry({
    required this.command,
    required this.timestamp,
    required this.type,
    this.workingDirectory,
    this.exitCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'workingDirectory': workingDirectory,
      'exitCode': exitCode,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      command: json['command'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: HistoryEntryType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => HistoryEntryType.command,
      ),
      workingDirectory: json['workingDirectory'],
      exitCode: json['exitCode'],
    );
  }

  @override
  String toString() {
    return '[$timestamp] $command';
  }
}