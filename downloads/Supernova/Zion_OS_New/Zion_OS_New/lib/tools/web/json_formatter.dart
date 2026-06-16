import 'dart:convert';

// ═══════════════════════════════════════════════════════════════════════════
// JSON FORMATTER TOOL
// ═══════════════════════════════════════════════════════════════════════════
// A comprehensive JSON formatting, validation, and analysis tool.
// Pure Dart implementation with no external dependencies.
// Features: Format, Minify, Validate, Tree View, Statistics
// ═══════════════════════════════════════════════════════════════════════════

/// JSON Format Operation
enum JsonOperation {
  format('Format', 'تنسيق'),
  minify('Minify', 'تصغير'),
  validate('Validate', 'تحقق'),
  statistics('Statistics', 'إحصائيات'),
  toXml('Convert to XML', 'تحويل إلى XML'),
  toYaml('Convert to YAML', 'تحويل إلى YAML');

  final String englishName;
  final String arabicName;

  const JsonOperation(this.englishName, this.arabicName);
}

/// JSON Analysis Result
class JsonAnalysisResult {
  final bool isValid;
  final String? errorMessage;
  final String formatted;
  final String minified;
  final int totalChars;
  final int totalLines;
  final int objectCount;
  final int arrayCount;
  final int stringCount;
  final int numberCount;
  final int booleanCount;
  final int nullCount;
  final int maxDepth;
  final List<String> keys;
  final String? prettyPrinted;

  JsonAnalysisResult({
    required this.isValid,
    this.errorMessage,
    required this.formatted,
    required this.minified,
    required this.totalChars,
    required this.totalLines,
    required this.objectCount,
    required this.arrayCount,
    required this.stringCount,
    required this.numberCount,
    required this.booleanCount,
    required this.nullCount,
    required this.maxDepth,
    required this.keys,
    this.prettyPrinted,
  });

