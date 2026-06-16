import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class BinaryManager {
  static final BinaryManager _instance = BinaryManager._internal();
  factory BinaryManager() => _instance;
  BinaryManager._internal();

  late String _binaryDir;
  bool _initialized = false;

  final Map<String, String> _binaryPaths = {};

  final Map<String, String> _defaultBinaries = {
    'busybox': 'assets/binaries/busybox',
    'bash': 'assets/binaries/bash',
    'nano': 'assets/binaries/nano',
    'vim': 'assets/binaries/vim',
    'curl': 'assets/binaries/curl',
    'wget': 'assets/binaries/wget',
    'git': 'assets/binaries/git',
    'python': 'assets/binaries/python',
    'node': 'assets/binaries/node',
  };

  Map<String, String> get binaryPaths => Map.unmodifiable(_binaryPaths);

  Future<void> _init() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    _binaryDir = '${appDir.path}/bin';
    await Directory(_binaryDir).create(recursive: true);
    _initialized = true;
  }

  Future<bool> isBinaryInstalled(String name) async {
    await _init();
    final binaryFile = File('$_binaryDir/$name');
    return await binaryFile.exists() && await binaryFile.length() > 1000;
  }

  Future<void> extractAllBinaries() async {
    await _init();
    for (final entry in _defaultBinaries.entries) {
      final name = entry.key;
      final assetPath = entry.value;
      try {
        await _extractBinaryFromAsset(name, assetPath);
      } catch (e) {
        print('BinaryManager: Failed to extract $name: $e');
      }
    }
    print('BinaryManager: All binaries extracted');
  }

  Future<void> _extractBinaryFromAsset(String name, String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final filePath = '$_binaryDir/$name';
      await File(filePath).writeAsBytes(bytes);
      await Process.run('chmod', ['755', filePath]);
      _binaryPaths[name] = filePath;
      print('BinaryManager: Extracted $name to $filePath');
    } catch (e) {
      print('BinaryManager: Error extracting $name from asset: $e');
    }
  }

  Future<void> downloadBinary(String name, String url) async {
    await _init();
    try {
      print('BinaryManager: Downloading $name from $url...');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final filePath = '$_binaryDir/$name';
      await File(filePath).writeAsBytes(response.bodyBytes);
      await Process.run('chmod', ['755', filePath]);
      _binaryPaths[name] = filePath;
      print('BinaryManager: Downloaded $name to $filePath');
    } catch (e) {
      print('BinaryManager: Error downloading $name: $e');
      throw Exception('Failed to download binary $name: $e');
    }
  }

  Future<void> downloadBinaryWithProgress(
    String name,
    String url, {
    void Function(int received, int total)? onProgress,
  }) async {
    await _init();
    try {
      print('BinaryManager: Downloading $name from $url...');
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final filePath = '$_binaryDir/$name';
      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null) {
          onProgress(received, contentLength);
        }
      }

      await sink.close();
      await Process.run('chmod', ['755', filePath]);
      _binaryPaths[name] = filePath;
      print('BinaryManager: Downloaded $name ($received bytes)');
    } catch (e) {
      print('BinaryManager: Error downloading $name: $e');
      throw Exception('Failed to download binary $name: $e');
    }
  }

  Future<bool> removeBinary(String name) async {
    await _init();
    try {
      final file = File('$_binaryDir/$name');
      if (await file.exists()) {
        await file.delete();
      }
      _binaryPaths.remove(name);
      return true;
    } catch (e) {
      print('BinaryManager: Error removing $name: $e');
      return false;
    }
  }

  Future<String?> getBinaryVersion(String name) async {
    final path = _binaryPaths[name];
    if (path == null || !await File(path).exists()) return null;
    try {
      final result = await Process.run(path, ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> listInstalledBinaries() async {
    await _init();
    final dir = Directory(_binaryDir);
    if (!await dir.exists()) return [];
    final binaries = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.mode & 0x40 != 0) {
          binaries.add(entity.path.split('/').last);
        }
      }
    }
    return binaries;
  }

  Future<void> setupBusyboxLinks() async {
    await _init();
    final busyboxPath = '$_binaryDir/busybox';
    if (!await File(busyboxPath).exists()) {
      print('BinaryManager: busybox not found, skipping link setup');
      return;
    }

    final applets = [
      'ls', 'cat', 'mkdir', 'rm', 'cp', 'mv', 'echo', 'ps', 'kill',
      'chmod', 'chown', 'ln', 'dd', 'df', 'du', 'grep', 'sed', 'awk',
      'tar', 'gzip', 'wget', 'ifconfig', 'netstat', 'ping', 'traceroute',
      'whoami', 'id', 'uname', 'pwd', 'clear', 'head', 'tail', 'sort',
      'uniq', 'wc', 'find', 'touch', 'date', 'sleep', 'usleep',
    ];

    for (final applet in applets) {
      final linkPath = '$_binaryDir/$applet';
      final link = Link(linkPath);
      try {
        if (await link.exists()) await link.delete();
        await link.create(busyboxPath);
      } catch (e) {
        try {
          final result = await Process.run('ln', ['-sf', busyboxPath, linkPath]);
          if (result.exitCode != 0) throw Exception(result.stderr);
        } catch (e2) {
          print('BinaryManager: Failed to create link for $applet: $e2');
        }
      }
    }
    print('BinaryManager: Busybox links setup complete');
  }

  Future<Map<String, dynamic>> getBinaryInfo(String name) async {
    final installed = await isBinaryInstalled(name);
    final path = '$_binaryDir/$name';
    String? version;
    int? size;

    if (installed) {
      version = await getBinaryVersion(name);
      size = await File(path).length();
    }

    return {
      'name': name,
      'installed': installed,
      'path': path,
      'version': version ?? 'Unknown',
      'size': size ?? 0,
    };
  }

  Future<Map<String, dynamic>> getStatus() async {
    final installed = await listInstalledBinaries();
    final infoList = <Map<String, dynamic>>[];
    for (final name in installed) {
      infoList.add(await getBinaryInfo(name));
    }
    return {
      'binaryDir': _binaryDir,
      'installedCount': installed.length,
      'binaries': infoList,
    };
  }
}
