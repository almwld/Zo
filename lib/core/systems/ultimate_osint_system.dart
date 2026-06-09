import 'dart:async';
import 'dart:io';
import 'dart:convert';

class UltimateOsintSystem {
  /// البحث عن معلومات دومين
  static Future<Map<String, dynamic>> gatherDomainInfo(String domain) async {
    final info = <String, dynamic>{
      'domain': domain,
      'timestamp': DateTime.now().toIso8601String(),
      'ip_addresses': <String>[],
      'whois': <String, dynamic>{},
      'subdomains': <String>[],
      'technologies': <String>[],
    };

    try {
      final addresses = await InternetAddress.lookup(domain);
      info['ip_addresses'] = addresses.map((a) => a.address).toList();
    } catch (_) {}

    info['subdomains'] = await _findSubdomains(domain);
    info['technologies'] = await _detectTechnologies(domain);

    return info;
  }

  /// البحث عن معلومات IP
  static Future<Map<String, dynamic>> gatherIpInfo(String ip) async {
    final info = <String, dynamic>{'ip': ip};

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://ipapi.co/$ip/json/'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        info['country'] = data['country_name'];
        info['city'] = data['city'];
        info['isp'] = data['org'];
        info['timezone'] = data['timezone'];
      }
    } catch (_) {}

    return info;
  }

  /// البحث عن عنوان بريد إلكتروني
  static Map<String, dynamic> gatherEmailInfo(String email) {
    final info = <String, dynamic>{'email': email};

    if (email.contains('@')) {
      final parts = email.split('@');
      info['username'] = parts[0];
      info['domain'] = parts[1];
      info['provider'] = _identifyEmailProvider(parts[1]);
    }

    return info;
  }

  /// البحث عن حسابات تواصل اجتماعي
  static List<Map<String, dynamic>> searchSocialMedia(String username) {
    final platforms = [
      {'name': 'GitHub', 'url': 'https://github.com/$username'},
      {'name': 'Twitter', 'url': 'https://twitter.com/$username'},
      {'name': 'Instagram', 'url': 'https://instagram.com/$username'},
      {'name': 'LinkedIn', 'url': 'https://linkedin.com/in/$username'},
      {'name': 'Reddit', 'url': 'https://reddit.com/user/$username'},
    ];

    return platforms;
  }

  /// البحث عن ملفات حساسة على خادم
  static Future<List<Map<String, dynamic>>> findSensitiveFiles(String baseUrl) async {
    final sensitivePaths = [
      'robots.txt', '.git/config', '.env', 'backup.zip', 'wp-config.php.bak',
      'phpinfo.php', 'server-status', 'admin/', 'login/', 'test/',
    ];

    final found = <Map<String, dynamic>>[];
    for (final path in sensitivePaths) {
      try {
        final url = baseUrl.endsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();

        if (response.statusCode == 200 || response.statusCode == 403) {
          found.add({
            'path': path,
            'status': response.statusCode,
            'accessible': response.statusCode == 200,
          });
        }
      } catch (_) {}
    }

    return found;
  }

  static Future<List<String>> _findSubdomains(String domain) async {
    final commonSubs = ['www', 'mail', 'ftp', 'blog', 'shop', 'api', 'dev', 'admin', 'test', 'staging'];
    final found = <String>[];

    for (final sub in commonSubs) {
      try {
        final host = '$sub.$domain';
        await InternetAddress.lookup(host);
        found.add(host);
      } catch (_) {}
    }

    return found;
  }

  static Future<List<String>> _detectTechnologies(String domain) async {
    final technologies = <String>[];
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://$domain'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (body.contains('wp-content')) technologies.add('WordPress');
      if (body.contains('jquery')) technologies.add('jQuery');
      if (body.contains('bootstrap')) technologies.add('Bootstrap');
      if (body.contains('react')) technologies.add('React');

      final server = response.headers.value('server');
      if (server != null) technologies.add(server);
    } catch (_) {}

    return technologies;
  }

  static String _identifyEmailProvider(String domain) {
    if (domain.contains('gmail')) return 'Google';
    if (domain.contains('outlook') || domain.contains('hotmail')) return 'Microsoft';
    if (domain.contains('yahoo')) return 'Yahoo';
    if (domain.contains('proton')) return 'ProtonMail';
    return 'Unknown';
  }
}
