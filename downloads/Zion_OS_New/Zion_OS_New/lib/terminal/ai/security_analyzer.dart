enum SecurityLevel { safe, caution, warning, danger }

class SecurityResult {
  final bool isSafe;
  final SecurityLevel level;
  final String message;
  final List<String> warnings;
  final List<String> blockedCommands;
  final bool requiresConfirmation;
  final String? explanation;

  const SecurityResult({
    required this.isSafe,
    required this.level,
    this.message = '',
    this.warnings = const [],
    this.blockedCommands = const [],
    this.requiresConfirmation = false,
    this.explanation,
  });

  factory SecurityResult.safe() {
    return const SecurityResult(
      isSafe: true,
      level: SecurityLevel.safe,
      message: 'Command is safe to execute',
    );
  }

  factory SecurityResult.caution(String message, {List<String> warnings = const []}) {
    return SecurityResult(
      isSafe: true,
      level: SecurityLevel.caution,
      message: message,
      warnings: warnings,
      requiresConfirmation: true,
    );
  }

  factory SecurityResult.warning(String message, {List<String> warnings = const []}) {
    return SecurityResult(
      isSafe: false,
      level: SecurityLevel.warning,
      message: message,
      warnings: warnings,
      blockedCommands: ['command'],
    );
  }

  factory SecurityResult.danger(String message, {List<String> warnings = const []}) {
    return SecurityResult(
      isSafe: false,
      level: SecurityLevel.danger,
      message: message,
      warnings: warnings,
      blockedCommands: ['command'],
    );
  }

  Map<String, dynamic> toJson() => {
    'isSafe': isSafe,
    'level': level.toString().split('.').last,
    'message': message,
    'warnings': warnings,
    'blockedCommands': blockedCommands,
    'requiresConfirmation': requiresConfirmation,
    'explanation': explanation,
  };

  @override
  String toString() {
    return 'SecurityResult(level: ${level.toString().split('.').last}, safe: $isSafe, message: $message)';
  }
}

class SecurityAnalyzer {
  static const List<String> dangerousPatterns = [
    // Destructive operations
    r'rm\s+-rf\s+/',
    r'rm\s+-rf\s+\*/',
    r'rm\s+-rf\s+/system',
    r'rm\s+-rf\s+/data',
    r'rm\s+-rf\s+/storage',
    r'rm\s+-rf\s+/sdcard',
    r'rm\s+-rf\s+/home',
    r'rm\s+-rf\s+~/',
    r'rm\s+-rf\s+/\$\{',
    r'rm\s+-rf\s+/\w+/\.\.\.',

    // Disk operations
    r'mkfs\.\w+\s+/dev/',
    r'dd\s+if=.+of=/dev/[sh]d',
    r'dd\s+if=.+of=/dev/sda',
    r'dd\s+if=.+of=/dev/block/',

    // Privilege escalation
    r'chmod\s+-R\s+777\s+/',
    r'chmod\s+777\s+/etc',
    r'chown\s+-R\s+root:root\s+/',

    // Fork bombs
    r':\(\)\s*\{\s*:\|:\&\s*\};',
    r'fork\s*bomb',

    // System modifications
    r'mv\s+/\w+\s+/\w+',
    r'>\s+/etc/passwd',
    r'>\s+/etc/shadow',

    // Network attacks
    r'nping\s+.*--tcp-connect-probe',
    r'hping3\s+.*-S\s+-p\s+\d+',

    // Cryptocurrency miners
    r'xmrig',
    r'cpuminer',
    r'minerd',

    // Backdoors
    r'nc\s+-[lL]\s+-p\s+\d+',
    r'ncat\s+-[lL]\s+\d+',
    r'netcat\s+-[lL]',
  ];

  static const List<String> blockedPatterns = [
    // System partition destruction
    r'^rm\s+-rf\s+/\s*$',
    r'^rm\s+-rf\s+/\s+--no-preserve-root',
    r'^rm\s+-rf\s+/\*\s*$',

    // Boot partition
    r'^dd\s+if=.*\s+of=/dev/sda\s*$',
    r'^dd\s+if=.*\s+of=/dev/mmcblk0\s*$',
    r'^dd\s+if=.*\s+of=/dev/block/',

    // Fork bomb
    r'^:\(\)\{\s*:\|:\&\s*\};:',

    // Direct device writes
    r'^mkfs\.\w+\s+/dev/\w+\s*$',

    // Dangerous chmod on system
    r'^chmod\s+-R\s+000\s+/\s*$',
    r'^chmod\s+-R\s+777\s+/\s*$',
  ];

