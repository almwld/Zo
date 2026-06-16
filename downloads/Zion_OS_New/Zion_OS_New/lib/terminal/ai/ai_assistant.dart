import 'security_analyzer.dart';
import 'command_translator.dart';

class AIAssistant {
  static final Map<String, String> _translationCache = {};
  static final List<String> _commandHistory = [];
  static const int _maxHistorySize = 100;

  // ===== TRANSLATION =====

  static String? translate(String arabicCommand) {
    if (_translationCache.containsKey(arabicCommand)) {
      return _translationCache[arabicCommand];
    }

    final result = CommandTranslator.translate(arabicCommand);
    if (result != null) {
      _translationCache[arabicCommand] = result;
    }
    return result;
  }

  static String translateOrPassthrough(String input) {
    return CommandTranslator.translateOrKeep(input);
  }

  static bool canTranslate(String input) {
    return CommandTranslator.canTranslate(input);
  }

  // ===== CORRECTION =====

  static String correct(String command) {
    var corrected = command.trim();

    // Fix common typos
    corrected = _fixCommonTypos(corrected);

    // Fix spacing issues
    corrected = _fixSpacing(corrected);

    // Fix common command mistakes
    corrected = _fixCommandMistakes(corrected);

    // Fix argument order
    corrected = _fixArgumentOrder(corrected);

    return corrected;
  }

  static String _fixCommonTypos(String cmd) {
    final typos = {
      'sl': 'ls',
      'ks': 'ls',
      'cd..': 'cd ..',
      'cd~': 'cd ~',
      'grpe': 'grep',
      'grup': 'grep',
      'catr': 'cat',
      'tial': 'tail',
      'heda': 'head',
      'mkdor': 'mkdir',
      'mldir': 'mkdir',
      'rmdi': 'rmdir',
      'touc': 'touch',
      'echp': 'echo',
      'wwget': 'wget',
      'curll': 'curl',
      'greo': 'grep',
      'grepp': 'grep',
      'mroe': 'more',
      'les': 'less',
      'catt': 'cat',
      'mvv': 'mv',
      'cpp': 'cp',
      'rmm': 'rm',
      'chmmod': 'chmod',
      'chwon': 'chown',
      'sudp': 'sudo',
      'sudoo': 'sudo',
      'apt-getg': 'apt-get',
      'sytemctl': 'systemctl',
      'systmctl': 'systemctl',
      'systectl': 'systemctl',
      'dockr': 'docker',
      'dokcer': 'docker',
      'gitr': 'git',
      'gitt': 'git',
    };

    final parts = cmd.split(' ');
    if (parts.isNotEmpty && typos.containsKey(parts[0])) {
      parts[0] = typos[parts[0]]!;
      return parts.join(' ');
    }

    return cmd;
  }

  static String _fixSpacing(String cmd) {
    return cmd
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*\|\s*'), ' | ')
        .replaceAll(RegExp(r'\s*>\s*'), ' > ')
        .replaceAll(RegExp(r'\s*<\s*'), ' < ')
        .replaceAll(RegExp(r'\s*;\s*'), '; ')
        .replaceAll(RegExp(r'\s*&&\s*'), ' && ')
        .replaceAll(RegExp(r'\s*\|\|\s*'), ' || ')
        .trim();
  }

  static String _fixCommandMistakes(String cmd) {
    final lower = cmd.toLowerCase();

    // Fix apt without subcommand
    if (RegExp(r'^apt\s+[^a-z]').hasMatch(lower) || lower == 'apt') {
      return cmd.replaceFirst(RegExp(r'^apt', caseSensitive: false), 'apt install');
    }

    // Fix git without subcommand
    if (lower == 'git' || RegExp(r'^git\s+[^a-z]').hasMatch(lower)) {
      return cmd.replaceFirst(RegExp(r'^git', caseSensitive: false), 'git status');
    }

    // Fix docker without subcommand
    if (lower == 'docker' || RegExp(r'^docker\s+[^a-z]').hasMatch(lower)) {
      return cmd.replaceFirst(RegExp(r'^docker', caseSensitive: false), 'docker ps');
    }

    // Fix systemctl without subcommand
    if (lower == 'systemctl' || RegExp(r'^systemctl\s+[^a-z]').hasMatch(lower)) {
      return cmd.replaceFirst(RegExp(r'^systemctl', caseSensitive: false), 'systemctl status');
    }

    // Fix cd without argument (go home)
    if (lower == 'cd' || lower == 'cd ') {
      return 'cd ~';
    }

    // Fix ls with flags order
    if (RegExp(r'^ls\s+-.+\s+/').hasMatch(cmd)) {
      final match = RegExp(r'^ls\s+(.+)\s+(/.*)').firstMatch(cmd);
      if (match != null) {
        return 'ls ${match.group(2)} ${match.group(1)}';
      }
    }

    return cmd;
  }

