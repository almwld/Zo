import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordCrackerApp extends StatefulWidget {
  const PasswordCrackerApp({super.key});

  @override
  State<PasswordCrackerApp> createState() => _PasswordCrackerAppState();
}

class _PasswordCrackerAppState extends State<PasswordCrackerApp> {
  final TextEditingController _hashController = TextEditingController();
  final TextEditingController _customWordlistController = TextEditingController();
  String _result = '';
  bool _isCracking = false;
  String _selectedHashType = 'MD5';
  String _selectedAttack = 'Dictionary';

  final List<String> _hashTypes = ['MD5', 'SHA1', 'SHA256'];
  final List<String> _attackTypes = ['Dictionary', 'Brute Force', 'Rainbow Table'];
  
  // قاعدة بيانات Rainbow Tables مبسطة
  final Map<String, String> _rainbowTable = {
    '098f6bcd4621d373cade4e832627b4f6': 'test',
    '5f4dcc3b5aa765d61d8327deb882cf99': 'password',
    '25d55ad283aa400af464c76d713c07ad': '12345678',
    'e10adc3949ba59abbe56e057f20f883e': '123456',
    '21232f297a57a5a743894a0e4a801fc3': 'admin',
    '827ccb0eea8a706c4c34a16891f84e7b': '123123',
  };
  
  final List<String> _dictionary = ['admin', 'password', '123456', 'root', 'toor', 'test', 'qwerty', 'abc123'];

  Future<void> _crackPassword() async {
    final hash = _hashController.text.trim();
    if (hash.isEmpty) {
      setState(() => _result = '⚠️ الرجاء إدخال الهاش');
      return;
    }

    setState(() {
      _isCracking = true;
      _result = 'جاري كسر كلمة المرور...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    String? foundPassword;

    switch (_selectedAttack) {
      case 'Rainbow Table':
        foundPassword = _rainbowTable[hash.toLowerCase()];
        if (foundPassword == null && _customWordlistController.text.isNotEmpty) {
          final customWords = _customWordlistController.text.split(',');
          for (final word in customWords) {
            final testHash = _computeHash(word.trim());
            if (testHash == hash) {
              foundPassword = word.trim();
              break;
            }
          }
        }
        break;
        
      case 'Dictionary':
        final words = _customWordlistController.text.isNotEmpty
            ? _customWordlistController.text.split(',')
            : _dictionary;
        for (final word in words) {
          final testHash = _computeHash(word.trim());
          if (testHash == hash) {
            foundPassword = word.trim();
            break;
          }
        }
        break;
        
      case 'Brute Force':
        foundPassword = await _bruteForce(hash);
        break;
    }

    setState(() {
      _isCracking = false;
      if (foundPassword != null) {
        _result = '✅ تم العثور على كلمة المرور: "$foundPassword"';
      } else {
        _result = '❌ لم يتم العثور على كلمة المرور\nجرب قاموساً أكبر أو هجوماً مختلفاً';
      }
    });
  }

  Future<String?> _bruteForce(String targetHash) async {
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    for (var len = 1; len <= 4; len++) {
      final total = pow(chars.length, len).toInt();
      for (var i = 0; i < total; i++) {
        final candidate = _intToString(i, chars, len);
        final testHash = _computeHash(candidate);
        if (testHash == targetHash) return candidate;
        if (i % 1000 == 0 && mounted) {
          setState(() => _result = 'جاري التجربة: $candidate');
          await Future.delayed(Duration.zero);
        }
      }
    }
    return null;
  }

  String _intToString(int value, String charset, int length) {
    final result = StringBuffer();
    var temp = value;
    for (var i = 0; i < length; i++) {
      result.write(charset[temp % charset.length]);
      temp ~/= charset.length;
    }
    return result.toString();
  }

  String _computeHash(String input) {
    switch (_selectedHashType) {
      case 'MD5':
        return md5.convert(utf8.encode(input)).toString();
      case 'SHA1':
        return sha1.convert(utf8.encode(input)).toString();
      case 'SHA256':
        return sha256.convert(utf8.encode(input)).toString();
      default:
        return md5.convert(utf8.encode(input)).toString();
    }
  }

  void _clear() {
    _hashController.clear();
    _customWordlistController.clear();
    setState(() => _result = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Password Cracker', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // نوع الهاش
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedHashType,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Color(0xFF00FF41)),
                  items: _hashTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedHashType = v!),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // نوع الهجوم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAttack,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Color(0xFF00FF41)),
                  items: _attackTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedAttack = v!),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // حقل الهاش
            TextField(
              controller: _hashController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'الهاش المستهدف',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41), width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            
            // حقل القاموس المخصص
            TextField(
              controller: _customWordlistController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'قاموس مخصص (كلمات مفصولة بفواصل)',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41), width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCracking ? null : _crackPassword,
                    icon: _isCracking ? const SizedBox(width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.vpn_key),
                    label: const Text('كسر كلمة المرور'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF41), foregroundColor: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('مسح'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // النتيجة
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'النتيجة ستظهر هنا...' : _result,
                    style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