  static const List<String> cautionPatterns = [
    r'^rm\s+-[rf]+',
    r'^mv\s+/',
    r'^chmod\s+-R',
    r'^chown\s+-R',
    r'^mkfs',
    r'^fdisk',
    r'^parted',
    r'^dd\s+if=',
    r'^wget\s+.*\s*\|\s*sh',
    r'^curl\s+.*\s*\|\s*sh',
    r'^curl\s+.*\s*\|\s*bash',
    r'^eval\s+\$\(wget',
    r'^eval\s+\$\(curl',
    r'^source\s+<(curl',
    r'^source\s+<(wget',
    r'^apt\s+purge',
    r'^apt-get\s+purge',
    r'^dpkg\s+--remove',
    r'^pacman\s+-Rsc',
    r'^dnf\s+remove',
  ];

  static SecurityResult check(String command) {
    if (command.trim().isEmpty) {
      return SecurityResult.safe();
    }

    final trimmedCommand = command.trim();
    final warnings = <String>[];

    // Check blocked patterns first
    for (final pattern in blockedPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(trimmedCommand)) {
          return SecurityResult.danger(
            'This command is BLOCKED for security reasons. It could cause irreversible damage to your device.',
            warnings: ['Pattern matched: $pattern'],
          );
        }
      } catch (e) {
        continue;
      }
    }

    // Check dangerous patterns
    for (final pattern in dangerousPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(trimmedCommand)) {
          warnings.add('Potentially dangerous operation detected');
        }
      } catch (e) {
        continue;
      }
    }

    // Check caution patterns
    bool requiresConfirmation = false;
    for (final pattern in cautionPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(trimmedCommand)) {
          requiresConfirmation = true;
          warnings.add('Command requires elevated privileges or may modify system files');
        }
      } catch (e) {
        continue;
      }
    }

    // Check for pipe to shell (common attack vector)
    if (_isPipeToShell(trimmedCommand)) {
      warnings.add('Piping from network to shell can execute arbitrary code');
      requiresConfirmation = true;
    }

    // Check for recursive operations on home
    if (_isRecursiveOnHome(trimmedCommand)) {
      warnings.add('Recursive operation in home directory');
      requiresConfirmation = true;
    }

    // Evaluate final result
    if (warnings.isEmpty) {
      return SecurityResult.safe();
    }

    if (requiresConfirmation) {
      return SecurityResult.caution(
        'This command may have side effects. Please review before executing.',
        warnings: warnings,
      );
    }

    return SecurityResult.warning(
      'Security warnings detected for this command.',
      warnings: warnings,
    );
  }

  static bool _isPipeToShell(String command) {
    final pipePatterns = [
      RegExp(r'\|\s*sh\s*$', caseSensitive: false),
      RegExp(r'\|\s*bash\s*$', caseSensitive: false),
      RegExp(r'\|\s*zsh\s*$', caseSensitive: false),
      RegExp(r'\|\s*ksh\s*$', caseSensitive: false),
      RegExp(r'eval\s+', caseSensitive: false),
      RegExp(r'\`\s*wget', caseSensitive: false),
      RegExp(r'\`\s*curl', caseSensitive: false),
    ];

    return pipePatterns.any((pattern) => pattern.hasMatch(command));
  }

  static bool _isRecursiveOnHome(String command) {
    final patterns = [
      RegExp(r'-R\s+~', caseSensitive: false),
      RegExp(r'--recursive\s+~', caseSensitive: false),
      RegExp(r'-R\s+\$HOME', caseSensitive: false),
    ];

    return patterns.any((pattern) => pattern.hasMatch(command));
  }

  static bool isDangerous(String command) {
    final result = check(command);
    return result.level == SecurityLevel.danger ||
        result.level == SecurityLevel.warning;
  }

  static bool requiresConfirmation(String command) {
    final result = check(command);
    return result.requiresConfirmation;
  }

  static List<String> getWarnings(String command) {
    final result = check(command);
    return result.warnings;
  }

  static String getExplanation(String command) {
    final result = check(command);
    return result.message;
  }

  static SecurityResult analyzeScript(String script) {
    final lines = script.split('\n');
    final allWarnings = <String>[];
    SecurityLevel highestLevel = SecurityLevel.safe;
    var hasBlocked = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final result = check(line);

      if (!result.isSafe) {
        allWarnings.add('Line ${i + 1}: ${result.message}');
      }

      if (result.warnings.isNotEmpty) {
        allWarnings.addAll(result.warnings.map((w) => '  - $w'));
      }

      if (result.level.index > highestLevel.index) {
        highestLevel = result.level;
      }

      if (result.level == SecurityLevel.danger) {
        hasBlocked = true;
      }
    }

    if (hasBlocked) {
      return SecurityResult.danger(
        'Script contains blocked commands that will not execute.',
        warnings: allWarnings,
      );
    }

    if (highestLevel == SecurityLevel.warning) {
      return SecurityResult.warning(
        'Script contains potentially dangerous commands.',
        warnings: allWarnings,
      );
    }

    if (highestLevel == SecurityLevel.caution) {
      return SecurityResult.caution(
        'Script contains commands that require confirmation.',
        warnings: allWarnings,
      );
    }

    return SecurityResult.safe();
  }
}