  static String _fixArgumentOrder(String cmd) {
    // Move flags after command but before positional args
    final parts = cmd.split(' ');
    if (parts.length < 3) return cmd;

    final command = parts[0];
    final flags = <String>[];
    final args = <String>[];

    for (var i = 1; i < parts.length; i++) {
      if (parts[i].startsWith('-')) {
        flags.add(parts[i]);
      } else {
        args.add(parts[i]);
      }
    }

    if (flags.isNotEmpty && args.isNotEmpty) {
      return [command, ...flags, ...args].join(' ');
    }

    return cmd;
  }

  // ===== SUGGESTIONS =====

  static String? suggest(List<String> history) {
    if (history.isEmpty) return null;

    // Store history
    for (final cmd in history) {
      _addToHistory(cmd);
    }

    // Get recent command patterns
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;

    // Suggest based on patterns
    if (_isPackageInstallPattern(recent)) {
      return 'Did you mean: apt update && apt upgrade';
    }

    if (_isGitWorkflowPattern(recent)) {
      return 'Did you mean: git add . && git commit -m "update"';
    }

    if (_isDirectoryNavigationPattern(recent)) {
      return 'Did you mean: cd .. or pushd/popd for navigation';
    }

    if (_isFileSearchPattern(recent)) {
      return 'Did you mean: find . -name "*.txt" -type f';
    }

    if (_isProcessManagementPattern(recent)) {
      return 'Did you mean: ps aux | grep <process>';
    }

    // Suggest next command based on last command
    final lastCmd = history.last.trim().toLowerCase();
    final suggestion = _getNextCommandSuggestion(lastCmd);
    if (suggestion != null) {
      return suggestion;
    }

    return null;
  }

  static void _addToHistory(String command) {
    if (_commandHistory.length >= _maxHistorySize) {
      _commandHistory.removeAt(0);
    }
    _commandHistory.add(command);
  }

  static bool _isPackageInstallPattern(List<String> recent) {
    var installCount = 0;
    for (final cmd in recent) {
      if (cmd.contains('apt install') || cmd.contains('apt-get install')) {
        installCount++;
      }
    }
    return installCount >= 2;
  }

  static bool _isGitWorkflowPattern(List<String> recent) {
    return recent.any((cmd) => cmd.contains('git status') || cmd.contains('git diff'));
  }

  static bool _isDirectoryNavigationPattern(List<String> recent) {
    var cdCount = 0;
    for (final cmd in recent) {
      if (cmd.trim().startsWith('cd ')) cdCount++;
    }
    return cdCount >= 3;
  }

  static bool _isFileSearchPattern(List<String> recent) {
    return recent.any((cmd) => cmd.contains('ls') && cmd.contains('*'));
  }

  static bool _isProcessManagementPattern(List<String> recent) {
    return recent.any((cmd) => cmd.contains('ps') || cmd.contains('top') || cmd.contains('htop'));
  }

