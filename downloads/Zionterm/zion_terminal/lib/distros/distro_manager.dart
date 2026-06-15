// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Distro Manager - مدير التوزيعات                        ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: مدير التوزيعات Linux المختلفة (Ubuntu, Kali, Debian)         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    DistroManager - مدير التوزيعات
///                    Linux Distribution Manager
/// ═══════════════════════════════════════════════════════════════════════════

class DistroManager extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //                      التوزيعات المدعومة
  // ═══════════════════════════════════════════════════════════════════════

  static final List<DistroInfo> supportedDistros = [
    DistroInfo(
      id: 'ubuntu',
      name: 'Ubuntu',
      nameAr: 'أوبونتو',
      version: '22.04 LTS',
      description: 'توزيعة Linux الأكثر شعبية',
      descriptionAr: 'Most popular Linux distribution',
      icon: Icons.laptop_chromebook,
      color: Color(0xFFE95420),
      defaultPackages: ['python3', 'git', 'vim', 'curl', 'wget', 'build-essential'],
    ),
    DistroInfo(
      id: 'kali',
      name: 'Kali Linux',
      nameAr: 'كالي لينكس',
      version: '2024.1',
      description: 'توزيعة أمن سيبراني واختبار الاختراق',
      descriptionAr: 'Cybersecurity and penetration testing distro',
      icon: Icons.security,
      color: Color(0xFF367BF0),
      defaultPackages: ['nmap', 'metasploit-framework', 'hydra', 'wireshark', 'aircrack-ng'],
    ),
    DistroInfo(
      id: 'debian',
      name: 'Debian',
      nameAr: 'ديبيان',
      version: '12 (Bookworm)',
      description: 'توزيعة Linux مستقرة وموثوقة',
      descriptionAr: 'Stable and reliable Linux distribution',
      icon: Icons.desktop_windows,
      color: Color(0xFFA80030),
      defaultPackages: ['python3', 'git', 'vim', 'curl', 'wget'],
    ),
    DistroInfo(
      id: 'arch',
      name: 'Arch Linux',
      nameAr: 'آرش لينكس',
      version: 'Rolling',
      description: 'توزيعة rolling release خفيفة',
      descriptionAr: 'Lightweight rolling release distribution',
      icon: Icons.architecture,
      color: Color(0xFF1793D1),
      defaultPackages: ['base-devel', 'git', 'vim', 'curl', 'wget'],
    ),
    DistroInfo(
      id: 'fedora',
      name: 'Fedora',
      nameAr: 'فيدورا',
      version: '39',
      description: 'توزيعة محدثة من Red Hat',
      descriptionAr: 'Community-driven Linux from Red Hat',
      icon: Icons.computer,
      color: Color(0xFF3C6EB4),
      defaultPackages: ['python3', 'git', 'vim', 'curl', 'wget', 'gcc'],
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //                      حالة المدير
  // ═══════════════════════════════════════════════════════════════════════

  DistroInfo? _currentDistro;
  bool _isLoggedIn = false;
  String _currentUser = 'user';
  String _homeDirectory = '/home/user';
  bool _isLoading = false;
  String? _error;

  // ═══════════════════════════════════════════════════════════════════════
  //                      خصائص القراءة فقط
  // ═══════════════════════════════════════════════════════════════════════

  DistroInfo? get currentDistro => _currentDistro;
  bool get isLoggedIn => _isLoggedIn;
  String get currentUser => _currentUser;
  String get homeDirectory => _homeDirectory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get prompt {
    if (!_isLoggedIn) return '';
    return '$_currentUser@${_currentDistro?.id ?? "unknown"}:\$ ';
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تسجيل الدخول
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> login(String distroId, {String? user}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // البحث عن التوزيعة
      final distro = supportedDistros.firstWhere(
        (d) => d.id == distroId,
        orElse: () => throw Exception('Distribution not found'),
      );

      // محاكاة عملية تسجيل الدخول
      await Future.delayed(const Duration(seconds: 1));

      _currentDistro = distro;
      _currentUser = user ?? 'user';
      _homeDirectory = '/home/$_currentUser';
      _isLoggedIn = true;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      تسجيل الخروج
  // ═══════════════════════════════════════════════════════════════════════

  void logout() {
    _currentDistro = null;
    _isLoggedIn = false;
    _currentUser = 'user';
    _homeDirectory = '/home/user';
    _error = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدارة المستخدمين
  // ═══════════════════════════════════════════════════════════════════════

  Future<bool> addUser(String username) async {
    if (!_isLoggedIn) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = username;
      _homeDirectory = '/home/$username';

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchUser(String username) async {
    if (!_isLoggedIn) return false;

    _currentUser = username;
    _homeDirectory = '/home/$username';
    notifyListeners();

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      إدارة الملفات
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<FileInfo>> listFiles(String path) async {
    if (!_isLoggedIn) return [];

    // محاكاة قائمة الملفات
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      FileInfo(name: '.', type: FileType.directory, size: 4096),
      FileInfo(name: '..', type: FileType.directory, size: 4096),
      FileInfo(name: 'home', type: FileType.directory, size: 4096),
      FileInfo(name: 'etc', type: FileType.directory, size: 4096),
      FileInfo(name: 'usr', type: FileType.directory, size: 4096),
      FileInfo(name: 'var', type: FileType.directory, size: 4096),
      FileInfo(name: 'bin', type: FileType.directory, size: 4096),
      FileInfo(name: 'README.txt', type: FileType.file, size: 1024),
      FileInfo(name: 'config.json', type: FileType.file, size: 2048),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      الأوامر النصية
  // ═══════════════════════════════════════════════════════════════════════

  String processCommand(String command) {
    final parts = command.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';

    final cmd = parts[0].toLowerCase();

    switch (cmd) {
      case '!distro':
        return _processDistroCommand(parts);
      case 'login':
        if (parts.length > 1) {
          login(parts[1]);
          return 'Logging in to ${parts[1]}...';
        }
        return 'Usage: login <distro>';
      case 'logout':
      case 'exit':
        if (_isLoggedIn) {
          logout();
          return 'Logged out from distribution';
        }
        return 'Not logged in to any distribution';
      case 'whoami':
        return _currentUser;
      case 'pwd':
        return _homeDirectory;
      case 'hostname':
        return _currentDistro?.id ?? 'unknown';
      case 'uname':
        if (parts.length > 1 && parts[1] == '-a') {
          return '${_currentDistro?.name ?? "Linux"} ${_currentDistro?.version ?? "1.0"} x86_64 GNU/Linux';
        }
        return 'Linux';
      default:
        return command;
    }
  }

  String _processDistroCommand(List<String> parts) {
    if (parts.length < 2) {
      return '''
Available commands:
  !distro list           - List available distributions
  !distro login <name>   - Login to a distribution
  !distro logout         - Logout from current distribution
  !distro info <name>    - Show distribution info
  !distro current        - Show current distribution
''';
    }

    final subcmd = parts[1].toLowerCase();

    switch (subcmd) {
      case 'list':
        return _listDistros();
      case 'login':
        if (parts.length > 2) {
          login(parts[2]);
          return 'Logging in to ${parts[2]}...';
        }
        return 'Usage: !distro login <name>';
      case 'logout':
        logout();
        return 'Logged out';
      case 'info':
        if (parts.length > 2) {
          return _getDistroInfo(parts[2]);
        }
        return 'Usage: !distro info <name>';
      case 'current':
        if (_currentDistro != null) {
          return '''
Current Distribution: ${_currentDistro!.name}
Version: ${_currentDistro!.version}
User: $_currentUser
Home: $_homeDirectory
''';
        }
        return 'Not logged in to any distribution';
      default:
        return 'Unknown subcommand: $subcmd';
    }
  }

  String _listDistros() {
    final buffer = StringBuffer();
    buffer.writeln('Available Distributions:\n');

    for (final distro in supportedDistros) {
      final isCurrent = _currentDistro?.id == distro.id;
      final marker = isCurrent ? ' [CURRENT]' : '';
      buffer.writeln('  ${distro.name} (${distro.id})$marker');
      buffer.writeln('    Version: ${distro.version}');
      buffer.writeln('    Description: ${distro.description}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _getDistroInfo(String distroId) {
    DistroInfo? distro;
    try {
      distro = supportedDistros.firstWhere((d) => d.id == distroId);
    } catch (_) {
      return 'Distribution not found: $distroId';
    }

    return '''
Distribution: ${distro.name}
Version: ${distro.version}
Description: ${distro.description}
Default Packages: ${distro.defaultPackages.join(', ')}
''';
  }

  // ═══════════════════════════════════════════════════════════════════════
  //                      معلومات التوزيعة
  // ═══════════════════════════════════════════════════════════════════════

  DistroInfo? getDistro(String id) {
    try {
      return supportedDistros.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DistroInfo> getDistros() {
    return List.unmodifiable(supportedDistros);
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    DistroInfo - معلومات التوزيعة
///                    Distribution Information
/// ═══════════════════════════════════════════════════════════════════════════

class DistroInfo {
  final String id;
  final String name;
  final String nameAr;
  final String version;
  final String description;
  final String descriptionAr;
  final IconData icon;
  final Color color;
  final List<String> defaultPackages;

  const DistroInfo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.version,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.color,
    required this.defaultPackages,
  });

  String getDisplayName({bool arabic = false}) {
    return arabic ? nameAr : name;
  }

  String getDisplayDescription({bool arabic = false}) {
    return arabic ? descriptionAr : description;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    FileInfo - معلومات الملف
///                    File Information
/// ═══════════════════════════════════════════════════════════════════════════

enum FileType {
  file,
  directory,
  link,
  device,
  fifo,
  socket,
}

class FileInfo {
  final String name;
  final FileType type;
  final int size;
  final String? permissions;
  final DateTime? modifiedDate;
  final String? owner;
  final String? group;

  FileInfo({
    required this.name,
    required this.type,
    required this.size,
    this.permissions,
    this.modifiedDate,
    this.owner,
    this.group,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isDirectory => type == FileType.directory;
  bool get isFile => type == FileType.file;
  bool get isLink => type == FileType.link;

  IconData get icon {
    switch (type) {
      case FileType.file:
        return Icons.insert_drive_file;
      case FileType.directory:
        return Icons.folder;
      case FileType.link:
        return Icons.link;
      case FileType.device:
        return Icons.devices;
      case FileType.fifo:
        return Icons.input;
      case FileType.socket:
        return Icons.settings_ethernet;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: distro_manager.dart
// ═══════════════════════════════════════════════════════════════════════════