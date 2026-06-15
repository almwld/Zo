class SecurityAnalyzer {
  static const List<String> _dangerousCommands = [
    'rm -rf', 'dd if=', 'mkfs', 'format', ':(){ :|:& };:', 'chmod 777',
    'sudo', 'su', 'passwd', 'useradd', 'userdel', 'kill -9',
  ];
  
  static const List<String> _suspiciousPatterns = [
    'wget', 'curl', 'nc', 'netcat', 'telnet', 'ssh', 'scp',
    './', 'chmod +x', 'bash -i', 'sh -i',
  ];
  
  static SecurityLevel analyzeCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    for (var dangerous in _dangerousCommands) {
      if (lowerCommand.contains(dangerous)) {
        return SecurityLevel.dangerous;
      }
    }
    
    for (var suspicious in _suspiciousPatterns) {
      if (lowerCommand.contains(suspicious)) {
        return SecurityLevel.suspicious;
      }
    }
    
    return SecurityLevel.safe;
  }
  
  static String getWarningMessage(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.dangerous:
        return '⚠️ تحذير: هذا الأمر خطير وقد يتلف النظام!';
      case SecurityLevel.suspicious:
        return '⚡ تنبيه: هذا الأمر قد يكون مشبوهاً. تأكد من مصدره.';
      case SecurityLevel.safe:
        return '✅ الأمر آمن';
    }
  }
  
  static bool requiresConfirmation(SecurityLevel level) {
    return level == SecurityLevel.dangerous;
  }
}

enum SecurityLevel { safe, suspicious, dangerous }
