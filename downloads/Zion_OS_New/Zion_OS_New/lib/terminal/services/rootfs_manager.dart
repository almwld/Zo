import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class RootFSManager {
  static final RootFSManager _instance = RootFSManager._internal();
  factory RootFSManager() => _instance;
  RootFSManager._internal();

  late String _rootfsDir;
  bool _initialized = false;

  final _downloadProgressController = StreamController<double>.broadcast();
  Stream<double> get downloadProgress => _downloadProgressController.stream;

  Future<void> _init() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    _rootfsDir = '${appDir.path}/rootfs';
    await Directory(_rootfsDir).create(recursive: true);
    _initialized = true;
  }

  String get rootfsPath => _rootfsDir;

  Future<void> downloadRootFS(String distro, String url) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$ distro';
    final archivePath = '$rootfsPath.tar.gz';

    await Directory(rootfsPath).create(recursive: true);

    try {
      print('RootFSManager: Downloading $distro from $url...');
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final file = File(archivePath);
      final sink = file.openWrite();

      int received = 0;
      int lastPercent = -1;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (contentLength > 0) {
          final percent = (received / contentLength * 100).toInt();
          if (percent != lastPercent) {
            lastPercent = percent;
            _downloadProgressController.add(percent / 100.0);
          }
        }
      }

      await sink.close();
      print('RootFSManager: Download complete: $received bytes');
      _downloadProgressController.add(1.0);

      await extractRootFS(distro);
      await setupResolvConf(distro);
      await setupBindMounts(distro);

    } catch (e) {
      _downloadProgressController.addError(e);
      print('RootFSManager: Error downloading rootfs: $e');
      throw Exception('Failed to download RootFS: $e');
    }
  }

  Future<void> downloadRootFSFromAsset(String distro, String assetPath) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final archivePath = '$rootfsPath.tar.gz';

    await Directory(rootfsPath).create(recursive: true);

    try {
      print('RootFSManager: Loading $distro from assets...');
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      await File(archivePath).writeAsBytes(bytes);
      _downloadProgressController.add(0.5);

      await extractRootFS(distro);
      await setupResolvConf(distro);
      await setupBindMounts(distro);

      _downloadProgressController.add(1.0);
      print('RootFSManager: RootFS setup complete for $distro');
    } catch (e) {
      _downloadProgressController.addError(e);
      print('RootFSManager: Error loading rootfs from asset: $e');
      throw Exception('Failed to load RootFS from asset: $e');
    }
  }

  Future<void> extractRootFS(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final archivePath = '$rootfsPath.tar.gz';
    final archiveFile = File(archivePath);

    if (!await archiveFile.exists()) {
      throw Exception('Archive not found: $archivePath');
    }

    print('RootFSManager: Extracting $distro...');
    _downloadProgressController.add(0.55);

    try {
      final result = await Process.run('tar', [
        '-xzf', archivePath,
        '-C', rootfsPath,
        '--strip-components=1',
      ]);

      if (result.exitCode != 0) {
        throw Exception('tar failed: ${result.stderr}');
      }

      await archiveFile.delete();
      _downloadProgressController.add(0.75);
      print('RootFSManager: Extraction complete');
    } catch (e) {
      try {
        print('RootFSManager: Trying manual extraction...');
        final bytes = await archiveFile.readAsBytes();
        final decoded = gzip.decode(bytes);
        await _extractTar(decoded, rootfsPath);
        await archiveFile.delete();
        _downloadProgressController.add(0.75);
        print('RootFSManager: Manual extraction complete');
      } catch (e2) {
        throw Exception('Failed to extract RootFS: $e / $e2');
      }
    }
  }

  Future<void> _extractTar(List<int> tarBytes, String destination) async {
    final reader = TarReader(Stream.fromIterable([Uint8List.fromList(tarBytes)]));
    await reader.forEach((entry) async {
      final name = path.join(destination, entry.header.name);
      if (entry.header.typeFlag == TarHeader.dir) {
        await Directory(name).create(recursive: true);
      } else if (entry.header.typeFlag == TarHeader.reg) {
        await File(name).create(recursive: true);
        await File(name).writeAsBytes(await entry.contents.toBytes());
      } else if (entry.header.typeFlag == TarHeader.symlink) {
        final link = Link(name);
        if (await link.exists()) await link.delete();
        await link.create(entry.header.linkName!);
      }
    });
  }

  Future<void> setupResolvConf(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final resolvConf = File('$rootfsPath/etc/resolv.conf');

    try {
      await Directory('$rootfsPath/etc').create(recursive: true);
      await resolvConf.writeAsString('''
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
''');
      print('RootFSManager: resolv.conf configured');
    } catch (e) {
      print('RootFSManager: Error writing resolv.conf: $e');
    }
  }

  Future<void> setupBindMounts(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';

    final mounts = [
      {'src': '/proc', 'dst': '$rootfsPath/proc'},
      {'src': '/sys', 'dst': '$rootfsPath/sys'},
      {'src': '/dev', 'dst': '$rootfsPath/dev'},
      {'src': '/dev/pts', 'dst': '$rootfsPath/dev/pts'},
    ];

    for (final mount in mounts) {
      try {
        final srcDir = Directory(mount['src']!);
        final dstDir = Directory(mount['dst']!);

        if (await srcDir.exists()) {
          await dstDir.create(recursive: true);
        }
      } catch (e) {
        print('RootFSManager: Warning - bind mount setup for ${mount['src']}: $e');
      }
    }

    try {
      final sdcard = Directory('/sdcard');
      final storageDir = Directory('$rootfsPath/sdcard');
      if (await sdcard.exists()) {
        await storageDir.create(recursive: true);
      }
    } catch (e) {
      print('RootFSManager: Warning - sdcard bind mount: $e');
    }

    print('RootFSManager: Bind mounts configured');
  }

  Future<void> removeRootFS(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final dir = Directory(rootfsPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print('RootFSManager: Removed $distro');
    }
  }

  Future<bool> isRootFSInstalled(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final dir = Directory(rootfsPath);
    return await dir.exists() &&
        await File('$rootfsPath/bin/sh').exists() ||
        await File('$rootfsPath/bin/bash').exists();
  }

  Future<List<String>> listInstalledDistros() async {
    await _init();
    final dir = Directory(_rootfsDir);
    if (!await dir.exists()) return [];

    final distros = <String>[];
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        final name = path.basename(entity.path);
        if (await isRootFSInstalled(name)) {
          distros.add(name);
        }
      }
    }
    return distros;
  }

  Future<Map<String, dynamic>> getRootFSInfo(String distro) async {
    await _init();
    final rootfsPath = '$_rootfsDir/$distro';
    final installed = await isRootFSInstalled(distro);

    int size = 0;
    if (installed) {
      size = await _calculateDirectorySize(Directory(rootfsPath));
    }

    return {
      'distro': distro,
      'installed': installed,
      'path': rootfsPath,
      'size': size,
      'sizeFormatted': _formatSize(size),
    };
  }

  Future<int> _calculateDirectorySize(Directory dir) async {
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (e) {
      print('RootFSManager: Error calculating size: $e');
    }
    return total;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<Map<String, dynamic>> getStatus() async {
    final installed = await listInstalledDistros();
    final infoList = <Map<String, dynamic>>[];
    for (final distro in installed) {
      infoList.add(await getRootFSInfo(distro));
    }
    return {
      'rootfsDir': _rootfsDir,
      'installedCount': installed.length,
      'distros': infoList,
    };
  }

  void dispose() {
    _downloadProgressController.close();
  }
}