  static String? _getNextCommandSuggestion(String lastCmd) {
    final suggestions = {
      'ls': 'Common follow-ups: cd <dir>, cat <file>, file <file>',
      'pwd': 'Common follow-ups: ls, cd ~, cd /',
      'cd': 'Common follow-ups: ls, pwd, mkdir',
      'mkdir': 'Common follow-ups: cd <dir>, ls',
      'git clone': 'Common follow-ups: cd <repo>, ls, git status',
      'git status': 'Common follow-ups: git add, git diff, git commit',
      'git add': 'Common follow-ups: git status, git commit',
      'git commit': 'Common follow-ups: git push, git log',
      'apt update': 'Common follow-ups: apt upgrade, apt search',
      'apt install': 'Common follow-ups: <command> --version, man <command>',
      'make': 'Common follow-ups: make install, ./<program>',
      'gcc': 'Common follow-ups: ./a.out, ls',
      'docker ps': 'Common follow-ups: docker logs, docker exec',
      'systemctl status': 'Common follow-ups: systemctl start, journalctl',
      'find': 'Common follow-ups: cat <file>, file <file>',
      'grep': 'Common follow-ups: less, head, tail',
      'tar': 'Common follow-ups: ls, cd',
      'wget': 'Common follow-ups: ls, file, chmod +x',
      'curl': 'Common follow-ups: less, jq, grep',
      'ssh': 'Common follow-ups: ls, pwd, exit',
      'scp': 'Common follow-ups: ssh, ls',
      'chmod': 'Common follow-ups: ls -la, ./<script>',
      'chown': 'Common follow-ups: ls -la',
      'nano': 'Saved file. Common follow-ups: cat, head, less',
      'vim': 'Saved file. Common follow-ups: cat, head, less',
    };

    for (final entry in suggestions.entries) {
      if (lastCmd.startsWith(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  // ===== SECURITY ANALYSIS =====

  static SecurityResult analyze(String command) {
    return SecurityAnalyzer.check(command);
  }

  static bool isSafe(String command) {
    return SecurityAnalyzer.check(command).isSafe;
  }

  static bool requiresConfirmation(String command) {
    return SecurityAnalyzer.requiresConfirmation(command);
  }

  // ===== EXPLANATION =====

  static String explain(String command) {
    final parts = command.trim().split(' ');
    if (parts.isEmpty) return 'Empty command';

    final baseCmd = parts[0].toLowerCase();
    final args = parts.sublist(1);

    final explanations = <String>[];

    // Explain base command
    final cmdExplanation = _explainCommand(baseCmd);
    if (cmdExplanation != null) {
      explanations.add(cmdExplanation);
    }

    // Explain arguments
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      final argExplanation = _explainArgument(baseCmd, arg, i, args);
      if (argExplanation != null) {
        explanations.add(argExplanation);
      }
    }

    // Explain pipes and redirections
    if (command.contains('|')) {
      explanations.add('Pipes (|) send output of one command as input to another');
    }
    if (command.contains('>')) {
      if (command.contains('>>')) {
        explanations.add('>> appends output to file (creates if not exists)');
      } else {
        explanations.add('> redirects output to file (overwrites existing)');
      }
    }
    if (command.contains('<')) {
      explanations.add('< redirects file content as command input');
    }

    // Security analysis
    final security = SecurityAnalyzer.check(command);
    if (!security.isSafe) {
      explanations.add('\nSecurity: ${security.message}');
      for (final warning in security.warnings) {
        explanations.add('  ⚠ $warning');
      }
    }

    if (explanations.isEmpty) {
      return 'Command: $command\nNo detailed explanation available for this command.';
    }

    return explanations.join('\n');
  }

  static String? _explainCommand(String cmd) {
    final explanations = {
      'ls': 'List directory contents',
      'cd': 'Change current directory',
      'pwd': 'Print working directory (show current path)',
      'cat': 'Concatenate and display file contents',
      'echo': 'Display a line of text or write to file',
      'touch': 'Create empty file or update timestamp',
      'mkdir': 'Create new directory',
      'rmdir': 'Remove empty directory',
      'rm': 'Remove files or directories',
      'cp': 'Copy files or directories',
      'mv': 'Move/rename files or directories',
      'find': 'Search for files in directory hierarchy',
      'grep': 'Search text using patterns',
      'chmod': 'Change file permissions',
      'chown': 'Change file owner and group',
      'ps': 'Report process status',
      'top': 'Display system processes',
      'kill': 'Send signal to process',
      'df': 'Report disk space usage',
      'du': 'Estimate file space usage',
      'free': 'Display memory usage',
      'whoami': 'Display current user',
      'uname': 'Print system information',
      'date': 'Display or set system date/time',
      'wget': 'Download files from web',
      'curl': 'Transfer data from/to server',
      'ssh': 'Secure shell remote login',
      'scp': 'Secure copy (remote file copy)',
      'tar': 'Archive files',
      'gzip': 'Compress files',
      'gunzip': 'Decompress files',
      'zip': 'Package and compress files',
      'unzip': 'Extract compressed files',
      'git': 'Version control system',
      'apt': 'Package manager (Debian/Ubuntu)',
      'yum': 'Package manager (RHEL/CentOS)',
      'dnf': 'Package manager (Fedora)',
      'pacman': 'Package manager (Arch)',
      'snap': 'Universal package manager',
      'docker': 'Container management',
      'systemctl': 'Control systemd services',
      'journalctl': 'Query systemd journal',
      'nano': 'Text editor (simple)',
      'vim': 'Text editor (advanced)',
      'emacs': 'Text editor (extensible)',
      'sed': 'Stream editor',
      'awk': 'Pattern scanning and processing',
      'sort': 'Sort lines of text',
      'uniq': 'Report or omit repeated lines',
      'wc': 'Count lines, words, bytes',
      'head': 'Output first part of files',
      'tail': 'Output last part of files',
      'tee': 'Read from stdin and write to stdout and files',
      'xargs': 'Build and execute command lines',
      'which': 'Locate a command',
      'whereis': 'Locate binary, source, and manual files',
      'man': 'Display manual pages',
      'info': 'Read documentation',
      'clear': 'Clear terminal screen',
      'exit': 'Exit the shell',
      'history': 'Show command history',
      'alias': 'Create command alias',
      'export': 'Set environment variable',
      'env': 'Display environment variables',
      'source': 'Execute commands from file in current shell',
      'sudo': 'Execute command as superuser',
      'su': 'Switch user',
      'id': 'Display user and group information',
      'ping': 'Test network connectivity',
      'traceroute': 'Trace network route',
      'netstat': 'Network statistics',
      'ss': 'Investigate sockets',
      'ip': 'Show/manipulate routing, devices, policy routing',
      'ifconfig': 'Configure network interfaces',
      'host': 'DNS lookup utility',
      'nslookup': 'Query Internet name servers',
      'dig': 'DNS lookup',
      'lscpu': 'Display CPU information',
      'lsblk': 'List block devices',
      'lspci': 'List PCI devices',
      'lsusb': 'List USB devices',
      'mount': 'Mount filesystem',
      'umount': 'Unmount filesystem',
      'reboot': 'Reboot system',
      'shutdown': 'Shutdown system',
      'uptime': 'Show how long system has been running',
      'users': 'Show who is logged on',
      'who': 'Show who is logged on',
      'w': 'Show who is logged on and what they are doing',
      'finger': 'User information lookup',
      'passwd': 'Change user password',
      'crontab': 'Schedule periodic background work',
      'at': 'Queue, examine, or delete jobs',
      'batch': 'Execute commands when system load permits',
    };

    return explanations[cmd];
  }

  static String? _explainArgument(String cmd, String arg, int index, List<String> allArgs) {
    // Common flags
    if (arg.startsWith('-')) {
      return _explainFlag(cmd, arg);
    }

    // File patterns
    if (arg.contains('*') || arg.contains('?')) {
      return '"$arg" is a wildcard pattern matching multiple files';
    }

    // Common paths
    if (arg == '~' || arg == r'$HOME') {
      return '"$arg" refers to your home directory';
    }
    if (arg == '.' || arg == './') {
      return '"$arg" refers to the current directory';
    }
    if (arg == '..' || arg == '../') {
      return '"$arg" refers to the parent directory';
    }
    if (arg == '/') {
      return '"/" is the root directory';
    }

    // Pipes and redirections
    if (arg == '|') return null; // Handled separately
    if (arg == '>') return null;
    if (arg == '>>') return null;
    if (arg == '<') return null;

    // If it looks like a file
    if (arg.contains('.') && !arg.startsWith('-')) {
      return '"$arg" appears to be a filename';
    }

    // If it looks like a URL
    if (arg.startsWith('http://') || arg.startsWith('https://') || arg.startsWith('ftp://')) {
      return '"$arg" is a URL';
    }

    return null;
  }

  static String? _explainFlag(String cmd, String flag) {
    final commonFlags = {
      '-a': 'Show all (including hidden files)',
      '-A': 'Show almost all (exclude . and ..)',
      '-l': 'Use long listing format',
      '-h': 'Human-readable sizes',
      '-r': 'Reverse order',
      '-R': 'Recursive (include subdirectories)',
      '-t': 'Sort by modification time',
      '-S': 'Sort by file size',
      '-i': 'Show inode numbers',
      '-1': 'One file per line',
      '-s': 'Show size (blocks)',
      '-d': 'List directories themselves',
      '-F': 'Append indicator to entries',
      '-p': 'Append / to directories',
      '-c': 'Show change time',
      '-u': 'Show access time',
      '-f': 'Disable sorting',
      '-v': 'Verbose (show details)',
      '-n': 'Numeric output',
      '-q': 'Quiet mode',
      '-f': 'Force (no confirmation)',
      '-i': 'Interactive (confirm before overwrite)',
      '-b': 'Backup existing files',
      '-u': 'Update (copy only newer)',
      '-p': 'Preserve attributes',
      '-n': 'No clobber (don\'t overwrite)',
      '-T': 'Show file system type',
      '-x': 'Exclude patterns',
      '-E': 'Extended regex',
      '-o': 'Output format',
      '-e': 'Execute expression',
      '-I': 'Replace string from stdin',
      '-P': 'Preserve environment',
      '-k': 'Keep (don\'t delete)',
      '-y': 'Assume yes to prompts',
      '-s': 'Silent/quiet',
      '-w': 'Width',
      '-m': 'Mode/method',
      '-g': 'Group',
      '-L': 'Follow symlinks',
      '-H': 'Follow symlinks on command line',
      '-D': 'Debug mode',
      '-C': 'Context',
      '-N': 'Line numbers',
      '-B': 'Before context',
      '-A': 'After context',
      '-x': 'Exact match',
      '-I': 'Ignore binary',
      '-z': 'Null-terminated',
      '-Z': 'Compress',
      '-j': 'Jobs/threads',
      '-O': 'Output file',
      '-J': 'JSON output',
      '-X': 'Exclude',
      '-G': 'Basic regex',
      '-K': 'Keep alive',
      '-U': 'Unicode',
      '-M': 'Maximum',
      '-W': 'Width',
      '-V': 'Version',
    };

    if (commonFlags.containsKey(flag)) {
      return '"$flag": ${commonFlags[flag]}';
    }

    // Combined flags like -la, -lh, etc.
    if (flag.length > 2 && flag.startsWith('-') && !flag.startsWith('--')) {
      final chars = flag.substring(1).split('');
      final explanations = <String>[];
      for (final ch in chars) {
        final f = '-$ch';
        if (commonFlags.containsKey(f)) {
          explanations.add('"$f": ${commonFlags[f]}');
        }
      }
      if (explanations.isNotEmpty) {
        return explanations.join(', ');
      }
    }

    return '"$flag": Command-specific flag';
  }

  // ===== AUTOCOMPLETE =====

  static List<String> getAutocompleteSuggestions(String partial, List<String> history) {
    final suggestions = <String>[];
    final lowerPartial = partial.toLowerCase();

    // Common commands
    final commonCommands = [
      'ls', 'cd', 'pwd', 'cat', 'echo', 'touch', 'mkdir', 'rm', 'cp', 'mv',
      'grep', 'find', 'chmod', 'chown', 'ps', 'top', 'kill', 'df', 'du',
      'free', 'whoami', 'uname', 'date', 'wget', 'curl', 'ssh', 'scp',
      'tar', 'gzip', 'git', 'apt', 'nano', 'vim', 'sed', 'awk', 'sort',
      'head', 'tail', 'clear', 'exit', 'history', 'sudo', 'man',
    ];

    for (final cmd in commonCommands) {
      if (cmd.startsWith(lowerPartial)) {
        suggestions.add(cmd);
      }
    }

    // From history
    for (final cmd in history.reversed) {
      final trimmed = cmd.trim();
      if (trimmed.toLowerCase().startsWith(lowerPartial) && !suggestions.contains(trimmed)) {
        suggestions.add(trimmed);
      }
    }

    return suggestions.take(10).toList();
  }

  // ===== UTILITY =====

  static void clearCache() {
    _translationCache.clear();
    _commandHistory.clear();
  }

  static List<String> getCommandHistory() {
    return List.unmodifiable(_commandHistory);
  }

  static Map<String, dynamic> getStatus() {
    return {
      'translationCacheSize': _translationCache.length,
      'historySize': _commandHistory.length,
      'maxHistorySize': _maxHistorySize,
      'availableCommands': CommandTranslator.getAllCommands().length,
    };
  }
}
