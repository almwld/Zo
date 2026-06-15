import 'package:flutter/material.dart';

class IconMapper {
  static Widget getIcon(String appName, {double size = 28}) {
    return Icon(_getMaterialIcon(appName), size: size, color: const Color(0xFF00BCD4));
  }

  static IconData _getMaterialIcon(String appName) {
    switch (appName) {
      case "TERMINAL": return Icons.terminal;
      case "NETWORK SCANNER": return Icons.network_wifi;
      case "WIFI": return Icons.wifi;
      case "EXPLOIT": return Icons.bug_report;
      case "CRYPTO": return Icons.lock;
      case "STEALTH": return Icons.visibility_off;
      case "CRACKER": return Icons.vpn_key;
      case "DDOS": return Icons.speed;
      case "DATABASE": return Icons.storage;
      case "CLOUD": return Icons.cloud;
      case "FORENSICS": return Icons.search;
      case "TEXT ANALYZER": return Icons.analytics;
      case "SETTINGS": return Icons.settings;
      case "FILE MANAGER": return Icons.folder;
      case "BROWSER": return Icons.public;
      case "WEATHER": return Icons.wb_sunny;
      case "CURRENCY": return Icons.attach_money;
      case "TRANSLATOR": return Icons.translate;
      case "MAPS": return Icons.map;
      case "RADIO": return Icons.radio;
      case "SHARE": return Icons.share;
      case "EMAIL": return Icons.email;
      case "NOTES": return Icons.note;
      case "CLOCK": return Icons.access_time;
      case "CALCULATOR": return Icons.calculate;
      case "BACKUP": return Icons.backup;
      case "CLEANER": return Icons.cleaning_services;
      case "APP LOCK": return Icons.lock;
      case "NOTIFY": return Icons.notifications;
      case "GALLERY": return Icons.photo_library;
      case "VIDEO": return Icons.play_circle_filled;
      case "CALENDAR": return Icons.calendar_today;
      case "QR CODE": return Icons.qr_code_scanner;
      case "DOCUMENTS": return Icons.description;
      case "BATTERY": return Icons.battery_charging_full;
      case "SECURITY HUB": return Icons.security;
      case "TOOLS HUB": return Icons.build;
      case "PERF HUB": return Icons.speed;
      case "DATA HUB": return Icons.storage;
      case "NET HUB": return Icons.network_check;
      case "PRIV HUB": return Icons.privacy_tip;
      case "AUTO HUB": return Icons.settings_applications;
      case "ROOT TERM": return Icons.terminal;
      default: return Icons.apps;
    }
  }
}
