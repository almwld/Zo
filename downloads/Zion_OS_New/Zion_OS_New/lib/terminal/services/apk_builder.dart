import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ApkBuilder {
  static final ApkBuilder _instance = ApkBuilder._internal();
  factory ApkBuilder() => _instance;
  ApkBuilder._internal();

  final List<String> _supportedArchitectures = [
    'arm64-v8a',
    'armeabi-v7a',
    'x86_64',
    'x86',
  ];

  final Map<String, String> _abiMapping = {
    'arm64-v8a': 'aarch64',
    'armeabi-v7a': 'arm',
    'x86_64': 'x86_64',
    'x86': 'i686',
  };

  Future<List<String>> getAvailableArchitectures() async {
    final result = <String>[];
    for (final abi in _supportedArchitectures) {
      result.add('$abi (${_abiMapping[abi]})');
    }
    return result;
  }

  Future<List<String>> getProjectArchitectures() async {
    final appDir = await getApplicationSupportDirectory();
    final jniDir = Directory('${appDir.parent.path}/android/app/src/main/jniLibs');

    if (!await jniDir.exists()) return [];

    final archs = <String>[];
    await for (final entity in jniDir.list()) {
      if (entity is Directory) {
        final name = path.basename(entity.path);
        if (_supportedArchitectures.contains(name)) {
          archs.add(name);
        }
      }
    }
    return archs;
  }

  Future<String> buildApk({bool release = true}) async {
    try {
      print('ApkBuilder: Starting ${release ? 'release' : 'debug'} build...');

      final projectDir = await _getProjectRoot();

      final buildArgs = [
        'assemble${release ? 'Release' : 'Debug'}',
      ];

      final result = await Process.run(
        './gradlew',
        buildArgs,
        workingDirectory: '$projectDir/android',
        environment: {
          ...Platform.environment,
          'JAVA_HOME': await _findJavaHome(),
          'ANDROID_HOME': await _findAndroidSdk(),
        },
      );

      if (result.exitCode != 0) {
        throw Exception(
          'Gradle build failed with exit code ${result.exitCode}:\n${result.stderr}',
        );
      }

      final buildType = release ? 'release' : 'debug';
      final apkDir = Directory(
        '$projectDir/android/app/build/outputs/apk/$buildType',
      );

      final apkFiles = await apkDir
          .list()
          .where((f) => f is File && f.path.endsWith('.apk'))
          .toList();

      if (apkFiles.isEmpty) {
        throw Exception('No APK file found after build');
      }

      final apkPath = apkFiles.first.path;
      final size = await getApkSize(apkPath);
      print('ApkBuilder: Build successful!');
      print('ApkBuilder: APK: $apkPath');
      print('ApkBuilder: Size: ${_formatSize(size)}');

      return apkPath;
    } catch (e) {
      print('ApkBuilder: Build failed: $e');
      throw Exception('APK build failed: $e');
    }
  }

  Future<String> buildSplitApks({bool release = true}) async {
    try {
      print('ApkBuilder: Starting split APK build...');

      final projectDir = await _getProjectRoot();
      final buildType = release ? 'Release' : 'Debug';

      final result = await Process.run(
        './gradlew',
        ['assemble${buildType}Splits'],
        workingDirectory: '$projectDir/android',
        environment: {
          ...Platform.environment,
          'JAVA_HOME': await _findJavaHome(),
          'ANDROID_HOME': await _findAndroidSdk(),
        },
      );

      if (result.exitCode != 0) {
        throw Exception(
          'Split APK build failed: ${result.stderr}',
        );
      }

      final outputDir =
          '$projectDir/android/app/build/outputs/apk/${release ? 'release' : 'debug'}';
      return outputDir;
    } catch (e) {
      print('ApkBuilder: Split build failed: $e');
      throw Exception('Split APK build failed: $e');
    }
  }

  Future<String> buildAppBundle({bool release = true}) async {
    try {
      print('ApkBuilder: Starting App Bundle build...');

      final projectDir = await _getProjectRoot();

      final result = await Process.run(
        './gradlew',
        ['bundle${release ? 'Release' : 'Debug'}'],
        workingDirectory: '$projectDir/android',
        environment: {
          ...Platform.environment,
          'JAVA_HOME': await _findJavaHome(),
          'ANDROID_HOME': await _findAndroidSdk(),
        },
      );

      if (result.exitCode != 0) {
        throw Exception('Bundle build failed: ${result.stderr}');
      }

      final buildType = release ? 'release' : 'debug';
      final aabPath =
          '$projectDir/android/app/build/outputs/bundle/$buildType/app-$buildType.aab';

      if (!await File(aabPath).exists()) {
        throw Exception('AAB file not found: $aabPath');
      }

      final size = await getApkSize(aabPath);
      print('ApkBuilder: Bundle build successful!');
      print('ApkBuilder: AAB: $aabPath');
      print('ApkBuilder: Size: ${_formatSize(size)}');

      return aabPath;
    } catch (e) {
      print('ApkBuilder: Bundle build failed: $e');
      throw Exception('App Bundle build failed: $e');
    }
  }

  Future<int> getApkSize([String? apkPath]) async {
    if (apkPath == null) {
      final projectDir = await _getProjectRoot();
      final defaultPath =
          '$projectDir/android/app/build/outputs/apk/release/app-release.apk';
      apkPath = defaultPath;
    }

    final file = File(apkPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<Map<String, int>> getApkSizesByAbi({bool release = true}) async {
    final projectDir = await _getProjectRoot();
    final buildType = release ? 'release' : 'debug';
    final outputDir =
        Directory('$projectDir/android/app/build/outputs/apk/$buildType');

    final sizes = <String, int>{};

    if (await outputDir.exists()) {
      await for (final entity in outputDir.list()) {
        if (entity is File && entity.path.endsWith('.apk')) {
          final fileName = path.basename(entity.path);
          final size = await entity.length();
          sizes[fileName] = size;
        }
      }
    }

    return sizes;
  }

  Future<String> _getProjectRoot() async {
    final appDir = await getApplicationSupportDirectory();
    return appDir.parent.path;
  }

  Future<String> _findJavaHome() async {
    final javaHome = Platform.environment['JAVA_HOME'];
    if (javaHome != null && javaHome.isNotEmpty) return javaHome;

    final candidates = [
      '/usr/lib/jvm/java-17-openjdk',
      '/usr/lib/jvm/java-11-openjdk',
      '/usr/lib/jvm/java-17-openjdk-amd64',
      '/usr/lib/jvm/java-11-openjdk-amd64',
      '/opt/android-studio/jbr',
      '/Applications/Android Studio.app/Contents/jbr/Contents/Home',
    ];

    for (final candidate in candidates) {
      if (await Directory(candidate).exists()) {
        return candidate;
      }
    }

    try {
      final result = await Process.run('which', ['javac']);
      if (result.exitCode == 0) {
        final javaPath = result.stdout.toString().trim();
        final link = await File(javaPath).resolveSymbolicLinks();
        return path.normalize(path.join(link, '..', '..'));
      }
    } catch (_) {}

    return '/usr/lib/jvm/default-java';
  }

  Future<String> _findAndroidSdk() async {
    final androidHome = Platform.environment['ANDROID_HOME'];
    if (androidHome != null && androidHome.isNotEmpty) return androidHome;

    final androidSdk = Platform.environment['ANDROID_SDK'];
    if (androidSdk != null && androidSdk.isNotEmpty) return androidSdk;

    final candidates = [
      '${Platform.environment['HOME']}/Android/Sdk',
      '${Platform.environment['HOME']}/android-sdk',
      '/opt/android-sdk',
      '/usr/local/android-sdk',
      '/Applications/Android Studio.app/sdk',
    ];

    for (final candidate in candidates) {
      if (await Directory(candidate).exists()) {
        return candidate;
      }
    }

    return '${Platform.environment['HOME']}/Android/Sdk';
  }

  Future<Map<String, dynamic>> getBuildInfo() async {
    final projectDir = await _getProjectRoot();
    final gradleFile = File('$projectDir/android/app/build.gradle');

    String? versionName;
    int? versionCode;
    String? applicationId;
    String? minSdk;
    String? targetSdk;
    String? compileSdk;

    if (await gradleFile.exists()) {
      final content = await gradleFile.readAsString();

      final versionNameMatch =
          RegExp(r'versionName\s+"([^"]+)"').firstMatch(content);
      versionName = versionNameMatch?.group(1);

      final versionCodeMatch =
          RegExp(r'versionCode\s+(\d+)').firstMatch(content);
      versionCode = int.tryParse(versionCodeMatch?.group(1) ?? '0');

      final appIdMatch =
          RegExp(r'applicationId\s+"([^"]+)"').firstMatch(content);
      applicationId = appIdMatch?.group(1);

      final minSdkMatch = RegExp(r'minSdk\s+(\d+)').firstMatch(content);
      minSdk = minSdkMatch?.group(1);

      final targetSdkMatch =
          RegExp(r'targetSdk\s+(\d+)').firstMatch(content);
      targetSdk = targetSdkMatch?.group(1);

      final compileSdkMatch =
          RegExp(r'compileSdk\s+(\d+)').firstMatch(content);
      compileSdk = compileSdkMatch?.group(1);
    }

    final architectures = await getAvailableArchitectures();
    final projectArchs = await getProjectArchitectures();

    return {
      'projectDir': projectDir,
      'versionName': versionName ?? 'unknown',
      'versionCode': versionCode ?? 0,
      'applicationId': applicationId ?? 'com.zion.terminal',
      'minSdk': minSdk ?? '24',
      'targetSdk': targetSdk ?? '34',
      'compileSdk': compileSdk ?? '34',
      'supportedArchitectures': architectures,
      'includedArchitectures': projectArchs,
    };
  }

  Future<void> cleanBuild() async {
    try {
      final projectDir = await _getProjectRoot();
      final result = await Process.run(
        './gradlew',
        ['clean'],
        workingDirectory: '$projectDir/android',
        environment: {
          ...Platform.environment,
          'JAVA_HOME': await _findJavaHome(),
          'ANDROID_HOME': await _findAndroidSdk(),
        },
      );

      if (result.exitCode != 0) {
        throw Exception('Clean failed: ${result.stderr}');
      }

      print('ApkBuilder: Build cleaned successfully');
    } catch (e) {
      print('ApkBuilder: Clean failed: $e');
      throw Exception('Build clean failed: $e');
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<Map<String, dynamic>> getStatus() async {
    final buildInfo = await getBuildInfo();
    final apkSize = await getApkSize();
    final apkSizes = await getApkSizesByAbi();

    return {
      ...buildInfo,
      'currentApkSize': apkSize,
      'currentApkSizeFormatted': _formatSize(apkSize),
      'apkSizesByAbi': apkSizes.map(
        (key, value) => MapEntry(key, _formatSize(value)),
      ),
    };
  }
}
