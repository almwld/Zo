import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  static bool _initialized = false;
  static Locale _currentLocale = const Locale('en');
  static final Map<String, Map<String, String>> _translations = {};
  static final StreamController<Locale> _localeController = StreamController<Locale>.broadcast();

  static Stream<Locale> get onLocaleChanged => _localeController.stream;

  static final Map<String, Map<String, String>> _defaultTranslations = {
    'en': {
      'app_name': 'Zion Terminal',
      'terminal': 'Terminal',
      'settings': 'Settings',
      'about': 'About',
      'licenses': 'Open Source Licenses',
      'help': 'Help',
      'new_tab': 'New Tab',
      'close_tab': 'Close Tab',
      'clear': 'Clear',
      'copy': 'Copy',
      'paste': 'Paste',
      'select_all': 'Select All',
      'search': 'Search',
      'execute': 'Execute',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'ok': 'OK',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Information',
      'success': 'Success',
      'loading': 'Loading...',
      'install': 'Install',
      'uninstall': 'Uninstall',
      'update': 'Update',
      'upgrade': 'Upgrade',
      'remove': 'Remove',
      'package': 'Package',
      'packages': 'Packages',
      'repository': 'Repository',
      'repositories': 'Repositories',
      'distribution': 'Distribution',
      'distributions': 'Distributions',
      'theme': 'Theme',
      'themes': 'Themes',
      'language': 'Language',
      'languages': 'Languages',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_default': 'System Default',
      'font_size': 'Font Size',
      'font_family': 'Font Family',
      'keyboard_shortcuts': 'Keyboard Shortcuts',
      'session': 'Session',
      'sessions': 'Sessions',
      'process': 'Process',
      'processes': 'Processes',
      'memory': 'Memory',
      'cpu': 'CPU',
      'storage': 'Storage',
      'network': 'Network',
      'security': 'Security',
      'command_history': 'Command History',
      'bookmark': 'Bookmark',
      'bookmarks': 'Bookmarks',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'load': 'Load',
      'backup': 'Backup',
      'restore': 'Restore',
      'export': 'Export',
      'import': 'Import',
      'refresh': 'Refresh',
      'sync': 'Synchronize',
      'auto_complete': 'Auto Complete',
      'suggestions': 'Suggestions',
      'welcome_message': 'Welcome to Zion Terminal!',
      'type_help': "Type 'help' for available commands",
      'proot_not_installed': 'PRoot is not installed',
      'installing_proot': 'Installing PRoot...',
      'proot_ready': 'PRoot is ready',
      'rootfs_not_found': 'RootFS not found',
      'downloading_rootfs': 'Downloading RootFS...',
      'extracting_rootfs': 'Extracting RootFS...',
      'rootfs_ready': 'RootFS is ready',
      'enter_command': 'Enter command...',
      'command_executed': 'Command executed',
      'execution_failed': 'Execution failed',
      'permission_denied': 'Permission denied',
      'file_not_found': 'File not found',
      'directory_not_found': 'Directory not found',
      'connection_error': 'Connection error',
      'timeout_error': 'Timeout error',
      'unknown_error': 'Unknown error',
      'ai_assistant': 'AI Assistant',
      'translate_command': 'Translate Command',
      'security_check': 'Security Check',
      'explain_command': 'Explain Command',
      'arabic_input': 'Arabic Input',
    },
    'ar': {
      'app_name': 'زيون تيرمنال',
      'terminal': 'الطرفية',
      'settings': 'الإعدادات',
      'about': 'حول',
      'licenses': 'التراخيص مفتوحة المصدر',
      'help': 'المساعدة',
      'new_tab': 'تبويب جديد',
      'close_tab': 'إغلاق التبويب',
      'clear': 'مسح',
      'copy': 'نسخ',
      'paste': 'لصق',
      'select_all': 'تحديد الكل',
      'search': 'بحث',
      'execute': 'تنفيذ',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'ok': 'موافق',
      'error': 'خطأ',
      'warning': 'تحذير',
      'info': 'معلومات',
      'success': 'نجاح',
      'loading': 'جاري التحميل...',
      'install': 'تثبيت',
      'uninstall': 'إلغاء التثبيت',
      'update': 'تحديث',
      'upgrade': 'ترقية',
      'remove': 'حذف',
      'package': 'حزمة',
      'packages': 'الحزم',
      'repository': 'مستودع',
      'repositories': 'المستودعات',
      'distribution': 'توزيعة',
      'distributions': 'التوزيعات',
      'theme': 'سمة',
      'themes': 'السمات',
      'language': 'اللغة',
      'languages': 'اللغات',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'system_default': 'النظام الافتراضي',
      'font_size': 'حجم الخط',
      'font_family': 'نوع الخط',
      'keyboard_shortcuts': 'اختصارات لوحة المفاتيح',
      'session': 'جلسة',
      'sessions': 'الجلسات',
      'process': 'عملية',
      'processes': 'العمليات',
      'memory': 'الذاكرة',
      'cpu': 'المعالج',
      'storage': 'التخزين',
      'network': 'الشبكة',
      'security': 'الأمان',
      'command_history': 'سجل الأوامر',
      'bookmark': 'إشارة مرجعية',
      'bookmarks': 'الإشارات المرجعية',
      'edit': 'تحرير',
      'delete': 'حذف',
      'save': 'حفظ',
      'load': 'تحميل',
      'backup': 'نسخ احتياطي',
      'restore': 'استعادة',
      'export': 'تصدير',
      'import': 'استيراد',
      'refresh': 'تحديث',
      'sync': 'مزامنة',
      'auto_complete': 'الإكمال التلقائي',
      'suggestions': 'اقتراحات',
      'welcome_message': 'مرحباً بك في زيون تيرمنال!',
      'type_help': "اكتب 'help' للأوامر المتاحة",
      'proot_not_installed': 'PRoot غير مثبت',
      'installing_proot': 'جاري تثبيت PRoot...',
      'proot_ready': 'PRoot جاهز',
      'rootfs_not_found': 'RootFS غير موجود',
      'downloading_rootfs': 'جاري تحميل RootFS...',
      'extracting_rootfs': 'جاري استخراج RootFS...',
      'rootfs_ready': 'RootFS جاهز',
      'enter_command': 'أدخل الأمر...',
      'command_executed': 'تم تنفيذ الأمر',
      'execution_failed': 'فشل التنفيذ',
      'permission_denied': 'الإذن مرفوض',
      'file_not_found': 'الملف غير موجود',
      'directory_not_found': 'المجلد غير موجود',
      'connection_error': 'خطأ في الاتصال',
      'timeout_error': 'انتهاء المهلة',
      'unknown_error': 'خطأ غير معروف',
      'ai_assistant': 'المساعد الذكي',
      'translate_command': 'ترجمة الأمر',
      'security_check': 'فحص الأمان',
      'explain_command': 'شرح الأمر',
      'arabic_input': 'الإدخال العربي',
    },
    'fr': {
      'app_name': 'Zion Terminal',
      'terminal': 'Terminal',
      'settings': 'Paramètres',
      'about': 'À propos',
      'licenses': 'Licences Open Source',
      'help': 'Aide',
      'new_tab': 'Nouvel onglet',
      'close_tab': 'Fermer l\'onglet',
      'clear': 'Effacer',
      'copy': 'Copier',
      'paste': 'Coller',
      'select_all': 'Tout sélectionner',
      'search': 'Rechercher',
      'execute': 'Exécuter',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'ok': 'OK',
      'error': 'Erreur',
      'warning': 'Avertissement',
      'info': 'Information',
      'success': 'Succès',
      'loading': 'Chargement...',
      'install': 'Installer',
      'uninstall': 'Désinstaller',
      'update': 'Mettre à jour',
      'upgrade': 'Mettre à niveau',
      'remove': 'Supprimer',
      'package': 'Paquet',
      'packages': 'Paquets',
      'theme': 'Thème',
      'themes': 'Thèmes',
      'language': 'Langue',
      'languages': 'Langues',
      'dark_mode': 'Mode sombre',
      'light_mode': 'Mode clair',
      'system_default': 'Par défaut du système',
      'settings_menu': 'Menu des paramètres',
    },
    'es': {
      'app_name': 'Zion Terminal',
      'terminal': 'Terminal',
      'settings': 'Configuración',
      'about': 'Acerca de',
      'licenses': 'Licencias de Código Abierto',
      'help': 'Ayuda',
      'new_tab': 'Nueva pestaña',
      'close_tab': 'Cerrar pestaña',
      'clear': 'Limpiar',
      'copy': 'Copiar',
      'paste': 'Pegar',
      'select_all': 'Seleccionar todo',
      'search': 'Buscar',
      'execute': 'Ejecutar',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'ok': 'OK',
      'error': 'Error',
      'warning': 'Advertencia',
      'info': 'Información',
      'success': 'Éxito',
      'loading': 'Cargando...',
      'install': 'Instalar',
      'uninstall': 'Desinstalar',
      'update': 'Actualizar',
      'upgrade': 'Actualizar',
      'remove': 'Eliminar',
      'package': 'Paquete',
      'packages': 'Paquetes',
      'theme': 'Tema',
      'themes': 'Temas',
      'language': 'Idioma',
      'languages': 'Idiomas',
      'dark_mode': 'Modo oscuro',
      'light_mode': 'Modo claro',
      'system_default': 'Predeterminado del sistema',
    },
  };

  static Future<void> init() async {
    if (_initialized) return;

    _translations.addAll(_defaultTranslations);

    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code') ?? 'en';
    await setLanguage(savedLang, save: false);

    _initialized = true;
  }

  static Future<void> setLanguage(String lang, {bool save = true}) async {
    final locale = Locale(lang);
    _currentLocale = locale;

    if (save) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', lang);
    }

    _localeController.add(locale);
  }

  static String translate(String key) {
    final langCode = _currentLocale.languageCode;

    if (_translations.containsKey(langCode) && _translations[langCode]!.containsKey(key)) {
      return _translations[langCode]![key]!;
    }

    if (_translations['en']!.containsKey(key)) {
      return _translations['en']![key]!;
    }

    return key;
  }

  static String t(String key) => translate(key);

  static Locale get currentLocale => _currentLocale;

  static bool get isArabic => _currentLocale.languageCode == 'ar';

  static bool get isRTL => _currentLocale.languageCode == 'ar';

  static String get currentLanguageName {
    final names = {
      'en': 'English',
      'ar': 'العربية',
      'fr': 'Français',
      'es': 'Español',
    };
    return names[_currentLocale.languageCode] ?? 'Unknown';
  }

  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
      {'code': 'fr', 'name': 'French', 'native': 'Français'},
      {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    ];
  }

  static Future<void> addCustomTranslations(String langCode, Map<String, String> translations) async {
    if (!_translations.containsKey(langCode)) {
      _translations[langCode] = {};
    }
    _translations[langCode]!.addAll(translations);
  }

  static bool hasTranslation(String key) {
    final langCode = _currentLocale.languageCode;
    return (_translations.containsKey(langCode) && _translations[langCode]!.containsKey(key)) ||
        _translations['en']!.containsKey(key);
  }

  static Map<String, String> getMissingTranslations(String langCode) {
    final missing = <String, String>{};
    final enKeys = _translations['en']?.keys ?? [];

    for (final key in enKeys) {
      if (!_translations.containsKey(langCode) ||
          !_translations[langCode]!.containsKey(key)) {
        missing[key] = _translations['en']![key]!;
      }
    }

    return missing;
  }

  static Future<void> resetToDefaults() async {
    _translations.clear();
    _translations.addAll(_defaultTranslations);
    await setLanguage('en');
  }

  static Future<void> reload() async {
    await init();
  }

  static TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  static Map<String, dynamic> getStatus() {
    return {
      'currentLocale': _currentLocale.languageCode,
      'isArabic': isArabic,
      'isRTL': isRTL,
      'availableLanguages': getAvailableLanguages(),
      'translationKeysCount': _translations[_currentLocale.languageCode]?.length ?? 0,
    };
  }

  static void dispose() {
    _localeController.close();
  }
}
