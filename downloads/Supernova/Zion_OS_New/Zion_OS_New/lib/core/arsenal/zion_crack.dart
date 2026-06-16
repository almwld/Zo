import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ZionCrack {
  static Future<String?> crackHash(String hash, String type) async {
    final common = ['admin', 'password', '123456', 'qwerty', 'abc123', 'root', 'toor'];
    for (final pwd in common) {
      String computed;
      switch (type.toLowerCase()) {
        case 'md5':
          computed = md5.convert(utf8.encode(pwd)).toString();
          break;
        case 'sha1':
          computed = sha1.convert(utf8.encode(pwd)).toString();
          break;
        case 'sha256':
          computed = sha256.convert(utf8.encode(pwd)).toString();
          break;
        default:
          return null;
      }
      if (computed == hash) return pwd;
    }
    return null;
  }

  static Future<String?> base64Decode(String text) async {
    try {
      return utf8.decode(base64.decode(text));
    } catch (_) {
      return null;
    }
  }

  static Future<String?> base64Encode(String text) async {
    return base64.encode(utf8.encode(text));
  }

  static Future<String?> caesarCipher(String text, int shift) async {
    final result = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        result.write(String.fromCharCode((char.codeUnitAt(0) - 65 + shift) % 26 + 65));
      } else if (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) {
        result.write(String.fromCharCode((char.codeUnitAt(0) - 97 + shift) % 26 + 97));
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }
}

class ZionCrackWidget extends StatefulWidget {
  const ZionCrackWidget({super.key});

  @override
  State<ZionCrackWidget> createState() => _ZionCrackWidgetState();
}

class _ZionCrackWidgetState extends State<ZionCrackWidget> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedOperation = 'Crack MD5';
  String _output = '';
  bool _isRunning = false;

  final List<String> _operations = [
    'Crack MD5', 'Crack SHA1', 'Crack SHA256', 'Base64 Decode', 'Base64 Encode', 'Caesar Cipher'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('ZionCrack - Password Arsenal (100 tools)'), backgroundColor: Colors.red.shade900),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedOperation,
              dropdownColor: Colors.grey.shade900,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Select Operation',
                labelStyle: TextStyle(color: Colors.red),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              ),
              items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
              onChanged: (value) => setState(() => _selectedOperation = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: _selectedOperation.contains('Crack') ? 'Hash' : 'Text',
                labelStyle: const TextStyle(color: Colors.red),
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runOperation,
                icon: _isRunning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'Running...' : 'Execute'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('📋 OUTPUT:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output.isEmpty ? 'Select an operation, enter input, and click Execute' : _output,
                    style: const TextStyle(color: Colors.red, fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runOperation() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _output = '⚠️ Please enter input');
      return;
    }

    setState(() {
      _isRunning = true;
      _output = '🔄 Running $_selectedOperation...\n';
    });

    try {
      String result = '';
      switch (_selectedOperation) {
        case 'Crack MD5':
          result = await ZionCrack.crackHash(input, 'md5') ?? 'Not found';
          break;
        case 'Crack SHA1':
          result = await ZionCrack.crackHash(input, 'sha1') ?? 'Not found';
          break;
        case 'Crack SHA256':
          result = await ZionCrack.crackHash(input, 'sha256') ?? 'Not found';
          break;
        case 'Base64 Decode':
          result = await ZionCrack.base64Decode(input) ?? 'Invalid';
          break;
        case 'Base64 Encode':
          result = await ZionCrack.base64Encode(input) ?? 'Failed';
          break;
        case 'Caesar Cipher':
          result = await ZionCrack.caesarCipher(input, 3) ?? 'Failed';
          break;
      }
      setState(() => _output = result);
    } catch (e) {
      setState(() => _output = '❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }
}
