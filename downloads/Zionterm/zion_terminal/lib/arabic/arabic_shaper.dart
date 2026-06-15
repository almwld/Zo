// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Arabic Shaper - تشكيل النصوص العربية                   ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: تشكيل الأحرف العربية ومعالجة Unicode                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

/// ═══════════════════════════════════════════════════════════════════════════
///                    ArabicShaper - تشكيل النصوص العربية
///                    Arabic Text Shaping and Character Transformation
/// ═══════════════════════════════════════════════════════════════════════════

class ArabicShaper {
  // ═══════════════════════════════════════════════════════════════════════
  //                      جداول الأشكال
  //                      Shape Tables
  // ═══════════════════════════════════════════════════════════════════════

  /// خرائط الأشكال للأحرف العربية
  /// Shape maps for Arabic letters
  static final Map<String, Map<String, String>> _shapeMaps = {
    // ═══════════════════════════════════════════════════════════════════
    //                      الحروف الأساسية
    // ═══════════════════════════════════════════════════════════════════

    'ا': {
      'isolated': 'ا',
      'initial': 'أ',
      'medial': 'ـا',
      'final': 'ـا',
    },
    'أ': {
      'isolated': 'أ',
      'initial': 'أ',
      'medial': 'ـأ',
      'final': 'ـأ',
    },
    'آ': {
      'isolated': 'آ',
      'initial': 'آ',
      'medial': 'ـآ',
      'final': 'ـآ',
    },
    'ؤ': {
      'isolated': 'ؤ',
      'initial': 'ؤ',
      'medial': 'ـؤ',
      'final': 'ـؤ',
    },
    'ئ': {
      'isolated': 'ئ',
      'initial': 'ئ',
      'medial': 'ـئ',
      'final': 'ـئ',
    },
    'إ': {
      'isolated': 'إ',
      'initial': 'إ',
      'medial': 'ـإ',
      'final': 'ـإ',
    },
    'ء': {
      'isolated': 'ء',
      'initial': 'ء',
      'medial': 'ء',
      'final': 'ء',
    },
    'ى': {
      'isolated': 'ى',
      'initial': 'ي',
      'medial': 'ـي',
      'final': 'ـى',
    },

    // ═══════════════════════════════════════════════════════════════════
    //                      حروف القطع
    // ═══════════════════════════════════════════════════════════════════

    'ب': {
      'isolated': 'ب',
      'initial': 'بـ',
      'medial': 'ـبـ',
      'final': 'ـب',
    },
    'ت': {
      'isolated': 'ت',
      'initial': 'تـ',
      'medial': 'ـتـ',
      'final': 'ـت',
    },
    'ث': {
      'isolated': 'ث',
      'initial': 'ثـ',
      'medial': 'ـثـ',
      'final': 'ـث',
    },
    'ج': {
      'isolated': 'ج',
      'initial': 'جـ',
      'medial': 'ـجـ',
      'final': 'ـج',
    },
    'ح': {
      'isolated': 'ح',
      'initial': 'حـ',
      'medial': 'ـحـ',
      'final': 'ـح',
    },
    'خ': {
      'isolated': 'خ',
      'initial': 'خـ',
      'medial': 'ـخـ',
      'final': 'ـخ',
    },
    'د': {
      'isolated': 'د',
      'initial': 'د',
      'medial': 'ـد',
      'final': 'ـد',
    },
    'ذ': {
      'isolated': 'ذ',
      'initial': 'ذ',
      'medial': 'ـذ',
      'final': 'ـذ',
    },
    'ر': {
      'isolated': 'ر',
      'initial': 'ر',
      'medial': 'ـر',
      'final': 'ـر',
    },
    'ز': {
      'isolated': 'ز',
      'initial': 'ز',
      'medial': 'ـز',
      'final': 'ـز',
    },
    'س': {
      'isolated': 'س',
      'initial': 'سـ',
      'medial': 'ـسـ',
      'final': 'ـس',
    },
    'ش': {
      'isolated': 'ش',
      'initial': 'شـ',
      'medial': 'ـشـ',
      'final': 'ـش',
    },
    'ص': {
      'isolated': 'ص',
      'initial': 'صـ',
      'medial': 'ـصـ',
      'final': 'ـص',
    },
    'ض': {
      'isolated': 'ض',
      'initial': 'ضـ',
      'medial': 'ـضـ',
      'final': 'ـض',
    },
    'ط': {
      'isolated': 'ط',
      'initial': 'ط',
      'medial': 'ـط',
      'final': 'ـط',
    },
    'ظ': {
      'isolated': 'ظ',
      'initial': 'ظ',
      'medial': 'ـظ',
      'final': 'ـظ',
    },
    'ع': {
      'isolated': 'ع',
      'initial': 'عـ',
      'medial': 'ـعـ',
      'final': 'ـع',
    },
    'غ': {
      'isolated': 'غ',
      'initial': 'غـ',
      'medial': 'ـغـ',
      'final': 'ـغ',
    },
    'ف': {
      'isolated': 'ف',
      'initial': 'فـ',
      'medial': 'ـفـ',
      'final': 'ـف',
    },
    'ق': {
      'isolated': 'ق',
      'initial': 'قـ',
      'medial': 'ـقـ',
      'final': 'ـق',
    },
    'ك': {
      'isolated': 'ك',
      'initial': 'كـ',
      'medial': 'ـكـ',
      'final': 'ـك',
    },
    'ل': {
      'isolated': 'ل',
      'initial': 'لـ',
      'medial': 'ـلـ',
      'final': 'ـل',
    },
    'م': {
      'isolated': 'م',
      'initial': 'مـ',
      'medial': 'ـمـ',
      'final': 'ـم',
    },
    'ن': {
      'isolated': 'ن',
      'initial': 'نـ',
      'medial': 'ـنـ',
      'final': 'ـن',
    },
    'ه': {
      'isolated': 'ه',
      'initial': 'هـ',
      'medial': 'ـهـ',
      'final': 'ـه',
    },
    'و': {
      'isolated': 'و',
      'initial': 'و',
      'medial': 'ـو',
      'final': 'ـو',
    },
    'ي': {
      'isolated': 'ي',
      'initial': 'يـ',
      'medial': 'ـيـ',
      'final': 'ـي',
    },
    'ة': {
      'isolated': 'ة',
      'initial': 'ة',
      'medial': 'ـة',
      'final': 'ـة',
    },
    'ى': {
      'isolated': 'ى',
      'initial': 'ي',
      'medial': 'ـي',
      'final': 'ـى',
    },

    // ═══════════════════════════════════════════════════════════════════
    //                      حروف إضافية
    // ═══════════════════════════════════════════════════════════════════

    'ٱ': {
      'isolated': 'ٱ',
      'initial': 'ٱ',
      'medial': 'ـٱ',
      'final': 'ـٱ',
    },
    'ٮ': {
      'isolated': 'ٮ',
      'initial': 'ٮ',
      'medial': 'ـٮ',
      'final': 'ـٮ',
    },
    'ٯ': {
      'isolated': 'ٯ',
      'initial': 'ٯ',
      'medial': 'ٯ',
      'final': 'ٯ',
    },
    'پ': {
      'isolated': 'پ',
      'initial': 'پـ',
      'medial': 'ـپـ',
      'final': 'ـپ',
    },
    'چ': {
      'isolated': 'چ',
      'initial': 'چـ',
      'medial': 'ـچـ',
      'final': 'ـچ',
    },
    'ژ': {
      'isolated': 'ژ',
      'initial': 'ژ',
      'medial': 'ـژ',
      'final': 'ـژ',
    },
    'گ': {
      'isolated': 'گ',
      'initial': 'گـ',
      'medial': 'ـگـ',
      'final': 'ـگ',
    },
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      أحرف لا تتصل بما بعدها
  //                      Non-connecting characters
  // ═══════════════════════════════════════════════════════════════════════

  static const Set<String> _nonConnectingChars = {
    'ا', 'د', 'ذ', 'ر', 'ز', 'و', 'ؤ', 'ئ', 'ء', 'آ', 'أ', 'إ',
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    '،', '؛', '؟', '!', '.', ',', ';', '?', ':', '-', ')', '(',
    ' ', '\t', '\n', '\r',
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      أحرف RTL
  //                      RTL Characters
  // ═══════════════════════════════════════════════════════════════════════

  static const Set<String> _rtlChars = {
    'ا', 'أ', 'آ', 'إ', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
    'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل',
    'م', 'ن', 'ه', 'و', 'ي', 'ى', 'ة', 'ؤ', 'ئ', 'ء',
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    '،', '؛', '؟', '!',
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      تشكيل النص
  // ═══════════════════════════════════════════════════════════════════════

  /// تشكيل نص عربي كامل
  /// Shape a complete Arabic text
  static String shape(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    final chars = text.characters.toList();

    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];

      if (!isArabicChar(char)) {
        buffer.write(char);
        continue;
      }

      final prevChar = i > 0 ? chars[i - 1] : null;
      final nextChar = i < chars.length - 1 ? chars[i + 1] : null;

      final shape = _getShape(char, prevChar, nextChar);
      buffer.write(shape);
    }

    return buffer.toString();
  }

  /// الحصول على شكل الحرف بناءً على سياقه
  /// Get character shape based on context
  static String _getShape(String char, String? prevChar, String? nextChar) {
    final map = _shapeMaps[char];
    if (map == null) return char;

    final prevConnects = prevChar != null && _connectsToPrev(prevChar);
    final nextConnects = nextChar != null && _connectsToNext(nextChar);

    String position;
    if (!prevConnects && !nextConnects) {
      position = 'isolated';
    } else if (!prevConnects && nextConnects) {
      position = 'initial';
    } else if (prevConnects && nextConnects) {
      position = 'medial';
    } else {
      position = 'final';
    }

    return map[position] ?? char;
  }

  /// هل الحرف يتصل بما قبله
  /// Whether character connects to previous
  static bool _connectsToPrev(String char) {
    if (isDiacritic(char)) return true;
    if (_nonConnectingChars.contains(char)) return false;
    if (_shapeMaps.containsKey(char)) return true;
    return false;
  }

  /// هل الحرف يتصل بما بعده
  /// Whether character connects to next
  static bool _connectsToNext(String char) {
    if (isDiacritic(char)) return true;
    if (_nonConnectingChars.contains(char)) return false;
    if (_shapeMaps.containsKey(char)) return true;
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التحقق من الأحرف
  // ═══════════════════════════════════════════════════════════════════════

  /// هل الحرف عربي
  /// Whether character is Arabic
  static bool isArabicChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);

    // النطاق الأساسي للأحرف العربية
    if (code >= 0x0621 && code <= 0x063A) return true;
    if (code >= 0x0641 && code <= 0x064A) return true;

    // حروف إضافية
    if (code >= 0x0670 && code <= 0x06D3) return true;
    if (code >= 0x06D5 && code <= 0x06DC) return true;
    if (code >= 0x06E5 && code <= 0x06E8) return true;
    if (code >= 0x06EA && code <= 0x06ED) return true;

    // أرقام عربية
    if (code >= 0x0660 && code <= 0x0669) return true;

    // علامات ترقيم عربية
    if (code == 0x060C || code == 0x060D) return true;
    if (code == 0x061B || code == 0x061F) return true;

    return false;
  }

