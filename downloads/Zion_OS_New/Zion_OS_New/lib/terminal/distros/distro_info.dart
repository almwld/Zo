import 'dart:convert';

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
  final String? version;
  final String? codename;
  final List<String> features;
  final Map<String, dynamic>? metadata;

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
    this.version,
    this.codename,
    this.features = const [],
    this.metadata,
  });

  factory DistroInfo.fromJson(Map<String, dynamic> json) {
    return DistroInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      downloadUrl: json['downloadUrl'] ?? json['download_url'] ?? '',
      checksum: json['checksum'],
      sizeBytes: json['sizeBytes'] ?? json['size_bytes'] ?? 0,
      architecture: json['architecture'] ?? 'all',
      isInstalled: json['isInstalled'] ?? json['is_installed'] ?? false,
      version: json['version'],
      codename: json['codename'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'downloadUrl': downloadUrl,
    'checksum': checksum,
    'sizeBytes': sizeBytes,
    'architecture': architecture,
    'isInstalled': isInstalled,
    'version': version,
    'codename': codename,
    'features': features,
    'metadata': metadata,
  };

  String get sizeFormatted {
    if (sizeBytes <= 0) return 'Unknown';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get displayName {
    if (version != null) {
      return '$name $version';
    }
    return name;
  }

  String get fullDescription {
    final buffer = StringBuffer();
    buffer.writeln(description);
    if (codename != null) {
      buffer.writeln('Codename: $codename');
    }
    if (features.isNotEmpty) {
      buffer.writeln('Features: ${features.join(', ')}');
    }
    return buffer.toString();
  }

  DistroInfo copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? downloadUrl,
    String? checksum,
    int? sizeBytes,
    String? architecture,
    bool? isInstalled,
    String? version,
    String? codename,
    List<String>? features,
    Map<String, dynamic>? metadata,
  }) {
    return DistroInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      checksum: checksum ?? this.checksum,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      architecture: architecture ?? this.architecture,
      isInstalled: isInstalled ?? this.isInstalled,
      version: version ?? this.version,
      codename: codename ?? this.codename,
      features: features ?? this.features,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'DistroInfo(id: $id, name: $name, installed: $isInstalled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistroInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DistroCatalog {
  static List<DistroInfo> getDefaultDistros() {
    return [
      DistroInfo(
        id: 'ubuntu',
        name: 'Ubuntu',
        description: 'Most popular Linux distribution. Great for beginners and advanced users alike.',
        icon: 'assets/icons/ubuntu.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/ubuntu-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 250000000,
        architecture: 'aarch64',
        version: '22.04 LTS',
        codename: 'Jammy Jellyfish',
        features: ['LTS Support', 'APT Package Manager', 'Large Community', 'GUI Support'],
      ),
      DistroInfo(
        id: 'debian',
        name: 'Debian',
        description: 'The universal operating system. Known for stability and security.',
        icon: 'assets/icons/debian.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/debian-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 200000000,
        architecture: 'aarch64',
        version: '12',
        codename: 'Bookworm',
        features: ['Stable', 'APT Package Manager', 'Free Software', 'Universal'],
      ),
      DistroInfo(
        id: 'alpine',
        name: 'Alpine Linux',
        description: 'Lightweight security-oriented distribution. Uses musl libc and BusyBox.',
        icon: 'assets/icons/alpine.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/alpine-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 50000000,
        architecture: 'aarch64',
        version: '3.18',
        features: ['Lightweight', 'APK Package Manager', 'Security-focused', 'Musl libc'],
      ),
      DistroInfo(
        id: 'fedora',
        name: 'Fedora',
        description: 'Cutting edge Linux distribution sponsored by Red Hat.',
        icon: 'assets/icons/fedora.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/fedora-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 300000000,
        architecture: 'aarch64',
        version: '39',
        features: ['Latest Software', 'DNF Package Manager', 'SELinux', 'RPM-based'],
      ),
      DistroInfo(
        id: 'arch',
        name: 'Arch Linux',
        description: 'A simple, lightweight distribution following a rolling release model.',
        icon: 'assets/icons/arch.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/archlinux-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 280000000,
        architecture: 'aarch64',
        features: ['Rolling Release', 'Pacman Package Manager', 'AUR', 'Minimalist'],
      ),
      DistroInfo(
        id: 'kali',
        name: 'Kali Linux',
        description: 'Advanced penetration testing distribution with security tools.',
        icon: 'assets/icons/kali.png',
        downloadUrl: 'https://github.com/termux/proot-distro/releases/download/v4.6.0/kali-aarch64-pd-v4.6.0.tar.xz',
        sizeBytes: 350000000,
        architecture: 'aarch64',
        version: '2024.1',
        features: ['Penetration Testing', 'Security Tools', 'APT Package Manager', 'Rolling Release'],
      ),
    ];
  }

  static List<DistroInfo> getMinimalDistros() {
    return [
      DistroInfo(
        id: 'alpine_minimal',
        name: 'Alpine (Minimal)',
        description: 'Bare minimum Alpine Linux installation.',
        icon: 'assets/icons/alpine.png',
        downloadUrl: 'https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz',
        sizeBytes: 2800000,
        architecture: 'aarch64',
        version: '3.18',
        features: ['Minimal', 'APK', 'BusyBox'],
      ),
      DistroInfo(
        id: 'busybox',
        name: 'BusyBox Only',
        description: 'Just BusyBox - the Swiss Army Knife of Embedded Linux.',
        icon: 'assets/icons/busybox.png',
        downloadUrl: '',
        sizeBytes: 1000000,
        architecture: 'all',
        features: ['Ultra Minimal', 'Built-in Utilities', 'Static Binary'],
      ),
    ];
  }

  static DistroInfo? getDistroById(String id) {
    final all = [...getDefaultDistros(), ...getMinimalDistros()];
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<DistroInfo> searchDistros(String query) {
    final all = [...getDefaultDistros(), ...getMinimalDistros()];
    final lowerQuery = query.toLowerCase();
    return all.where((d) {
      return d.name.toLowerCase().contains(lowerQuery) ||
          d.description.toLowerCase().contains(lowerQuery) ||
          d.id.toLowerCase().contains(lowerQuery) ||
          (d.codename?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  static List<String> getCategories() {
    return [
      'All',
      'Beginner Friendly',
      'Lightweight',
      'Security',
      'Development',
      'Minimal',
    ];
  }

  static List<DistroInfo> getDistrosByCategory(String category) {
    final all = getDefaultDistros();

    switch (category) {
      case 'Beginner Friendly':
        return all.where((d) => ['ubuntu', 'debian', 'fedora'].contains(d.id)).toList();
      case 'Lightweight':
        return all.where((d) => ['alpine'].contains(d.id)).toList();
      case 'Security':
        return all.where((d) => ['kali', 'alpine'].contains(d.id)).toList();
      case 'Development':
        return all.where((d) => ['arch', 'fedora', 'ubuntu'].contains(d.id)).toList();
      case 'Minimal':
        return getMinimalDistros();
      default:
        return all;
    }
  }
}
