import 'dart:async';
import 'dart:io';
import 'dart:convert';

class PackageInfo {
  final String name;
  final String version;
  final String description;
  final String architecture;
  final String section;
  final String maintainer;
  final int installedSize;
  final String homepage;
  final bool isInstalled;
  final String? status;
  final List<String> dependencies;
  final List<String> reverseDependencies;
  final DateTime? installDate;

  PackageInfo({
    required this.name,
    required this.version,
    this.description = '',
    this.architecture = '',
    this.section = '',
    this.maintainer = '',
    this.installedSize = 0,
    this.homepage = '',
    this.isInstalled = false,
    this.status,
    this.dependencies = const [],
    this.reverseDependencies = const [],
    this.installDate,
  });

  factory PackageInfo.fromDpkgStatus(String block) {
    final lines = block.split('\n');
    final map = <String, String>{};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          map[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      }
    }

    return PackageInfo(
      name: map['Package'] ?? 'unknown',
      version: map['Version'] ?? '',
      description: map['Description'] ?? '',
      architecture: map['Architecture'] ?? '',
      section: map['Section'] ?? '',
      maintainer: map['Maintainer'] ?? '',
      installedSize: int.tryParse(map['Installed-Size'] ?? '0') ?? 0,
      homepage: map['Homepage'] ?? '',
      isInstalled: (map['Status'] ?? '').contains('installed'),
      status: map['Status'],
      dependencies: _parseDependencies(map['Depends'] ?? ''),
    );
  }

  factory PackageInfo.fromAptShow(String output) {
    final lines = output.split('\n');
    final map = <String, String>{};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          map[parts[0].trim()] = parts.sublist(1).join(':').trim();
        }
      }
    }

    return PackageInfo(
      name: map['Package'] ?? 'unknown',
      version: map['Version'] ?? '',
      description: map['Description'] ?? '',
      architecture: map['Architecture'] ?? '',
      section: map['Section'] ?? '',
      maintainer: map['Maintainer'] ?? '',
      homepage: map['Homepage'] ?? '',
      isInstalled: (map['Status'] ?? '').contains('installed'),
      dependencies: _parseDependencies(map['Depends'] ?? ''),
    );
  }

  static List<String> _parseDependencies(String deps) {
    if (deps.isEmpty) return [];
    return deps
        .split(',')
        .map((d) => d.trim().split(' ').first)
        .where((d) => d.isNotEmpty)
        .toList();
  }

  String get installedSizeFormatted {
    if (installedSize < 1024) return '${installedSize} KB';
    if (installedSize < 1024 * 1024) return '${(installedSize / 1024).toStringAsFixed(1)} MB';
    return '${(installedSize / (1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'version': version,
    'description': description,
    'architecture': architecture,
    'section': section,
    'maintainer': maintainer,
    'installedSize': installedSize,
    'homepage': homepage,
    'isInstalled': isInstalled,
    'status': status,
    'dependencies': dependencies,
  };

  @override
  String toString() => 'PackageInfo($name $version)';
}

class PackageManager {
  static final PackageManager _instance = PackageManager._internal();
  factory PackageManager() => _instance;
  PackageManager._internal();

  String _packageManager = 'apt';
  String? _rootfsPath;
  bool _useProot = false;

  final _progressController = StreamController<String>.broadcast();
  Stream<String> get progressStream => _progressController.stream;

  void configure({String? rootfsPath, bool useProot = false}) {
    _rootfsPath = rootfsPath;
    _useProot = useProot;
    _detectPackageManager();
  }

  void _detectPackageManager() {
    final packageManagers = ['apt', 'apt-get', 'pacman', 'dnf', 'yum', 'apk', 'zypper'];

    if (_rootfsPath != null) {
      for (final pm in packageManagers) {
        final binPath = '$_rootfsPath/usr/bin/$pm';
        if (File(binPath).existsSync()) {
          _packageManager = pm;
          return;
        }
      }
    }

    _packageManager = 'apt';
  }

  List<String> _buildCommand(String subcommand, [List<String> args = const []]) {
    final cmd = <String>[];

    if (_useProot && _rootfsPath != null) {
      cmd.add('proot');
      cmd.add('-r');
      cmd.add(_rootfsPath!);
      cmd.add('-b');
      cmd.add('/dev');
      cmd.add('-b');
      cmd.add('/proc');
      cmd.add('-b');
      cmd.add('/sys');
      cmd.add('-b');
      cmd.add('/sdcard');
    }

    cmd.add(_packageManager);
    cmd.add(subcommand);
    cmd.addAll(args);

    if (_packageManager == 'apt' || _packageManager == 'apt-get') {
      cmd.add('-y');
    }

    return cmd;
  }