  /// هل الحرف علامة تشكيل
  /// Whether character is a diacritic
  static bool isDiacritic(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);

    // Fatha, Kasra, Damma
    if (code >= 0x064B && code <= 0x065F) return true;

    // Sukun, Shadda, Madda
    if (code >= 0x06E0 && code <= 0x06E4) return true;
    if (code >= 0x06E6 && code <= 0x06E9) return true;

    return false;
  }

  /// هل النص عربي بالكامل
  /// Whether text is entirely Arabic
  static bool isArabicText(String text) {
    for (final char in text.characters) {
      if (!isArabicChar(char) && !isDiacritic(char) && char != ' ') {
        return false;
      }
    }
    return true;
  }

  /// هل النص يحتوي على نص عربي
  /// Whether text contains Arabic
  static bool containsArabic(String text) {
    for (final char in text.characters) {
      if (isArabicChar(char)) return true;
    }
    return false;
  }

  /// هل الحرف RTL
  /// Whether character is RTL
  static bool isRtl(String char) {
    return _rtlChars.contains(char);
  }

  /// هل النص RTL
  /// Whether text is RTL
  static bool isRtlText(String text) {
    for (final char in text.characters) {
      if (isRtl(char)) return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التشكيل
  // ═══════════════════════════════════════════════════════════════════════

  /// إضافة تشكيل للنص
  /// Add diacritics to text
  static String addDiacritics(String text, String diacritics) {
    final buffer = StringBuffer();
    int diacriticIndex = 0;

    for (final char in text.characters) {
      buffer.write(char);

      if (isArabicChar(char) && diacriticIndex < diacritics.length) {
        buffer.write(diacritics[diacriticIndex]);
        diacriticIndex++;
      }
    }

    return buffer.toString();
  }

  /// إزالة التشكيل من النص
  /// Remove diacritics from text
  static String removeDiacritics(String text) {
    return text.runes
        .where((code) =>
            !(code >= 0x064B && code <= 0x065F) &&
            !(code >= 0x06E0 && code <= 0x06E4) &&
            !(code >= 0x06E6 && code <= 0x06ED))
        .map((code) => String.fromCharCode(code))
        .join();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      التقسيم
  // ═══════════════════════════════════════════════════════════════════════

  /// تقسيم النص إلى كلمات
  /// Split text into words
  static List<String> splitIntoWords(String text) {
    return text.split(RegExp(r'[\s‌]+')).where((w) => w.isNotEmpty).toList();
  }

  /// تقسيم النص إلى مقاطع
  /// Split text into segments
  static List<String> splitIntoSegments(String text) {
    final segments = <String>[];
    var currentSegment = StringBuffer();
    bool inArabic = false;

    for (final char in text.characters) {
      final isArabic = isArabicChar(char);

      if (inArabic && !isArabic) {
        segments.add(currentSegment.toString());
        currentSegment = StringBuffer();
      } else if (!inArabic && isArabic) {
        if (currentSegment.isNotEmpty) {
          segments.add(currentSegment.toString());
          currentSegment = StringBuffer();
        }
      }

      currentSegment.write(char);
      inArabic = isArabic;
    }

    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment.toString());
    }

    return segments;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الترتيب
  // ═══════════════════════════════════════════════════════════════════════

  /// عكس النص العربي (للعرض RTL)
  /// Reverse Arabic text (for RTL display)
  static String reverseForRtl(String text) {
    final segments = splitIntoSegments(text);
    return segments.reversed.join('');
  }

  /// توحيد الترميز
  /// Normalize encoding
  static String normalize(String text) {
    return text
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: arabic_shaper.dart
// ═══════════════════════════════════════════════════════════════════════════