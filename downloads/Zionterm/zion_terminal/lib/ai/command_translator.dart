class CommandTranslator {
  static const Map<String, String> _arabicToEnglish = {
    'مساعدة': 'help',
    'عرض الملفات': 'ls',
    'الدليل الحالي': 'pwd',
    'تغيير الدليل': 'cd',
    'نسخ': 'cp',
    'نقل': 'mv',
    'حذف': 'rm',
    'إنشاء مجلد': 'mkdir',
    'حذف مجلد': 'rmdir',
    'عرض المحتوى': 'cat',
    'بحث': 'grep',
    'صلاحيات': 'chmod',
    'مستخدم': 'whoami',
  };
  
  static const Map<String, String> _englishToArabic = {
    'help': 'مساعدة',
    'ls': 'عرض الملفات',
    'pwd': 'الدليل الحالي',
    'cd': 'تغيير الدليل',
    'cp': 'نسخ',
    'mv': 'نقل',
    'rm': 'حذف',
    'mkdir': 'إنشاء مجلد',
    'rmdir': 'حذف مجلد',
    'cat': 'عرض المحتوى',
    'grep': 'بحث',
    'chmod': 'صلاحيات',
    'whoami': 'مستخدم',
  };
  
  static String translateToEnglish(String arabicCommand) {
    for (var entry in _arabicToEnglish.entries) {
      if (arabicCommand.contains(entry.key)) {
        return arabicCommand.replaceAll(entry.key, entry.value);
      }
    }
    return arabicCommand;
  }
  
  static String translateToArabic(String englishCommand) {
    for (var entry in _englishToArabic.entries) {
      if (englishCommand.contains(entry.key)) {
        return englishCommand.replaceAll(entry.key, entry.value);
      }
    }
    return englishCommand;
  }
  
  static bool isArabicCommand(String command) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(command);
  }
}
