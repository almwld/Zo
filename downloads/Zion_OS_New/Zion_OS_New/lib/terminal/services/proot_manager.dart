import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ProotManager {
  static final ProotManager _instance = ProotManager._internal();
  factory ProotManager() => _instance;
  ProotManager._internal();

  late String _prootPath;
  late String _prootDir;
  bool _initialized = false;

  String get prootPath => _prootPath;
  String get prootDir => _prootDir;

  Future<void> _init() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    _prootDir = '${appDir.path}/bin';
    _prootPath = '$_prootDir/proot';
    await Directory(_prootDir).create(recursive: true);
    _initialized = true;
  }

  Future<bool> isProotInstalled() async {
    await _init();
    final prootFile = File(_prootPath);
    return await prootFile.exists() && await prootFile.length() > 1000;
  }

  Future<bool> installProot() async {
    await _init();
    try {
      if (await isProotInstalled()) return true;

      final String assetName = _getProotAssetName();
      final ByteData data = await rootBundle.load('assets/binaries/$assetName');
      final Uint8List bytes = data.buffer.asUint8List();

      await File(_prootPath).writeAsBytes(bytes);
      await Process.run('chmod', ['755', _prootPath]);

      return await isProotInstalled();
    } catch (e) {
      print('ProotManager: Error installing PRoot: $e');
      return false;
    }
  }

  Future<void> extractProot() async {
    await _init();
    try {
      if (await isProotInstalled()) return;

      final String assetName = _getProotAssetName();
      final ByteData data = await rootBundle.load('assets/binaries/$assetName');
      final Uint8List bytes = data.buffer.asUint8List();

      final file = File(_prootPath);
      await file.writeAsBytes(bytes);
      await Process.run('chmod', ['755', _prootPath]);

      print('ProotManager: PRoot extracted to $_prootPath');
    } catch (e) {
      print('ProotManager: Error extracting PRoot: $e');
      throw Exception('Failed to extract PRoot: $e');
    }
  }

  Future<bool> uninstallProot() async {
    await _init();
    try {
      final prootFile = File(_prootPath);
      if (await prootFile.exists()) {
        await prootFile.delete();
      }
      return !(await isProotInstalled());
    } catch (e) {
      print('ProotManager: Error uninstalling PRoot: $e');
      return false;
    }
  }

  Future<String> getProotVersion() async {
    if (!await isProotInstalled()) return 'Not installed';
    try {
      final result = await Process.run(_prootPath, ['--version']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
      return 'Unknown';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _getProotAssetName() {
    final cpuArch = Platform.resolvedExecutable.contains('arm64')
        ? 'aarch64'
        : Platform.resolvedExecutable.contains('arm')
            ? 'arm'
            : Platform.resolvedExecutable.contains('x86_64')
                ? 'x86_64'
                : 'i686';
    return 'proot-$cpuArch';
  }

  Future<Map<String, dynamic>> getStatus() async {
    final installed = await isProotInstalled();
    final version = installed ? await getProotVersion() : 'Not installed';
    return {
      'installed': installed,
      'version': version,
      'path': _prootPath,
    };
  }
}
