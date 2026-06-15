class UbuntuEnvironment {
  static const String name = 'Ubuntu';
  static const String version = '22.04 LTS';
  static const String icon = 'assets/icons/ubuntu.png';
  
  static const List<String> preInstalledPackages = [
    'bash', 'coreutils', 'sudo', 'apt', 'wget', 'curl', 'git', 'vim', 'nano',
  ];
  
  static List<String> getAvailablePackages() {
    return preInstalledPackages;
  }
  
  static Future<bool> installPackage(String package) async {
    // تثبيت حزمة في بيئة Ubuntu
    return true;
  }
  
  static Future<bool> uninstallPackage(String package) async {
    // إزالة حزمة
    return true;
  }
  
  static String getWelcomeMessage() {
    return '''
    ╔═══════════════════════════════════════════╗
    ║         Ubuntu $version                  ║
    ║     Welcome to Zion OS Terminal          ║
    ╚═══════════════════════════════════════════╝
    ''';
  }
}
