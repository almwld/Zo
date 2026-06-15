// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    AI Assistant - المساعد الذكي                            ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: مساعد ذكي لترجمة الأوامر وتحليل الأمان                       ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import '../services/language_manager.dart';
import '../terminal/terminal_history.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    AIAssistant - المساعد الذكي
///                    AI Assistant for Command Translation and Security
/// ═══════════════════════════════════════════════════════════════════════════

class AIAssistant extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //                      قاموس الأوامر العربية
  // ═══════════════════════════════════════════════════════════════════════

  static final Map<String, String> _arabicCommands = {
    // ═══════════════════════════════════════════════════════════════════
    //                      الأوامر الأساسية
    // ═══════════════════════════════════════════════════════════════════

    'اعرض': 'ls',
    'اعرض الملفات': 'ls -la',
    'اعرض الكل': 'ls -la',
    'عرض': 'ls',
    'قائمة': 'ls',
    'ادخل': 'cd',
    'دخل': 'cd',
    'تغيير المجلد': 'cd',
    'ارجع': 'cd ..',
    'رجوع': 'cd ..',
    'العودة': 'cd ..',
    'اين انا': 'pwd',
    'المسار': 'pwd',
    'اعرض المحتوى': 'cat',
    'محتوى': 'cat',
    'ابحث': 'grep',
    'بحث': 'grep',
    'انسخ': 'cp',
    'نسخ': 'cp',
    'انقل': 'mv',
    'نقل': 'mv',
    'احذف': 'rm',
    'حذف': 'rm',
    'مسح': 'rm',
    'انشئ مجلد': 'mkdir',
    'مجلد جديد': 'mkdir',
    'انشئ ملف': 'touch',
    'ملف جديد': 'touch',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر الحزم
    // ═══════════════════════════════════════════════════════════════════

    'ثبت': 'pkg install',
    'ثبت حزمة': 'pkg install',
    'تثبيت': 'pkg install',
    'حدث': 'pkg update',
    'حدث الحزم': 'pkg update',
    'تحديث': 'pkg update',
    'رق': 'pkg upgrade',
    'رقّي': 'pkg upgrade',
    'رقي': 'pkg upgrade',
    'رقي الحزم': 'pkg upgrade',
    'ابحث عن حزمة': 'pkg search',
    'ابحث عن': 'pkg search',
    'احذف حزمة': 'pkg remove',
    'احذف الحزمة': 'pkg remove',
    'الحزم المثبتة': 'pkg list-installed',
    'المثبتة': 'pkg list-installed',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر الأدوات
    // ═══════════════════════════════════════════════════════════════════

    'افحص الشبكة': 'nmap',
    'فحص الشبكة': 'nmap',
    'افحص المنافذ': 'nmap -p-',
    'فحص المنافذ': 'nmap -p-',
    'اختبر الاختراق': 'msfconsole',
    'اختبار الاختراق': 'msfconsole',
    'خمن كلمة السر': 'hydra',
    'تخمين كلمة السر': 'hydra',
    'حلل الحزم': 'wireshark',
    'تحليل الحزم': 'wireshark',
    'تصنت': 'tcpdump',
    'تصنت على الشبكة': 'tcpdump',
    'تاريخ': 'date',
    'التاريخ': 'date',
    'وقت': 'time',
    'الوقت': 'time',
    'مساعدة': 'help',
    'مساعدتي': 'help',
    'من أنا': 'whoami',
    'مستخدم': 'whoami',
    'البحث': 'find',
    'ابحث عن ملف': 'find',
    'العمليات': 'ps',
    'عرض العمليات': 'ps aux',
    'اقتل عملية': 'kill',
    'إيقاف': 'kill',
    'نسخ بعيد': 'scp',
    'الاتصال': 'ssh',
    'اتصال': 'ssh',
    'تحميل': 'wget',
    'تحميل من': 'wget',
    'رفع': 'curl',
    'الة حاسبة': 'bc',
    'حاسبة': 'bc',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر التوزيعات
    // ═══════════════════════════════════════════════════════════════════

    'دخول اوبونتو': '!distro login ubuntu',
    'اوبونتو': '!distro login ubuntu',
    'دخول كالي': '!distro login kali',
    'كالي': '!distro login kali',
    'دخول دبيان': '!distro login debian',
    'دبيان': '!distro login debian',
    'الخروج': 'exit',
    'الخروج من': 'exit',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر اللغة
    // ═══════════════════════════════════════════════════════════════════

    'لغة عربي': '!lang ar',
    'عربي': '!lang ar',
    'لغة انجليزي': '!lang en',
    'انجليزي': '!lang en',
    'بدل اللغة': '!lang toggle',
    'تبديل اللغة': '!lang toggle',
    'اللغة': '!lang status',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر AI
    // ═══════════════════════════════════════════════════════════════════

    'اشرح': '!explain',
    'شرح': '!explain',
    'اقترح': '!suggest',
    'اقتراح': '!suggest',
    'ترجم': '!translate',
    'ترجمة': '!translate',
    'حلل الامان': '!security',
    'تحليل امان': '!security',
    'امان': '!security',
    'تلخيص': '!summarize',
    'لخص': '!summarize',

    // ═══════════════════════════════════════════════════════════════════
    //                      أوامر إضافية
    // ═══════════════════════════════════════════════════════════════════

    'صلاحيات': 'chmod',
    ' chmod': 'chmod',
    'مالك': 'chown',
    ' chown': 'chown',
    'مستخدم جديد': 'adduser',
    'مجموعة جديدة': 'groupadd',
    'تغيير كلمة السر': 'passwd',
    'عرض المساحة': 'df',
    'المساحة': 'df -h',
    'الذاكرة': 'free',
    'استخدام الذاكرة': 'free -h',
    'معلومات النظام': 'uname -a',
    'معلومات': 'uname -a',
    'المتغيرات': 'env',
    'متغيرات البيئة': 'env',
    'البحث في الملفات': 'grep -r',
    'استبدال': 'sed',
    'ترتيب': 'sort',
    'عد الكلمات': 'wc',
    'عرض أول': 'head',
    'عرض آخر': 'tail',
    'مراقبة': 'watch',
    'البرامج': 'dpkg -l',
    'البرامج العاملة': 'ps aux',
    'الإنترنت': 'ping',
    'فحص الاتصال': 'ping -c 4',
    'مسار الشبكة': 'traceroute',
    'dns': 'nslookup',
    'ip': 'ip addr',
    'البطارية': 'upower -i /org/freedesktop/UPower/devices/battery_BAT0',
    'درجة الحرارة': 'sensors',
    'القرص': 'lsblk',
    'الملفات المخفية': 'ls -a',
    'الملفات الكبيرة': 'du -sh * | sort -rh',
    'tar': 'tar -cvf',
    'unzip': 'unzip',
    'zip': 'zip -r',
    'git': 'git',
    'vim': 'vim',
    'nano': 'nano',
    'python': 'python3',
    'node': 'node',
    'gcc': 'gcc',
    'clang': 'clang',
    'make': 'make',
    'cmake': 'cmake',
    'docker': 'docker',
    'kubectl': 'kubectl',
    'terraform': 'terraform',
    'ansible': 'ansible',
  };

  // ═══════════════════════════════════════════════════════════════════════
  //                      أوامر خطرة
  // ═══════════════════════════════════════════════════════════════════════

  static final List<String> _dangerousCommands = [
    'rm -rf /',
    'rm -rf /*',
    'rm -rf .',
    'rm -rf',
    ':(){:|:&};:',
    'fork()',
    'dd if=/dev/zero of=/dev/sda',
    'mkfs.ext4',
    'fdisk /dev/sda',
    'shutdown -h now',
    'reboot',
    'init 0',
    'init 6',
    'chmod -R 777 /',
    'chmod 777',
    '> /dev/sda',
    '/dev/null',
    'eval',
    'exec',
  ];

  static final List<String> _warningCommands = [
    'rm ',
    'chmod 777',
    'chmod 000',
    'chown',
    'shutdown',
    'reboot',
    'init',
    'killall',
    'pkill',
    'kill -9',
    'dd',
    'fdisk',
    'mkfs',
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //                      سجل الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  final List<String> _commandHistory = [];
  final TerminalHistory? history;

  // ═══════════════════════════════════════════════════════════════════════
  //                      المنشئ
  // ═══════════════════════════════════════════════════════════════════════

  AIAssistant({this.history});

  // ═══════════════════════════════════════════════════════════════════════
  //                      ترجمة الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  String translate(String arabicCommand) {
    final trimmed = arabicCommand.trim().toLowerCase();

    // البحث المباشر في القاموس
    if (_arabicCommands.containsKey(trimmed)) {
      _addToHistory(arabicCommand, _arabicCommands[trimmed]!);
      return _arabicCommands[trimmed]!;
    }

    // البحث مع variations
    for (final entry in _arabicCommands.entries) {
      if (trimmed.contains(entry.key) || entry.key.contains(trimmed)) {
        var result = entry.value;

        // استبدال الكلمات المتبقية
        var remaining = trimmed.replaceAll(entry.key, '').trim();
        if (remaining.isNotEmpty) {
          result = '$result $remaining';
        }

        _addToHistory(arabicCommand, result);
        return result;
      }
    }

    return arabicCommand;
  }

  bool isArabicCommand(String command) {
    // التحقق من وجود أحرف عربية
    for (final char in command.characters) {
      if (LanguageManager.isArabic != null && LanguageManager.isArabic) {
        return true;
      }
    }

    // التحقق من وجود أمر عربي معروف
    final trimmed = command.trim().toLowerCase();
    for (final key in _arabicCommands.keys) {
      if (trimmed.startsWith(key) || trimmed.contains(key)) {
        return true;
      }
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحليل الأمان
  // ═══════════════════════════════════════════════════════════════════════

  SecurityResult analyze(String command) {
    final trimmed = command.trim().toLowerCase();

    // التحقق من الأوامر الخطيرة جداً
    for (final dangerous in _dangerousCommands) {
      if (trimmed.contains(dangerous.toLowerCase())) {
        return SecurityResult(
          level: SecurityLevel.blocked,
          message: LanguageManager.t('security.dangerous_command'),
          details: 'هذا الأمر قد يسبب ضرراً كبيراً للنظام',
          warning: '⚠️ أمر خطير! هل أنت متأكد من المتابعة؟',
        );
      }
    }

    // التحقق من الأوامر المحذرة
    for (final warning in _warningCommands) {
      if (trimmed.startsWith(warning.toLowerCase())) {
        if (trimmed.contains('-rf') || trimmed.contains('777') || trimmed.contains('-9')) {
          return SecurityResult(
            level: SecurityLevel.warning,
            message: LanguageManager.t('security.warning_rm'),
            details: 'هذا الأمر قد يؤثر على ملفات مهمة',
            warning: '⚠️ تحذير: هذا الأمر قد يكون خطيراً!',
          );
        }
      }
    }

    return SecurityResult(
      level: SecurityLevel.safe,
      message: 'الأمر آمن',
      details: 'لا توجد مخاطر أمنية معروفة',
    );
  }

  bool isCommandSafe(String command) {
    return analyze(command).level != SecurityLevel.blocked;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      اقتراح الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  List<String> suggest(String partial, {int limit = 5}) {
    final trimmed = partial.toLowerCase().trim();
    final suggestions = <String>[];

    // اقتراحات من قاموس الأوامر العربية
    for (final entry in _arabicCommands.entries) {
      if (entry.key.startsWith(trimmed) || entry.key.contains(trimmed)) {
        suggestions.add('${entry.key} → ${entry.value}');
        if (suggestions.length >= limit) break;
      }
    }

    // اقتراحات من سجل الأوامر
    if (history != null) {
      for (final cmd in history!.commandHistory) {
        if (cmd.command.startsWith(trimmed) && !suggestions.contains(cmd.command)) {
          suggestions.add(cmd.command);
          if (suggestions.length >= limit * 2) break;
        }
      }
    }

    return suggestions.take(limit).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      شرح الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  String explain(String command) {
    final trimmed = command.trim().toLowerCase();

    // شرح الأوامر الأساسية
    final explanations = {
      'ls': 'ls - يعرض قائمة الملفات والمجلدات في الدليل الحالي\n'
          '- الخيارات: -l (تفصيلي), -a (مخفي), -h (حجم مقروء)',
      'cd': 'cd - تغيير الدليل الحالي\n'
          '- cd .. للرجوع، cd / للمسار الجذر، cd ~ للرئيسي',
      'pwd': 'pwd - يعرض المسار الحالي (Working Directory)',
      'cat': 'cat - يعرض محتوى الملف\n'
          '- cat file.txt لعرض المحتوى، cat file1 file2 لدمج',
      'rm': 'rm - حذف الملفات والمجلدات\n'
          '- rm file لحذف ملف، rm -r dir لحذف مجلد، rm -rf لحذف إجباري',
      'cp': 'cp - نسخ الملفات\n'
          '- cp source dest للنسخ، cp -r dir1 dir2 للنسخ المتكرر',
      'mv': 'mv - نقل أو إعادة تسمية الملفات\n'
          '- mv source dest للنقل، mv old new للتسمية',
      'mkdir': 'mkdir - إنشاء مجلد جديد\n'
          '- mkdir dirName، mkdir -p path/to/dir لإنشاء المسار',
      'grep': 'grep - البحث في الملفات\n'
          '- grep pattern file، grep -r pattern dir',
      'chmod': 'chmod - تغيير صلاحيات الملفات\n'
          '- chmod 755 file، chmod +x script.sh',
      'chown': 'chown - تغيير مالك الملف\n'
          '- chown user:group file',
      'ps': 'ps - عرض العمليات الجارية\n'
          '- ps aux لعرض كل العمليات',
      'kill': 'kill - إيقاف عملية\n'
          '- kill PID، kill -9 PID للإيقاف الإجباري',
      'apt': 'apt - مدير حزم Debian/Ubuntu\n'
          '- apt update، apt install package، apt remove package',
      'pkg': 'pkg - مدير حزم Termux\n'
          '- pkg update، pkg install package، pkg remove package',
      'nmap': 'nmap - فحص الشبكات والمنافذ\n'
          '- nmap -sV host، nmap -p- host',
      'ping': 'ping - اختبار الاتصال\n'
          '- ping host، ping -c 4 host',
      'ssh': 'ssh - اتصال آمن بعيد\n'
          '- ssh user@host',
      'wget': 'wget - تحميل من الإنترنت\n'
          '- wget url',
      'curl': 'curl - نقل البيانات\n'
          '- curl url، curl -X POST url',
      'git': 'git - نظام التحكم بالإصدارات\n'
          '- git init، git add، git commit، git push',
      'python': 'python - مترجم Python\n'
          '- python script.py، python -m module',
      'node': 'node -运行环境 JavaScript\n'
          '- node script.js',
      'gcc': 'gcc - مترجم C\n'
          '- gcc file.c -o output',
      'vim': 'vim - محرر نصوص متقدم\n'
          '- vim file، i للإدراج، :wq للحفظ والخروج',
      'nano': 'nano - محرر نصوص بسيط\n'
          '- nano file، Ctrl+O للحفظ، Ctrl+X للخروج',
      'df': 'df - عرض استخدام القرص\n'
          '- df -h (بالحجم المقروء)',
      'free': 'free - عرض استخدام الذاكرة\n'
          '- free -h',
      'top': 'top - عرض العمليات والموارد\n'
          '- q للخروج',
      'find': 'find - البحث عن الملفات\n'
          '- find . -name "*.txt"',
      'tar': 'tar - ضغط وفك ضغط الملفات\n'
          '- tar -cvf archive.tar files، tar -xvf archive.tar',
    };

    // استخراج اسم الأمر الأساسي
    var baseCommand = trimmed.split(' ').first;
    baseCommand = baseCommand.replaceAll(RegExp(r'[!@#$%^&*()]'), '');

    return explanations[baseCommand] ??
        'الأمر: $command\n'
            'لا يوجد شرح متوفر لهذا الأمر';
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تصحيح الأخطاء
  // ═══════════════════════════════════════════════════════════════════════

  String correct(String command) {
    var corrected = command.trim();

    // تصحيحات شائعة
    final corrections = {
      'apt-get': 'apt',
      'aptitude': 'apt',
      'python': 'python3',
      'python2': 'python3',
      'pip': 'pip3',
      'nodejs': 'node',
      'chmod 7777': 'chmod 755',
      'rm -rf /': 'عرض رسالة تحذير',
      'sudo su': 'su',
    };

    for (final entry in corrections.entries) {
      if (corrected.toLowerCase().contains(entry.key)) {
        corrected = corrected.replaceAll(entry.key, entry.value);
      }
    }

    // إزالة المسافات الزائدة
    corrected = corrected.replaceAll(RegExp(r'\s+'), ' ');

    return corrected;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تلخيص المخرجات
  // ═══════════════════════════════════════════════════════════════════════

  String summarize(String output, {int maxLength = 200}) {
    if (output.length <= maxLength) {
      return output;
    }

    final lines = output.split('\n');
    if (lines.length <= 5) {
      return output;
    }

    final summary = StringBuffer();
    summary.writeln('--- ملخص المخرجات ---');
    summary.writeln('عدد الأسطر: ${lines.length}');
    summary.writeln('عدد الأحرف: ${output.length}');
    summary.writeln();

    // إضافة أول وآخر 3 أسطر
    summary.writeln('البداية:');
    for (int i = 0; i < 3 && i < lines.length; i++) {
      summary.writeln(lines[i]);
    }

    if (lines.length > 6) {
      summary.writeln('... (${lines.length - 6} سطر مخفي) ...');
    }

    summary.writeln('النهاية:');
    for (int i = lines.length - 3; i < lines.length; i++) {
      if (i >= 0) {
        summary.writeln(lines[i]);
      }
    }

    return summary.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      سجل الأوامر
  // ═══════════════════════════════════════════════════════════════════════

  void _addToHistory(String original, String translated) {
    _commandHistory.add('$original → $translated');
    if (_commandHistory.length > 100) {
      _commandHistory.removeAt(0);
    }
  }

  List<String> get commandHistory => List.unmodifiable(_commandHistory);

  // ═══════════════════════════════════════════════════════════════════════
  //                      معالجة الأوامر الخاصة
  // ═══════════════════════════════════════════════════════════════════════

  String processCommand(String command) {
    final trimmed = command.trim();

    // التحقق من أوامر AI الخاصة
    if (trimmed.startsWith('!explain ')) {
      final cmd = trimmed.substring('!explain '.length);
      return explain(cmd);
    }

    if (trimmed.startsWith('!suggest ')) {
      final partial = trimmed.substring('!suggest '.length);
      final suggestions = suggest(partial);
      if (suggestions.isEmpty) {
        return 'لا توجد اقتراحات';
      }
      return 'اقتراحات:\n${suggestions.map((s) => '  $s').join('\n')}';
    }

    if (trimmed.startsWith('!translate ')) {
      final text = trimmed.substring('!translate '.length);
      return translate(text);
    }

    if (trimmed.startsWith('!security ')) {
      final cmd = trimmed.substring('!security '.length);
      final result = analyze(cmd);
      return '${result.warning}\n${result.message}\n${result.details}';
    }

    if (trimmed.startsWith('!summarize')) {
      return 'استخدم !summarize مع مسار ملف';
    }

    // ترجمة الأوامر العربية
    if (isArabicCommand(trimmed)) {
      return translate(trimmed);
    }

    return command;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    SecurityResult - نتيجة التحليل الأمني
///                    Security Analysis Result
/// ═══════════════════════════════════════════════════════════════════════════

enum SecurityLevel {
  safe,
  warning,
  blocked,
}

class SecurityResult {
  final SecurityLevel level;
  final String message;
  final String details;
  final String? warning;

  SecurityResult({
    required this.level,
    required this.message,
    required this.details,
    this.warning,
  });

  bool get isSafe => level == SecurityLevel.safe;
  bool get isWarning => level == SecurityLevel.warning;
  bool get isBlocked => level == SecurityLevel.blocked;
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: ai_assistant.dart
// ═══════════════════════════════════════════════════════════════════════════