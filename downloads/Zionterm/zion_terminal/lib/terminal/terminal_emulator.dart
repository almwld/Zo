// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Emulator - محاكي الطرفية                      ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: محاكي طرفية كامل مع معالجة escape sequences                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'dart:async';
import 'package:flutter/material.dart';
import 'terminal_cell.dart';
import 'terminal_screen.dart';
import 'terminal_colors.dart';
import '../arabic/arabic_shaper.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalEmulator - محاكي الطرفية
///                    Terminal Emulator with Escape Sequence Processing
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalEmulator {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الأساسية
  //                      Core Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// شاشة الطرفية
  late TerminalScreen screen;

  /// مستمع الإخراج
  void Function(String)? onOutput;

  /// مستمع تغيير الحجم
  void Function(int, int)? onResize;

  /// حالة escape sequence الحالية
  EscapeSequenceState _escapeState = EscapeSequenceState.idle;

  /// معلمات CSI
  List<int> _csiParams = [];

  /// حرف CSI الحالي
  String _csiCommand = '';

  /// النص التراكمي للـ OSC
  String _oscText = '';

  /// مؤقت للـ DCS
  Timer? _dcsTimer;

  // ═══════════════════════════════════════════════════════════════════════
  //                      أنماط النص الحالية
  // ═══════════════════════════════════════════════════════════════════════

  Color _currentForeground = TerminalColors.defaultForeground;
  Color _currentBackground = TerminalColors.defaultBackground;
  bool _bold = false;
  bool _italic = false;
  bool _underline = false;
  bool _strikethrough = false;
  bool _blink = false;
  bool _hidden = false;
  bool _reverse = false;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص تصحيح الأخطاء
  // ═══════════════════════════════════════════════════════════════════════

  bool debugMode = false;
  final List<String> _debugLog = [];
  static const int maxDebugLogSize = 1000;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  // ═══════════════════════════════════════════════════════════════════════

  TerminalEmulator({
    int rows = 24,
    int columns = 80,
  }) {
    screen = TerminalScreen(rows: rows, columns: columns);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الكتابة والمعالجة
  // ═══════════════════════════════════════════════════════════════════════

  void write(String text) {
    for (int i = 0; i < text.length; i++) {
      _processChar(text[i]);
    }
  }

  void _processChar(String char) {
    switch (_escapeState) {
      case EscapeSequenceState.idle:
        _processCharIdle(char);
        break;
      case EscapeSequenceState.esc:
        _processCharEscape(char);
        break;
      case EscapeSequenceState.csi:
        _processCharCsi(char);
        break;
      case EscapeSequenceState.osc:
        _processCharOsc(char);
        break;
      case EscapeSequenceState.dcs:
        _processCharDcs(char);
        break;
      case EscapeSequenceState.oscString:
        _processCharOscString(char);
        break;
    }
  }

  void _processCharIdle(String char) {
    final code = char.codeUnitAt(0);

    if (code < 32) {
      _processControlChar(char, code);
    } else if (char == '\x1B') {
      _escapeState = EscapeSequenceState.esc;
    } else {
      _writeChar(char);
    }
  }

  void _processControlChar(String char, int code) {
    switch (code) {
      case 0x07: // BEL
        break;
      case 0x08: // BS
        screen.backspace();
        break;
      case 0x09: // HT
        screen.tab();
        break;
      case 0x0A: // LF
      case 0x0B: // VT
        screen.newLine();
        break;
      case 0x0C: // FF
        screen.newLine();
        break;
      case 0x0D: // CR
        screen.carriageReturn();
        break;
      case 0x7F: // DEL
        screen.backspace();
        break;
    }
  }

  void _processCharEscape(String char) {
    _escapeState = EscapeSequenceState.idle;

    switch (char) {
      case '[':
        _escapeState = EscapeSequenceState.csi;
        _csiParams = [];
        _csiCommand = '';
        break;
      case ']':
        _escapeState = EscapeSequenceState.osc;
        _oscText = '';
        break;
      case 'P':
        _escapeState = EscapeSequenceState.dcs;
        _oscText = '';
        break;
      case 'D':
        screen.lineFeed();
        break;
      case 'E':
        screen.carriageReturn();
        screen.lineFeed();
        break;
      case 'M':
        if (screen.cursorRow > 0) {
          screen.cursorRow--;
        }
        break;
      case 'c':
        reset();
        break;
    }
  }

  void _processCharCsi(String char) {
    final code = char.codeUnitAt(0);

    if (code >= 0x30 && code <= 0x39) {
      if (_csiParams.isEmpty) {
        _csiParams.add(code - 0x30);
      } else {
        final lastIndex = _csiParams.length - 1;
        _csiParams[lastIndex] = _csiParams[lastIndex] * 10 + (code - 0x30);
      }
    } else if (char == ';') {
      _csiParams.add(0);
    } else if (code >= 0x40 && code <= 0x7E) {
      _csiCommand = char;
      _executeCsi();
      _escapeState = EscapeSequenceState.idle;
    }
  }

  void _executeCsi() {
    final p = _csiParams.isEmpty ? [0] : _csiParams;
    final p0 = p.isNotEmpty ? p[0] : 0;
    final p1 = p.length > 1 ? p[1] : 0;

    switch (_csiCommand) {
      case 'A':
        screen.moveCursorUp(p0 == 0 ? 1 : p0);
        break;
      case 'B':
        screen.moveCursorDown(p0 == 0 ? 1 : p0);
        break;
      case 'C':
        screen.moveCursorForward(p0 == 0 ? 1 : p0);
        break;
      case 'D':
        screen.moveCursorBackward(p0 == 0 ? 1 : p0);
        break;
      case 'G':
        screen.moveCursorToColumn((p0 == 0 ? 1 : p0) - 1);
        break;
      case 'H':
      case 'f':
        final row = (p0 == 0 ? 1 : p0) - 1;
        final col = (p1 == 0 ? 1 : p1) - 1;
        screen.moveCursor(row, col);
        break;
      case 'J':
        switch (p0) {
          case 0:
            screen.clearToEndOfScreen();
            break;
          case 1:
            screen.clearToBeginningOfScreen();
            break;
          case 2:
          case 3:
            screen.clearScreen();
            break;
        }
        break;
      case 'K':
        switch (p0) {
          case 0:
            screen.clearToEndOfLine();
            break;
          case 1:
            screen.clearToBeginningOfLine();
            break;
          case 2:
            screen.clearEntireCurrentLine();
            break;
        }
        break;
      case 'P':
        screen.deleteChar();
        break;
      case 'X':
        screen.eraseChars(p0 == 0 ? 1 : p0);
        break;
      case 'd':
        screen.moveCursor(p0 - 1, screen.cursorColumn);
        break;
      case 'h':
        _handleSetMode(p, true);
        break;
      case 'l':
        _handleSetMode(p, false);
        break;
      case 'm':
        _executeSgr(p);
        break;
      case 'n':
        _handleDeviceStatusReport(p0);
        break;
      case 'r':
        final top = (p0 == 0 ? 1 : p0) - 1;
        final bottom = (p1 == 0 ? screen.rows : p1) - 1;
        if (top < bottom && bottom < screen.rows) {
          screen.scrollRegionTop = top;
          screen.scrollRegionBottom = bottom;
          screen.moveCursor(0, 0);
        }
        break;
      case 's':
        screen.saveCursor();
        break;
      case 'u':
        screen.restoreCursor();
        break;
    }
  }

  void _processCharOsc(String char) {
    if (char == '\x07') {
      _executeOsc();
      _escapeState = EscapeSequenceState.idle;
    } else if (char == '\x1B') {
      _escapeState = EscapeSequenceState.esc;
    } else {
      _oscText += char;
    }
  }

  void _executeOsc() {
    if (_oscText.isEmpty) return;
    final parts = _oscText.split(';');
    if (parts.isEmpty) return;
    final command = int.tryParse(parts[0]) ?? 0;
    // معالجة OSC commands
  }

  void _processCharDcs(String char) {
    if (char == '\x1B') {
      _escapeState = EscapeSequenceState.esc;
    } else if (char == '\\') {
      _executeDcs();
      _escapeState = EscapeSequenceState.idle;
    } else {
      _oscText += char;
    }
  }

  void _executeDcs() {}

  void _processCharOscString(String char) {
    if (char == '\x1B') {
      _escapeState = EscapeSequenceState.esc;
    } else if (char == '\\') {
      _executeOsc();
      _escapeState = EscapeSequenceState.idle;
    } else {
      _oscText += char;
    }
  }

  void _executeSgr(List<int> params) {
    if (params.isEmpty) {
      _resetStyles();
      return;
    }

    for (int i = 0; i < params.length; i++) {
      final code = params[i];

      if (code == 0) {
        _resetStyles();
      } else if (code == 1) {
        _bold = true;
      } else if (code == 3) {
        _italic = true;
      } else if (code == 4) {
        _underline = true;
      } else if (code == 7) {
        _reverse = true;
      } else if (code == 9) {
        _strikethrough = true;
      } else if (code == 22) {
        _bold = false;
      } else if (code == 23) {
        _italic = false;
      } else if (code == 24) {
        _underline = false;
      } else if (code == 27) {
        _reverse = false;
      } else if (code == 29) {
        _strikethrough = false;
      } else if (code >= 30 && code <= 37) {
        _currentForeground = TerminalColors.fromIndex(code - 30);
      } else if (code == 39) {
        _currentForeground = TerminalColors.defaultForeground;
      } else if (code >= 40 && code <= 47) {
        _currentBackground = TerminalColors.fromIndex(code - 40);
      } else if (code == 49) {
        _currentBackground = TerminalColors.defaultBackground;
      } else if (code >= 90 && code <= 97) {
        _currentForeground = TerminalColors.fromIndex(code - 90 + 8);
      } else if (code >= 100 && code <= 107) {
        _currentBackground = TerminalColors.fromIndex(code - 100 + 8);
      } else if (code == 38) {
        i = _parseExtendedColor(params, i, true);
      } else if (code == 48) {
        i = _parseExtendedColor(params, i, false);
      }
    }
  }

  int _parseExtendedColor(List<int> params, int index, bool isForeground) {
    if (index + 2 >= params.length) return index;

    if (params[index + 1] == 5) {
      final colorIndex = params[index + 2];
      if (isForeground) {
        _currentForeground = TerminalColors.fromIndex(colorIndex);
      } else {
        _currentBackground = TerminalColors.fromIndex(colorIndex);
      }
      return index + 2;
    } else if (params[index + 1] == 2) {
      if (index + 4 >= params.length) return index;
      final r = params[index + 2];
      final g = params[index + 3];
      final b = params[index + 4];
      final color = TerminalColors.fromRgb(r, g, b);
      if (isForeground) {
        _currentForeground = color;
      } else {
        _currentBackground = color;
      }
      return index + 4;
    }
    return index;
  }

  void _resetStyles() {
    _currentForeground = TerminalColors.defaultForeground;
    _currentBackground = TerminalColors.defaultBackground;
    _bold = false;
    _italic = false;
    _underline = false;
    _strikethrough = false;
    _blink = false;
    _hidden = false;
    _reverse = false;
  }

  void _handleSetMode(List<int> params, bool enable) {
    for (final mode in params) {
      switch (mode) {
        case 7:
          screen.lineWrap = enable;
          break;
      }
    }
  }

  void _handleDeviceStatusReport(int type) {
    switch (type) {
      case 5:
        write('\x1B[0n');
        break;
      case 6:
        write('\x1B[${screen.cursorRow + 1};${screen.cursorColumn + 1}R');
        break;
    }
  }

  void _writeChar(String char) {
    if (screen.wrapNext) {
      screen.carriageReturn();
      screen.lineFeed();
    }

    String displayChar = char;
    if (ArabicShaper.isArabicChar(char)) {
      displayChar = ArabicShaper.shape(char);
    }

    final cell = screen.getCell(screen.cursorRow, screen.cursorColumn);
    cell.character = displayChar;
    cell.foreground = _currentForeground;
    cell.background = _currentBackground;
    cell.bold = _bold;
    cell.italic = _italic;
    cell.underline = _underline;
    cell.strikethrough = _strikethrough;
    cell.blink = _blink;
    cell.hidden = _hidden;
    cell.reverse = _reverse;

    screen.moveCursorForwardOne();
  }

  void resize(int rows, int columns) {
    screen.resize(rows, columns);
    onResize?.call(rows, columns);
  }

  void reset() {
    screen.reinitialize();
    _resetStyles();
    _escapeState = EscapeSequenceState.idle;
    _csiParams = [];
    _csiCommand = '';
    _oscText = '';
    _debugLog.clear();
  }

  void resetScreen() {
    screen.clearScreen();
  }

  void setDebugMode(bool enabled) {
    debugMode = enabled;
    if (!enabled) {
      _debugLog.clear();
    }
  }

  void _addDebugLog(String message) {
    _debugLog.add('${DateTime.now()}: $message');
    if (_debugLog.length > maxDebugLogSize) {
      _debugLog.removeAt(0);
    }
  }

  List<String> getDebugLog() => List.unmodifiable(_debugLog);

  void clearDebugLog() {
    _debugLog.clear();
  }

  void dispose() {
    _dcsTimer?.cancel();
    onOutput = null;
    onResize = null;
  }
}

enum EscapeSequenceState {
  idle,
  esc,
  csi,
  osc,
  dcs,
  oscString,
}