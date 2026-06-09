import 'dart:convert';

class UltimateProtocolAnalyzerSystem {
  /// تحليل HTTP
  static Map<String, dynamic>? parseHttp(String raw) {
    try {
      final lines = raw.split('\r\n');
      if (lines.isEmpty || !lines[0].contains('HTTP')) return null;

      final requestLine = lines[0].split(' ');
      final headers = <String, String>{};
      int i = 1;
      while (i < lines.length && lines[i].isNotEmpty) {
        final colonIndex = lines[i].indexOf(':');
        if (colonIndex > 0) {
          headers[lines[i].substring(0, colonIndex).trim()] = lines[i].substring(colonIndex + 1).trim();
        }
        i++;
      }

      String? body;
      if (i < lines.length - 1) {
        body = lines.sublist(i + 1).join('\r\n');
      }

      return {
        'protocol': 'HTTP',
        'method': requestLine[0],
        'path': requestLine[1],
        'version': requestLine[2],
        'host': headers['Host'] ?? 'Unknown',
        'user_agent': headers['User-Agent'] ?? 'Unknown',
        'headers': headers,
        'body': body,
      };
    } catch (_) {
      return null;
    }
  }

  /// تحليل DNS
  static Map<String, dynamic>? parseDns(List<int> data) {
    if (data.length < 12) return null;

    final transactionId = (data[0] << 8) | data[1];
    final flags = (data[2] << 8) | data[3];
    final questions = (data[4] << 8) | data[5];
    final answers = (data[6] << 8) | data[7];

    final isResponse = (flags & 0x8000) != 0;
    final isQuery = !isResponse;

    return {
      'protocol': 'DNS',
      'transaction_id': transactionId.toRadixString(16),
      'is_query': isQuery,
      'is_response': isResponse,
      'questions': questions,
      'answers': answers,
    };
  }

  /// تحليل TLS/SSL
  static Map<String, dynamic>? parseTls(List<int> data) {
    if (data.length < 5) return null;

    final contentType = data[0];
    final version = '${data[1]}.${data[2]}';
    final length = (data[3] << 8) | data[4];

    final contentTypes = {
      20: 'Change Cipher Spec',
      21: 'Alert',
      22: 'Handshake',
      23: 'Application Data',
    };

    return {
      'protocol': 'TLS',
      'content_type': contentTypes[contentType] ?? 'Unknown ($contentType)',
      'version': version,
      'length': length,
    };
  }

  /// تحليل FTP
  static String? parseFtp(String raw) {
    final code = int.tryParse(raw.substring(0, 3));
    if (code == null) return null;

    return 'FTP Response: $code - ${raw.substring(4)}';
  }

  /// تحليل SMTP
  static String? parseSmtp(String raw) {
    if (raw.startsWith('220')) return 'SMTP Banner: $raw';
    if (raw.startsWith('HELO') || raw.startsWith('EHLO')) return 'SMTP HELO: $raw';
    if (raw.startsWith('MAIL FROM')) return 'SMTP MAIL FROM: $raw';
    if (raw.startsWith('RCPT TO')) return 'SMTP RCPT TO: $raw';
    return null;
  }

  /// التحليل التلقائي
  static Map<String, dynamic> autoAnalyze(List<int> data, int srcPort, int dstPort) {
    final raw = _safeDecode(data);

    if (dstPort == 80 || srcPort == 80 || dstPort == 8080 || srcPort == 8080) {
      final http = parseHttp(raw);
      if (http != null) return http;
    }

    if (dstPort == 443 || srcPort == 443) {
      final tls = parseTls(data);
      if (tls != null) return tls;
    }

    if (dstPort == 53 || srcPort == 53) {
      final dns = parseDns(data);
      if (dns != null) return dns;
    }

    if (dstPort == 21 || srcPort == 21) {
      final ftp = parseFtp(raw);
      if (ftp != null) return {'protocol': 'FTP', 'data': ftp};
    }

    if (dstPort == 25 || srcPort == 25) {
      final smtp = parseSmtp(raw);
      if (smtp != null) return {'protocol': 'SMTP', 'data': smtp};
    }

    return {'protocol': 'Unknown', 'raw': raw.substring(0, raw.length > 200 ? 200 : raw.length)};
  }

  static String _safeDecode(List<int> data) {
    try {
      return utf8.decode(data, allowMalformed: true);
    } catch (_) {
      return String.fromCharCodes(data);
    }
  }
}
