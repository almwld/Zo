// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Arabic BIDI - اتجاه النص العربي                        ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: خوارزمية Bidi Unicode لمعالجة اتجاه النص                     ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'dart:math' as math;
import 'arabic_shaper.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    ArabicBidi - معالجة اتجاه النص ثنائي الاتجاه
///                    Bidirectional Text Processing
/// ═══════════════════════════════════════════════════════════════════════════

class ArabicBidi {
  // ═══════════════════════════════════════════════════════════════════════
  //                      مستويات التضمين
  // ═══════════════════════════════════════════════════════════════════════

  static const int L = 0; // Left-to-Right
  static const int R = 1; // Right-to-Left
  static const int AL = 2; // Arabic Letter (Right-to-Left)
  static const int EN = 3; // European Number (Left-to-Right)
  static const int ES = 4; // European Separator
  static const int ET = 5; // European Terminator
  static const int AN = 6; // Arabic Number (Right-to-Left)
  static const int CS = 7; // Common Separator
  static const int B = 8;  // Block Separator
  static const int S = 9;  // Segment Separator
  static const int WS = 10; // Whitespace
  static const int ON = 11; // Other Neutrals

  // ═══════════════════════════════════════════════════════════════════════
  //                      محددات الاتجاه
  // ═══════════════════════════════════════════════════════════════════════

  static const String LRE = '\u202A'; // Left-to-Right Embedding
  static const String RLE = '\u202B'; // Right-to-Left Embedding
  static const String LRO = '\u202C'; // Left-to-Right Override
  static const String RLO = '\u202D'; // Right-to-Left Override
  static const String PDF = '\u202E'; // Pop Directional Format
  static const String LRM = '\u200E'; // Left-to-Right Mark
  static const String RLM = '\u200F'; // Right-to-Left Mark
  static const String ALM = '\u061C'; // Arabic Letter Mark

  // ═══════════════════════════════════════════════════════════════════════
  //                      خريطة أنواع الأحرف
  // ═══════════════════════════════════════════════════════════════════════

