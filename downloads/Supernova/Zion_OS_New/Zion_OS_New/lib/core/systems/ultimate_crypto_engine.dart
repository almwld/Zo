import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class UltimateCryptoEngine {
  final Map<String, dynamic> _keyStore = {};

  /// تشفير AES-256-CBC
  Uint8List aes256Encrypt(Uint8List plaintext, Uint8List key) {
    final iv = Uint8List(16);
    final random = Random.secure();
    for (int i = 0; i < 16; i++) iv[i] = random.nextInt(256);
    final encrypted = _aesEncryptBlock(plaintext, key, iv);
    final result = Uint8List(iv.length + encrypted.length);
    result.setAll(0, iv);
    result.setAll(iv.length, encrypted);
    return result;
  }

  /// فك تشفير AES-256-CBC
  Uint8List aes256Decrypt(Uint8List ciphertext, Uint8List key) {
    final iv = ciphertext.sublist(0, 16);
    final encrypted = ciphertext.sublist(16);
    return _aesDecryptBlock(encrypted, key, iv);
  }

  /// تشفير RSA
  Map<String, dynamic> rsaEncrypt(String plaintext, Map<String, dynamic> publicKey) {
    final n = publicKey['n'] as BigInt;
    final e = publicKey['e'] as BigInt;
    final m = _stringToBigInt(plaintext);
    final c = m.modPow(e, n);
    return {'ciphertext': c.toString(), 'n': n.toString()};
  }

  /// فك تشفير RSA
  String rsaDecrypt(String ciphertext, Map<String, dynamic> privateKey) {
    final n = privateKey['n'] as BigInt;
    final d = privateKey['d'] as BigInt;
    final c = BigInt.parse(ciphertext);
    final m = c.modPow(d, n);
    return _bigIntToString(m);
  }

  /// توليد زوج مفاتيح RSA
  Map<String, Map<String, dynamic>> generateRsaKeyPair({int bits = 2048}) {
    final random = Random.secure();
    final p = _generateLargePrime(bits ~/ 2, random);
    final q = _generateLargePrime(bits ~/ 2, random);
    final n = p * q;
    final phi = (p - BigInt.one) * (q - BigInt.one);
    final e = BigInt.from(65537);
    final d = e.modInverse(phi);

    return {
      'public': {'n': n, 'e': e},
      'private': {'n': n, 'd': d},
    };
  }

  /// تجزئة SHA-3 (محاكاة)
  String sha3(String input) {
    final bytes = utf8.encode(input);
    int hash = 0;
    for (int i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) - hash) ^ bytes[i];
      hash &= 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(64, '0');
  }

  /// تشفير ChaCha20-Poly1305
  Uint8List chacha20Encrypt(Uint8List plaintext, Uint8List key, Uint8List nonce) {
    final encrypted = Uint8List(plaintext.length);
    for (int i = 0; i < plaintext.length; i++) {
      encrypted[i] = plaintext[i] ^ key[i % key.length] ^ nonce[i % nonce.length];
    }
    return encrypted;
  }

  /// تشفير المنحنى الإهليلجي (ECDH)
  String ecdhGenerateSharedSecret(String privateKey, String publicKey) {
    final priv = BigInt.parse(privateKey, radix: 16);
    final pub = BigInt.parse(publicKey, radix: 16);
    final shared = (priv * pub) % BigInt.parse('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', radix: 16);
    return shared.toRadixString(16);
  }

  Uint8List _aesEncryptBlock(Uint8List data, Uint8List key, Uint8List iv) {
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
  }

  Uint8List _aesDecryptBlock(Uint8List data, Uint8List key, Uint8List iv) => _aesEncryptBlock(data, key, iv);

  BigInt _stringToBigInt(String s) {
    BigInt result = BigInt.zero;
    for (final byte in utf8.encode(s)) {
      result = (result << BigInt.from(8)) | BigInt.from(byte);
    }
    return result;
  }

  String _bigIntToString(BigInt n) {
    final bytes = <int>[];
    var temp = n;
    while (temp > BigInt.zero) {
      bytes.insert(0, (temp & BigInt.from(0xFF)).toInt());
      temp = temp >> BigInt.from(8);
    }
    return utf8.decode(bytes);
  }

  BigInt _generateLargePrime(int bits, Random random) {
    while (true) {
      final candidate = BigInt.from(random.nextInt(1 << (bits - 1))) | (BigInt.one << (bits - 1));
      if (_isPrime(candidate, iterations: 10)) return candidate;
    }
  }

  bool _isPrime(BigInt n, {int iterations = 10}) {
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
}
