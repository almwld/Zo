// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Screen - شاشة الطرفية                         ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: إدارة شاشة الطرفية - التخزين والتمرير والبحث                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'terminal_cell.dart';
import 'terminal_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalScreen - شاشة الطرفية
///                    Terminal Screen Buffer Manager
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalScreen {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الأساسية
  //                      Core Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// عدد الأسطر في الشاشة
  /// Number of rows on screen
  int rows;

  /// عدد الأعمدة في الشاشة
  /// Number of columns on screen
  int columns;

  /// مصفوفة خلايا الشاشة الحالية
  /// Current screen cell buffer
  late List<List<TerminalCell>> cells;

  /// سجل التمرير (السطور السابقة)
  /// Scrollback buffer (previous lines)
  final List<List<TerminalCell>> scrollback;

  /// الحد الأقصىلسجل التمرير
  /// Maximum scrollback lines
  final int maxScrollbackLines;

  /// موضع المؤشر - الصف
  /// Cursor position - Row
  int cursorRow;

  /// موضع المؤشر - العمود
  /// Cursor position - Column
  int cursorColumn;

  /// موضع المؤشر المحفوظ
  /// Saved cursor position - Row
  int savedCursorRow;

  /// موضع المؤشر المحفوظ
  /// Saved cursor position - Column
  int savedCursorColumn;

  /// موضع بداية التحديد
  /// Selection start position
  int? selectionStartRow;
  int? selectionStartCol;

  /// موضع نهاية التحديد
  /// Selection end position
  int? selectionEndRow;
  int? selectionEndCol;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص التمرير
  //                      Scroll Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// مؤشر التمرير الأفقي
  /// Horizontal scroll offset
  int scrollOffsetX;

  /// مؤشر التمرير الرأسي
  /// Vertical scroll offset
  int scrollOffsetY;

  /// هل التمرير مُفعّل
  /// Whether scrolling is enabled
  bool scrollEnabled;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص الطمس
  //                      Clear Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// بداية منطقة الطمس (للأعلى)
  /// Top margin for clear
  int scrollRegionTop;

  /// نهاية منطقة الطمس (للأسفل)
  /// Bottom margin for clear
  int scrollRegionBottom;

  /// وضع الطمس الحالي (إيقاف/تشغيل)
  /// Current scroll region mode (alternate)
  bool alternateScrollRegion;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص اللف
  //                      Wrap Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// هل لف السطر مُفعّل
  /// Whether line wrap is enabled
  bool lineWrap;

  /// حالة لف السطر التالي
  /// Next line wrap state
  bool wrapNext;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  //                      Constructor
  // ═══════════════════════════════════════════════════════════════════════

  /// منشئ افتراضي
  /// Default constructor
  TerminalScreen({
    this.rows = 24,
    this.columns = 80,
    this.maxScrollbackLines = 10000,
    this.cursorRow = 0,
    this.cursorColumn = 0,
    this.scrollOffsetX = 0,
    this.scrollOffsetY = 0,
    this.scrollEnabled = true,
    this.scrollRegionTop = 0,
    this.scrollRegionBottom = -1,
    this.alternateScrollRegion = false,
    this.lineWrap = true,
    this.wrapNext = false,
  })  : scrollback = [],
        savedCursorRow = 0,
        savedCursorColumn = 0 {
    _initializeCells();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التهيئة
  //                      Initialization
  // ═══════════════════════════════════════════════════════════════════════

  /// تهيئة خلايا الشاشة
  /// Initialize screen cells
  void _initializeCells() {
    cells = List.generate(
      rows,
      (row) => List.generate(
        columns,
        (col) => TerminalCell(),
      ),
    );
  }

  /// إعادة تهيئة الشاشة
  /// Reinitialize the screen
  void reinitialize() {
    _initializeCells();
    cursorRow = 0;
    cursorColumn = 0;
    scrollOffsetX = 0;
    scrollOffsetY = 0;
    clearScrollback();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحجيم الشاشة
  //                      Screen Resizing
  // ═══════════════════════════════════════════════════════════════════════

  /// تغيير حجم الشاشة
  /// Resize the screen
  void resize(int newRows, int newColumns) {
    if (newRows == rows && newColumns == columns) return;

    final newCells = List.generate(
      newRows,
      (row) => List.generate(
        newColumns,
        (col) => TerminalCell(),
      ),
    );

    // نسخ الخلايا القديمة إلى الجديدة
    for (int row = 0; row < newRows && row < rows; row++) {
      for (int col = 0; col < newColumns && col < columns; col++) {
        newCells[row][col] = cells[row][col].clone();
      }
    }

    cells = newCells;
    rows = newRows;
    columns = newColumns;

    // تعديل موضع المؤشر
    if (cursorRow >= rows) cursorRow = rows - 1;
    if (cursorColumn >= columns) cursorColumn = columns - 1;

    // تعديل منطقة الطمس
    if (scrollRegionBottom >= rows || scrollRegionBottom == -1) {
      scrollRegionBottom = rows - 1;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      عمليات الخلية
  //                      Cell Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على خلية
  /// Get a cell
  TerminalCell getCell(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) {
      return TerminalCell();
    }
    return cells[row][col];
  }

  /// تعيين خلية
  /// Set a cell
  void setCell(int row, int col, TerminalCell cell) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return;
    cells[row][col] = cell;
  }

  /// تعيين حرف في موضع
  /// Set a character at position
  void setChar(int row, int col, String char) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return;
    cells[row][col].character = char;
  }

  /// الحصول على حرف من موضع
  /// Get a character from position
  String getChar(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return ' ';
    return cells[row][col].character;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      عمليات المؤشر
  //                      Cursor Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// تحريك المؤشر
  /// Move cursor
  void moveCursor(int row, int col) {
    cursorRow = row.clamp(0, rows - 1);
    cursorColumn = col.clamp(0, columns - 1);
    wrapNext = false;
  }

  /// تحريك المؤشر للأمام
  /// Move cursor forward
  void moveCursorForward(int count) {
    for (int i = 0; i < count; i++) {
      moveCursorForwardOne();
    }
  }

  /// تحريك المؤشر للأمام بمقدار حرف واحد
  /// Move cursor forward by one character
  void moveCursorForwardOne() {
    if (cursorColumn < columns - 1) {
      cursorColumn++;
      wrapNext = false;
    } else if (lineWrap) {
      wrapNext = true;
    }
  }

  /// تحريك المؤشر للخلف
  /// Move cursor backward
  void moveCursorBackward(int count) {
    for (int i = 0; i < count; i++) {
      if (cursorColumn > 0) {
        cursorColumn--;
      } else if (cursorRow > 0) {
        cursorRow--;
        cursorColumn = columns - 1;
      }
      wrapNext = false;
    }
  }

  /// تحريك المؤشر للأعلى
  /// Move cursor up
  void moveCursorUp(int count) {
    cursorRow = (cursorRow - count).clamp(0, rows - 1);
  }

  /// تحريك المؤشر للأسفل
  /// Move cursor down
  void moveCursorDown(int count) {
    cursorRow = (cursorRow + count).clamp(0, rows - 1);
  }

  /// تحريك المؤشر إلى بداية السطر
  /// Move cursor to beginning of line
  void moveCursorToLineStart() {
    cursorColumn = 0;
    wrapNext = false;
  }

  /// تحريك المؤشر إلى العمود الأول
  /// Move cursor to first column
  void moveCursorToColumn(int col) {
    cursorColumn = col.clamp(0, columns - 1);
    wrapNext = false;
  }

  /// حفظ موضع المؤشر
  /// Save cursor position
  void saveCursor() {
    savedCursorRow = cursorRow;
    savedCursorColumn = cursorColumn;
  }

  /// استعادة موضع المؤشر
  /// Restore cursor position
  void restoreCursor() {
    cursorRow = savedCursorRow.clamp(0, rows - 1);
    cursorColumn = savedCursorColumn.clamp(0, columns - 1);
    wrapNext = false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      عمليات المسح
  //                      Clear Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// مسح الشاشة بالكامل
  /// Clear entire screen
  void clearScreen() {
    for (int row = 0; row < rows; row++) {
      clearLine(row);
    }
    moveCursor(0, 0);
  }

  /// مسح السطر بالكامل
  /// Clear entire line
  void clearLine(int row) {
    for (int col = 0; col < columns; col++) {
      cells[row][col].reset();
    }
  }

  /// مسح من المؤشر إلى نهاية السطر
  /// Clear from cursor to end of line
  void clearToEndOfLine() {
    for (int col = cursorColumn; col < columns; col++) {
      cells[cursorRow][col].reset();
    }
  }

  /// مسح من بداية السطر إلى المؤشر
  /// Clear from beginning of line to cursor
  void clearToBeginningOfLine() {
    for (int col = 0; col <= cursorColumn; col++) {
      cells[cursorRow][col].reset();
    }
  }

  /// مسح السطر بالكامل
  /// Clear entire current line
  void clearEntireCurrentLine() {
    clearLine(cursorRow);
  }

  /// مسح من المؤشر إلى نهاية الشاشة
  /// Clear from cursor to end of screen
  void clearToEndOfScreen() {
    // مسح السطر الحالي من المؤشر للنهاية
    clearToEndOfLine();

    // مسح الأسطر التالية
    for (int row = cursorRow + 1; row < rows; row++) {
      clearLine(row);
    }
  }

  /// مسح من بداية الشاشة إلى المؤشر
  /// Clear from beginning of screen to cursor
  void clearToBeginningOfScreen() {
    // مسح الأسطر السابقة
    for (int row = 0; row < cursorRow; row++) {
      clearLine(row);
    }

    // مسح السطر الحالي من البداية للمؤشر
    clearToBeginningOfLine();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      عمليات التمرير
  //                      Scroll Operations
  // ═══════════════════════════════════════════════════════════════════════

  /// تمرير السطر للأعلى
  /// Scroll up by one line
  void scrollUp() {
    scrollUpLines(1);
  }

  /// تمرير السطور
  /// Scroll up by multiple lines
  void scrollUpLines(int count) {
    for (int i = 0; i < count; i++) {
      _scrollUpOneLine();
    }
  }

  /// تمرير سطر واحد للأعلى
  /// Scroll up by one line
  void _scrollUpOneLine() {
    // حفظ السطر في سجل التمرير
    if (scrollbackEnabled) {
      scrollback.add(cells[0].map((c) => c.clone()).toList());
      if (scrollback.length > maxScrollbackLines) {
        scrollback.removeAt(0);
      }
    }

    // نقل الأسطر للأعلى
    for (int row = 0; row < rows - 1; row++) {
      for (int col = 0; col < columns; col++) {
        cells[row][col] = cells[row + 1][col].clone();
      }
    }

    // مسح السطر الأخير
    clearLine(rows - 1);
  }

  /// تمرير السطر للأسفل
  /// Scroll down by one line
  void scrollDown() {
    scrollDownLines(1);
  }

  /// تمرير السطور للأسفل
  /// Scroll down by multiple lines
  void scrollDownLines(int count) {
    for (int i = 0; i < count; i++) {
      _scrollDownOneLine();
    }
  }

  /// تمرير سطر واحد للأسفل
  /// Scroll down by one line
  void _scrollDownOneLine() {
    // نقل الأسطر للأسفل
    for (int row = rows - 1; row > 0; row--) {
      for (int col = 0; col < columns; col++) {
        cells[row][col] = cells[row - 1][col].clone();
      }
    }

    // مسح السطر الأول
    clearLine(0);
  }

  /// هل سجل التمرير مُفعّل
  /// Whether scrollback is enabled
  bool get scrollbackEnabled => maxScrollbackLines > 0;

  /// مسح سجل التمرير
  /// Clear scrollback buffer
  void clearScrollback() {
    scrollback.clear();
  }

  /// الحصول على عدد أسطر سجل التمرير
  /// Get number of scrollback lines
  int get scrollbackLineCount => scrollback.length;

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدراج وحذف السطور
  //                      Line Insertion and Deletion
  // ═══════════════════════════════════════════════════════════════════════

  /// إدراج سطر في الموضع الحالي
  /// Insert a line at current position
  void insertLine() {
    insertLines(1);
  }

  /// إدراج عدة سطور
  /// Insert multiple lines
  void insertLines(int count) {
    final top = scrollRegionTop;
    final bottom = scrollRegionBottom == -1 ? rows - 1 : scrollRegionBottom;

    for (int i = 0; i < count; i++) {
      // حذف السطر الأخير في المنطقة
      for (int row = bottom; row > top; row--) {
        for (int col = 0; col < columns; col++) {
          cells[row][col] = cells[row - 1][col].clone();
        }
      }
      // مسح السطر في الموضع
      clearLine(top);
    }
  }

  /// حذف سطر من الموضع الحالي
  /// Delete a line at current position
  void deleteLine() {
    deleteLines(1);
  }

  /// حذف عدة سطور
  /// Delete multiple lines
  void deleteLines(int count) {
    final top = scrollRegionTop;
    final bottom = scrollRegionBottom == -1 ? rows - 1 : scrollRegionBottom;

    for (int i = 0; i < count && (top + i) < bottom; i++) {
      // نقل السطور للأعلى
      for (int row = top; row < bottom; row++) {
        for (int col = 0; col < columns; col++) {
          cells[row][col] = cells[row + 1][col].clone();
        }
      }
      // مسح السطر الأخير
      clearLine(bottom);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدراج وحذف الأحرف
  //                      Character Insertion and Deletion
  // ═══════════════════════════════════════════════════════════════════════

  /// إدراج حرف في الموضع الحالي
  /// Insert a character at current position
  void insertChar(String char) {
    // نقل الأحرف التالية لليمين
    for (int col = columns - 1; col > cursorColumn; col--) {
      cells[cursorRow][col] = cells[cursorRow][col - 1].clone();
    }
    // إدراج الحرف الجديد
    cells[cursorRow][cursorColumn].character = char;
    moveCursorForwardOne();
  }

  /// حذف حرف من الموضع الحالي
  /// Delete a character at current position
  void deleteChar() {
    // نقل الأحرف التالية لليسار
    for (int col = cursorColumn; col < columns - 1; col++) {
      cells[cursorRow][col] = cells[cursorRow][col + 1].clone();
    }
    // مسح最后一个 حرف
    cells[cursorRow][columns - 1].reset();
  }

  /// حذف عدة أحرف
  /// Delete multiple characters
  void deleteChars(int count) {
    for (int i = 0; i < count; i++) {
      deleteChar();
    }
  }

  /// مسح الأحرف من الموضع الحالي
  /// Erase characters from current position
  void eraseChars(int count) {
    for (int col = cursorColumn; col < columns && col < cursorColumn + count; col++) {
      cells[cursorRow][col].reset();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      Backspace و Tab
  //                      Backspace and Tab
  // ═══════════════════════════════════════════════════════════════════════

  /// تنفيذ backspace
  /// Execute backspace
  void backspace() {
    if (cursorColumn > 0) {
      cursorColumn--;
      cells[cursorRow][cursorColumn].character = ' ';
    } else if (cursorRow > 0) {
      cursorRow--;
      cursorColumn = columns - 1;
      cells[cursorRow][cursorColumn].character = ' ';
    }
  }

  /// تنفيذ tab
  /// Execute tab
  void tab() {
    // البحث عن下一个 جدولة tab
    int nextTab = ((cursorColumn ~/ 8) + 1) * 8;
    if (nextTab >= columns) {
      nextTab = columns - 1;
    }
    cursorColumn = nextTab;
    wrapNext = false;
  }

  /// تنفيذ backtab
  /// Execute backtab
  void backtab() {
    int prevTab = ((cursorColumn - 1) ~/ 8) * 8;
    if (prevTab < 0) {
      prevTab = 0;
    }
    cursorColumn = prevTab;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إرجاع السطر الجديد
  //                      Carriage Return and Line Feed
  // ═══════════════════════════════════════════════════════════════════════

  /// تنفيذ إرجاع السطر الجديد (CRLF)
  /// Execute carriage return and line feed
  void newLine() {
    if (wrapNext) {
      wrapNext = false;
      cursorColumn = 0;
    }
    lineFeed();
  }

  /// تنفيذ تغذية السطر
  /// Execute line feed
  void lineFeed() {
    if (cursorRow < scrollRegionBottom) {
      cursorRow++;
    } else {
      scrollUp();
    }
  }

  /// تنفيذ إرجاع النقل
  /// Execute carriage return
  void carriageReturn() {
    cursorColumn = 0;
    wrapNext = false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إرجاع النص
  //                      Text Retrieval
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على النص بالكامل
  /// Get all text
  String getText() {
    final buffer = StringBuffer();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final char = cells[row][col].character;
        if (char != ' ') {
          buffer.write(char);
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// الحصول على سطر معين
  /// Get a specific line
  String getLine(int row) {
    if (row < 0 || row >= rows) return '';

    final buffer = StringBuffer();
    for (int col = 0; col < columns; col++) {
      buffer.write(cells[row][col].character);
    }
    return buffer.toString().trimRight();
  }

  /// الحصول على النص في نطاق
  /// Get text in a range
  String getTextInRange(int startRow, int startCol, int endRow, int endCol) {
    if (startRow < 0 || startRow >= rows) return '';
    if (endRow < 0 || endRow >= rows) return '';

    final buffer = StringBuffer();

    for (int row = startRow; row <= endRow; row++) {
      final start = row == startRow ? startCol : 0;
      final end = row == endRow ? endCol : columns - 1;

      for (int col = start; col <= end && col < columns; col++) {
        buffer.write(cells[row][col].character);
      }

      if (row < endRow) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      البحث
  //                      Search
  // ═══════════════════════════════════════════════════════════════════════

  /// البحث في الشاشة
  /// Search in screen
  List<SearchResult> search(String query, {bool caseSensitive = false}) {
    final results = <SearchResult>[];
    final searchQuery = caseSensitive ? query : query.toLowerCase();

    // البحث في الشاشة الحالية
    for (int row = 0; row < rows; row++) {
      final line = getLine(row);
      final searchLine = caseSensitive ? line : line.toLowerCase();

      int index = 0;
      while (true) {
        index = searchLine.indexOf(searchQuery, index);
        if (index == -1) break;

        results.add(SearchResult(
          row: row,
          startColumn: index,
          endColumn: index + query.length,
          text: line.substring(index, index + query.length),
          line: line,
        ));

        index += query.length;
      }
    }

    // البحث في سجل التمرير
    for (int i = 0; i < scrollback.length; i++) {
      final row = scrollback[i];
      final line = row.map((c) => c.character).join().trimRight();
      final searchLine = caseSensitive ? line : line.toLowerCase();

      int index = 0;
      while (true) {
        index = searchLine.indexOf(searchQuery, index);
        if (index == -1) break;

        results.add(SearchResult(
          row: -(i + 1), // negative for scrollback
          startColumn: index,
          endColumn: index + query.length,
          text: line.substring(index, index + query.length),
          line: line,
        ));

        index += query.length;
      }
    }

    return results;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التحديد
  //                      Selection
  // ═══════════════════════════════════════════════════════════════════════

  /// بدء التحديد
  /// Start selection
  void startSelection(int row, int col) {
    selectionStartRow = row;
    selectionStartCol = col;
    selectionEndRow = row;
    selectionEndCol = col;
  }

  /// تمديد التحديد
  /// Extend selection
  void extendSelection(int row, int col) {
    selectionEndRow = row;
    selectionEndCol = col;
  }

  /// إنهاء التحديد
  /// End selection
  void endSelection() {
    if (selectionStartRow == null || selectionEndRow == null) return;

    final startRow = selectionStartRow!;
    final startCol = selectionStartCol!;
    final endRow = selectionEndRow!;
    final endCol = selectionEndCol!;

    // ترتيب النطاق
    final minRow = startRow < endRow ? startRow : endRow;
    final maxRow = startRow < endRow ? endRow : startRow;
    final minCol = (startRow <= endRow ? startCol : endCol);
    final maxCol = (startRow <= endRow ? endCol : startCol);

    // التحقق من كون التحديد في سطر واحد
    if (minRow == maxRow) {
      return getTextInRange(minRow, minCol, maxRow, maxCol);
    }

    return getTextInRange(minRow, minCol, maxRow, maxCol);
  }

  /// إلغاء التحديد
  /// Clear selection
  void clearSelection() {
    selectionStartRow = null;
    selectionStartCol = null;
    selectionEndRow = null;
    selectionEndCol = null;
  }

  /// هل هناك تحديد
  /// Whether there is a selection
  bool get hasSelection =>
      selectionStartRow != null &&
      selectionEndRow != null &&
      (selectionStartRow != selectionEndRow || selectionStartCol != selectionEndCol);

  // ═══════════════════════════════════════════════════════════════════════
  //                      نسخ ولصق
  //                      Copy and Paste
  // ═══════════════════════════════════════════════════════════════════════

  /// نسخ التحديد إلى الحافظة
  /// Copy selection to clipboard
  String? copySelection() {
    if (!hasSelection) return null;
    return endSelection();
  }

  /// لصق نص في الموضع الحالي
  /// Paste text at current position
  void paste(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '\n') {
        newLine();
      } else if (char == '\t') {
        tab();
      } else if (char == '\r') {
        carriageReturn();
      } else {
        cells[cursorRow][cursorColumn].character = char;
        moveCursorForwardOne();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تصدير واستيراد
  //                      Export and Import
  // ═══════════════════════════════════════════════════════════════════════

  /// تصدير الشاشة إلى JSON
  /// Export screen to JSON
  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'columns': columns,
      'cursorRow': cursorRow,
      'cursorColumn': cursorColumn,
      'scrollback': scrollback
          .map((row) => row.map((cell) => {
                'character': cell.character,
                'foreground': cell.foreground.value,
                'background': cell.background.value,
              }).toList())
          .toList(),
    };
  }

  /// استيراد الشاشة من JSON
  /// Import screen from JSON
  void fromJson(Map<String, dynamic> json) {
    rows = json['rows'] ?? 24;
    columns = json['columns'] ?? 80;
    cursorRow = json['cursorRow'] ?? 0;
    cursorColumn = json['cursorColumn'] ?? 0;

    _initializeCells();

    // استيراد سجل التمرير
    if (json['scrollback'] != null) {
      scrollback.clear();
      for (final rowJson in json['scrollback']) {
        final row = <TerminalCell>[];
        for (final cellJson in rowJson) {
          row.add(TerminalCell(
            character: cellJson['character'] ?? ' ',
            foreground: Color(cellJson['foreground'] ?? 0xFFE6EDF3),
            background: Color(cellJson['background'] ?? 0xFF0D1117),
          ));
        }
        scrollback.add(row);
      }
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    SearchResult - نتيجة البحث
///                    Search Result
/// ═══════════════════════════════════════════════════════════════════════════

class SearchResult {
  final int row;
  final int startColumn;
  final int endColumn;
  final String text;
  final String line;

  SearchResult({
    required this.row,
    required this.startColumn,
    required this.endColumn,
    required this.text,
    required this.line,
  });

  @override
  String toString() {
    return 'SearchResult(row: $row, col: $startColumn-$endColumn, text: "$text")';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: terminal_screen.dart
// ═══════════════════════════════════════════════════════════════════════════