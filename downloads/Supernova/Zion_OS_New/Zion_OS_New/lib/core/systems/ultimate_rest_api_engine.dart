import 'dart:async';
import 'dart:io';
import 'dart:convert';

class UltimateRestApiEngine {
  HttpServer? _server;
  final Map<String, Function> _routes = {};

  void registerRoute(String method, String path, Function handler) {
    _routes['$method:$path'] = handler;
  }

  Future<void> start({int port = 8080}) async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('[API] Server started on port $port');

    await for (final request in _server!) {
      _handleRequest(request);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    final method = request.method;
    final key = '$method:$path';

    HttpResponse response = request.response;
    response.headers.contentType = ContentType.json;

    if (_routes.containsKey(key)) {
      try {
        final handler = _routes[key]!;
        final result = await handler(request);
        response.statusCode = 200;
        response.write(jsonEncode(result));
      } catch (e) {
        response.statusCode = 500;
        response.write(jsonEncode({'error': e.toString()}));
      }
    } else {
      response.statusCode = 404;
      response.write(jsonEncode({'error': 'Route not found'}));
    }

    await response.close();
  }

  void stop() {
    _server?.close();
  }
}
