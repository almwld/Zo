import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class UltimateSurveillanceSystem {
  final List<Map<String, dynamic>> _networkLog = [];
  final List<Map<String, dynamic>> _dnsLog = [];
  final List<Map<String, dynamic>> _httpLog = [];
  ServerSocket? _interceptor;
  bool _isRunning = false;

  /// بدء اعتراض الشبكة (MITM)
  Future<bool> startInterception({int port = 8080}) async {
    try {
      _interceptor = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _isRunning = true;

      _interceptor!.listen((clientSocket) {
        _handleIncomingConnection(clientSocket);
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// معالجة اتصال وارد
  void _handleIncomingConnection(Socket clientSocket) async {
    final clientAddress = '${clientSocket.remoteAddress.address}:${clientSocket.remotePort}';

    clientSocket.listen((data) async {
      final request = _safeDecode(data);
      final parsed = _parseHttpRequest(request);

      _httpLog.add({
        'timestamp': DateTime.now().toIso8601String(),
        'client': clientAddress,
        'request': parsed,
        'size': data.length,
      });

      // محاولة إعادة توجيه الطلب للخادم الحقيقي
      if (parsed != null && parsed['host'] != null) {
        try {
          final forwardSocket = await Socket.connect(parsed['host'], 80, timeout: const Duration(seconds: 5));
          forwardSocket.add(data);
          forwardSocket.listen((responseData) {
            clientSocket.add(responseData);
          });
        } catch (_) {
          clientSocket.destroy();
        }
      }
    });
  }

  /// اعتراض DNS
  Future<void> interceptDns(String domain) async {
    try {
      final addresses = await InternetAddress.lookup(domain);
      _dnsLog.add({
        'timestamp': DateTime.now().toIso8601String(),
        'domain': domain,
        'resolved_to': addresses.map((e) => e.address).toList(),
      });
    } catch (_) {}
  }

  /// فحص الشبكة المحلية
  Future<List<Map<String, dynamic>>> scanLocalNetwork() async {
    final devices = <Map<String, dynamic>>[];
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
              for (int i = 1; i <= 254; i++) {
                final ip = '$subnet.$i';
                try {
                  final socket = await Socket.connect(ip, 80, timeout: const Duration(milliseconds: 200));
                  devices.add({'ip': ip, 'port': 80, 'status': 'open'});
                  socket.destroy();
                } catch (_) {}
              }
            }
          }
        }
      }
    } catch (_) {}
    return devices;
  }

  /// تحليل حركة الشبكة
  Map<String, dynamic> analyzeTraffic() {
    final totalRequests = _httpLog.length;
    final uniqueHosts = <String>{};
    final methods = <String, int>{};

    for (final log in _httpLog) {
      final parsed = log['request'];
      if (parsed != null && parsed['host'] != null) {
        uniqueHosts.add(parsed['host']);
        methods[parsed['method'] ?? 'GET'] = (methods[parsed['method'] ?? 'GET'] ?? 0) + 1;
      }
    }

    return {
      'total_requests': totalRequests,
      'unique_hosts': uniqueHosts.length,
      'methods': methods,
      'dns_queries': _dnsLog.length,
      'devices_scanned': _networkLog.length,
    };
  }

  /// إيقاف الاعتراض
  void stopInterception() {
    _isRunning = false;
    _interceptor?.close();
  }

  Map<String, dynamic>? _parseHttpRequest(String raw) {
    try {
      final lines = raw.split('\r\n');
      final requestLine = lines[0].split(' ');
      final headers = <String, String>{};

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].isEmpty) break;
        final colonIndex = lines[i].indexOf(':');
        if (colonIndex > 0) {
          headers[lines[i].substring(0, colonIndex).trim()] = lines[i].substring(colonIndex + 1).trim();
        }
      }

      return {
        'method': requestLine[0],
        'path': requestLine[1],
        'version': requestLine[2],
        'host': headers['Host'] ?? 'unknown',
        'user_agent': headers['User-Agent'] ?? 'unknown',
      };
    } catch (_) {
      return null;
    }
  }

  String _safeDecode(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return String.fromCharCodes(bytes);
    }
  }
}
