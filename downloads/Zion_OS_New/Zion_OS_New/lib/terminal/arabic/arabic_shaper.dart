class ArabicShaper {
  static const Map<int, Map<String, int>> arabicShapes = {
    // ألف (Alif)
    0x0627: {'isolated': 0xFE8D, 'initial': 0x0627, 'medial': 0x0627, 'final': 0xFE8E},
    // باء (Ba)
    0x0628: {'isolated': 0xFE8F, 'initial': 0xFE91, 'medial': 0xFE92, 'final': 0xFE90},
    // تاء (Ta)
    0x062A: {'isolated': 0xFE95, 'initial': 0xFE97, 'medial': 0xFE98, 'final': 0xFE96},
    // ثاء (Tha)
    0x062B: {'isolated': 0xFE99, 'initial': 0xFE9B, 'medial': 0xFE9C, 'final': 0xFE9A},
    // جيم (Jeem)
    0x062C: {'isolated': 0xFE9D, 'initial': 0xFE9F, 'medial': 0xFEA0, 'final': 0xFE9E},
    // حاء (Ha)
    0x062D: {'isolated': 0xFEA1, 'initial': 0xFEA3, 'medial': 0xFEA4, 'final': 0xFEA2},
    // خاء (Kha)
    0x062E: {'isolated': 0xFEA5, 'initial': 0xFEA7, 'medial': 0xFEA8, 'final': 0xFEA6},
    // دال (Dal)
    0x062F: {'isolated': 0xFEA9, 'initial': 0xFEA9, 'medial': 0xFEAA, 'final': 0xFEAA},
    // ذال (Dhal)
    0x0630: {'isolated': 0xFEAB, 'initial': 0xFEAB, 'medial': 0xFEAC, 'final': 0xFEAC},
    // راء (Ra)
    0x0631: {'isolated': 0xFEAD, 'initial': 0xFEAD, 'medial': 0xFEAE, 'final': 0xFEAE},
    // زاي (Zay)
    0x0632: {'isolated': 0xFEAF, 'initial': 0xFEAF, 'medial': 0xFEB0, 'final': 0xFEB0},
    // سين (Seen)
    0x0633: {'isolated': 0xFEB1, 'initial': 0xFEB3, 'medial': 0xFEB4, 'final': 0xFEB2},
    // شين (Sheen)
    0x0634: {'isolated': 0xFEB5, 'initial': 0xFEB7, 'medial': 0xFEB8, 'final': 0xFEB6},
    // صاد (Sad)
    0x0635: {'isolated': 0xFEB9, 'initial': 0xFEBB, 'medial': 0xFEBC, 'final': 0xFEBA},
    // ضاد (Dad)
    0x0636: {'isolated': 0xFEBD, 'initial': 0xFEBF, 'medial': 0xFEC0, 'final': 0xFEBE},
    // طاء (Tah)
    0x0637: {'isolated': 0xFEC1, 'initial': 0xFEC3, 'medial': 0xFEC4, 'final': 0xFEC2},
    // ظاء (Zah)
    0x0638: {'isolated': 0xFEC5, 'initial': 0xFEC7, 'medial': 0xFEC8, 'final': 0xFEC6},
    // عين (Ain)
    0x0639: {'isolated': 0xFEC9, 'initial': 0xFECB, 'medial': 0xFECC, 'final': 0xFECA},
    // غين (Ghain)
    0x063A: {'isolated': 0xFECD, 'initial': 0xFECF, 'medial': 0xFED0, 'final': 0xFECE},
    // فاء (Fa)
    0x0641: {'isolated': 0xFED1, 'initial': 0xFED3, 'medial': 0xFED4, 'final': 0xFED2},
    // قاف (Qaf)
    0x0642: {'isolated': 0xFED5, 'initial': 0xFED7, 'medial': 0xFED8, 'final': 0xFED6},
    // كاف (Kaf)
    0x0643: {'isolated': 0xFED9, 'initial': 0xFEDB, 'medial': 0xFEDC, 'final': 0xFEDA},
    // لام (Lam)
    0x0644: {'isolated': 0xFEDD, 'initial': 0xFEDF, 'medial': 0xFEE0, 'final': 0xFEDE},
    // ميم (Meem)
    0x0645: {'isolated': 0xFEE1, 'initial': 0xFEE3, 'medial': 0xFEE4, 'final': 0xFEE2},
    // نون (Noon)
    0x0646: {'isolated': 0xFEE5, 'initial': 0xFEE7, 'medial': 0xFEE8, 'final': 0xFEE6},
    // هاء (Ha)
    0x0647: {'isolated': 0xFEE9, 'initial': 0xFEEB, 'medial': 0xFEEC, 'final': 0xFEEA},
    // واو (Waw)
    0x0648: {'isolated': 0xFEED, 'initial': 0xFEED, 'medial': 0xFEEE, 'final': 0xFEEE},
    // ياء (Ya)
    0x064A: {'isolated': 0xFEF1, 'initial': 0xFEF3, 'medial': 0xFEF4, 'final': 0xFEF2},
    // ألف ممدودة (Alef Madda)
    0x0622: {'isolated': 0xFE81, 'initial': 0xFE81, 'medial': 0xFE82, 'final': 0xFE82},
    // ألف همزة فوق (Aleph Hamza Above)
    0x0623: {'isolated': 0xFE83, 'initial': 0xFE83, 'medial': 0xFE84, 'final': 0xFE84},
    // ألف همزة تحت (Aleph Hamza Below)
    0x0625: {'isolated': 0xFE87, 'initial': 0xFE87, 'medial': 0xFE88, 'final': 0xFE88},
    // ئ (Ya Hamza)
    0x0626: {'isolated': 0xFE89, 'initial': 0xFE8B, 'medial': 0xFE8C, 'final': 0xFE8A},
    // ة (Ta Marbuta)
    0x0629: {'isolated': 0xFE93, 'initial': 0xFE93, 'medial': 0xFE94, 'final': 0xFE94},
    // ى (Aleph Maksura)
    0x0649: {'isolated': 0xFEEF, 'initial': 0xFEEF, 'medial': 0xFEF0, 'final': 0xFEF0},
    // لا (Lam Alef)
    0xFEFB: {'isolated': 0xFEFB, 'initial': 0xFEFB, 'medial': 0xFEFC, 'final': 0xFEFC},
    // لأ (Lam Aleph Hamza Above)
    0xFEF7: {'isolated': 0xFEF7, 'initial': 0xFEF7, 'medial': 0xFEF8, 'final': 0xFEF8},
    // لإ (Lam Aleph Hamza Below)
    0xFEF9: {'isolated': 0xFEF9, 'initial': 0xFEF9, 'medial': 0xFEFA, 'final': 0xFEFA},
    // لآ (Lam Alef Madda)
    0xFEF5: {'isolated': 0xFEF5, 'initial': 0xFEF5, 'medial': 0xFEF6, 'final': 0xFEF6},
  };

  // Diacritics (Tashkeel) - don't connect to following letters
  static const Set<int> _diacritics = {
    0x064B, // Fathatan
    0x064C, // Dammatan
    0x064D, // Kasratan
    0x064E, // Fatha
    0x064F, // Damma
    0x0650, // Kasra
    0x0651, // Shadda
    0x0652, // Sukun
    0x0653, // Maddah
    0x0654, // Hamza Above
    0x0655, // Hamza Below
  };

  // Letters that don't connect to the left (dual-form)
  static const Set<int> _dualFormLetters = {
    0x0627, // Alif
    0x0622, // Alif Madda
    0x0623, // Alif Hamza Above
    0x0625, // Alif Hamza Below
    0x062F, // Dal
    0x0630, // Dhal
    0x0631, // Ra
    0x0632, // Zay
    0x0648, // Waw
    0x0649, // Aleph Maksura
    0x0629, // Ta Marbuta
  };

  // Lam Alef ligature combinations
  static const Map<int, Map<int, int>> _lamAlefLigatures = {
    0x0627: {0xFE81: 0xFEF5, 0xFE82: 0xFEF6, 0xFE8D: 0xFEFB, 0xFE8E: 0xFEFC},
    0x0623: {0xFE83: 0xFEF7, 0xFE84: 0xFEF8},
    0x0625: {0xFE87: 0xFEF9, 0xFE88: 0xFEFA},
  };

  static bool isArabic(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return isArabicChar(code);
  }

  static bool isArabicChar(int codePoint) {
    return (codePoint >= 0x0600 && codePoint <= 0x06FF) ||
        (codePoint >= 0x0750 && codePoint <= 0x077F) ||
        (codePoint >= 0x08A0 && codePoint <= 0x08FF) ||
        (codePoint >= 0xFB50 && codePoint <= 0xFDFF) ||
        (codePoint >= 0xFE70 && codePoint <= 0xFEFF);
  }

  static bool _isConnecting(int codePoint) {
    return arabicShapes.containsKey(codePoint) && !_dualFormLetters.contains(codePoint);
  }

  static bool _canConnectToLeft(int codePoint) {
    return arabicShapes.containsKey(codePoint) && !_dualFormLetters.contains(codePoint);
  }

  static bool _canConnectToRight(int codePoint) {
    return arabicShapes.containsKey(codePoint);
  }

  static String shape(String text) {
    if (text.isEmpty) return text;

    final codePoints = text.runes.toList();
    final shapedChars = <String>[];
    final arabicBuffer = <_ArabicRun>[];

    for (int i = 0; i < codePoints.length; i++) {
      final cp = codePoints[i];

      if (isArabicChar(cp)) {
        final prevConnects = i > 0 && _isConnecting(codePoints[i - 1]) && _canConnectToRight(cp);
        final nextConnects = i < codePoints.length - 1 &&
            _canConnectToLeft(cp) &&
            _canConnectToRight(codePoints[i + 1]);

        arabicBuffer.add(_ArabicRun(
          codePoint: cp,
          hasLeftConnection: prevConnects,
          hasRightConnection: nextConnects,
          index: i,
        ));
      } else {
        if (arabicBuffer.isNotEmpty) {
          _processArabicBuffer(arabicBuffer, shapedChars);
          arabicBuffer.clear();
        }
        shapedChars.add(String.fromCharCode(cp));
      }
    }

    if (arabicBuffer.isNotEmpty) {
      _processArabicBuffer(arabicBuffer, shapedChars);
    }

    return shapedChars.join();
  }

  static void _processArabicBuffer(List<_ArabicRun> buffer, List<String> output) {
    // Process Lam-Alef ligatures first
    final processed = _processLamAlefLigatures(buffer);

    // Apply shaping
    final result = <String>[];
    for (int i = 0; i < processed.length; i++) {
      final run = processed[i];
      if (arabicShapes.containsKey(run.codePoint)) {
        final shapes = arabicShapes[run.codePoint]!;
        int shapedCode;

        if (run.hasLeftConnection && run.hasRightConnection) {
          shapedCode = shapes['medial']!;
        } else if (run.hasLeftConnection) {
          shapedCode = shapes['final']!;
        } else if (run.hasRightConnection) {
          shapedCode = shapes['initial']!;
        } else {
          shapedCode = shapes['isolated']!;
        }

        result.add(String.fromCharCode(shapedCode));
      } else {
        result.add(String.fromCharCode(run.codePoint));
      }
    }

    output.addAll(result.reversed);
  }

  static List<_ArabicRun> _processLamAlefLigatures(List<_ArabicRun> buffer) {
    final result = <_ArabicRun>[];

    for (int i = 0; i < buffer.length; i++) {
      if (i < buffer.length - 1 &&
          buffer[i].codePoint == 0x0644 && // Lam
          _lamAlefLigatures.containsKey(buffer[i + 1].codePoint)) {
        final alefCode = buffer[i + 1].codePoint;
        final isFinal = !buffer[i + 1].hasRightConnection;

        final ligatureMap = _lamAlefLigatures[alefCode]!;
        final ligatureCode = isFinal
            ? ligatureMap.values.last
            : ligatureMap.values.first;

        if (ligatureCode != null) {
          result.add(_ArabicRun(
            codePoint: ligatureCode,
            hasLeftConnection: buffer[i].hasLeftConnection,
            hasRightConnection: false,
            index: buffer[i].index,
          ));
          i++;
          continue;
        }
      }
      result.add(buffer[i]);
    }

    return result;
  }

  static String getShape(int codePoint, String form) {
    if (!arabicShapes.containsKey(codePoint)) {
      return String.fromCharCode(codePoint);
    }

    final shapes = arabicShapes[codePoint]!;
    final shapedCode = shapes[form];
    if (shapedCode != null) {
      return String.fromCharCode(shapedCode);
    }

    return String.fromCharCode(codePoint);
  }

  static String shapeWithTashkeel(String text) {
    if (text.isEmpty) return text;

    final codePoints = text.runes.toList();
    final result = <String>[];

    for (int i = 0; i < codePoints.length; i++) {
      final cp = codePoints[i];

      if (_diacritics.contains(cp)) {
        continue;
      }

      result.add(String.fromCharCode(cp));
    }

    return shape(result.join());
  }

  static String reverseWordsForDisplay(String text) {
    if (text.isEmpty) return text;

    final words = text.split(RegExp(r'(?<=\s)(?=\S)|(?<=\S)(?=\s)'));
    final result = <String>[];
    var currentArabicSegment = <String>[];

    for (final word in words) {
      if (word.isNotEmpty && isArabicChar(word.runes.first)) {
        currentArabicSegment.add(word);
      } else {
        if (currentArabicSegment.isNotEmpty) {
          result.addAll(currentArabicSegment.reversed);
          currentArabicSegment.clear();
        }
        result.add(word);
      }
    }

    if (currentArabicSegment.isNotEmpty) {
      result.addAll(currentArabicSegment.reversed);
    }

    return result.join();
  }

  static bool containsArabic(String text) {
    for (final rune in text.runes) {
      if (isArabicChar(rune)) return true;
    }
    return false;
  }

  static int countArabicChars(String text) {
    int count = 0;
    for (final rune in text.runes) {
      if (isArabicChar(rune)) count++;
    }
    return count;
  }

  static String normalizeArabic(String text) {
    var result = text;

    // Normalize Arabic alef variants
    result = result.replaceAll('\u0623', '\u0627'); // أ → ا
    result = result.replaceAll('\u0622', '\u0627'); // آ → ا
    result = result.replaceAll('\u0625', '\u0627'); // إ → ا

    // Normalize taa marbuta
    result = result.replaceAll('\u0629', '\u0647'); // ة → ه

    // Normalize yaa
    result = result.replaceAll('\u0649', '\u064A'); // ى → ي

    return result;
  }

  static String removeTashkeel(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (!_diacritics.contains(rune)) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String removeHarakat(String text) {
    final harakat = {
      0x064B, 0x064C, 0x064D, 0x064E, 0x064F, 0x0650, 0x0651, 0x0652
    };
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (!harakat.contains(rune)) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}

class _ArabicRun {
  final int codePoint;
  final bool hasLeftConnection;
  final bool hasRightConnection;
  final int index;

  _ArabicRun({
    required this.codePoint,
    required this.hasLeftConnection,
    required this.hasRightConnection,
    required this.index,
  });

  @override
  String toString() {
    return '_ArabicRun(${String.fromCharCode(codePoint)}, left=$hasLeftConnection, right=$hasRightConnection)';
  }
}
