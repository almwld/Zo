import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'distro_info.dart';
import '../services/proot_manager.dart';

class DistroManager {
  static final DistroManager _instance = DistroManager._internal();
  factory DistroManager() => _instance;
  DistroManager._internal();

  late String _distrosDir;
  bool _initialized = false;

  final _statusController = StreamController<String>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  Stream<String> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;

  final List<DistroInfo> _availableDistros = DistroCatalog.getDefaultDistros();

  Future<void> _init() async {
    if (_initialized) return;
    final appDir = await getApplicationSupportDirectory();
    _distrosDir = '${appDir.path}/distros';
    await Directory(_distrosDir).create(recursive: true);
    _initialized = true;
  }

  Future<void> installDistro(DistroInfo distro) async {
    await _init();
    final distroDir = '$_distrosDir/${distro.id}';
    final rootfsPath = '$distroDir/rootfs';

    try {
      if (await isDistroInstalled(distro)) {
        _statusController.add('${distro.name} is already installed');
        return;
      }

      _statusController.add('Installing ${distro.name}...');
      _progressController.add(0.0);

      await Directory(rootfsPath).create(recursive: true);

      // Check if PRoot is available
      final prootManager = ProotManager();
      if (!await prootManager.isProotInstalled()) {
        _statusController.add('Installing PRoot...');
        await prootManager.installProot();
      }
      _progressController.add(0.1);

      // Setup environment
      await _setupDistroEnvironment(distro);
      _progressController.add(0.2);

      _statusController.add('${distro.name} installed successfully');
      _progressController.add(1.0);
      distro.isInstalled = true;

    } catch (e) {
      _statusController.add('Error installing ${distro.name}: $e');
      _progressController.addError(e);
      throw Exception('Failed to install distro: $e');
    }
  }

  Future<void> removeDistro(String distroId) async {
    await _init();
    final distroDir = Directory('$_distrosDir/$distroId');

    try {
      if (await distroDir.exists()) {
        _statusController.add('Removing $distroId...');
        await distroDir.delete(recursive: true);
        _statusController.add('$distroId removed successfully');

        // Update distro status
        final distro = _availableDistros.firstWhere(
          (d) => d.id == distroId,
          orElse: () => DistroInfo(
            id: distroId,
            name: distroId,
            description: '',
            icon: '',
            downloadUrl: '',
            sizeBytes: 0,
            architecture: '',
          ),
        );
        distro.isInstalled = false;
      } else {
        _statusController.add('$distroId is not installed');
      }
    } catch (e) {
      _statusController.add('Error removing $distroId: $e');
      throw Exception('Failed to remove distro: $e');
    }
  }

  Future<ProcessResult> loginToDistro(
    String distroId, {
    String user = 'root',
    List<String> additionalArgs = const [],
  }) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';

    if (!await Directory(rootfsPath).exists()) {
      throw Exception('Distribution $distroId is not installed');
    }

    final prootManager = ProotManager();
    final prootPath = prootManager.prootPath;

    final args = [
      '-r', rootfsPath,
      '-b', '/dev',
      '-b', '/proc',
      '-b', '/sys',
      '-b', '/sdcard',
      '-b', '/data',
      '-w', '/root',
      '-0',
      ...additionalArgs,
      '/bin/su',
      '-l',
      user,
    ];

