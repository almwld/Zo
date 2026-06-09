import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class UltimateReverseEngineeringSystem {
  /// تحليل ملف PE (Windows Executable)
  static Map<String, dynamic> analyzePeFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return {'error': 'File not found'};

    final bytes = file.readAsBytesSync();
    final result = <String, dynamic>{
      'file': filePath,
      'size': bytes.length,
      'type': 'Unknown',
      'architecture': 'Unknown',
      'sections': <Map<String, dynamic>>[],
      'imports': <String>[],
      'exports': <String>[],
      'strings': <String>[],
      'suspicious': <String>[],
    };

    // فحص توقيع MZ
    if (bytes.length > 2 && bytes[0] == 0x4D && bytes[1] == 0x5A) {
      result['type'] = 'PE (Windows Executable)';

      // قراءة PE Header Offset
      if (bytes.length > 0x3C) {
        final peOffset = _readUint32(bytes, 0x3C);
        if (peOffset + 4 < bytes.length && bytes[peOffset] == 0x50 && bytes[peOffset + 1] == 0x45) {
          result['pe_offset'] = peOffset;

          // قراءة Machine Type
          final machine = _readUint16(bytes, peOffset + 4);
          result['architecture'] = machine == 0x14C ? 'x86 (32-bit)' : machine == 0x8664 ? 'x64 (64-bit)' : 'Unknown';

          // قراءة عدد الأقسام
          final numSections = _readUint16(bytes, peOffset + 6);
          final optionalHeaderSize = _readUint16(bytes, peOffset + 20);
          final sectionTableOffset = peOffset + 24 + optionalHeaderSize;

          for (int i = 0; i < numSections; i++) {
            final offset = sectionTableOffset + (i * 40);
            final name = _readAscii(bytes, offset, 8).trim();
            final virtualSize = _readUint32(bytes, offset + 8);
            final rawSize = _readUint32(bytes, offset + 16);

            result['sections'].add({
              'name': name,
              'virtual_size': virtualSize,
              'raw_size': rawSize,
            });

            // فحص أقسام مشبوهة
            if (name.contains('.text') && virtualSize > rawSize * 10) {
              result['suspicious'].add('Unusual .text section size ratio (possible packing)');
            }
          }
        }
      }
    }

    // استخراج السلاسل النصية
    result['strings'] = _extractStrings(bytes, minLength: 4);
    result['imports'] = _findImports(bytes);
    result['exports'] = _findExports(bytes);
    result['suspicious'].addAll(_findSuspiciousPatterns(bytes));

    return result;
  }

  /// تحليل ملف ELF (Linux Executable)
  static Map<String, dynamic> analyzeElfFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return {'error': 'File not found'};

    final bytes = file.readAsBytesSync();
    final result = <String, dynamic>{
      'file': filePath,
      'size': bytes.length,
      'type': 'Unknown',
      'architecture': 'Unknown',
      'sections': <Map<String, dynamic>>[],
      'strings': <String>[],
      'suspicious': <String>[],
    };

    if (bytes.length > 4 && bytes[0] == 0x7F && bytes[1] == 0x45 && bytes[2] == 0x4C && bytes[3] == 0x46) {
      result['type'] = 'ELF (Linux Executable)';

      final elfClass = bytes[4];
      result['architecture'] = elfClass == 1 ? '32-bit' : elfClass == 2 ? '64-bit' : 'Unknown';

      // فحص suspicious
      if (bytes.length > 100) {
        result['strings'] = _extractStrings(bytes);
        result['suspicious'].addAll(_findSuspiciousPatterns(bytes));
      }
    }

    return result;
  }

  /// تحليل ملف APK
  static Map<String, dynamic> analyzeApkFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return {'error': 'File not found'};

    final bytes = file.readAsBytesSync();
    final result = <String, dynamic>{
      'file': filePath,
      'size': bytes.length,
      'type': 'ZIP/APK',
      'strings': <String>[],
      'permissions': <String>[],
      'suspicious': <String>[],
    };

    result['strings'] = _extractStrings(bytes);
    result['permissions'] = _extractPermissions(bytes);
    result['suspicious'].addAll(_findSuspiciousPatterns(bytes));

    return result;
  }

  /// استخراج السلاسل النصية
  static List<String> _extractStrings(List<int> bytes, {int minLength = 4}) {
    final strings = <String>[];
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte >= 32 && byte <= 126) {
        buffer.writeCharCode(byte);
      } else {
        if (buffer.length >= minLength) {
          strings.add(buffer.toString());
        }
        buffer.clear();
      }
    }
    if (buffer.length >= minLength) strings.add(buffer.toString());
    return strings.toSet().toList();
  }

  /// البحث عن أنماط مشبوهة
  static List<String> _findSuspiciousPatterns(List<int> bytes) {
    final suspicious = <String>[];
    final content = String.fromCharCodes(bytes);

    final patterns = {
      'Reverse Shell': [r'/bin/bash', r'/bin/sh', r'cmd.exe', r'nc -e', r'socket'],
      'Keylogger': [r'GetAsyncKeyState', r'SetWindowsHookEx'],
      'Ransomware': [r'encrypt', r'decrypt', r'ransom'],
      'Persistence': [r'Software\\Microsoft\\Windows\\CurrentVersion\\Run'],
      'Privilege Escalation': [r'SeDebugPrivilege', r'SeTakeOwnershipPrivilege'],
    };

    for (final entry in patterns.entries) {
      for (final pattern in entry.value) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(content)) {
          suspicious.add('Detected ${entry.key}: $pattern');
        }
      }
    }

    return suspicious;
  }

  /// استخراج Import Table
  static List<String> _findImports(List<int> bytes) {
    final imports = <String>[];
    final dlls = ['kernel32.dll', 'user32.dll', 'advapi32.dll', 'ws2_32.dll', 'wininet.dll'];
    for (final dll in dlls) {
      final dllBytes = dll.codeUnits;
      for (int i = 0; i < bytes.length - dllBytes.length; i++) {
        if (bytes.sublist(i, i + dllBytes.length).every((b) => dllBytes[bytes.indexOf(b) - i] == b)) {
          imports.add(dll);
          break;
        }
      }
    }
    return imports;
  }

  static List<String> _findExports(List<int> bytes) {
    return _extractStrings(bytes).where((s) => s.startsWith('DllRegisterServer') || s.startsWith('DllMain')).toList();
  }

  static List<String> _extractPermissions(List<int> bytes) {
    final perms = <String>[];
    final permPatterns = ['android.permission.', 'CAMERA', 'RECORD_AUDIO', 'READ_SMS', 'ACCESS_FINE_LOCATION'];
    for (final perm in permPatterns) {
      final permBytes = perm.codeUnits;
      for (int i = 0; i < bytes.length - permBytes.length; i++) {
        if (bytes.sublist(i, i + permBytes.length).every((b) => permBytes[bytes.indexOf(b) - i] == b)) {
          perms.add(perm);
          break;
        }
      }
    }
    return perms;
  }

  static int _readUint16(List<int> bytes, int offset) => (bytes[offset] | (bytes[offset + 1] << 8));
  static int _readUint32(List<int> bytes, int offset) => (bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24));
  static String _readAscii(List<int> bytes, int offset, int length) => String.fromCharCodes(bytes.sublist(offset, offset + length));
}
