import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class UltimateBinaryAnalyzerSystem {
  /// تحليل أي ملف ثنائي
  static Map<String, dynamic> analyzeFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return {'error': 'File not found'};

    final bytes = file.readAsBytesSync();
    final result = <String, dynamic>{
      'file': filePath,
      'size': bytes.length,
      'md5': _calculateMd5(bytes),
      'sha256': _calculateSha256(bytes),
      'entropy': _calculateEntropy(bytes),
      'type': _detectFileType(bytes),
      'architecture': _detectArchitecture(bytes),
      'sections': <Map<String, dynamic>>[],
      'strings': <String>[],
      'imports': <String>[],
      'exports': <String>[],
      'resources': <Map<String, dynamic>>{},
      'packer_signs': <String>[],
      'suspicious': <String>[],
    };

    // استخراج السلاسل النصية
    result['strings'] = _extractStrings(bytes, minLength: 4);

    // تحليل PE (Windows)
    if (result['type'] == 'PE') {
      final peInfo = _analyzePeFile(bytes);
      result.addAll(peInfo);
    }

    // تحليل ELF (Linux)
    if (result['type'] == 'ELF') {
      final elfInfo = _analyzeElfFile(bytes);
      result.addAll(elfInfo);
    }

    // فحص التعبئة (Packing)
    result['packer_signs'] = _detectPacker(bytes);
    result['suspicious'] = _findSuspiciousPatterns(bytes);

    return result;
  }

  /// تحديد نوع الملف
  static String _detectFileType(List<int> bytes) {
    if (bytes.length < 4) return 'Unknown';
    if (bytes[0] == 0x7F && bytes[1] == 0x45 && bytes[2] == 0x4C && bytes[3] == 0x46) return 'ELF';
    if (bytes[0] == 0x4D && bytes[1] == 0x5A) return 'PE';
    if (bytes[0] == 0x50 && bytes[1] == 0x4B) return 'ZIP/APK';
    if (bytes[0] == 0xCA && bytes[1] == 0xFE && bytes[2] == 0xBA && bytes[3] == 0xBE) return 'Mach-O';
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) return 'PDF';
    return 'Unknown';
  }

  /// تحديد المعمارية
  static String _detectArchitecture(List<int> bytes) {
    if (bytes.length < 6) return 'Unknown';
    if (bytes[0] == 0x7F && bytes[1] == 0x45) {
      return bytes[4] == 1 ? 'x86 (32-bit)' : 'x64 (64-bit)';
    }
    if (bytes[0] == 0x4D && bytes[1] == 0x5A) {
      if (bytes.length > 0x3C) {
        final peOffset = _readUint32(bytes, 0x3C);
        if (peOffset + 4 < bytes.length) {
          final machine = _readUint16(bytes, peOffset + 4);
          return machine == 0x14C ? 'x86' : machine == 0x8664 ? 'x64' : 'Unknown';
        }
      }
    }
    return 'Unknown';
  }

  /// تحليل PE
  static Map<String, dynamic> _analyzePeFile(List<int> bytes) {
    final info = <String, dynamic>{};
    if (bytes.length <= 0x3C) return info;

    final peOffset = _readUint32(bytes, 0x3C);
    if (peOffset + 24 >= bytes.length) return info;

    final numSections = _readUint16(bytes, peOffset + 6);
    final optionalHeaderSize = _readUint16(bytes, peOffset + 20);
    final sectionTableOffset = peOffset + 24 + optionalHeaderSize;

    final sections = <Map<String, dynamic>>[];
    for (int i = 0; i < numSections; i++) {
      final offset = sectionTableOffset + (i * 40);
      if (offset + 40 > bytes.length) break;
      final name = _readAscii(bytes, offset, 8).trim();
      final virtualSize = _readUint32(bytes, offset + 8);
      final virtualAddress = _readUint32(bytes, offset + 12);
      final rawSize = _readUint32(bytes, offset + 16);
      final rawOffset = _readUint32(bytes, offset + 20);

      sections.add({
        'name': name,
        'virtual_size': virtualSize,
        'virtual_address': virtualAddress.toRadixString(16),
        'raw_size': rawSize,
        'raw_offset': rawOffset,
      });
    }
    info['sections'] = sections;
    return info;
  }

  /// تحليل ELF
  static Map<String, dynamic> _analyzeElfFile(List<int> bytes) {
    final info = <String, dynamic>{};
    if (bytes.length < 64) return info;

    final elfClass = bytes[4];
    final is64 = elfClass == 2;
    final entryPoint = is64 ? _readUint64(bytes, 24) : _readUint32(bytes, 24);

    info['entry_point'] = entryPoint.toRadixString(16);
    info['elf_class'] = is64 ? 'ELF64' : 'ELF32';

    return info;
  }

  /// اكتشاف أدوات التعبئة
  static List<String> _detectPacker(List<int> bytes) {
    final packers = <String>[];
    final content = String.fromCharCodes(bytes);

    if (content.contains('UPX')) packers.add('UPX');
    if (content.contains('ASPack')) packers.add('ASPack');
    if (content.contains('Themida')) packers.add('Themida');
    if (content.contains('VMProtect')) packers.add('VMProtect');

    return packers;
  }

  /// البحث عن أنماط مشبوهة
  static List<String> _findSuspiciousPatterns(List<int> bytes) {
    final suspicious = <String>[];
    final content = String.fromCharCodes(bytes);

    final patterns = {
      'Reverse Shell': [r'/bin/bash', r'/bin/sh', r'cmd.exe'],
      'Keylogger': [r'GetAsyncKeyState', r'SetWindowsHookEx'],
      'Ransomware': [r'encrypt', r'ransom'],
    };

    for (final entry in patterns.entries) {
      for (final pattern in entry.value) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(content)) {
          suspicious.add('${entry.key}: $pattern');
        }
      }
    }

    return suspicious;
  }

  static List<String> _extractStrings(List<int> bytes, {int minLength = 4}) {
    final strings = <String>[];
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte >= 32 && byte <= 126) {
        buffer.writeCharCode(byte);
      } else {
        if (buffer.length >= minLength) strings.add(buffer.toString());
        buffer.clear();
      }
    }
    if (buffer.length >= minLength) strings.add(buffer.toString());
    return strings.toSet().toList();
  }

  static String _calculateMd5(List<int> bytes) {
    int hash = 0;
    for (final b in bytes) { hash = ((hash << 5) - hash) + b; hash &= 0xFFFFFFFF; }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String _calculateSha256(List<int> bytes) {
    int hash = 0;
    for (final b in bytes) { hash = ((hash << 5) - hash) ^ b; hash &= 0xFFFFFFFF; }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static double _calculateEntropy(List<int> bytes) {
    final freq = <int, int>{};
    for (final b in bytes) { freq[b] = (freq[b] ?? 0) + 1; }
    double entropy = 0;
    for (final count in freq.values) {
      final p = count / bytes.length;
      entropy -= p * (p > 0 ? _log2(p) : 0);
    }
    return entropy;
  }

  static double _log2(double x) => x > 0 ? x.log(2) : 0;

  static int _readUint16(List<int> bytes, int offset) => (bytes[offset] | (bytes[offset + 1] << 8));
  static int _readUint32(List<int> bytes, int offset) => (bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24));
  static int _readUint64(List<int> bytes, int offset) => _readUint32(bytes, offset) | (_readUint32(bytes, offset + 4) << 32);
  static String _readAscii(List<int> bytes, int offset, int length) => String.fromCharCodes(bytes.sublist(offset, offset + length));
}
