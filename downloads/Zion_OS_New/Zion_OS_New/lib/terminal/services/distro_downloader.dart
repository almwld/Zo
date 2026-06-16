import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DistroInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String downloadUrl;
  final String? checksum;
  final int sizeBytes;
  final String architecture;
  bool isInstalled;

  DistroInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.downloadUrl,
    this.checksum,
    required this.sizeBytes,
    required this.architecture,
    this.isInstalled = false,
  });

  factory DistroInfo.fromJson(Map<String, dynamic> json) {
    return DistroInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      downloadUrl: json['download_url'],
      checksum: json['checksum'],
      sizeBytes: json['size_bytes'] ?? 0,
      architecture: json['architecture'] ?? 'all',
      isInstalled: json['is_installed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'download_url': downloadUrl,
    'checksum': checksum,
    'size_bytes': sizeBytes,
    'architecture': architecture,
    'is_installed': isInstalled,
  };

  String get sizeFormatted {
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class DistroDownloader {
  static final DistroDownloader _instance = DistroDownloader._internal();
  factory DistroDownloader() => _instance;
  DistroDownloader._internal();

  late String _downloadDir;
  bool _initialized = false;

  final _statusController = StreamController<String>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  Stream<String> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;

  final List<DistroInfo> _availableDistros = [
    DistroInfo(
      id: 'ubuntu',
      name: 'Ubuntu',
      description: 'Ubuntu 22.04 LTS - Most popular Linux distribution',
      icon: 'assets/icons/ubuntu.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/ubuntu-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 250000000,
      architecture: 'aarch64',
    ),
    DistroInfo(
      id: 'debian',
      name: 'Debian',
      description: 'Debian 12 (Bookworm) - The universal operating system',
      icon: 'assets/icons/debian.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/debian-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 200000000,
      architecture: 'aarch64',
    ),
    DistroInfo(
      id: 'alpine',
      name: 'Alpine Linux',
      description: 'Alpine 3.18 - Lightweight security-oriented distribution',
      icon: 'assets/icons/alpine.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/alpine-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 50000000,
      architecture: 'aarch64',
    ),
    DistroInfo(
      id: 'fedora',
      name: 'Fedora',
      description: 'Fedora 39 - Cutting edge Linux distribution',
      icon: 'assets/icons/fedora.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/fedora-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 300000000,
      architecture: 'aarch64',
    ),
    DistroInfo(
      id: 'arch',
      name: 'Arch Linux',
      description: 'Arch Linux - A simple, lightweight distribution',
      icon: 'assets/icons/arch.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/archlinux-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 280000000,
      architecture: 'aarch64',
    ),
    DistroInfo(
      id: 'kali',
      name: 'Kali Linux',
      description: 'Kali Linux - Advanced penetration testing distribution',
      icon: 'assets/icons/kali.png',
      downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/kali-aarch64-pd-v4.6.0.tar.xz',
      sizeBytes: 350000000,
      architecture: 'aarch64',
    ),
  ];

  Future<void> _init() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    _downloadDir = '${appDir.path}/distros';
    await Directory(_downloadDir).create(recursive: true);
    _initialized = true;
  }

  Future<void> downloadDistro(DistroInfo distro) async {
    await _init();
    final distroDir = '$_downloadDir/${distro.id}';
    final archivePath = '$distroDir/rootfs.tar.xz';

    await Directory(distroDir).create(recursive: true);

    try {
      _statusController.add('Downloading ${distro.name}...');
      _progressController.add(0.0);

      final request = http.Request('GET', Uri.parse(distro.downloadUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final contentLength = response.contentLength ?? distro.sizeBytes;
      final file = File(archivePath);
      final sink = file.openWrite();

      int received = 0;
      int lastPercent = -1;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (contentLength > 0) {
          final percent = (received / contentLength * 100).toInt();
          if (percent != lastPercent && percent % 5 == 0) {
            lastPercent = percent;
            _progressController.add(percent / 100.0);
            _statusController.add('Downloading ${distro.name}... $percent%');
          }
        }
      }

      await sink.close();
      _progressController.add(0.5);
      _statusController.add('Download complete. Verifying...');

      if (distro.checksum != null) {
        await verifyChecksum(archivePath, distro.checksum!);
        _statusController.add('Checksum verified.');
      }

      _progressController.add(0.55);
      _statusController.add('Extracting ${distro.name}...');

      await extractDistro(distro);

      _progressController.add(1.0);
      _statusController.add('${distro.name} installed successfully!');
      distro.isInstalled = true;

    } catch (e) {
      _statusController.add('Error: $e');
      _progressController.addError(e);
      throw Exception('Failed to download distro: $e');
    }
  }

  Future<void> extractDistro(DistroInfo distro) async {
    await _init();
    final distroDir = '$_downloadDir/${distro.id}';
    final archivePath = '$distroDir/rootfs.tar.xz';
    final rootfsPath = '$distroDir/rootfs';

    if (!await File(archivePath).exists()) {
      throw Exception('Archive not found: $archivePath');
    }

    await Directory(rootfsPath).create(recursive: true);

    try {
      _statusController.add('Extracting archive...');
      final result = await Process.run('tar', [
        '-xJf', archivePath,
        '-C', rootfsPath,
      ]);

      if (result.exitCode != 0) {
        throw Exception('tar extraction failed: ${result.stderr}');
      }

      await _setupDistroEnvironment(distro);
      await File(archivePath).delete();

      _progressController.add(0.85);
      _statusController.add('Setting up environment...');

      print('DistroDownloader: ${distro.name} extracted successfully');
    } catch (e) {
      print('DistroDownloader: Error extracting: $e');
      _statusController.add('Extraction error: $e');

      try {
        await _extractManually(archivePath, rootfsPath);
        await _setupDistroEnvironment(distro);
        _statusController.add('Extraction completed (fallback).');
      } catch (e2) {
        throw Exception('Failed to extract distro: $e / $e2');
      }
    }
  }

  Future<void> _extractManually(String archivePath, String destination) async {
    final archiveBytes = await File(archivePath).readAsBytes();
    final decompressed = await _decompressXz(archiveBytes);
    await _extractTarFallback(decompressed, destination);
  }

  Future<List<int>> _decompressXz(List<int> compressed) async {
    try {
      final result = await Process.run('xz', ['-d', '-c']);
      if (result.exitCode == 0) return result.stdout as List<int>;
    } catch (_) {}

    final tempFile = File('${await getTemporaryDirectory()}/temp.tar.xz');
    await tempFile.writeAsBytes(compressed);

    final result = await Process.run('xz', ['-d', tempFile.path]);
    if (result.exitCode == 0) {
      final tarFile = File(tempFile.path.replaceAll('.xz', ''));
      return await tarFile.readAsBytes();
    }

    throw Exception('XZ decompression failed');
  }

  Future<void> _extractTarFallback(List<int> tarBytes, String destination) async {
    final bytes = Uint8List.fromList(tarBytes);
    int offset = 0;

    while (offset + 512 <= bytes.length) {
      final block = bytes.sublist(offset, offset + 512);
      offset += 512;

      if (block.every((b) => b == 0)) break;

      final nameBytes = block.sublist(0, 100);
      final nullIndex = nameBytes.indexOf(0);
      final name = String.fromCharCodes(
        nullIndex >= 0 ? nameBytes.sublist(0, nullIndex) : nameBytes,
      ).trim();

      if (name.isEmpty) break;

      final sizeStr = String.fromCharCodes(block.sublist(124, 136)).trim();
      final size = int.tryParse(sizeStr, radix: 8) ?? 0;
      final typeFlag = block[156];

      final filePath = path.join(destination, name);
      final contentSize = ((size + 511) ~/ 512) * 512;

      if (typeFlag == 53) {
        await Directory(filePath).create(recursive: true);
      } else if (typeFlag == 48 || typeFlag == 0) {
        if (size > 0) {
          await File(filePath).create(recursive: true);
          await File(filePath).writeAsBytes(
            bytes.sublist(offset, offset + size),
          );
        }
      } else if (typeFlag == 50) {
        final linkBytes = block.sublist(157, 257);
        final linkNullIndex = linkBytes.indexOf(0);
        final linkName = String.fromCharCodes(
          linkNullIndex >= 0 ? linkBytes.sublist(0, linkNullIndex) : linkBytes,
        ).trim();
        if (linkName.isNotEmpty) {
          final link = Link(filePath);
          if (await link.exists()) await link.delete();
          await link.create(linkName);
        }
      }

      offset += contentSize;
    }
  }

  Future<void> _setupDistroEnvironment(DistroInfo distro) async {
    final rootfsPath = '$_downloadDir/${distro.id}/rootfs';

    try {
      final resolvConf = File('$rootfsPath/etc/resolv.conf');
      await Directory('$rootfsPath/etc').create(recursive: true);
      await resolvConf.writeAsString('''
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
''');
    } catch (e) {
      print('DistroDownloader: Error writing resolv.conf: $e');
    }

    try {
      final profileFile = File('$rootfsPath/etc/profile.d/zion.sh');
      await profileFile.create(recursive: true);
      await profileFile.writeAsString('''
# Zion Terminal environment
export TERM=xterm-256color
export LANG=en_US.UTF-8
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH
export HOME=/root
export USER=root
''');
    } catch (e) {
      print('DistroDownloader: Error writing profile: $e');
    }

    final mountDirs = ['proc', 'sys', 'dev', 'tmp', 'sdcard'];
    for (final dir in mountDirs) {
      try {
        await Directory('$rootfsPath/$dir').create(recursive: true);
      } catch (e) {
        print('DistroDownloader: Error creating $dir: $e');
      }
    }
  }

  Future<void> verifyChecksum(String filePath, String expectedSha256) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found for checksum verification');
    }

    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    final actualHash = digest.toString();

    if (actualHash.toLowerCase() != expectedSha256.toLowerCase()) {
      throw Exception(
        'Checksum mismatch!\nExpected: $expectedSha256\nActual: $actualHash',
      );
    }

    print('DistroDownloader: Checksum verified: $actualHash');
  }

  Future<void> removeDistro(DistroInfo distro) async {
    await _init();
    final distroDir = Directory('$_downloadDir/${distro.id}');
    if (await distroDir.exists()) {
      await distroDir.delete(recursive: true);
      distro.isInstalled = false;
      _statusController.add('${distro.name} removed successfully');
    }
  }

  Future<bool> isDistroInstalled(DistroInfo distro) async {
    await _init();
    final rootfsPath = '$_downloadDir/${distro.id}/rootfs';
    final binDir = Directory('$rootfsPath/bin');
    final usrBinDir = Directory('$rootfsPath/usr/bin');
    return await binDir.exists() || await usrBinDir.exists();
  }

  List<DistroInfo> getAvailableDistros() {
    return List.unmodifiable(_availableDistros);
  }

  Future<List<DistroInfo>> listInstalledDistros() async {
    await _init();
    final installed = <DistroInfo>[];
    for (final distro in _availableDistros) {
      if (await isDistroInstalled(distro)) {
        distro.isInstalled = true;
        installed.add(distro);
      }
    }
    return installed;
  }

  Future<Map<String, dynamic>> getDistroStatus(DistroInfo distro) async {
    final installed = await isDistroInstalled(distro);
    final rootfsPath = '$_downloadDir/${distro.id}/rootfs';

    int size = 0;
    if (installed) {
      size = await _calculateDirectorySize(Directory(rootfsPath));
    }

    return {
      'distro': distro.toJson(),
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
      print('DistroDownloader: Error calculating size: $e');
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
    await _init();
    final available = getAvailableDistros();
    final installed = await listInstalledDistros();
    return {
      'downloadDir': _downloadDir,
      'availableCount': available.length,
      'installedCount': installed.length,
      'available': available.map((d) => d.toJson()).toList(),
      'installed': installed.map((d) => d.toJson()).toList(),
    };
  }

  void dispose() {
    _statusController.close();
    _progressController.close();
  }
}