    return await Process.run(prootPath, args);
  }

  Future<ProcessResult> executeInDistro(
    String distroId,
    String command, {
    String user = 'root',
    String? workingDirectory,
  }) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';

    if (!await Directory(rootfsPath).exists()) {
      throw Exception('Distribution $distroId is not installed');
    }

    final prootManager = ProotManager();
    final prootPath = prootManager.prootPath;

    final args = [
      '-r', rootfsPath,
      '-b', '/dev',
      '-b', '/proc',
      '-b', '/sys',
      '-b', '/sdcard',
      '-b', '/data',
      if (workingDirectory != null) ...['-w', workingDirectory],
      '-0',
      '/bin/su',
      '-l',
      user,
      '-c',
      command,
    ];

    return await Process.run(prootPath, args);
  }

  Future<Process> startShellInDistro(
    String distroId, {
    String user = 'root',
    String shell = '/bin/bash',
  }) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';

    if (!await Directory(rootfsPath).exists()) {
      throw Exception('Distribution $distroId is not installed');
    }

    final prootManager = ProotManager();
    final prootPath = prootManager.prootPath;

    final args = [
      '-r', rootfsPath,
      '-b', '/dev',
      '-b', '/proc',
      '-b', '/sys',
      '-b', '/sdcard',
      '-b', '/data',
      '-w', '/root',
      '-0',
      '/bin/su',
      '-l',
      user,
      '-s',
      shell,
    ];

    return await Process.start(prootPath, args);
  }

  Future<void> _setupDistroEnvironment(DistroInfo distro) async {
    await _init();
    final rootfsPath = '$_distrosDir/${distro.id}/rootfs';

    // Create essential directories
    final dirs = [
      'etc',
      'proc',
      'sys',
      'dev',
      'tmp',
      'root',
      'sdcard',
      'data',
      'usr/local/bin',
      'var/log',
    ];

    for (final dir in dirs) {
      try {
        await Directory('$rootfsPath/$dir').create(recursive: true);
      } catch (e) {
        print('DistroManager: Warning creating $dir: $e');
      }
    }

    // Setup resolv.conf
    try {
      final resolvConf = File('$rootfsPath/etc/resolv.conf');
      await resolvConf.writeAsString('''
# Zion Terminal - DNS Configuration
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
''');
    } catch (e) {
      print('DistroManager: Error writing resolv.conf: $e');
    }

    // Setup environment profile
    try {
      final profileFile = File('$rootfsPath/etc/profile.d/zion.sh');
      await profileFile.create(recursive: true);
      await profileFile.writeAsString('''
# Zion Terminal Environment
export TERM=xterm-256color
export LANG=en_US.UTF-8
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export USER=root
export EDITOR=nano
export PAGER=less
''');
    } catch (e) {
      print('DistroManager: Error writing profile: $e');
    }

    // Setup hosts file
    try {
      final hostsFile = File('$rootfsPath/etc/hosts');
      await hostsFile.writeAsString('''
127.0.0.1 localhost
127.0.1.1 ${distro.id}
::1 localhost ip6-localhost ip6-loopback
''');
    } catch (e) {
      print('DistroManager: Error writing hosts: $e');
    }

    // Setup hostname
    try {
      final hostnameFile = File('$rootfsPath/etc/hostname');
      await hostnameFile.writeAsString('${distro.id}\n');
    } catch (e) {
      print('DistroManager: Error writing hostname: $e');
    }

    // Setup fstab
    try {
      final fstabFile = File('$rootfsPath/etc/fstab');
      await fstabFile.writeAsString('''
# Zion Terminal - Static File System Information
proc /proc proc defaults 0 0
sysfs /sys sysfs defaults 0 0
tmpfs /tmp tmpfs defaults,size=100M 0 0
''');
    } catch (e) {
      print('DistroManager: Error writing fstab: $e');
    }

    // Setup bashrc
    try {
      final bashrcFile = File('$rootfsPath/root/.bashrc');
      await bashrcFile.create(recursive: true);
      await bashrcFile.writeAsString('''
# Zion Terminal - Bash Configuration
export PS1='\\[\\e[0;32m\\][${distro.name}]\\[\\e[0m\\] \\[\\e[0;34m\\]\\w\\[\\e[0m\\] \\\$ '

alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias h='history'
alias c='clear'

# Enable bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Zion welcome message
echo "Welcome to ${distro.name} on Zion Terminal!"
echo "Type 'help' for available commands"
''');
    } catch (e) {
      print('DistroManager: Error writing bashrc: $e');
    }
  }

  Future<bool> isDistroInstalled(String distroId) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';
    final binDir = Directory('$rootfsPath/bin');
    final usrBinDir = Directory('$rootfsPath/usr/bin');
    return await binDir.exists() || await usrBinDir.exists();
  }

  Future<bool> isDistroInstalledByInfo(DistroInfo distro) async {
    return isDistroInstalled(distro.id);
  }

  Future<List<DistroInfo>> listInstalled() async {
    await _init();
    final installed = <DistroInfo>[];

    for (final distro in _availableDistros) {
      if (await isDistroInstalled(distro.id)) {
        distro.isInstalled = true;
        installed.add(distro);
      }
    }

    return installed;
  }

  List<DistroInfo> listAvailable() {
    return List.unmodifiable(_availableDistros);
  }

  Future<List<Map<String, dynamic>>> listInstalledWithDetails() async {
    await _init();
    final installed = await listInstalled();
    final details = <Map<String, dynamic>>[];

    for (final distro in installed) {
      final info = await getDistroDetails(distro.id);
      details.add(info);
    }

    return details;
  }

  Future<Map<String, dynamic>> getDistroDetails(String distroId) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';
    final installed = await isDistroInstalled(distroId);

    int size = 0;
    String? version;
    Map<String, dynamic>? releaseInfo;

    if (installed) {
      size = await _calculateDirectorySize(Directory(rootfsPath));

      // Try to read OS release
      try {
        final osReleaseFile = File('$rootfsPath/etc/os-release');
        if (await osReleaseFile.exists()) {
          final content = await osReleaseFile.readAsString();
          releaseInfo = _parseOsRelease(content);
          version = releaseInfo['VERSION_ID'];
        }
      } catch (e) {
        print('DistroManager: Error reading os-release: $e');
      }
    }

    final distro = _availableDistros.firstWhere(
      (d) => d.id == distroId,
      orElse: () => DistroInfo(
        id: distroId,
        name: distroId,
        description: '',
        icon: '',
        downloadUrl: '',
        sizeBytes: 0,
        architecture: '',
      ),
    );

    return {
      'id': distroId,
      'name': distro.name,
      'installed': installed,
      'path': rootfsPath,
      'size': size,
      'sizeFormatted': _formatSize(size),
      'version': version ?? distro.version ?? 'Unknown',
      'releaseInfo': releaseInfo,
      'architecture': distro.architecture,
    };
  }

  Map<String, dynamic> _parseOsRelease(String content) {
    final result = <String, dynamic>{};
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          var value = parts.sublist(1).join('=').trim();
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
          result[key] = value;
        }
      }
    }

    return result;
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
      print('DistroManager: Error calculating size: $e');
    }
    return total;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> backupDistro(String distroId, String backupPath) async {
    await _init();
    final rootfsPath = '$_distrosDir/$distroId/rootfs';

    if (!await Directory(rootfsPath).exists()) {
      throw Exception('Distribution $distroId is not installed');
    }

    _statusController.add('Creating backup of $distroId...');

    try {
      final result = await Process.run(
        'tar',
        ['-czf', backupPath, '-C', '$_distrosDir/$distroId', 'rootfs'],
      );

      if (result.exitCode == 0) {
        _statusController.add('Backup created: $backupPath');
      } else {
        throw Exception('tar failed: ${result.stderr}');
      }
    } catch (e) {
      _statusController.add('Backup failed: $e');
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<void> restoreDistro(String distroId, String backupPath) async {
    await _init();
    final distroDir = '$_distrosDir/$distroId';

    if (!await File(backupPath).exists()) {
      throw Exception('Backup file not found: $backupPath');
    }

    _statusController.add('Restoring $distroId from backup...');

    try {
      await Directory(distroDir).create(recursive: true);

      final result = await Process.run(
        'tar',
        ['-xzf', backupPath, '-C', distroDir],
      );

      if (result.exitCode == 0) {
        _statusController.add('$distroId restored successfully');
      } else {
        throw Exception('tar failed: ${result.stderr}');
      }
    } catch (e) {
      _statusController.add('Restore failed: $e');
      throw Exception('Failed to restore distro: $e');
    }
  }

  Future<void> cloneDistro(String sourceId, String targetId) async {
    await _init();
    final sourcePath = '$_distrosDir/$sourceId/rootfs';
    final targetPath = '$_distrosDir/$targetId/rootfs';

    if (!await Directory(sourcePath).exists()) {
      throw Exception('Source distribution $sourceId is not installed');
    }

    _statusController.add('Cloning $sourceId to $targetId...');

    try {
      await Directory(targetPath).create(recursive: true);

      final result = await Process.run(
        'cp',
        ['-a', '$sourcePath/.', targetPath],
      );

      if (result.exitCode == 0) {
        _statusController.add('Clone completed');
      } else {
        throw Exception('cp failed: ${result.stderr}');
      }
    } catch (e) {
      _statusController.add('Clone failed: $e');
      throw Exception('Failed to clone distro: $e');
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    await _init();
    final available = listAvailable();
    final installed = await listInstalled();

    int totalSize = 0;
    for (final distro in installed) {
      final details = await getDistroDetails(distro.id);
      totalSize += (details['size'] as int?) ?? 0;
    }

    return {
      'distrosDir': _distrosDir,
      'availableCount': available.length,
      'installedCount': installed.length,
      'totalSize': totalSize,
      'totalSizeFormatted': _formatSize(totalSize),
      'available': available.map((d) => d.toJson()).toList(),
      'installed': installed.map((d) => d.toJson()).toList(),
    };
  }

  void dispose() {
    _statusController.close();
    _progressController.close();
  }
}