  String get formattedReport {
    final buffer = StringBuffer();
    buffer.writeln('╔══════════════════════════════════════════════╗');
    buffer.writeln('║           JSON ANALYSIS REPORT               ║');
    buffer.writeln('╚══════════════════════════════════════════════╝');
    buffer.writeln();

    if (!isValid) {
      buffer.writeln('STATUS: INVALID JSON');
      buffer.writeln('Error: $errorMessage');
      return buffer.toString();
    }

    buffer.writeln('STATUS: VALID JSON');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('STATISTICS');
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('Total Characters:  $totalChars');
    buffer.writeln('Total Lines:       $totalLines');
    buffer.writeln('Max Depth:         $maxDepth');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('ELEMENT COUNTS');
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('Objects:           $objectCount');
    buffer.writeln('Arrays:            $arrayCount');
    buffer.writeln('Strings:           $stringCount');
    buffer.writeln('Numbers:           $numberCount');
    buffer.writeln('Booleans:          $booleanCount');
    buffer.writeln('Nulls:             $nullCount');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('KEYS (${keys.length})');
    buffer.writeln('═══════════════════════════════════════════════');
    for (var i = 0; i < keys.length && i < 20; i++) {
      buffer.writeln('  - ${keys[i]}');
    }
    if (keys.length > 20) {
      buffer.writeln('  ... and ${keys.length - 20} more');
    }

    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// JSON FORMATTER ENGINE
// ═══════════════════════════════════════════════════════════════════════════

class JsonFormatter {
  /// Format JSON string with proper indentation
  static String format(String input, {String indent = '  '}) {
    try {
      final parsed = json.decode(input);
      return const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (e) {
      return 'Invalid JSON: $e\n\nInput:\n$input';
    }
  }

  /// Minify JSON by removing all whitespace
  static String minify(String input) {
    try {
      final parsed = json.decode(input);
      return json.encode(parsed);
    } catch (e) {
      return 'Invalid JSON: $e';
    }
  }

  /// Validate JSON and return detailed analysis
  static JsonAnalysisResult analyze(String input) {
    try {
      final parsed = json.decode(input);
      final formatted = const JsonEncoder.withIndent('  ').convert(parsed);
      final minified = json.encode(parsed);

      // Count statistics
      final stats = _collectStats(parsed);

      return JsonAnalysisResult(
        isValid: true,
        formatted: formatted,
        minified: minified,
        totalChars: input.length,
        totalLines: formatted.split('\n').length,
        objectCount: stats['objects'] ?? 0,
        arrayCount: stats['arrays'] ?? 0,
        stringCount: stats['strings'] ?? 0,
        numberCount: stats['numbers'] ?? 0,
        booleanCount: stats['booleans'] ?? 0,
        nullCount: stats['nulls'] ?? 0,
        maxDepth: stats['maxDepth'] ?? 0,
        keys: _collectKeys(parsed),
        prettyPrinted: formatted,
      );
    } catch (e) {
      return JsonAnalysisResult(
        isValid: false,
        errorMessage: e.toString(),
        formatted: input,
        minified: input,
        totalChars: input.length,
        totalLines: input.split('\n').length,
        objectCount: 0,
        arrayCount: 0,
        stringCount: 0,
        numberCount: 0,
        booleanCount: 0,
        nullCount: 0,
        maxDepth: 0,
        keys: [],
      );
    }
  }

  /// Convert JSON to XML
  static String toXml(dynamic jsonData, {String rootName = 'root'}) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    _jsonToXmlInternal(buffer, jsonData, rootName, 0);
    return buffer.toString();
  }

  static void _jsonToXmlInternal(
      StringBuffer buffer, dynamic data, String name, int depth) {
    final indent = '  ' * depth;

    if (data == null) {
      buffer.writeln('$indent<$name/>');
    } else if (data is String) {
      buffer.writeln('$indent<$name>${_escapeXml(data)}</$name>');
    } else if (data is num || data is bool) {
      buffer.writeln('$indent<$name>$data</$name>');
    } else if (data is List) {
      buffer.writeln('$indent<$name>');
      for (var i = 0; i < data.length; i++) {
        _jsonToXmlInternal(buffer, data[i], 'item', depth + 1);
      }
      buffer.writeln('$indent</$name>');
    } else if (data is Map) {
      buffer.writeln('$indent<$name>');
      data.forEach((key, value) {
        _jsonToXmlInternal(buffer, value, key.toString(), depth + 1);
      });
      buffer.writeln('$indent</$name>');
    }
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Convert JSON to YAML
  static String toYaml(dynamic jsonData, {int depth = 0}) {
    final buffer = StringBuffer();
    final indent = '  ' * depth;

    if (jsonData == null) {
      buffer.write('null');
    } else if (jsonData is String) {
      buffer.write(jsonData.contains('\n') || jsonData.contains(':')
          ? '"${_escapeYaml(jsonData)}"'
          : jsonData);
    } else if (jsonData is num || jsonData is bool) {
      buffer.write(jsonData);
    } else if (jsonData is List) {
      if (jsonData.isEmpty) {
        buffer.write('[]');
      } else {
        for (final item in jsonData) {
          buffer.writeln();
          buffer.write('$indent- ');
          final itemYaml = toYaml(item, depth + 1).trimLeft();
          buffer.write(itemYaml);
        }
      }
    } else if (jsonData is Map) {
      if (jsonData.isEmpty) {
        buffer.write('{}');
      } else {
        jsonData.forEach((key, value) {
          buffer.writeln();
          buffer.write('$indent$key: ');
          if (value is Map || value is List) {
            final childYaml = toYaml(value, depth + 1);
            // Remove leading newline for first element
            final lines = childYaml.split('\n');
            if (lines.length > 1) {
              for (var i = 1; i < lines.length; i++) {
                buffer.writeln(lines[i]);
              }
            } else {
              buffer.write(childYaml.trimLeft());
            }
          } else {
            buffer.write(toYaml(value, depth + 1).trimLeft());
          }
        });
      }
    }

    return buffer.toString();
  }

  static String _escapeYaml(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\t', '\\t');
  }

  // ── Statistics Collection ───────────────────────────

  static Map<String, int> _collectStats(dynamic data, [int depth = 0]) {
    final stats = <String, int>{
      'objects': 0,
      'arrays': 0,
      'strings': 0,
      'numbers': 0,
      'booleans': 0,
      'nulls': 0,
      'maxDepth': depth,
    };

    if (data == null) {
      stats['nulls'] = 1;
    } else if (data is String) {
      stats['strings'] = 1;
    } else if (data is num) {
      stats['numbers'] = 1;
    } else if (data is bool) {
      stats['booleans'] = 1;
    } else if (data is List) {
      stats['arrays'] = 1;
      for (final item in data) {
        final itemStats = _collectStats(item, depth + 1);
        itemStats.forEach((key, value) {
          stats[key] = (stats[key] ?? 0) + value;
        });
        if ((itemStats['maxDepth'] ?? 0) > stats['maxDepth']!) {
          stats['maxDepth'] = itemStats['maxDepth'];
        }
      }
    } else if (data is Map) {
      stats['objects'] = 1;
      data.forEach((key, value) {
        final valueStats = _collectStats(value, depth + 1);
        valueStats.forEach((key, value) {
          stats[key] = (stats[key] ?? 0) + value;
        });
        if ((valueStats['maxDepth'] ?? 0) > stats['maxDepth']!) {
          stats['maxDepth'] = valueStats['maxDepth'];
        }
      });
    }

    return stats;
  }

  static List<String> _collectKeys(dynamic data, [String prefix = '']) {
    final keys = <String>[];

    if (data is Map) {
      data.forEach((key, value) {
        final fullKey = prefix.isEmpty ? key.toString() : '$prefix.$key';
        keys.add(fullKey);
        keys.addAll(_collectKeys(value, fullKey));
      });
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        if (data[i] is Map || data[i] is List) {
          keys.addAll(_collectKeys(data[i], '$prefix[$i]'));
        }
      }
    }

    return keys;
  }

  // ── Utility Functions ───────────────────────────────

  /// Check if a string is valid JSON
  static bool isValid(String input) {
    try {
      json.decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get JSON type description
  static String getTypeDescription(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return 'string';
    if (value is int) return 'integer';
    if (value is double) return 'float';
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    if (value is List) return 'array[${value.length}]';
    if (value is Map) return 'object{${value.length}}';
    return 'unknown';
  }

  /// Compare two JSON strings
  static String compare(String json1, String json2) {
    try {
      final parsed1 = json.decode(json1);
      final parsed2 = json.decode(json2);

      final result = _deepCompare(parsed1, parsed2, '');

      if (result.isEmpty) {
        return 'The two JSON structures are identical.';
      }

      final buffer = StringBuffer();
      buffer.writeln('Differences found:');
      buffer.writeln();
      for (final diff in result) {
        buffer.writeln('  $diff');
      }
      return buffer.toString();
    } catch (e) {
      return 'Error comparing JSON: $e';
    }
  }

  static List<String> _deepCompare(dynamic a, dynamic b, String path) {
    final differences = <String>[];

    if (a.runtimeType != b.runtimeType) {
      differences.add('$path: Type differs (${a.runtimeType} vs ${b.runtimeType})');
      return differences;
    }

    if (a is Map && b is Map) {
      final allKeys = {...a.keys, ...b.keys};
      for (final key in allKeys) {
        final newPath = path.isEmpty ? '/$key' : '$path/$key';
        if (!a.containsKey(key)) {
          differences.add('$newPath: Missing in first JSON');
        } else if (!b.containsKey(key)) {
          differences.add('$newPath: Missing in second JSON');
        } else {
          differences.addAll(_deepCompare(a[key], b[key], newPath));
        }
      }
    } else if (a is List && b is List) {
      final maxLen = a.length > b.length ? a.length : b.length;
      for (var i = 0; i < maxLen; i++) {
        final newPath = '$path[$i]';
        if (i >= a.length) {
          differences.add('$newPath: Missing in first JSON');
        } else if (i >= b.length) {
          differences.add('$newPath: Missing in second JSON');
        } else {
          differences.addAll(_deepCompare(a[i], b[i], newPath));
        }
      }
    } else if (a != b) {
      differences.add('$path: Value differs ($a vs $b)');
    }

    return differences;
  }

  /// Generate a tree-view representation of JSON
  static String toTreeView(dynamic data, {String prefix = '', bool isLast = true}) {
    final buffer = StringBuffer();
    final connector = isLast ? '└── ' : '├── ';

    if (data is Map) {
      final entries = data.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final isLastEntry = i == entries.length - 1;
        final childPrefix = prefix + (isLast ? '    ' : '│   ');

        if (entry.value is Map || entry.value is List) {
          buffer.writeln('$prefix${isLastEntry ? '└── ' : '├── '}${entry.key}:');
          buffer.write(toTreeView(entry.value, prefix: childPrefix, isLast: isLastEntry));
        } else {
          buffer.writeln(
              '$prefix${isLastEntry ? '└── ' : '├── '}${entry.key}: ${entry.value}');
        }
      }
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        final isLastEntry = i == data.length - 1;
        final childPrefix = prefix + (isLast ? '    ' : '│   ');

        if (data[i] is Map || data[i] is List) {
          buffer.writeln('$prefix${isLastEntry ? '└── ' : '├── '}[$i]:');
          buffer.write(toTreeView(data[i], prefix: childPrefix, isLast: isLastEntry));
        } else {
          buffer.writeln('$prefix${isLastEntry ? '└── ' : '├── '}[$i]: ${data[i]}');
        }
      }
    }

    return buffer.toString();
  }
}