  static final Map<int, int> _charTypeMap = {
    // Left-to-Right
    0x0041: L, 0x0042: L, 0x0043: L, 0x0044: L, 0x0045: L,
    0x0046: L, 0x0047: L, 0x0048: L, 0x0049: L, 0x004A: L,
    0x004B: L, 0x004C: L, 0x004D: L, 0x004E: L, 0x004F: L,
    0x0050: L, 0x0051: L, 0x0052: L, 0x0053: L, 0x0054: L,
    0x0055: L, 0x0056: L, 0x0057: L, 0x0058: L, 0x0059: L,
    0x005A: L,
    0x0061: L, 0x0062: L, 0x0063: L, 0x0064: L, 0x0065: L,
    0x0066: L, 0x0067: L, 0x0068: L, 0x0069: L, 0x006A: L,
    0x006B: L, 0x006C: L, 0x006D: L, 0x006E: L, 0x006F: L,
    0x0070: L, 0x0071: L, 0x0072: L, 0x0073: L, 0x0074: L,
    0x0075: L, 0x0076: L, 0x0077: L, 0x0078: L, 0x0079: L,
    0x007A: L,

    // Arabic Letters (Right-to-Left)
    0x0621: AL, 0x0622: AL, 0x0623: AL, 0x0624: AL, 0x0625: AL,
    0x0626: AL, 0x0627: AL, 0x0628: AL, 0x0629: AL, 0x062A: AL,
    0x062B: AL, 0x062C: AL, 0x062D: AL, 0x062E: AL, 0x062F: AL,
    0x0630: AL, 0x0631: AL, 0x0632: AL, 0x0633: AL, 0x0634: AL,
    0x0635: AL, 0x0636: AL, 0x0637: AL, 0x0638: AL, 0x0639: AL,
    0x063A: AL,
    0x0641: AL, 0x0642: AL, 0x0643: AL, 0x0644: AL, 0x0645: AL,
    0x0646: AL, 0x0647: AL, 0x0648: AL, 0x0649: AL, 0x064A: AL,

    // Arabic Extended
    0x0671: AL, 0x0670: AL, 0x0675: AL,
    0x0686: AL, 0x0687: AL, 0x0688: AL, 0x0689: AL, 0x068A: AL,
    0x068B: AL, 0x068C: AL, 0x068D: AL, 0x068E: AL, 0x068F: AL,
    0x0690: AL, 0x0691: AL, 0x0692: AL, 0x0693: AL, 0x0694: AL,
    0x0695: AL, 0x0696: AL, 0x0697: AL, 0x0698: AL, 0x0699: AL,
    0x069A: AL, 0x069B: AL, 0x069C: AL, 0x069D: AL, 0x069E: AL,
    0x069F: AL, 0x06A0: AL, 0x06A1: AL, 0x06A2: AL, 0x06A3: AL,
    0x06A4: AL, 0x06A5: AL, 0x06A6: AL, 0x06A7: AL, 0x06A8: AL,
    0x06A9: AL, 0x06AA: AL, 0x06AB: AL, 0x06AC: AL, 0x06AD: AL,
    0x06AE: AL, 0x06AF: AL, 0x06B0: AL, 0x06B1: AL, 0x06B2: AL,
    0x06B3: AL, 0x06B4: AL, 0x06B5: AL, 0x06B6: AL, 0x06B7: AL,
    0x06B8: AL, 0x06B9: AL, 0x06BA: AL, 0x06BB: AL, 0x06BC: AL,
    0x06BD: AL, 0x06BE: AL, 0x06BF: AL,
    0x06C0: AL, 0x06C1: AL, 0x06C2: AL, 0x06C3: AL, 0x06C4: AL,
    0x06C5: AL, 0x06C6: AL, 0x06C7: AL, 0x06C8: AL, 0x06C9: AL,
    0x06CA: AL, 0x06CB: AL, 0x06CC: AL, 0x06CD: AL, 0x06CE: AL,
    0x06CF: AL, 0x06D0: AL, 0x06D1: AL, 0x06D2: AL, 0x06D3: AL,
    0x06D5: AL,

    // Arabic Numbers
    0x0660: AN, 0x0661: AN, 0x0662: AN, 0x0663: AN, 0x0664: AN,
    0x0665: AN, 0x0666: AN, 0x0667: AN, 0x0668: AN, 0x0669: AN,

    // Arabic Punctuation
    0x060C: CS, 0x060D: CS, 0x061B: CS, 0x061F: CS,
    0x0621: AL, // Hamza

    // European Numbers
    0x0030: EN, 0x0031: EN, 0x0032: EN, 0x0033: EN, 0x0034: EN,
    0x0035: EN, 0x0036: EN, 0x0037: EN, 0x0038: EN, 0x0039: EN,

    // Arabic-Indic Digits
    0x0660: AN, 0x0661: AN, 0x0662: AN, 0x0663: AN, 0x0664: AN,
    0x0665: AN, 0x0666: AN, 0x0667: AN, 0x0668: AN, 0x0669: AN,

    // Extended Arabic-Indic Digits
    0x06F0: EN, 0x06F1: EN, 0x06F2: EN, 0x06F3: EN, 0x06F4: EN,
    0x06F5: EN, 0x06F6: EN, 0x06F7: EN, 0x06F8: EN, 0x06F9: EN,

    // Whitespace
    0x0020: WS, 0x0009: WS, 0x000A: WS, 0x000D: WS,
    0x00A0: WS, 0x2000: WS, 0x2001: WS, 0x2002: WS, 0x2003: WS,
    0x2004: WS, 0x2005: WS, 0x2006: WS, 0x2008: WS, 0x2009: WS,
    0x200A: WS, 0x2028: WS, 0x2029: WS, 0x3000: WS,

    // Common Separators
    0x002C: CS, 0x002E: CS, 0x003A: CS, 0x003B: CS,
    0x060C: CS, 0x066C: CS,

    // Segment Separators
    0x0009: S, 0x000A: S, 0x000D: S,

    // Block Separators
    0x000B: B, 0x000C: B, 0x2024: B,
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      الحصول على نوع الحرف
  // ═══════════════════════════════════════════════════════════════════════

  static int getCharType(String char) {
    if (char.isEmpty) return ON;
    return _charTypeMap[char.codeUnitAt(0)] ?? ON;
  }

  static int getCharTypeFromCode(int code) {
    return _charTypeMap[code] ?? ON;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحديد نوع الفئة
  // ═══════════════════════════════════════════════════════════════════════

  static bool isStrongChar(int type) {
    return type == L || type == R || type == AL;
  }

  static bool isWeakChar(int type) {
    return type == EN || type == ES || type == ET || type == AN || type == CS;
  }

  static bool isNeutralChar(int type) {
    return type == B || type == S || type == WS || type == ON;
  }

  static bool isNumber(int type) {
    return type == EN || type == AN;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      خطوة X1 - تحديد الأنواع
  // ═══════════════════════════════════════════════════════════════════════

  static List<int> getParagraphEmbeddingLevel(String text, int startIndex, int endIndex) {
    int level = L;

    for (int i = startIndex; i < endIndex; i++) {
      final type = getCharType(text[i]);
      if (type == AL) {
        level = R;
        break;
      } else if (type == R) {
        level = R;
        break;
      }
    }

    return [level, startIndex, endIndex];
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      خطوة X2 - قوائم RDF
  // ═══════════════════════════════════════════════════════════════════════

  static List<List<int>> computeResolvingLevelsAndCharacters(
    String text,
    List<int> paragraphEmbeddingLevel,
  ) {
    // تبسيط: إرجاع مستوى التضمين للفقرة
    return [paragraphEmbeddingLevel];
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إعادة ترتيب النص
  // ═══════════════════════════════════════════════════════════════════════

  /// إعادة ترتيب النص ثنائي الاتجاه للعرض الصحيح
  /// Reorder bidirectional text for correct display
  static String reorder(String text, {bool rtl = false}) {
    if (text.isEmpty) return text;

    final chars = text.characters.toList();
    final n = chars.length;

    if (n == 0) return text;

    // تحديد مستوى تضمين الفقرة
    int paragraphLevel = rtl ? 1 : 0;
    for (final char in chars) {
      final type = getCharType(char);
      if (type == AL || type == R) {
        paragraphLevel = 1;
        break;
      }
    }

    // حساب مستويات التضمين لكل حرف
    final levels = <int>[];
    int currentLevel = paragraphLevel;

    for (int i = 0; i < n; i++) {
      final type = getCharType(chars[i]);

      // تحديث المستوى بناءً على نوع الحرف
      if (type == L || type == R || type == AL) {
        currentLevel = (type == AL) ? 1 : 0;
      }

      levels.add(currentLevel);
    }

    // إيجاد الحدود
    final boundaries = <int>[];
    for (int i = 0; i < n - 1; i++) {
      if (levels[i] != levels[i + 1]) {
        boundaries.add(i + 1);
      }
    }

    // تقسيم إلى سلاسل
    final runs = <List<int>>[];
    int start = 0;
    for (final boundary in boundaries) {
      runs.add(List.generate(boundary - start, (i) => start + i));
      start = boundary;
    }
    if (start < n) {
      runs.add(List.generate(n - start, (i) => start + i));
    }

    // إعادة ترتيب كل سلسلة
    final reordered = List<String?>.filled(n, null);

    for (final run in runs) {
      final runLevel = levels[run[0]];
      final isEvenLevel = runLevel % 2 == 0;

      // إذا كان المستوى زوجي، احتفظ بالترتيب (LTR)
      // إذا كان المستوى فردي، اعكس الترتيب (RTL)
      if (!isEvenLevel) {
        for (int i = 0; i < run.length; i++) {
          reordered[run[i]] = chars[run[run.length - 1 - i]];
        }
      } else {
        for (int i = 0; i < run.length; i++) {
          reordered[run[i]] = chars[run[i]];
        }
      }
    }

    // تجميع النتيجة
    final result = reordered.where((c) => c != null).join('');

    // تطبيق التشكيل العربي إذا كان النص عربياً
    if (ArabicShaper.containsArabic(text)) {
      return ArabicShaper.shape(result);
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحديد اتجاه النص
  // ═══════════════════════════════════════════════════════════════════════

  /// تحديد اتجاه النص الغالب
  /// Determine dominant text direction
  static int getBaseDirection(String text) {
    int ltrCount = 0;
    int rtlCount = 0;

    for (final char in text.characters) {
      final type = getCharType(char);
      if (type == L || type == EN) {
        ltrCount++;
      } else if (type == R || type == AL || type == AN) {
        rtlCount++;
      }
    }

    return rtlCount > ltrCount ? 1 : 0;
  }

  /// هل النص RTL
  /// Whether text is RTL
  static bool isRtl(String text) {
    return getBaseDirection(text) == 1;
  }

  /// هل النص LTR
  /// Whether text is LTR
  static bool isLtr(String text) {
    return getBaseDirection(text) == 0;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إضافة محددات الاتجاه
  // ═══════════════════════════════════════════════════════════════════════

  /// إضافة محددات اتجاه الفقرة
  /// Add paragraph direction marks
  static String addDirectionMarks(String text, {bool rtl = false}) {
    if (text.isEmpty) return text;

    if (rtl) {
      return '$RLM$text$RLM';
    } else {
      return '$LRM$text$LRM';
    }
  }

  /// إضافة علامات تضمين
  /// Add embedding marks
  static String addEmbedding(String text, {bool rtl = false}) {
    if (text.isEmpty) return text;

    if (rtl) {
      return '$RLE$text$PDF';
    } else {
      return '$LRE$text$PDF';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      معالجة مختلطة اللغات
  // ═══════════════════════════════════════════════════════════════════════

  /// معالجة نص مختلط اللغات (عربي + إنجليزي)
  /// Process mixed language text (Arabic + English)
  static String processMixedText(String text) {
    if (text.isEmpty) return text;

    final segments = <String>[];
    var currentSegment = StringBuffer();
    bool? inArabic;

    for (final char in text.characters) {
      final isArabic = ArabicShaper.isArabicChar(char);

      if (inArabic == null) {
        inArabic = isArabic;
        currentSegment.write(char);
      } else if (inArabic != isArabic) {
        segments.add(_processSegment(currentSegment.toString(), inArabic));
        currentSegment = StringBuffer();
        currentSegment.write(char);
        inArabic = isArabic;
      } else {
        currentSegment.write(char);
      }
    }

    if (currentSegment.isNotEmpty && inArabic != null) {
      segments.add(_processSegment(currentSegment.toString(), inArabic));
    }

    return segments.join(' ');
  }

  static String _processSegment(String segment, bool isArabic) {
    if (segment.isEmpty) return segment;

    if (isArabic) {
      return reorder(segment, rtl: true);
    } else {
      return segment;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تصحيح اتجاه الأرقام
  // ═══════════════════════════════════════════════════════════════════════

  /// تصحيح اتجاه الأرقام في النص
  /// Fix number direction in text
  static String fixNumberDirection(String text) {
    final buffer = StringBuffer();
    bool precededByArabic = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final type = getCharType(char);

      // التحقق من الحرف السابق
      if (i > 0) {
        final prevType = getCharType(text[i - 1]);
        precededByArabic = (prevType == AL || prevType == R);
      }

      if (type == EN) {
        if (precededByArabic) {
          // تحويل الأرقام الإنجليزية إلى عربية
          buffer.write(_convertToArabicDigits(char));
        } else {
          buffer.write(char);
        }
      } else if (type == AN) {
        if (!precededByArabic) {
          // تحويل الأرقام العربية إلى إنجليزية
          buffer.write(_convertToEnglishDigits(char));
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  static String _convertToArabicDigits(String digit) {
    const englishToArabic = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
    };
    return englishToArabic[digit] ?? digit;
  }

  static String _convertToEnglishDigits(String digit) {
    const arabicToEnglish = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    return arabicToEnglish[digit] ?? digit;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تصحيح الترتيب البصري
  // ═══════════════════════════════════════════════════════════════════════

  /// تصحيح الترتيب البصري للنص
  /// Fix visual ordering of text
  static String fixVisualOrder(String text) {
    return reorder(text);
  }

  /// الحصول على ترتيب العرض البصري
  /// Get visual display order
  static List<int> getVisualOrder(String text) {
    if (text.isEmpty) return [];

    final chars = text.characters.toList();
    final n = chars.length;

    // حساب المستويات
    final levels = <int>[];
    int paragraphLevel = 0;

    for (final char in chars) {
      final type = getCharType(char);
      if (type == AL || type == R) {
        paragraphLevel = 1;
        break;
      }
    }

    int currentLevel = paragraphLevel;
    for (int i = 0; i < n; i++) {
      final type = getCharType(chars[i]);
      if (type == L || type == R || type == AL) {
        currentLevel = (type == AL) ? 1 : 0;
      }
      levels.add(currentLevel);
    }

    // ترتيب تصاعدي حسب المستوى
    final indices = List.generate(n, (i) => i);
    indices.sort((a, b) {
      final levelDiff = levels[a] - levels[b];
      if (levelDiff != 0) return levelDiff;

      // داخل نفس المستوى، الفردي معكوس
      if (levels[a] % 2 == 1) {
        return b - a;
      }
      return a - b;
    });

    return indices;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: arabic_bidi.dart
// ═══════════════════════════════════════════════════════════════════════════