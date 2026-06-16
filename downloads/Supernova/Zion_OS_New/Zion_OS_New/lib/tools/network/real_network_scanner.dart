import 'dart:async';
import 'dart:io';
import 'dart:convert';

class RealNetworkScanner {
  /// فحص منفذ TCP حقيقي
  static Future<bool> isTcpPortOpen(String host, int port, {int timeoutMs = 500}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(milliseconds: timeoutMs));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// فحص منفذ UDP حقيقي
  static Future<bool> isUdpPortOpen(String host, int port, {int timeoutMs = 500}) async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      final data = List<int>.filled(1, 0);
      socket.send(data, InternetAddress(host), port);

      final completer = Completer<bool>();
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            completer.complete(true);
          }
        }
      });

      final result = await completer.timeout(Duration(milliseconds: timeoutMs), onTimeout: () => false);
      socket.close();
      return result;
    } catch (_) {
      return false;
    }
  }

  /// فحص نطاق منافذ TCP
  static Future<List<int>> scanTcpPorts(String host, List<int> ports, {int concurrency = 50}) async {
    final openPorts = <int>[];
    final chunks = <List<int>>[];
    for (int i = 0; i < ports.length; i += concurrency) {
      chunks.add(ports.sublist(i, i + concurrency > ports.length ? ports.length : i + concurrency));
    }

    for (final chunk in chunks) {
      await Future.wait(chunk.map((port) async {
        if (await isTcpPortOpen(host, port)) {
          openPorts.add(port);
        }
      }));
    }

    openPorts.sort();
    return openPorts;
  }

  /// جلب بانر الخدمة (Banner Grabbing)
  static Future<String?> grabBanner(String host, int port, {int timeoutMs = 2000}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(milliseconds: timeoutMs));
      final completer = Completer<String?>();
      final buffer = StringBuffer();

      socket.listen((data) {
        buffer.write(utf8.decode(data, allowMalformed: true));
        if (buffer.toString().contains('\n')) {
          completer.complete(buffer.toString().trim());
        }
      }, onDone: () {
        if (!completer.isCompleted) completer.complete(buffer.toString().trim());
      }, onError: (_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      final result = await completer.timeout(Duration(milliseconds: timeoutMs), onTimeout: () => buffer.toString().trim());
      socket.destroy();
      return (result != null && result.isNotEmpty) ? result.split('\n').first : null;
    } catch (_) {
      return null;
    }
  }

  /// فحص Ping
  static Future<bool> ping(String host) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '1', host], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// استعلام DNS
  static Future<List<String>> dnsLookup(String domain) async {
    try {
      final addresses = await InternetAddress.lookup(domain);
      return addresses.map((e) => e.address).toList();
    } catch (_) {
      return [];
    }
  }
}
