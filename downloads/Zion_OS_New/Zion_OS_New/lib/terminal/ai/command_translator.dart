class CommandTranslator {
  static const Map<String, String> arabicToEnglish = {
    // Navigation
    'اذهب': 'cd',
    'انتقل': 'cd',
    'افتح_مجلد': 'cd',
    'افتح مجلد': 'cd',
    'اعرض': 'ls',
    'قائمة': 'ls',
    'محتويات': 'ls',
    'اعرض_تفاصيل': 'ls -la',
    'اعرض تفاصيل': 'ls -la',
    'كل_الملفات': 'ls -la',
    'كل الملفات': 'ls -la',

    // File operations
    'أنشئ_ملف': 'touch',
    'أنشئ ملف': 'touch',
    'ملف_جديد': 'touch',
    'ملف جديد': 'touch',
    'اقرأ': 'cat',
    'عرض_محتوى': 'cat',
    'عرض محتوى': 'cat',
    'اكتب': 'echo',
    'انسخ': 'cp',
    'نقل': 'mv',
    'احذف': 'rm',
    'امسح': 'rm',
    'إنشاء_مجلد': 'mkdir',
    'إنشاء مجلد': 'mkdir',
    'مجلد_جديد': 'mkdir',
    'مجلد جديد': 'mkdir',
    'احذف_مجلد': 'rmdir',
    'احذف مجلد': 'rmdir',
    'ابحث': 'find',
    'اكتب_في_ملف': 'echo >',
    'اكتب في ملف': 'echo >',
    'ألحق_بملف': 'echo >>',
    'ألحق بملف': 'echo >>',

    // System info
    'من_أنا': 'whoami',
    'من أنا': 'whoami',
    'المستخدم': 'whoami',
    'الهوية': 'id',
    'معلومات_النظام': 'uname -a',
    'معلومات النظام': 'uname -a',
    'النواة': 'uname -r',
    'الإصدار': 'uname -r',
    'التاريخ': 'date',
    'التقويم': 'cal',
    'الوقت': 'date +%T',

    // Process management
    'العمليات': 'ps',
    'اعرض_العمليات': 'ps aux',
    'اعرض العمليات': 'ps aux',
    'أعدل_أولوية': 'nice',
    'أعدل أولوية': 'nice',
    'اقتل': 'kill',
    'إنهاء': 'kill',
    'أوقف': 'kill -STOP',
    'استمر': 'kill -CONT',
    'أعد_تشغيل': 'reboot',
    'أعد تشغيل': 'reboot',
    'أغلق': 'shutdown',

    // Network
    'شبكة': 'ip',
    'الشبكة': 'ifconfig',
    'اعدادات_الشبكة': 'ifconfig',
    'اعدادات الشبكة': 'ifconfig',
    'اختبر_اتصال': 'ping',
    'اختبر اتصال': 'ping',
    'تتبع': 'traceroute',
    'تنزيل': 'wget',
    'حمّل': 'curl -O',
    'جلب': 'curl',
    'جدار_حماية': 'iptables',
    'جدار حماية': 'iptables',
    'المنافذ': 'netstat -tlnp',
    'اتصالات': 'netstat -an',

    // Package management
    'ثبت': 'apt install',
    'تثبيت': 'apt install',
    'حذف_حزمة': 'apt remove',
    'حذف حزمة': 'apt remove',
    'تحديث_الحزم': 'apt update',
    'تحديث الحزم': 'apt update',
    'ترقية': 'apt upgrade',
    'بحث_حزمة': 'apt search',
    'بحث حزمة': 'apt search',
    'معلومات_حزمة': 'apt show',
    'معلومات حزمة': 'apt show',
    'الحزم_المثبتة': 'dpkg -l',
    'الحزم المثبتة': 'dpkg -l',
    'تنظيف': 'apt autoremove',

    // Disk usage
    'مساحة': 'df -h',
    'القرص': 'df -h',
    'استخدام_القرص': 'df -h',
    'استخدام القرص': 'df -h',
    'حجم': 'du -sh',
    'حجم_مجلد': 'du -sh',
    'حجم مجلد': 'du -sh',
    'قرص_مفصّل': 'df -T',
    'قرص مفصّل': 'df -T',

    // Permissions
    'صلاحيات': 'chmod',
    'تغيير_صلاحيات': 'chmod',
    'تغيير صلاحيات': 'chmod',
    'مالك': 'chown',
    'تغيير_مالك': 'chown',
    'تغيير مالك': 'chown',
    'تصريح_تنفيذ': 'chmod +x',
    'تصريح تنفيذ': 'chmod +x',

    // Compression
    'اضغط': 'tar czf',
    'فك_ضغط': 'tar xzf',
    'فك ضغط': 'tar xzf',
    'ضغط_zip': 'zip -r',
    'ضغط zip': 'zip -r',
    'فك_zip': 'unzip',
    'فك zip': 'unzip',

    // Git
    'نسخة': 'git clone',
    'استنساخ': 'git clone',
    'حالة': 'git status',
    'أضف': 'git add',
    'التزام': 'git commit',
    'ادفع': 'git push',
    'اسحب': 'git pull',
    'سجل': 'git log',
    'فرع': 'git branch',
    'تبديل_فرع': 'git checkout',
    'تبديل فرع': 'git checkout',

    // Text editors
    'نعدّل': 'nano',
    'ن.nano': 'nano',
    'فيم': 'vim',
    'محرر': 'nano',

    // System maintenance
    'نظف': 'clear',
    'امسح_الشاشة': 'clear',
    'امسح الشاشة': 'clear',
    'تاريخ_الأوامر': 'history',
    'تاريخ الأوامر': 'history',
    'مساعدة': 'help',
    'دليل': 'man',
    'معلومات_الأمر': 'man',
    'معلومات الأمر': 'man',

    // Users and groups
    'مستخدمون': 'cat /etc/passwd',
    'مجموعات': 'cat /etc/group',
    'أضف_مستخدم': 'useradd',
    'أضف مستخدم': 'useradd',
    'احذف_مستخدم': 'userdel',
    'احذف مستخدم': 'userdel',
    'تغيير_كلمة_سر': 'passwd',
    'تغيير كلمة سر': 'passwd',

    // Services
    'الخدمات': 'systemctl list-units',
    'ابدأ_خدمة': 'systemctl start',
    'ابدأ خدمة': 'systemctl start',
    'أوقف_خدمة': 'systemctl stop',
    'أوقف خدمة': 'systemctl stop',
    'أعد_تشغيل_خدمة': 'systemctl restart',
    'أعد تشغيل خدمة': 'systemctl restart',
    'حالة_خدمة': 'systemctl status',
    'حالة خدمة': 'systemctl status',
    'فعّل_خدمة': 'systemctl enable',
    'فعّل خدمة': 'systemctl enable',

    // Environment
    'المتغيرات': 'env',
    'مسار': 'echo \$PATH',
    'المنزل': 'echo \$HOME',
    'القشرة': 'echo \$SHELL',

    // Hardware
    'معالج': 'lscpu',
    'ذاكرة': 'free -h',
    'أجهزة': 'lspci',
    'usb': 'lsusb',
    'بلوك': 'lsblk',

    // Common shortcuts
    'جذر': 'su',
    'سودو': 'sudo',
    'ارتقِ': 'sudo su',
    'الجذر': 'sudo -i',
    'خروج': 'exit',
    'انتهِ': 'exit',
  };

  static final Map<String, String> _englishCache = {};

  static String? translate(String input) {
    if (input.trim().isEmpty) return null;

    // Check cache first
    if (_englishCache.containsKey(input)) {
      return _englishCache[input];
    }

    final trimmed = input.trim();

    // Exact match
    if (arabicToEnglish.containsKey(trimmed)) {
      final result = arabicToEnglish[trimmed];
      _englishCache[input] = result!;
      return result;
    }

    // Try with normalized Arabic
    final normalized = _normalizeArabic(trimmed);
    if (arabicToEnglish.containsKey(normalized)) {
      final result = arabicToEnglish[normalized];
      _englishCache[input] = result!;
      return result;
    }

    // Try prefix matching
    for (final entry in arabicToEnglish.entries) {
      if (trimmed.startsWith(entry.key)) {
        final remaining = trimmed.substring(entry.key.length).trim();
        final result = remaining.isEmpty
            ? entry.value
            : '${entry.value} $remaining';
        _englishCache[input] = result;
        return result;
      }
    }

    // Try contains matching
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length > 1) {
      final translatedWords = <String>[];
      var hasTranslation = false;

      for (final word in words) {
        if (arabicToEnglish.containsKey(word)) {
          translatedWords.add(arabicToEnglish[word]!);
          hasTranslation = true;
        } else {
          translatedWords.add(word);
        }
      }

      if (hasTranslation) {
        final result = translatedWords.join(' ');
        _englishCache[input] = result;
        return result;
      }
    }

    return null;
  }

  static String translateOrKeep(String input) {
    return translate(input) ?? input;
  }

  static bool canTranslate(String input) {
    return translate(input) != null;
  }

  static Map<String, String> getSuggestions(String partial) {
    final suggestions = <String, String>{};
    final normalizedPartial = _normalizeArabic(partial.trim());

    for (final entry in arabicToEnglish.entries) {
      if (entry.key.startsWith(normalizedPartial) ||
          entry.key.contains(normalizedPartial)) {
        suggestions[entry.key] = entry.value;
      }
    }

    return suggestions;
  }

  static List<String> getAllCommands() {
    return arabicToEnglish.keys.toList();
  }

  static List<String> getAllEnglishCommands() {
    return arabicToEnglish.values.toList();
  }

  static Map<String, String> getCommandsByCategory(String category) {
    final categories = {
      'navigation': ['اذهب', 'انتقل', 'افتح_مجلد', 'اعرض', 'قائمة', 'محتويات', 'اعرض_تفاصيل', 'كل_الملفات'],
      'files': ['أنشئ_ملف', 'اقرأ', 'اكتب', 'انسخ', 'نقل', 'احذف', 'امسح', 'إنشاء_مجلد', 'احذف_مجلد', 'ابحث'],
      'system': ['من_أنا', 'المستخدم', 'معلومات_النظام', 'النواة', 'التاريخ', 'التقويم'],
      'process': ['العمليات', 'اعرض_العمليات', 'اقتل', 'إنهاء', 'أوقف', 'استمر'],
      'network': ['شبكة', 'الشبكة', 'اختبر_اتصال', 'تتبع', 'تنزيل', 'حمّل', 'جلب', 'المنافذ', 'اتصالات'],
      'packages': ['ثبت', 'حذف_حزمة', 'تحديث_الحزم', 'ترقية', 'بحث_حزمة', 'الحزم_المثبتة', 'تنظيف'],
      'disk': ['مساحة', 'القرص', 'استخدام_القرص', 'حجم', 'حجم_مجلد'],
      'permissions': ['صلاحيات', 'تغيير_صلاحيات', 'مالك', 'تغيير_مالك', 'تصريح_تنفيذ'],
    };

    final result = <String, String>{};
    final keys = categories[category] ?? [];
    for (final key in keys) {
      if (arabicToEnglish.containsKey(key)) {
        result[key] = arabicToEnglish[key]!;
      }
    }
    return result;
  }

  static List<String> getCategories() {
    return [
      'navigation',
      'files',
      'system',
      'process',
      'network',
      'packages',
      'disk',
      'permissions',
      'compression',
      'git',
    ];
  }

  static void clearCache() {
    _englishCache.clear();
  }

  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و');
  }

  static String translateScript(String script) {
    final lines = script.split('\n');
    final translatedLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        translatedLines.add(line);
        continue;
      }

      final translated = translate(trimmed);
      if (translated != null) {
        translatedLines.add('# [AR] $line');
        translatedLines.add(translated);
      } else {
        translatedLines.add(line);
      }
    }

    return translatedLines.join('\n');
  }

  static String autoDetectAndTranslate(String input) {
    // Detect if input is primarily Arabic
    var arabicCount = 0;
    var totalCount = 0;

    for (final rune in input.runes) {
      if (rune >= 0x0600 && rune <= 0x06FF) {
        arabicCount++;
      }
      if (rune > 32) {
        totalCount++;
      }
    }

    if (totalCount > 0 && arabicCount / totalCount > 0.3) {
      return translateOrKeep(input);
    }

    return input;
  }
}
