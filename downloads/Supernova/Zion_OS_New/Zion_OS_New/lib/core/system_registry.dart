class SystemRegistry {
  static final Map<String, String> _systems = {
    // أنظمة الاختراق
    'exploit': 'ultimate_exploitation_system.dart',
    'web_exploit': 'ultimate_web_exploiter.dart',
    'exploit_engine': 'ultimate_exploit_engine.dart',
    'post_exploit': 'ultimate_post_exploitation_system.dart',
    'privilege_escalation': 'ultimate_privilege_escalation_system.dart',
    'persistence': 'ultimate_persistence_system.dart',

    // أنظمة المراقبة والتجسس
    'surveillance': 'ultimate_surveillance_system.dart',
    'packet_capture': 'ultimate_packet_capture_system.dart',
    'protocol_analyzer': 'ultimate_protocol_analyzer_system.dart',
    'raw_network': 'ultimate_raw_network_system.dart',
    'wireless': 'ultimate_wireless_system.dart',

    // أنظمة الذكاء والتحكم
    'ai_attack': 'ultimate_ai_attack_system.dart',
    'consciousness': 'ultimate_consciousness_system.dart',
    'autonomous_agent': 'ultimate_autonomous_agent_system.dart',
    'botnet': 'ultimate_botnet_system.dart',
    'unified_command': 'ultimate_unified_command_system.dart',

    // أنظمة التخفي والتهرب
    'stealth': 'ultimate_stealth_system.dart',
    'evasion': 'ultimate_evasion_system.dart',

    // أنظمة الهندسة العكسية والتحليل
    'reverse_engineering': 'ultimate_reverse_engineering_system.dart',
    'disassembler': 'ultimate_disassembler_system.dart',
    'debugger': 'ultimate_debugger_system.dart',
    'binary_analyzer': 'ultimate_binary_analyzer_system.dart',
    'forensics': 'ultimate_forensics_system.dart',

    // أنظمة التشفير
    'crypto': 'ultimate_crypto_system.dart',
    'cryptanalysis': 'ultimate_cryptanalysis_system.dart',

    // أنظمة المعلومات والاستخبارات
    'osint': 'ultimate_osint_system.dart',
    'threat_intel': 'ultimate_threat_intel_system.dart',
    'incident_response': 'ultimate_incident_response_system.dart',

    // أنظمة متخصصة
    'social': 'ultimate_physical_social_system.dart',
    'psyops': 'ultimate_psyops_system.dart',
    'iot': 'ultimate_iot_hacking_system.dart',
    'can_bus': 'ultimate_can_bus_system.dart',
    'side_channel': 'ultimate_side_channel_system.dart',
    'electronic_warfare': 'ultimate_electronic_warfare_system.dart',
    'zero_day': 'ultimate_zero_day_discovery_system.dart',

    // أنظمة الجذر والوصول
    'modern_root': 'ultimate_modern_root_system.dart',
    'virtual_root': 'ultimate_virtual_root_system.dart',
    'kernel': 'ultimate_kernel_system.dart',
    'kernel_memory': 'ultimate_kernel_memory_system.dart',
    'mobile_rootkit': 'ultimate_mobile_rootkit_system.dart',
    'android_11_plus_root': 'ultimate_android_11_plus_root_system.dart',

    // أنظمة أخرى
    'ids': 'ultimate_ids_system.dart',
    'auto_propagation': 'ultimate_auto_propagation_system.dart',
    'kali_installer': 'ultimate_kali_installer_system.dart',
    'unified_metasploit': 'ultimate_unified_metasploit_system.dart',
  };

  static List<String> getAllSystems() => _systems.keys.toList();

  static String? getSystemFile(String name) => _systems[name];

  static int get totalSystems => _systems.length;
}
