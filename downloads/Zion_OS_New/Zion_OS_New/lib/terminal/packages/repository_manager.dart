import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Repository {
  final String url;
  final String distribution;
  final String component;
  final bool isEnabled;
  final String? architecture;
  final String? comment;
  final bool isSource;

  Repository({
    required this.url,
    required this.distribution,
    this.component = 'main',
    this.isEnabled = true,
    this.architecture,
    this.comment,
    this.isSource = false,
  });

  factory Repository.fromSourcesLine(String line) {
    var trimmed = line.trim();
    var enabled = true;

    if (trimmed.startsWith('#')) {
      enabled = false;
      trimmed = trimmed.substring(1).trim();
    }

    if (trimmed.startsWith('deb ')) {
      trimmed = trimmed.substring(4).trim();
    } else if (trimmed.startsWith('deb-src ')) {
      return Repository(
        url: '',
        distribution: '',
        isEnabled: enabled,
        isSource: true,
      );
    } else {
      throw FormatException('Invalid sources.list line: $line');
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      throw FormatException('Invalid sources.list format: $line');
    }

    final url = parts[0];
    final distribution = parts[1];
    final components = parts.sublist(2);

    return Repository(
      url: url,
      distribution: distribution,
      component: components.isNotEmpty ? components.join(' ') : 'main',
      isEnabled: enabled,
    );
  }

  String toSourcesLine() {
    final buffer = StringBuffer();
    if (!isEnabled) buffer.write('# ');
    buffer.write(isSource ? 'deb-src ' : 'deb ');
    if (architecture != null) {
      buffer.write('[arch=$architecture] ');
    }
    buffer.write('$url $distribution $component');
    if (comment != null) {
      buffer.write(' # $comment');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'distribution': distribution,
    'component': component,
    'isEnabled': isEnabled,
    'architecture': architecture,
    'isSource': isSource,
    'comment': comment,
  };

  @override
  String toString() {
    return 'Repository($url $distribution $component)';
  }

  Repository copyWith({
    String? url,
    String? distribution,
    String? component,
    bool? isEnabled,
    String? architecture,
    String? comment,
    bool? isSource,
  }) {
    return Repository(
      url: url ?? this.url,
      distribution: distribution ?? this.distribution,
      component: component ?? this.component,
      isEnabled: isEnabled ?? this.isEnabled,
      architecture: architecture ?? this.architecture,
      comment: comment ?? this.comment,
      isSource: isSource ?? this.isSource,
    );
  }
}

class RepositoryManager {
  static final RepositoryManager _instance = RepositoryManager._internal();
  factory RepositoryManager() => _instance;
  RepositoryManager._internal();

  String _sourcesListPath = '/etc/apt/sources.list';
  String _sourcesListDir = '/etc/apt/sources.list.d';
  bool _initialized = false;

  final _changeController = StreamController<List<Repository>>.broadcast();
  Stream<List<Repository>> get onRepositoriesChanged => _changeController.stream;

  void configure({String? rootfsPath}) {
    if (rootfsPath != null) {
      _sourcesListPath = '$rootfsPath/etc/apt/sources.list';
      _sourcesListDir = '$rootfsPath/etc/apt/sources.list.d';
    }
    _initialized = true;
  }

  Future<List<Repository>> listRepositories() async {
    _ensureInitialized();
    final repositories = <Repository>[];

    // Read main sources.list
    try {
      final file = File(_sourcesListPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final lines = LineSplitter.split(content);

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#') && !trimmed.startsWith('# deb')) {
            continue;
          }

          try {
            final repo = Repository.fromSourcesLine(trimmed);
            if (repo.url.isNotEmpty) {
              repositories.add(repo);
            }
          } catch (e) {
            // Skip malformed lines
            continue;
          }
        }
      }
    } catch (e) {
      print('RepositoryManager: Error reading sources.list: $e');
    }

    // Read sources.list.d
    try {
      final dir = Directory(_sourcesListDir);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.list')) {
            final content = await entity.readAsString();
            final lines = LineSplitter.split(content);

            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed.isEmpty ||
                  (trimmed.startsWith('#') && !trimmed.startsWith('# deb'))) {
                continue;
              }

              try {
                final repo = Repository.fromSourcesLine(trimmed);
                if (repo.url.isNotEmpty) {
                  repositories.add(repo);
                }
              } catch (e) {
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      print('RepositoryManager: Error reading sources.list.d: $e');
    }

    return repositories;
  }

  Future<void> addRepository(String url, String dist, {String component = 'main', String? architecture}) async {
    _ensureInitialized();

    final repository = Repository(
      url: url,
      distribution: dist,
      component: component,
      architecture: architecture,
    );

    try {
      final file = File(_sourcesListPath);
      final line = repository.toSourcesLine();

      if (await file.exists()) {
        final content = await file.readAsString();
        if (!content.contains(url)) {
          await file.writeAsString('\n$line\n', mode: FileMode.append);
        }
      } else {
        await file.create(recursive: true);
        await file.writeAsString('$line\n');
      }

      _changeController.add(await listRepositories());
    } catch (e) {
      throw Exception('Failed to add repository: $e');
    }
  }

  Future<void> addRepositoryObject(Repository repository) async {
    await addRepository(
      repository.url,
      repository.distribution,
      component: repository.component,
      architecture: repository.architecture,
    );
  }

  Future<void> removeRepository(String url) async {
    _ensureInitialized();

    try {
      final file = File(_sourcesListPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final lines = content.split('\n');
        final filtered = <String>[];

        for (final line in lines) {
          if (!line.contains(url)) {
            filtered.add(line);
          }
        }

        await file.writeAsString(filtered.join('\n'));
      }

      // Also check sources.list.d
      final dir = Directory(_sourcesListDir);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.list')) {
            final content = await entity.readAsString();
            if (content.contains(url)) {
              final lines = content.split('\n');
              final filtered = lines.where((l) => !l.contains(url)).toList();

              if (filtered.isEmpty || filtered.every((l) => l.trim().isEmpty)) {
                await entity.delete();
              } else {
                await entity.writeAsString(filtered.join('\n'));
              }
            }
          }
        }
      }

      _changeController.add(await listRepositories());
    } catch (e) {
      throw Exception('Failed to remove repository: $e');
    }
  }

  Future<void> enableRepository(String url) async {
    await _toggleRepository(url, true);
  }

  Future<void> disableRepository(String url) async {
    await _toggleRepository(url, false);
  }

  Future<void> _toggleRepository(String url, bool enable) async {
    _ensureInitialized();

    try {
      final file = File(_sourcesListPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final lines = content.split('\n');
        final modified = <String>[];

        for (final line in lines) {
          if (line.contains(url)) {
            if (enable && line.trim().startsWith('#')) {
              modified.add(line.replaceFirst('#', '').trim());
            } else if (!enable && !line.trim().startsWith('#')) {
              modified.add('# $line');
            } else {
              modified.add(line);
            }
          } else {
            modified.add(line);
          }
        }

        await file.writeAsString(modified.join('\n'));
      }

      _changeController.add(await listRepositories());
    } catch (e) {
      throw Exception('Failed to toggle repository: $e');
    }
  }

  Future<bool> validateRepository(Repository repository) async {
    try {
      final result = await Process.run(
        'curl',
        ['-s', '-o', '/dev/null', '-w', '%{http_code}', '${repository.url}/dists/${repository.distribution}/Release'],
        environment: {'PATH': '/usr/bin:/bin'},
      );

      final statusCode = int.tryParse((result.stdout as String).trim()) ?? 0;
      return statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Repository>> getDefaultRepositories() async {
    return [
      Repository(
        url: 'http://deb.debian.org/debian',
        distribution: 'stable',
        component: 'main contrib non-free',
      ),
      Repository(
        url: 'http://deb.debian.org/debian',
        distribution: 'stable-updates',
        component: 'main contrib non-free',
      ),
      Repository(
        url: 'http://security.debian.org/debian-security',
        distribution: 'stable-security',
        component: 'main contrib non-free',
      ),
    ];
  }

  Future<void> resetToDefaults() async {
    _ensureInitialized();

    try {
      final defaults = await getDefaultRepositories();
      final buffer = StringBuffer();

      buffer.writeln('# Default Debian repositories');
      buffer.writeln('# See sources.list(5) for more information');
      buffer.writeln();

      for (final repo in defaults) {
        buffer.writeln(repo.toSourcesLine());
      }

      final file = File(_sourcesListPath);
      await file.writeAsString(buffer.toString());

      // Clean up sources.list.d
      final dir = Directory(_sourcesListDir);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }

      _changeController.add(await listRepositories());
    } catch (e) {
      throw Exception('Failed to reset repositories: $e');
    }
  }

  Future<String> exportToString() async {
    final repositories = await listRepositories();
    final buffer = StringBuffer();

    buffer.writeln('# Zion Terminal - Repository Export');
    buffer.writeln('# Generated at ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    for (final repo in repositories) {
      buffer.writeln(repo.toSourcesLine());
    }

    return buffer.toString();
  }

  Future<void> importFromString(String content) async {
    final lines = LineSplitter.split(content);
    final repositories = <Repository>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty ||
          (trimmed.startsWith('#') && !trimmed.startsWith('# deb'))) {
        continue;
      }

      try {
        final repo = Repository.fromSourcesLine(trimmed);
        if (repo.url.isNotEmpty) {
          repositories.add(repo);
        }
      } catch (e) {
        continue;
      }
    }

    // Clear existing and write new
    final file = File(_sourcesListPath);
    final buffer = StringBuffer();
    for (final repo in repositories) {
      buffer.writeln(repo.toSourcesLine());
    }
    await file.writeAsString(buffer.toString());

    _changeController.add(await listRepositories());
  }

  Future<List<Map<String, dynamic>>> getRepositoryStats() async {
    final repositories = await listRepositories();
    final stats = <Map<String, dynamic>>[];

    for (final repo in repositories) {
      final isValid = await validateRepository(repo);
      stats.add({
        'repository': repo.toJson(),
        'isValid': isValid,
      });
    }

    return stats;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      configure();
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    final repositories = await listRepositories();
    final enabled = repositories.where((r) => r.isEnabled).length;

    return {
      'total': repositories.length,
      'enabled': enabled,
      'disabled': repositories.length - enabled,
      'sourcesListPath': _sourcesListPath,
      'repositories': repositories.map((r) => r.toJson()).toList(),
    };
  }

  void dispose() {
    _changeController.close();
  }
}
