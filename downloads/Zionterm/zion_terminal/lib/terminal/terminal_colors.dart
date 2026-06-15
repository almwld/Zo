// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Colors - ألوان الطرفية                        ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: نظام ألوان الطرفية - 256 لون + True Color                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalColors - نظام ألوان الطرفية
///                    Terminal Color System - 256 colors + True Color
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalColors {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الألوان الافتراضية
  //                      Default Colors
  // ═══════════════════════════════════════════════════════════════════════

  static const Color defaultForeground = Color(0xFFE6EDF3);
  static const Color defaultBackground = Color(0xFF0D1117);

  // ═══════════════════════════════════════════════════════════════════════
  //                      الألوان الأساسية (0-15)
  //                      Basic Colors (0-15)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<Color> basicColors = [
    Color(0xFF000000), // 0: أسود
    Color(0xFFCD0000), // 1: أحمر
    Color(0xFF00CD00), // 2: أخضر
    Color(0xFFCDCD00), // 3: أصفر
    Color(0xFF0000EE), // 4: أزرق
    Color(0xFFCD00CD), // 5: بنفسجي
    Color(0xFF00CDCD), // 6: سماوي
    Color(0xFFE5E5E5), // 7: رمادي فاتح
    Color(0xFF7F7F7F), // 8: رمادي داكن
    Color(0xFFFF0000), // 9: أحمر فاتح
    Color(0xFF00FF00), // 10: أخضر فاتح
    Color(0xFFFFFF00), // 11: أصفر فاتح
    Color(0xFF5C5CFF), // 12: أزرق فاتح
    Color(0xFFFF00FF), // 13: وردي
    Color(0xFF00FFFF), // 14: سماوي فاتح
    Color(0xFFFFFFFF), // 15: أبيض
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //                      الألوان الموسعة (16-231)
  //                      Extended Colors (16-231)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<Color> extendedColors = [
    // درجات الأحمر (16-27)
    Color(0xFF800000), Color(0xFF8B0000), Color(0xFFA52A2A), Color(0xFFB22222),
    Color(0xFFDC143C), Color(0xFFF08080), Color(0xFFFF0000), Color(0xFFFF6347),
    Color(0xFFFF7F50), Color(0xFFCD5C5C), Color(0xFFF08080), Color(0xFFE9967A),
    Color(0xFFFA8072), Color(0xFFFFA07A), Color(0xFFFF4500), Color(0xFFFF6B6B),
    Color(0xFFFF8C00), Color(0xFFD2691E), Color(0xFFFF7F00), Color(0xFFFF8C00),
    Color(0xFFFFA500), Color(0xFFFFB347), Color(0xFFFFCC00), Color(0xFFFFD700),
    Color(0xFFFFD700), Color(0xFFFFE135), Color(0xFFFFEB3B), Color(0xFFFFF176),

    // درجات الأخضر (28-51)
    Color(0xFF006400), Color(0xFF228B22), Color(0xFF32CD32), Color(0xFF008000),
    Color(0xFF00FF00), Color(0xFF3CB371), Color(0xFF8FBC8F), Color(0xFF90EE90),
    Color(0xFF98FB98), Color(0xFF00FA9A), Color(0xFF00FF7F), Color(0xFF7FFF00),
    Color(0xFFADFF2F), Color(0xFF7CFC00), Color(0xFF00FF41), Color(0xFF32FF32),
    Color(0xFF39FF14), Color(0xFF00FF00), Color(0xFF00CC00), Color(0xFF00B300),
    Color(0xFF009900), Color(0xFF008800), Color(0xFF007700), Color(0xFF006600),

    // درجات الأزرق (52-75)
    Color(0xFF000080), Color(0xFF0000CD), Color(0xFF0000FF), Color(0xFF4169E1),
    Color(0xFF6495ED), Color(0xFF87CEEB), Color(0xFF87CEFA), Color(0xFFADD8E6),
    Color(0xFFB0E0E6), Color(0xFF00BFFF), Color(0xFF00CED1), Color(0xFF20B2AA),
    Color(0xFF40E0D0), Color(0xFF48D1CC), Color(0xFF00FFFF), Color(0xFFE0FFFF),
    Color(0xFF00BFFF), Color(0xFF1E90FF), Color(0xFF87CEEB), Color(0xFF00AEEF),
    Color(0xFF00B4D8), Color(0xFF0077B6), Color(0xFF023E8A), Color(0xFF03045E),

    // درجات البنفسجي (76-99)
    Color(0xFF4B0082), Color(0xFF6A5ACD), Color(0xFF7B68EE), Color(0xFF8A2BE2),
    Color(0xFF9400D3), Color(0xFFBA55D3), Color(0xFF9932CC), Color(0xFF8B008B),
    Color(0xFF800080), Color(0xFFDA70D6), Color(0xFFEE82EE), Color(0xFFFF00FF),
    Color(0xFFDA70D6), Color(0xFFFF77FF), Color(0xFFFF99FF), Color(0xFFFFBBFF),
    Color(0xFFDDA0DD), Color(0xFFEE99AA), Color(0xFFC8A2C8), Color(0xFF967BB6),
    Color(0xFF9B59B6), Color(0xFF8E44AD), Color(0xFF7D3C98), Color(0xFF6C3483),

    // درجات البرتقالي والبني (100-123)
    Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFFCD853F), Color(0xFFD2691E),
    Color(0xFFF4A460), Color(0xFFFF7F50), Color(0xFFFF6347), Color(0xFFFF7F7F),
    Color(0xFFFF9966), Color(0xFFFFCC99), Color(0xFFFFE4B5), Color(0xFFFFDAB9),
    Color(0xFFEEE8AA), Color(0xFFF0E68C), Color(0xFFFFD700), Color(0xFFDAA520),
    Color(0xFFB8860B), Color(0xFFFF8C00), Color(0xFFFF6600), Color(0xFFFF4500),
    Color(0xFFDC143C), Color(0xFFB22222), Color(0xFF8B0000), Color(0xFF800000),

    // درجات الرمادي (124-147)
    Color(0xFF696969), Color(0xFF808080), Color(0xFFA9A9A9), Color(0xFFC0C0C0),
    Color(0xFFD3D3D3), Color(0xFFDCDCDC), Color(0xFFF5F5F5), Color(0xFF000000),
    Color(0xFF1C1C1C), Color(0xFF2C2C2C), Color(0xFF3C3C3C), Color(0xFF4C4C4C),
    Color(0xFF5C5C5C), Color(0xFF6C6C6C), Color(0xFF7C7C7C), Color(0xFF8C8C8C),
    Color(0xFF9C9C9C), Color(0xFFACACAC), Color(0xFFBCBCBC), Color(0xFFCCCCCC),
    Color(0xFFDCDCDC), Color(0xFFECECEC), Color(0xFFFCFCFC), Color(0xFFFFFFFF),

    // درجات متنوعة (148-231)
    Color(0xFF000080), Color(0xFF00008B), Color(0xFF0000CD), Color(0xFF0000FF),
    Color(0xFF1C1C1C), Color(0xFF232323), Color(0xFF2A2A2A), Color(0xFF323232),
    Color(0xFF393939), Color(0xFF414141), Color(0xFF494949), Color(0xFF515151),
    Color(0xFF595959), Color(0xFF616161), Color(0xFF696969), Color(0xFF707070),
    Color(0xFF787878), Color(0xFF808080), Color(0xFF878787), Color(0xFF8F8F8F),
    Color(0xFF969696), Color(0xFF9E9E9E), Color(0xFFA5A5A5), Color(0xFFADADAD),
    Color(0xFFB5B5B5), Color(0xFFBDBDBD), Color(0xFFC5C5C5), Color(0xFFCDCDCD),
    Color(0xFFD5D5D5), Color(0xFFDDDDDD), Color(0xFFE5E5E5), Color(0xFFEBEBEB),
    Color(0xFFF0F0F0), Color(0xFFF5F5F5), Color(0xFFFAFAFA), Color(0xFFFFFFFF),
    Color(0xFFFFC0CB), Color(0xFFFF69B4), Color(0xFFFF1493), Color(0xFFC71585),
    Color(0xFFDB7093), Color(0xFFF0E68C), Color(0xFFEEE8AA), Color(0xFFFFD700),
    Color(0xFFFFDAB9), Color(0xFFFFE4E1), Color(0xFFFFB6C1), Color(0xFFD8BFD8),
    Color(0xFFDDA0DD), Color(0xFFEE82EE), Color(0xFFE6E6FA), Color(0xFFFFF0F5),
    Color(0xFFBC8F8F), Color(0xFFF4A460), Color(0xFFD2B48C), Color(0xFFDEB887),
    Color(0xFFD2B48C), Color(0xFFC4A77D), Color(0xFFB8860B), Color(0xFFA0522D),
    Color(0xFF8B7355), Color(0xFF806040), Color(0xFF705030), Color(0xFF604020),
    Color(0xFF503010), Color(0xFF402000), Color(0xFF301000), Color(0xFF200800),
    Color(0xFF100000), Color(0xFF000000), Color(0xFF001000), Color(0xFF002000),
    Color(0xFF003000), Color(0xFF004000), Color(0xFF005000), Color(0xFF006000),
    Color(0xFF007000), Color(0xFF008000), Color(0xFF009000), Color(0xFF00A000),
    Color(0xFF00B000), Color(0xFF00C000), Color(0xFF00D000), Color(0xFF00E000),
    Color(0xFF00F000), Color(0xFF00FF00), Color(0xFF00FF10), Color(0xFF00FF20),
    Color(0xFF00FF30), Color(0xFF00FF40), Color(0xFF00FF50), Color(0xFF00FF60),
    Color(0xFF00FF70), Color(0xFF00FF80), Color(0xFF00FF90), Color(0xFF00FFA0),
    Color(0xFF00FFB0), Color(0xFF00FFC0), Color(0xFF00FFD0), Color(0xFF00FFE0),
    Color(0xFF00FFF0), Color(0xFF00FFFF), Color(0xFF10FFFF), Color(0xFF20FFFF),
    Color(0xFF30FFFF), Color(0xFF40FFFF), Color(0xFF50FFFF), Color(0xFF60FFFF),
    Color(0xFF70FFFF), Color(0xFF80FFFF), Color(0xFF90FFFF), Color(0xFFA0FFFF),
    Color(0xFFB0FFFF), Color(0xFFC0FFFF), Color(0xFFD0FFFF), Color(0xFFE0FFFF),
    Color(0xFFF0FFFF), Color(0xFFFFEFFF), Color(0xFFFFDFFF), Color(0xFFFFCFFF),
    Color(0xFFFFBFFF), Color(0xFFFFAFFF), Color(0xFFFF9FFF), Color(0xFFFF8FFF),
    Color(0xFFFF7FFF), Color(0xFFFF6FFF), Color(0xFFFF5FFF), Color(0xFFFF4FFF),
    Color(0xFFFF3FFF), Color(0xFFFF2FFF), Color(0xFFFF1FFF), Color(0xFFFF0FFF),
    Color(0xFFFF00FF), Color(0xFFFF00EF), Color(0xFFFF00DF), Color(0xFFFF00CF),
    Color(0xFFFF00BF), Color(0xFFFF00AF), Color(0xFFFF009F), Color(0xFFFF008F),
    Color(0xFFFF007F), Color(0xFFFF006F), Color(0xFFFF005F), Color(0xFFFF004F),
    Color(0xFFFF003F), Color(0xFFFF002F), Color(0xFFFF001F), Color(0xFFFF000F),
    Color(0xFFFF0000), Color(0xFFEF0000), Color(0xFFDF0000), Color(0xFFCF0000),
    Color(0xFFBF0000), Color(0xFFAF0000), Color(0xFF9F0000), Color(0xFF8F0000),
    Color(0xFF7F0000), Color(0xFF6F0000), Color(0xFF5F0000), Color(0xFF4F0000),
    Color(0xFF3F0000), Color(0xFF2F0000), Color(0xFF1F0000), Color(0xFF0F0000),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //                      256 لون كامل
  //                      Full 256 Colors
  // ═══════════════════════════════════════════════════════════════════════

  static const List<Color> color256 = [
    ...basicColors,
    ...extendedColors,
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //                      خريطة الألوان بالاسم
  //                      Color Name Map
  // ═══════════════════════════════════════════════════════════════════════

  static const Map<String, Color> colorNames = {
    'black': Color(0xFF000000),
    'red': Color(0xFFCD0000),
    'green': Color(0xFF00CD00),
    'yellow': Color(0xFFCDCD00),
    'blue': Color(0xFF0000EE),
    'magenta': Color(0xFFCD00CD),
    'cyan': Color(0xFF00CDCD),
    'white': Color(0xFFE5E5E5),
    'bright_black': Color(0xFF7F7F7F),
    'bright_red': Color(0xFFFF0000),
    'bright_green': Color(0xFF00FF00),
    'bright_yellow': Color(0xFFFFFF00),
    'bright_blue': Color(0xFF5C5CFF),
    'bright_magenta': Color(0xFFFF00FF),
    'bright_cyan': Color(0xFF00FFFF),
    'bright_white': Color(0xFFFFFFFF),
    'default': Color(0xFFE6EDF3),
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      دوال مساعدة
  //                      Helper Functions
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على لون من الفهرس (0-255)
  /// Get color from index (0-255)
  static Color fromIndex(int index) {
    if (index < 0) return defaultForeground;
    if (index > 255) return color256[255];
    return color256[index];
  }

  /// تحويل ANSI color code إلى لون
  /// Convert ANSI color code to Color
  static Color fromAnsi(int code) {
    if (code < 0 || code > 255) return defaultForeground;
    return color256[code];
  }

  /// تحويل RGB إلى لون
  /// Convert RGB to Color
  static Color fromRgb(int r, int g, int b) {
    return Color.fromARGB(255, r, g, b);
  }

  /// تحويل hex إلى لون
  /// Convert hex to Color
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// تحويل لون إلى hex
  /// Convert Color to hex
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// تحويل لون إلى RGB string
  /// Convert Color to RGB string
  static String toRgbString(Color color) {
    return '${color.red},${color.green},${color.blue}';
  }

  /// تحويل لون إلى ANSI 256 color code
  /// Convert Color to ANSI 256 color code
  static int toAnsi256(Color color) {
    // حساب أقرب لون من 256 لون
    int bestIndex = 0;
    double bestDistance = double.infinity;

    for (int i = 0; i < 256; i++) {
      final c = color256[i];
      final distance = _colorDistance(color, c);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  /// حساب المسافة بين لونين
  /// Calculate distance between two colors
  static double _colorDistance(Color c1, Color c2) {
    final dr = c1.red - c2.red;
    final dg = c1.green - c2.green;
    final db = c1.blue - c2.blue;
    return (dr * dr + dg * dg + db * db).toDouble();
  }

  /// تحديد ما إذا كان اللون فاتحاً أم داكناً
  /// Determine if a color is light or dark
  static bool isLight(Color color) {
    // استخدام صيغة luminance
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }

  /// الحصول على لون النص المناسب (أبيض أو أسود)
  /// Get appropriate text color (white or black)
  static Color getContrastColor(Color background) {
    return isLight(background) ? Colors.black : Colors.white;
  }

  /// مزج لونين
  /// Blend two colors
  static Color blend(Color color1, Color color2, double ratio) {
    final r = (color1.red * (1 - ratio) + color2.red * ratio).round();
    final g = (color1.green * (1 - ratio) + color2.green * ratio).round();
    final b = (color1.blue * (1 - ratio) + color2.blue * ratio).round();
    return Color.fromARGB(255, r, g, b);
  }

  /// الحصول على درجة شفافية اللون
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: terminal_colors.dart
// ═══════════════════════════════════════════════════════════════════════════