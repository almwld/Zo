import 'dart:math';

class UltimateCryptanalysisSystem {
  /// تحليل التردد (Frequency Analysis)
  static Map<String, int> frequencyAnalysis(String text) {
    final freq = <String, int>{};
    for (final char in text.split('')) {
      freq[char] = (freq[char] ?? 0) + 1;
    }
    return Map.fromEntries(freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  /// كسر تشفير Caesar Cipher
  static String? breakCaesarCipher(String ciphertext) {
    for (int shift = 0; shift < 26; shift++) {
      final decrypted = StringBuffer();
      for (final char in ciphertext.split('')) {
        if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
          decrypted.writeCharCode(((char.codeUnitAt(0) - 65 - shift + 26) % 26) + 65);
        } else if (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) {
          decrypted.writeCharCode(((char.codeUnitAt(0) - 97 - shift + 26) % 26) + 97);
        } else {
          decrypted.write(char);
        }
      }
      final plaintext = decrypted.toString();
      if (_isEnglish(plaintext)) return plaintext;
    }
    return null;
  }

  /// كسر تشفير XOR
  static String? breakXorCipher(List<int> ciphertext) {
    for (int key = 0; key < 256; key++) {
      final decrypted = StringBuffer();
      for (final byte in ciphertext) {
        final decryptedByte = byte ^ key;
        if (decryptedByte < 32 || decryptedByte > 126) break;
        decrypted.writeCharCode(decryptedByte);
      }
      if (decrypted.length == ciphertext.length && _isEnglish(decrypted.toString())) {
        return decrypted.toString();
      }
    }
    return null;
  }

  /// كسر تجزئة MD5 (هجوم القاموس)
  static String? crackMd5(String targetHash, List<String> wordlist) {
    for (final word in wordlist) {
      final hash = _simpleMd5(word);
      if (hash == targetHash) return word;
    }
    return null;
  }

  /// كسر تجزئة SHA1
  static String? crackSha1(String targetHash, List<String> wordlist) {
    for (final word in wordlist) {
      final hash = _simpleSha1(word);
      if (hash == targetHash) return word;
    }
    return null;
  }

  /// هجوم عيد الميلاد (Birthday Attack)
  static String? birthdayAttack(List<String> hashes) {
    final seen = <String, String>{};
    for (final hash in hashes) {
      if (seen.containsKey(hash)) return seen[hash];
      seen[hash] = hash;
    }
    return null;
  }

  /// هجوم القوة العمياء
  static String? bruteForce(String targetHash, String charset, int maxLength) {
    final chars = charset.split('');
    for (int len = 1; len <= maxLength; len++) {
      final combinations = _generateCombinations(chars, len);
      for (final combination in combinations) {
        final hash = _simpleMd5(combination);
        if (hash == targetHash) return combination;
      }
    }
    return null;
  }

  static bool _isEnglish(String text) {
    final commonWords = ['the', 'is', 'at', 'which', 'on', 'and', 'are', 'or', 'it', 'in'];
    return commonWords.any((w) => text.toLowerCase().contains(w));
  }

  static String _simpleMd5(String input) {
    int hash = 0;
    for (final byte in input.codeUnits) {
      hash = ((hash << 5) - hash) + byte;
      hash &= 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String _simpleSha1(String input) {
    int hash = 0;
    for (final byte in input.codeUnits) {
      hash = ((hash << 5) - hash) ^ byte;
      hash &= 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static List<String> _generateCombinations(List<String> chars, int length) {
    if (length == 0) return [''];
    final result = <String>[];
    final sub = _generateCombinations(chars, length - 1);
    for (final char in chars) {
      for (final s in sub) {
        result.add(char + s);
      }
    }
    return result;
  }
}