class TarHeader {
  static const int reg = 48;
  static const int dir = 53;
  static const int symlink = 50;
  final String name;
  final int size;
  final int typeFlag;
  final String? linkName;
  final int mode;
  final int uid;
  final int gid;
  final int mtime;

  TarHeader({
    required this.name,
    required this.size,
    required this.typeFlag,
    this.linkName,
    required this.mode,
    required this.uid,
    required this.gid,
    required this.mtime,
  });
}

class TarEntry {
  final TarHeader header;
  final Stream<List<int>> contents;

  TarEntry({required this.header, required this.contents});
}

class TarReader {
  final Stream<List<int>> input;
  TarReader(this.input);

  Future<void> forEach(Future<void> Function(TarEntry entry) action) async {
    final allBytes = await input.expand((x) => x).toList();
    final bytes = Uint8List.fromList(allBytes);
    int offset = 0;

    while (offset + 512 <= bytes.length) {
      final block = bytes.sublist(offset, offset + 512);
      offset += 512;

      if (block.every((b) => b == 0)) break;

      final name = _getString(block, 0, 100);
      if (name.isEmpty) break;

      final mode = int.tryParse(_getString(block, 100, 8).trim(), radix: 8) ?? 0;
      final uid = int.tryParse(_getString(block, 108, 8).trim(), radix: 8) ?? 0;
      final gid = int.tryParse(_getString(block, 116, 8).trim(), radix: 8) ?? 0;
      final sizeStr = _getString(block, 124, 12).trim();
      final size = int.tryParse(sizeStr, radix: 8) ?? 0;
      final mtime = int.tryParse(_getString(block, 136, 12).trim(), radix: 8) ?? 0;
      final typeFlag = block[156];
      final linkName = _getString(block, 157, 100);

      final header = TarHeader(
        name: name,
        size: size,
        typeFlag: typeFlag,
        linkName: linkName.isNotEmpty ? linkName : null,
        mode: mode,
        uid: uid,
        gid: gid,
        mtime: mtime,
      );

      final contentSize = ((size + 511) ~/ 512) * 512;
      final content = size > 0
          ? Stream.fromIterable([bytes.sublist(offset, offset + size)])
          : Stream<List<int>>.empty();

      await action(TarEntry(header: header, contents: content));
      offset += contentSize;
    }
  }

  String _getString(Uint8List bytes, int start, int length) {
    final end = start + length;
    final relevant = bytes.sublist(start, end > bytes.length ? bytes.length : end);
    final nullIndex = relevant.indexOf(0);
    final result = nullIndex >= 0
        ? relevant.sublist(0, nullIndex)
        : relevant;
    return String.fromCharCodes(result).trim();
  }
}
