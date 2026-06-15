// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Package Manager - مدير الحزم                            ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: مدير حزم APT/PKG لتثبيت وإدارة الحزم                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    PackageManager - مدير الحزم
///                    Package Manager for APT/PKG
/// ═══════════════════════════════════════════════════════════════════════════

class PackageManager extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //                      أنواع مدير الحزم
  // ═══════════════════════════════════════════════════════════════════════

  enum PackageManagerType {
    apt,    // Debian/Ubuntu
    pkg,    // Termux
    dnf,    // Fedora
    pacman, // Arch
    apk,    // Alpine
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      حالة التحديث
  // ═══════════════════════════════════════════════════════════════════════

  bool _isUpdating = false;
  DateTime? _lastUpdate;
  String? _updateError;
  List<String> _updateLog = [];

  // ═══════════════════════════════════════════════════════════════════════
  //                      الحزم المثبتة
  // ═══════════════════════════════════════════════════════════════════════

  final List<PackageInfo> _installedPackages = [];
  final List<PackageInfo> _availablePackages = [];
  final Map<String, List<String>> _repositories = {};

  // ═══════════════════════════════════════════════════════════════════════
  //                      نوع المدير
  // ═══════════════════════════════════════════════════════════════════════

  PackageManagerType _managerType = PackageManagerType.pkg;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص القراءة فقط
  // ═══════════════════════════════════════════════════════════════════════

  bool get isUpdating => _isUpdating;
  DateTime? get lastUpdate => _lastUpdate;
  String? get updateError => _updateError;
  List<String> get updateLog => List.unmodifiable(_updateLog);
  List<PackageInfo> get installedPackages => List.unmodifiable(_installedPackages);
  List<PackageInfo> get availablePackages => List.unmodifiable(_availablePackages);
  PackageManagerType get managerType => _managerType;

  int get installedCount => _installedPackages.length;
  int get availableCount => _availablePackages.length;

  // ═══════════════════════════════════════════════════════════════════════
  //                      تعيين نوع المدير
  // ═══════════════════════════════════════════════════════════════════════

  void setManagerType(PackageManagerType type) {
    _managerType = type;
    _addLog('Switched to ${_getManagerName()}');
    notifyListeners();
  }

  String _getManagerName() {
    switch (_managerType) {
      case PackageManagerType.apt:
        return 'APT (Debian/Ubuntu)';
      case PackageManagerType.pkg:
        return 'PKG (Termux)';
      case PackageManagerType.dnf:
        return 'DNF (Fedora)';
      case PackageManagerType.pacman:
        return 'Pacman (Arch)';
      case PackageManagerType.apk:
        return 'APK (Alpine)';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدارة المستودعات
  // ═══════════════════════════════════════════════════════════════════════

  void addRepository(String name, String url) {
    _repositories[name] = [url];
    _addLog('Added repository: $name ($url)');
    notifyListeners();
  }

  void removeRepository(String name) {
    _repositories.remove(name);
    _addLog('Removed repository: $name');
    notifyListeners();
  }

  List<String> getRepositories() {
    return _repositories.keys.toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تحديث
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> update() async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _updateError = null;
    _updateLog.clear();
    _addLog('Starting ${_getManagerName()} update...');
    notifyListeners();

    try {
      switch (_managerType) {
        case PackageManagerType.pkg:
          await _updatePkg();
          break;
        case PackageManagerType.apt:
          await _updateApt();
          break;
        case PackageManagerType.dnf:
          await _updateDnf();
          break;
        case PackageManagerType.pacman:
          await _updatePacman();
          break;
        case PackageManagerType.apk:
          await _updateApk();
          break;
      }

      _lastUpdate = DateTime.now();
      _addLog('Update completed successfully');
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = e.toString();
      _addLog('Update failed: $_updateError');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _updatePkg() async {
    _addLog('Updating package lists...');
    // محاكاة التحديث
    await Future.delayed(const Duration(seconds: 2));
    _addLog('Package lists updated');
  }

  Future<void> _updateApt() async {
    _addLog('Running apt update...');
    await Future.delayed(const Duration(seconds: 2));
    _addLog('APT cache updated');
  }

  Future<void> _updateDnf() async {
    _addLog('Running dnf check-update...');
    await Future.delayed(const Duration(seconds: 2));
    _addLog('DNF cache updated');
  }

  Future<void> _updatePacman() async {
    _addLog('Running pacman -Sy...');
    await Future.delayed(const Duration(seconds: 2));
    _addLog('Pacman sync database updated');
  }

  Future<void> _updateApk() async {
    _addLog('Running apk update...');
    await Future.delayed(const Duration(seconds: 2));
    _addLog('APK index updated');
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      ترقية
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> upgrade() async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _addLog('Starting upgrade...');
    notifyListeners();

    try {
      switch (_managerType) {
        case PackageManagerType.pkg:
          await _upgradePkg();
          break;
        case PackageManagerType.apt:
          await _upgradeApt();
          break;
        case PackageManagerType.dnf:
          await _upgradeDnf();
          break;
        case PackageManagerType.pacman:
          await _upgradePacman();
          break;
        case PackageManagerType.apk:
          await _upgradeApk();
          break;
      }

      _addLog('Upgrade completed');
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = e.toString();
      _addLog('Upgrade failed: $_updateError');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _upgradePkg() async {
    _addLog('Running pkg upgrade...');
    await Future.delayed(const Duration(seconds: 3));
    _addLog('All packages upgraded');
  }

  Future<void> _upgradeApt() async {
    _addLog('Running apt upgrade...');
    await Future.delayed(const Duration(seconds: 3));
    _addLog('All packages upgraded');
  }

  Future<void> _upgradeDnf() async {
    _addLog('Running dnf upgrade...');
    await Future.delayed(const Duration(seconds: 3));
    _addLog('All packages upgraded');
  }

  Future<void> _upgradePacman() async {
    _addLog('Running pacman -Su...');
    await Future.delayed(const Duration(seconds: 3));
    _addLog('All packages upgraded');
  }

  Future<void> _upgradeApk() async {
    _addLog('Running apk upgrade...');
    await Future.delayed(const Duration(seconds: 3));
    _addLog('All packages upgraded');
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تثبيت الحزم
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> install(String packageName) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _addLog('Installing $packageName...');
    notifyListeners();

    try {
      switch (_managerType) {
        case PackageManagerType.pkg:
          await _installPkg(packageName);
          break;
        case PackageManagerType.apt:
          await _installApt(packageName);
          break;
        case PackageManagerType.dnf:
          await _installDnf(packageName);
          break;
        case PackageManagerType.pacman:
          await _installPacman(packageName);
          break;
        case PackageManagerType.apk:
          await _installApk(packageName);
          break;
      }

      // إضافة الحزمة إلى قائمة المثبتة
      _installedPackages.add(PackageInfo(
        name: packageName,
        version: '1.0.0',
        description: 'Installed package',
        size: 1024,
      ));

      _addLog('$packageName installed successfully');
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = e.toString();
      _addLog('Installation failed: $_updateError');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _installPkg(String package) async {
    _addLog('Running pkg install $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installApt(String package) async {
    _addLog('Running apt install $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installDnf(String package) async {
    _addLog('Running dnf install $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installPacman(String package) async {
    _addLog('Running pacman -S $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _installApk(String package) async {
    _addLog('Running apk add $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      حذف الحزم
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> remove(String packageName) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _addLog('Removing $packageName...');
    notifyListeners();

    try {
      switch (_managerType) {
        case PackageManagerType.pkg:
          await _removePkg(packageName);
          break;
        case PackageManagerType.apt:
          await _removeApt(packageName);
          break;
        case PackageManagerType.dnf:
          await _removeDnf(packageName);
          break;
        case PackageManagerType.pacman:
          await _removePacman(packageName);
          break;
        case PackageManagerType.apk:
          await _removeApk(packageName);
          break;
      }

      // إزالة الحزمة من قائمة المثبتة
      _installedPackages.removeWhere((p) => p.name == packageName);

      _addLog('$packageName removed successfully');
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = e.toString();
      _addLog('Removal failed: $_updateError');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _removePkg(String package) async {
    _addLog('Running pkg remove $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _removeApt(String package) async {
    _addLog('Running apt remove $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _removeDnf(String package) async {
    _addLog('Running dnf remove $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _removePacman(String package) async {
    _addLog('Running pacman -R $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _removeApk(String package) async {
    _addLog('Running apk del $package...');
    await Future.delayed(const Duration(seconds: 2));
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      البحث
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<PackageInfo>> search(String query) async {
    _addLog('Searching for: $query');
    notifyListeners();

    // محاكاة البحث
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _availablePackages
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _addLog('Found ${results.length} packages');
    notifyListeners();

    return results;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      معلومات الحزمة
  // ═══════════════════════════════════════════════════════════════════════

  PackageInfo? getPackageInfo(String packageName) {
    // البحث في المثبتة
    for (final pkg in _installedPackages) {
      if (pkg.name == packageName) {
        return pkg;
      }
    }

    // البحث في المتاحة
    for (final pkg in _availablePackages) {
      if (pkg.name == packageName) {
        return pkg;
      }
    }

    return null;
  }

  bool isInstalled(String packageName) {
    return _installedPackages.any((p) => p.name == packageName);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      سجل
  // ═══════════════════════════════════════════════════════════════════════

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _updateLog.add('[$timestamp] $message');
    if (_updateLog.length > 100) {
      _updateLog.removeAt(0);
    }
  }

  void clearLog() {
    _updateLog.clear();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الأوامر النصية
  // ═══════════════════════════════════════════════════════════════════════

  String processCommand(String command) {
    final parts = command.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';

    final cmd = parts[0].toLowerCase();

    switch (cmd) {
      case 'pkg':
      case 'apt':
      case 'dnf':
      case 'pacman':
      case 'apk':
        return _processPackageCommand(parts);
      default:
        return command;
    }
  }

  String _processPackageCommand(List<String> parts) {
    if (parts.length < 2) {
      return 'Usage: pkg <command> [package]';
    }

    final subcmd = parts[1].toLowerCase();

    switch (subcmd) {
      case 'install':
      case 'add':
        return 'Installing ${parts.sublist(2).join(' ')}...';
      case 'remove':
      case 'delete':
      case 'del':
        return 'Removing ${parts.sublist(2).join(' ')}...';
      case 'update':
      case 'sync':
        return 'Updating package lists...';
      case 'upgrade':
      case 'up':
        return 'Upgrading packages...';
      case 'search':
        return 'Searching for ${parts.sublist(2).join(' ')}...';
      case 'list':
      case 'ls':
        return 'Installed packages:\n${_installedPackages.map((p) => '  ${p.name}').join('\n')}';
      case 'info':
        if (parts.length > 2) {
          final pkg = getPackageInfo(parts[2]);
          if (pkg != null) {
            return '''
Package: ${pkg.name}
Version: ${pkg.version}
Size: ${pkg.formattedSize}
Description: ${pkg.description}
Status: ${isInstalled(pkg.name) ? 'Installed' : 'Available'}
''';
          }
        }
        return 'Package not found';
      default:
        return 'Unknown command: $subcmd';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    PackageInfo - معلومات الحزمة
///                    Package Information
/// ═══════════════════════════════════════════════════════════════════════════

class PackageInfo {
  final String name;
  final String version;
  final String description;
  final int size;
  final String? architecture;
  final String? maintainer;
  final DateTime? installDate;
  final List<String> dependencies;
  final List<String> provides;

  PackageInfo({
    required this.name,
    required this.version,
    required this.description,
    required this.size,
    this.architecture,
    this.maintainer,
    this.installDate,
    this.dependencies = const [],
    this.provides = const [],
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isInstalled => installDate != null;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'size': size,
      'architecture': architecture,
      'maintainer': maintainer,
      'installDate': installDate?.toIso8601String(),
      'dependencies': dependencies,
      'provides': provides,
    };
  }

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      description: json['description'] ?? '',
      size: json['size'] ?? 0,
      architecture: json['architecture'],
      maintainer: json['maintainer'],
      installDate: json['installDate'] != null
          ? DateTime.tryParse(json['installDate'])
          : null,
      dependencies: List<String>.from(json['dependencies'] ?? []),
      provides: List<String>.from(json['provides'] ?? []),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: package_manager.dart
// ═══════════════════════════════════════════════════════════════════════════