  Future<bool> aptUpdate() async {
    _progressController.add('Updating package lists...');

    try {
      final result = await Process.run(
        _buildCommand('update').first,
        _buildCommand('update').sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('Package lists updated successfully');
        return true;
      } else {
        _progressController.add('Update failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error during update: $e');
      return false;
    }
  }

  Future<bool> aptUpgrade() async {
    _progressController.add('Upgrading packages...');

    try {
      final result = await Process.run(
        _buildCommand('upgrade').first,
        _buildCommand('upgrade').sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('Packages upgraded successfully');
        return true;
      } else {
        _progressController.add('Upgrade failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error during upgrade: $e');
      return false;
    }
  }

  Future<bool> aptInstall(String package) async {
    _progressController.add('Installing $package...');

    try {
      final result = await Process.run(
        _buildCommand('install', [package]).first,
        _buildCommand('install', [package]).sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('$package installed successfully');
        return true;
      } else {
        _progressController.add('Failed to install $package: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error installing $package: $e');
      return false;
    }
  }

  Future<bool> aptInstallMultiple(List<String> packages) async {
    if (packages.isEmpty) return true;

    _progressController.add('Installing ${packages.length} packages...');

    try {
      final result = await Process.run(
        _buildCommand('install', packages).first,
        _buildCommand('install', packages).sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('All packages installed successfully');
        return true;
      } else {
        _progressController.add('Installation failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error during installation: $e');
      return false;
    }
  }

  Future<bool> aptRemove(String package) async {
    _progressController.add('Removing $package...');

    try {
      final result = await Process.run(
        _buildCommand('remove', [package]).first,
        _buildCommand('remove', [package]).sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('$package removed successfully');
        return true;
      } else {
        _progressController.add('Failed to remove $package: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error removing $package: $e');
      return false;
    }
  }

  Future<bool> aptPurge(String package) async {
    _progressController.add('Purging $package (including configuration)...');

    try {
      final result = await Process.run(
        _buildCommand('purge', [package]).first,
        _buildCommand('purge', [package]).sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('$package purged successfully');
        return true;
      } else {
        _progressController.add('Failed to purge $package: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error purging $package: $e');
      return false;
    }
  }

  Future<bool> aptAutoremove() async {
    _progressController.add('Removing unused packages...');

    try {
      final result = await Process.run(
        _buildCommand('autoremove').first,
        _buildCommand('autoremove').sublist(1),
        environment: {
          'DEBIAN_FRONTEND': 'noninteractive',
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        _progressController.add('Unused packages removed');
        return true;
      } else {
        _progressController.add('Autoremove failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _progressController.add('Error during autoremove: $e');
      return false;
    }
  }

  Future<bool> aptClean() async {
    try {
      final result = await Process.run(
        _buildCommand('clean').first,
        _buildCommand('clean').sublist(1),
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> aptSearch(String query) async {
    _progressController.add('Searching for "$query"...');

    try {
      final result = await Process.run(
        _packageManager,
        ['search', query],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final packages = <String>[];

        for (final line in lines) {
          if (line.contains('/')) {
            final packageName = line.split('/').first.trim();
            if (packageName.isNotEmpty) {
              packages.add(packageName);
            }
          }
        }

        _progressController.add('Found ${packages.length} packages');
        return packages;
      } else {
        _progressController.add('Search failed: ${result.stderr}');
        return [];
      }
    } catch (e) {
      _progressController.add('Error searching: $e');
      return [];
    }
  }

  Future<PackageInfo?> aptShow(String package) async {
    try {
      final result = await Process.run(
        _packageManager,
        ['show', package],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        return PackageInfo.fromAptShow(result.stdout as String);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<PackageInfo>> listInstalled() async {
    _progressController.add('Listing installed packages...');

    try {
      final result = await Process.run(
        'dpkg-query',
        ['-l'],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final packages = <PackageInfo>[];

        for (final line in lines) {
          if (line.startsWith('ii ')) {
            final parts = line.split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              packages.add(PackageInfo(
                name: parts[1],
                version: parts[2],
                isInstalled: true,
                status: 'installed',
              ));
            }
          }
        }

        _progressController.add('Found ${packages.length} installed packages');
        return packages;
      } else {
        _progressController.add('Failed to list packages: ${result.stderr}');
        return [];
      }
    } catch (e) {
      _progressController.add('Error listing packages: $e');
      return [];
    }
  }

  Future<List<PackageInfo>> listUpgradable() async {
    try {
      final result = await Process.run(
        _packageManager,
        ['list', '--upgradable'],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final packages = <PackageInfo>[];

        for (final line in lines) {
          if (line.contains('/') && line.contains('[')) {
            final parts = line.split(RegExp(r'\s+'));
            if (parts.isNotEmpty) {
              final name = parts.first.split('/').first;
              packages.add(PackageInfo(
                name: name,
                version: parts.length > 1 ? parts[1] : '',
                isInstalled: true,
              ));
            }
          }
        }

        return packages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> isPackageInstalled(String package) async {
    try {
      final result = await Process.run(
        'dpkg-query',
        ['-W', '-f=\${Status}', package],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      return result.exitCode == 0 &&
          (result.stdout as String).contains('installed');
    } catch (e) {
      return false;
    }
  }

  Future<String> getPackageVersion(String package) async {
    try {
      final result = await Process.run(
        'dpkg-query',
        ['-W', '-f=\${Version}', package],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  Future<int> getInstalledPackageCount() async {
    final packages = await listInstalled();
    return packages.length;
  }

  Future<int> getUpgradablePackageCount() async {
    final packages = await listUpgradable();
    return packages.length;
  }

  Future<String> getDiskUsage() async {
    try {
      final result = await Process.run(
        'df',
        ['-h', '/'],
        environment: {
          'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        },
      );

      if (result.exitCode == 0) {
        return result.stdout as String;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    final installed = await getInstalledPackageCount();
    final upgradable = await getUpgradablePackageCount();
    final diskUsage = await getDiskUsage();

    return {
      'packageManager': _packageManager,
      'rootfsPath': _rootfsPath,
      'useProot': _useProot,
      'installedPackages': installed,
      'upgradablePackages': upgradable,
      'diskUsage': diskUsage,
    };
  }

  void dispose() {
    _progressController.close();
  }
}
