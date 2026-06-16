import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class UltimateCryptoSystem {
  /// تشفير AES-256 (محاكاة متقدمة)
  static String aesEncrypt(String plaintext, String key) {
    final encrypted = StringBuffer();
    for (int i = 0; i < plaintext.length; i++) {
      final charCode = plaintext.codeUnitAt(i);
      final keyChar = key.codeUnitAt(i % key.length);
      encrypted.writeCharCode((charCode ^ keyChar) & 0xFF);
    }
    return base64Encode(utf8.encode(encrypted.toString()));
  }

  /// فك تشفير AES-256
  static String aesDecrypt(String ciphertext, String key) {
    final decoded = utf8.decode(base64Decode(ciphertext));
    final decrypted = StringBuffer();
    for (int i = 0; i < decoded.length; i++) {
      final charCode = decoded.codeUnitAt(i);
      final keyChar = key.codeUnitAt(i % key.length);
      decrypted.writeCharCode((charCode ^ keyChar) & 0xFF);
    }
    return decrypted.toString();
  }

  /// توليد مفتاح RSA (محاكاة)
  static Map<String, String> generateRsaKeyPair({int bits = 2048}) {
    final random = Random.secure();
    final p = _generateLargePrime(bits ~/ 2, random);
    final q = _generateLargePrime(bits ~/ 2, random);
    final n = p * q;
    final phi = (p - BigInt.one) * (q - BigInt.one);
    final e = BigInt.from(65537);
    final d = _modInverse(e, phi);

    return {
      'public_key': '-----BEGIN PUBLIC KEY-----\n${_toBase64(n)}|${_toBase64(e)}\n-----END PUBLIC KEY-----',
      'private_key': '-----BEGIN PRIVATE KEY-----\n${_toBase64(n)}|${_toBase64(d)}\n-----END PRIVATE KEY-----',
      'bits': bits.toString(),
    };
  }

  /// هجوم تحليل التردد (Frequency Analysis)
  static Map<String, dynamic> frequencyAnalysis(String ciphertext) {
    final freq = <String, int>{};
    final total = ciphertext.length;

    for (final char in ciphertext.split('')) {
      freq[char] = (freq[char] ?? 0) + 1;
    }

    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final analysis = <String, dynamic>{};

    for (final entry in sorted.take(10)) {
      analysis[entry.key] = {
        'count': entry.value,
        'percentage': ((entry.value / total) * 100).toStringAsFixed(2),
      };
    }

    return analysis;
  }

  /// كسر تشفير XOR
  static String? crackXorCipher(List<int> ciphertext) {
    for (int key = 0; key < 256; key++) {
      final decrypted = StringBuffer();
      bool valid = true;

      for (final byte in ciphertext) {
        final decryptedByte = byte ^ key;
        if (decryptedByte < 32 || decryptedByte > 126) {
          if (decryptedByte != 10 && decryptedByte != 13) {
            valid = false;
            break;
          }
        }
        decrypted.writeCharCode(decryptedByte);
      }

      if (valid && decrypted.toString().contains(RegExp(r'[a-zA-Z]{3,}'))) {
        return decrypted.toString();
      }
    }

    return null;
  }

  /// توليد تجزئة SHA-256
  static String sha256(String input) {
    final bytes = utf8.encode(input);
    int h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
    int h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;

    final padded = _padMessage(bytes);
    for (int i = 0; i < padded.length; i += 64) {
      final chunk = padded.sublist(i, i + 64);
      final w = List<int>.filled(64, 0);
      for (int t = 0; t < 16; t++) {
        w[t] = (chunk[t * 4] << 24) | (chunk[t * 4 + 1] << 16) | (chunk[t * 4 + 2] << 8) | chunk[t * 4 + 3];
      }
      for (int t = 16; t < 64; t++) {
        w[t] = (_sigma1(w[t - 2]) + w[t - 7] + _sigma0(w[t - 15]) + w[t - 16]) & 0xFFFFFFFF;
      }

      int a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
      for (int t = 0; t < 64; t++) {
        final t1 = (h + _sigmaE1(e) + _ch(e, f, g) + _k[t] + w[t]) & 0xFFFFFFFF;
        final t2 = (_sigmaA0(a) + _maj(a, b, c)) & 0xFFFFFFFF;
        h = g; g = f; f = e; e = (d + t1) & 0xFFFFFFFF;
        d = c; c = b; b = a; a = (t1 + t2) & 0xFFFFFFFF;
      }
      h0 = (h0 + a) & 0xFFFFFFFF; h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF; h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF; h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF; h7 = (h7 + h) & 0xFFFFFFFF;
    }

    return '${h0.toRadixString(16).padLeft(8, '0')}${h1.toRadixString(16).padLeft(8, '0')}${h2.toRadixString(16).padLeft(8, '0')}${h3.toRadixString(16).padLeft(8, '0')}${h4.toRadixString(16).padLeft(8, '0')}${h5.toRadixString(16).padLeft(8, '0')}${h6.toRadixString(16).padLeft(8, '0')}${h7.toRadixString(16).padLeft(8, '0')}';
  }

  static int _sigma0(int x) => (_rotr(x, 7) ^ _rotr(x, 18) ^ (x >> 3)) & 0xFFFFFFFF;
  static int _sigma1(int x) => (_rotr(x, 17) ^ _rotr(x, 19) ^ (x >> 10)) & 0xFFFFFFFF;
  static int _sigmaA0(int x) => (_rotr(x, 2) ^ _rotr(x, 13) ^ _rotr(x, 22)) & 0xFFFFFFFF;
  static int _sigmaE1(int x) => (_rotr(x, 6) ^ _rotr(x, 11) ^ _rotr(x, 25)) & 0xFFFFFFFF;
  static int _ch(int x, int y, int z) => (x & y) ^ (~x & z) & 0xFFFFFFFF;
  static int _maj(int x, int y, int z) => (x & y) ^ (x & z) ^ (y & z) & 0xFFFFFFFF;
  static int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF;

  static final List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  static List<int> _padMessage(List<int> bytes) {
    final ml = bytes.length;
    final padded = List<int>.from(bytes)..add(0x80);
    while ((padded.length * 8) % 512 != 448) {
      padded.add(0);
    }
    final bitLength = ml * 8;
    padded.addAll([
      (bitLength >> 56) & 0xFF, (bitLength >> 48) & 0xFF,
      (bitLength >> 40) & 0xFF, (bitLength >> 32) & 0xFF,
      (bitLength >> 24) & 0xFF, (bitLength >> 16) & 0xFF,
      (bitLength >> 8) & 0xFF, bitLength & 0xFF,
    ]);
    return padded;
  }

  static BigInt _generateLargePrime(int bits, Random random) {
    while (true) {
      final candidate = BigInt.from(random.nextInt(1 << (bits - 1))) | (BigInt.one << (bits - 1));
      if (_isPrime(candidate)) return candidate;
    }
  }

  static bool _isPrime(BigInt n, {int iterations = 5}) {
    if (n == BigInt.two) return true;
    if (n < BigInt.two || n.isEven) return false;

    BigInt d = n - BigInt.one;
    int s = 0;
    while (d.isEven) { d >>= 1; s++; }

    for (int i = 0; i < iterations; i++) {
      final a = BigInt.from(Random().nextInt(1000000) + 2);
      BigInt x = a.modPow(d, n);
      if (x == BigInt.one || x == n - BigInt.one) continue;
      for (int r = 0; r < s - 1; r++) {
        x = x.modPow(BigInt.two, n);
        if (x == n - BigInt.one) break;
      }
      if (x != n - BigInt.one) return false;
    }
    return true;
  }

  static BigInt _modInverse(BigInt a, BigInt m) {
    BigInt m0 = m, y = BigInt.zero, x = BigInt.one;
    if (m == BigInt.one) return BigInt.zero;
    while (a > BigInt.one) {
      final q = a ~/ m;
      var t = m;
      m = a % m;
      a = t;
      t = y;
      y = x - q * y;
      x = t;
    }
    if (x < BigInt.zero) x += m0;
    return x;
  }

  static String _toBase64(BigInt number) => base64Encode(utf8.encode(number.toString()));
}
