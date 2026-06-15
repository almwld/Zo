class KaliEnvironment {
  static const String name = 'Kali Linux';
  static const String version = '2024.1';
  static const String icon = 'assets/icons/kali.png';
  
  static const List<String> preInstalledPackages = [
    'nmap', 'metasploit', 'hydra', 'sqlmap', 'wireshark', 'burpsuite',
    'aircrack-ng', 'john', 'hashcat', 'nikto', 'dirb', 'gobuster',
  ];
  
  static List<String> getAvailablePackages() {
    return preInstalledPackages;
  }
  
  static Future<bool> installPackage(String package) async {
    // تثبيت أداة اختراق
    return true;
  }
  
  static Future<bool> runTool(String tool) async {
    // تشغيل أداة اختراق
    return true;
  }
  
  static String getWelcomeMessage() {
    return '''
    ╔═══════════════════════════════════════════╗
    ║         Kali Linux $version              ║
    ║     Security Tools Environment           ║
    ╚═══════════════════════════════════════════╝
    ''';
  }
}
