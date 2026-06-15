// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Language Manager - مدير اللغة                          ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: إدارة الترجمة والتبديل بين اللغات                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    AppLanguage - لغات التطبيق
///                    Application Languages
/// ═══════════════════════════════════════════════════════════════════════════

enum AppLanguage {
  arabic,
  english,
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    LanguageManager - مدير اللغة
///                    Language Manager
/// ═══════════════════════════════════════════════════════════════════════════

class LanguageManager {
  // ═══════════════════════════════════════════════════════════════════════
  //                      الخصائص الثابتة
  // ═══════════════════════════════════════════════════════════════════════

  static AppLanguage _currentLanguage = AppLanguage.arabic;
  static Map<String, dynamic>? _translations;
  static SharedPreferences? _prefs;

  static const String _languageKey = 'language';
  static const String _defaultLanguage = 'arabic';

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحميل اللغة
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> loadLanguage(AppLanguage language) async {
    _currentLanguage = language;

    try {
      String jsonString;
      switch (language) {
        case AppLanguage.arabic:
          jsonString = await rootBundle.loadString('assets/translations/ar.json');
          break;
        case AppLanguage.english:
          jsonString = await rootBundle.loadString('assets/translations/en.json');
          break;
      }

      _translations = json.decode(jsonString);
    } catch (e) {
      _translations = _getDefaultTranslations(language);
    }

    // حفظ الإعداد
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_languageKey, language.name);
  }

  static Future<void> loadSavedLanguage() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedLang = _prefs!.getString(_languageKey) ?? _defaultLanguage;

    final language = savedLang == 'english'
        ? AppLanguage.english
        : AppLanguage.arabic;

    await loadLanguage(language);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الترجمة
  // ═══════════════════════════════════════════════════════════════════════

  static String translate(String key) {
    if (_translations == null) return key;

    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }

    return value.toString();
  }

  static String t(String key) => translate(key);

  static String get(String key, [Map<String, String>? params]) {
    var text = translate(key);

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }

    return text;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تبديل اللغة
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> toggleLanguage() async {
    final newLang = _currentLanguage == AppLanguage.arabic
        ? AppLanguage.english
        : AppLanguage.arabic;
    await loadLanguage(newLang);
  }

  static Future<void> setLanguage(AppLanguage language) async {
    if (language != _currentLanguage) {
      await loadLanguage(language);
    }
  }

  static Future<void> setLanguageByName(String languageName) async {
    final language = languageName.toLowerCase() == 'english'
        ? AppLanguage.english
        : AppLanguage.arabic;
    await setLanguage(language);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص اللغة الحالية
  // ═══════════════════════════════════════════════════════════════════════

  static AppLanguage get currentLanguage => _currentLanguage;

  static bool get isArabic => _currentLanguage == AppLanguage.arabic;
  static bool get isEnglish => _currentLanguage == AppLanguage.english;

  static String get currentLanguageName => _currentLanguage.name;

  static String get currentLanguageCode {
    switch (_currentLanguage) {
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.english:
        return 'en';
    }
  }

  static String get currentLocale {
    switch (_currentLanguage) {
      case AppLanguage.arabic:
        return 'ar_SA';
      case AppLanguage.english:
        return 'en_US';
    }
  }

  static bool get isRtl => _currentLanguage == AppLanguage.arabic;

  // ═══════════════════════════════════════════════════════════════════════
  //                      ترجمات افتراضية
  // ═══════════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _getDefaultTranslations(AppLanguage language) {
    if (language == AppLanguage.arabic) {
      return {
        'app_name': 'Zion OS - طرفية',
        'terminal': 'الطرفية',
        'new_session': 'جلسة جديدة',
        'close_session': 'إغلاق الجلسة',
        'settings': 'الإعدادات',
        'help': 'مساعدة',
        'about': 'حول',
        'messages': {
          'welcome': 'مرحباً بك في طرفية Zion OS',
          'loading': 'جاري التحميل...',
          'ready': 'جاهز',
          'error': 'خطأ',
          'warning': 'تحذير',
          'success': 'تم بنجاح',
          'confirm': 'تأكيد',
          'cancel': 'إلغاء',
        },
        'security': {
          'dangerous_command': '⚠️ أمر خطير!',
          'confirm_execution': 'هل أنت متأكد؟',
          'blocked': '🚫 تم منع الأمر الخطير',
        },
      };
    } else {
      return {
        'app_name': 'Zion OS - Terminal',
        'terminal': 'Terminal',
        'new_session': 'New Session',
        'close_session': 'Close Session',
        'settings': 'Settings',
        'help': 'Help',
        'about': 'About',
        'messages': {
          'welcome': 'Welcome to Zion OS Terminal',
          'loading': 'Loading...',
          'ready': 'Ready',
          'error': 'Error',
          'warning': 'Warning',
          'success': 'Success',
          'confirm': 'Confirm',
          'cancel': 'Cancel',
        },
        'security': {
          'dangerous_command': '⚠️ Dangerous Command!',
          'confirm_execution': 'Are you sure?',
          'blocked': '🚫 Dangerous command blocked',
        },
      };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الأوامر النصية
  // ═══════════════════════════════════════════════════════════════════════

  static String getLanguageCommand(String command) {
    switch (command.toLowerCase()) {
      case '!lang ar':
      case '!لغة عربي':
        return 'arabic';
      case '!lang en':
      case '!لغة انجليزي':
        return 'english';
      case '!lang toggle':
      case '!بدل اللغة':
        return 'toggle';
      case '!lang status':
      case '!لغة حالة':
        return 'status';
      default:
        return command;
    }
  }

  static String handleLanguageCommand(String command) {
    final action = getLanguageCommand(command);

    switch (action) {
      case 'arabic':
        setLanguageByName('arabic');
        return isArabic
            ? '✅ تم التبديل إلى العربية\nيمكنك الآن كتابة الأوامر بالعربية'
            : '✅ Switched to Arabic\nYou can now type commands in Arabic';
      case 'english':
        setLanguageByName('english');
        return isEnglish
            ? '✅ تم التبديل إلى الإنجليزية'
            : '✅ Switched to English';
      case 'toggle':
        toggleLanguage();
        return isArabic
            ? '✅ تم التبديل إلى العربية'
            : '✅ Switched to English';
      case 'status':
        return isArabic
            ? '🌐 اللغة الحالية: العربية\nCurrent Language: Arabic'
            : '🌐 Current Language: English\nاللغة الحالية: الإنجليزية';
      default:
        return action;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      معلومات إضافية
  // ═══════════════════════════════════════════════════════════════════════

  static List<AppLanguage> get supportedLanguages => AppLanguage.values;

  static String getLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.english:
        return 'English';
    }
  }

  static String getLanguageCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.english:
        return 'en';
    }
  }

  static String getLanguageFlag(AppLanguage language) {
    switch (language) {
      case AppLanguage.arabic:
        return '🇸🇦';
      case AppLanguage.english:
        return '🇺🇸';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: language_manager.dart
// ═══════════════════════════════════════════════════════════════════════════