import 'package:riverpod/riverpod.dart';
import '../systems/ultimate_exploitation_system.dart';
import '../systems/ultimate_surveillance_system.dart';
import '../systems/ultimate_botnet_system.dart';
import '../systems/ultimate_reverse_engineering_system.dart';
import '../systems/ultimate_crypto_system.dart';
import '../systems/ultimate_ai_attack_system.dart';
import '../systems/ultimate_osint_system.dart';
import '../systems/ultimate_web_exploiter.dart';
import '../systems/ultimate_physical_social_system.dart';
import '../systems/ultimate_unified_command_system.dart';
import '../systems/ultimate_wireless_system.dart';
import '../systems/ultimate_exploit_engine.dart';
import '../systems/ultimate_forensics_system.dart';
import '../systems/ultimate_post_exploitation_system.dart';
import '../systems/ultimate_psyops_system.dart';
import '../systems/ultimate_autonomous_agent_system.dart';
import '../systems/ultimate_threat_intel_system.dart';
import '../systems/ultimate_stealth_system.dart';
import '../systems/ultimate_incident_response_system.dart';
import '../systems/ultimate_consciousness_system.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final UltimateUnifiedCommandSystem _unified = UltimateUnifiedCommandSystem();
  final UltimateConsciousnessSystem _consciousness = UltimateConsciousnessSystem();
  final UltimateStealthSystem _stealth = UltimateStealthSystem();
  final UltimateCryptoSystem _crypto = UltimateCryptoSystem();
  final UltimateOsintSystem _osint = UltimateOsintSystem();

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      switch (command) {
        case 'start_ai': _consciousness.awaken(); return 'AI Consciousness awakened.';
        case 'stop_ai': _consciousness.sleep(); return 'AI Consciousness sleeping.';
        case 'ai_status': return _consciousness.getStatusReport().toString();
        case 'full_mission': return (await _unified.launchFullMission(target: target ?? '127.0.0.1', aggressive: true)).toString();
        case 'stealth_on': _stealth.enableStealthMode(); return 'Stealth mode enabled.';
        case 'stealth_off': _stealth.disableStealthMode(); return 'Stealth mode disabled.';
        case 'encrypt': return _crypto.aesEncrypt(options?['data'] ?? '', options?['key'] ?? 'default');
        case 'decrypt': return _crypto.aesDecrypt(options?['data'] ?? '', options?['key'] ?? 'default');
        case 'osint': return (await _osint.gatherDomainInfo(target ?? 'google.com')).toString();
        case 'help': return _getHelpText();
        default: return 'Command not found. Type "help" for available commands.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _getHelpText() => '''
=== PROJECT ZION - COMMAND HELP ===
start_ai    - Activate AI consciousness
stop_ai     - Deactivate AI consciousness
ai_status   - Get AI status report
full_mission <target> - Launch full mission
stealth_on  - Enable stealth mode
stealth_off - Disable stealth mode
encrypt     - Encrypt data
decrypt     - Decrypt data
osint <target> - Gather OSINT
help        - Show this help
====================================
''';
}
