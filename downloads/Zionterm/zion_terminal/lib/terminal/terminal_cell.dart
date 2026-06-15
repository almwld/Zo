// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Cell - خلية الطرفية                           ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: خلية طرفية فردية تمثل حرفاً واحداً مع تنسيقه                  ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'terminal_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalCell - خلية طرفية فردية
///                    Represents a single terminal cell with character and style
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalCell {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الأساسية
  //                      Core Properties
  // ═══════════════════════════════════════════════════════════════════════

  /// الحرف المعروض في الخلية
  /// The character displayed in this cell
  String character;

  /// لون النص الأمامي
  /// Foreground color
  Color foreground;

  /// لون الخلفية
  /// Background color
  Color background;

  /// هل الخلية تحتوي على نص عريض
  /// Whether the cell contains bold text
  bool bold;

  /// هل الخلية تحتوي على نص مائل
  /// Whether the cell contains italic text
  bool italic;

  /// هل الخلية تحتوي على نص تحته خط
  /// Whether the cell contains underlined text
  bool underline;

  /// هل الخلية تحتوي على نص يتوسطه خط
  /// Whether the cell contains strikethrough text
  bool strikethrough;

  /// هل الخلية وميضية
  /// Whether the cell is blinking
  bool blink;

  /// هل الخلية مخفية
  /// Whether the cell is hidden (invisible text)
  bool hidden;

  /// هل الحرف معكوس (لون النص يصبح لون الخلفية والعكس)
  /// Whether the character is reversed (swap foreground/background)
  bool reverse;

  /// هل الخلية مُمسوحة
  /// Whether the cell has been cleared
  bool cleared;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  //                      Constructor
  // ═══════════════════════════════════════════════════════════════════════

  /// منشئ افتراضي - ينشئ خلية فارغة
  /// Default constructor - creates an empty cell
  TerminalCell({
    this.character = ' ',
    this.foreground = TerminalColors.defaultForeground,
    this.background = TerminalColors.defaultBackground,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.blink = false,
    this.hidden = false,
    this.reverse = false,
    this.cleared = false,
  });

  /// منشئ النسخ
  /// Copy constructor
  TerminalCell.copy(TerminalCell other)
      : character = other.character,
        foreground = other.foreground,
        background = other.background,
        bold = other.bold,
        italic = other.italic,
        underline = other.underline,
        strikethrough = other.strikethrough,
        blink = other.blink,
        hidden = other.hidden,
        reverse = other.reverse,
        cleared = other.cleared;

  // ═══════════════════════════════════════════════════════════════════════
  //                      الدوال المساعدة
  //                      Helper Methods
  // ═══════════════════════════════════════════════════════════════════════

  /// إعادة الخلية إلى حالتها الافتراضية
  /// Reset the cell to default state
  void reset() {
    character = ' ';
    foreground = TerminalColors.defaultForeground;
    background = TerminalColors.defaultBackground;
    bold = false;
    italic = false;
    underline = false;
    strikethrough = false;
    blink = false;
    hidden = false;
    reverse = false;
    cleared = false;
  }

  /// نسخ الخلية
  /// Create a copy of this cell
  TerminalCell clone() {
    return TerminalCell.copy(this);
  }

  /// هل الخلية فارغة (تحتوي فقط على مسافة)
  /// Whether the cell is empty (contains only a space)
  bool get isEmpty => character == ' ' && !bold && !underline;

  /// الحصول على النص الفعلي (إذا كان مخفياً يُرجع مسافة)
  /// Get the actual text (if hidden, returns space)
  String get displayCharacter => hidden ? ' ' : character;

  /// تطبيق الأنماط على TextSpan
  /// Apply styles to a TextSpan
  TextSpan toTextSpan() {
    final effectiveForeground = reverse ? background : foreground;
    final effectiveBackground = reverse ? foreground : background;

    return TextSpan(
      text: displayCharacter,
      style: TextStyle(
        color: effectiveForeground,
        backgroundColor: effectiveBackground,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        decoration: underline
            ? (strikethrough ? TextDecoration.combine([TextDecoration.underline, TextDecoration.lineThrough]) : TextDecoration.underline)
            : (strikethrough ? TextDecoration.lineThrough : null),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      دوال المساواة والمقارنة
  //                      Equality and Comparison
  // ═══════════════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TerminalCell &&
        other.character == character &&
        other.foreground == foreground &&
        other.background == background &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.blink == blink &&
        other.hidden == hidden &&
        other.reverse == reverse;
  }

  @override
  int get hashCode {
    return Object.hash(
      character,
      foreground,
      background,
      bold,
      italic,
      underline,
      strikethrough,
      blink,
      hidden,
      reverse,
    );
  }

  @override
  String toString() {
    return 'TerminalCell(char: "$character", fg: $foreground, bg: $background, bold: $bold, italic: $italic)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: terminal_cell.dart
// ═══════════════════════════════════════════════════════════════════════════