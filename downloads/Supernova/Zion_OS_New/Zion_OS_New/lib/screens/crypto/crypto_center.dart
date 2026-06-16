import 'package:flutter/material.dart';
import '../../core/services/crypto_service.dart';

class CryptoCenter extends StatefulWidget {
  const CryptoCenter({super.key});

  @override
  State<CryptoCenter> createState() => _CryptoCenterState();
}

class _CryptoCenterState extends State<CryptoCenter> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CryptoService _crypto = CryptoService();
  
  // Hashing
  final TextEditingController _hashInputController = TextEditingController();
  String _hashOutput = '';
  String _selectedHashAlgo = 'MD5';
  
  // Base64
  final TextEditingController _base64InputController = TextEditingController();
  String _base64Output = '';
  String _base64Mode = 'Encode';
  
  // XOR
  final TextEditingController _xorTextController = TextEditingController();
  final TextEditingController _xorKeyController = TextEditingController();
  String _xorOutput = '';
  String _xorMode = 'Encrypt';
  
  // Caesar
  final TextEditingController _caesarTextController = TextEditingController();
  int _caesarShift = 3;
  String _caesarOutput = '';
  
  // Password Generator
  int _passwordLength = 12;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  String _generatedPassword = '';
  
  final List<String> _hashAlgos = ['MD5', 'SHA1', 'SHA256', 'SHA512'];
  final List<String> _base64Modes = ['Encode', 'Decode'];
  final List<String> _xorModes = ['Encrypt', 'Decrypt'];

  void _processHash() {
    final input = _hashInputController.text;
    if (input.isEmpty) {
      setState(() => _hashOutput = 'Please enter text');
      return;
    }
    
    String result;
    switch (_selectedHashAlgo) {
      case 'MD5':
        result = _crypto.md5(input);
        break;
      case 'SHA1':
        result = _crypto.sha1(input);
        break;
      case 'SHA256':
        result = _crypto.sha256(input);
        break;
      case 'SHA512':
        result = _crypto.sha512(input);
        break;
      default:
        result = _crypto.md5(input);
    }
    setState(() => _hashOutput = result);
  }
  
  void _processBase64() {
    final input = _base64InputController.text;
    if (input.isEmpty) {
      setState(() => _base64Output = 'Please enter text');
      return;
    }
    
    String result;
    if (_base64Mode == 'Encode') {
      result = _crypto.base64Encode(input);
    } else {
      result = _crypto.base64Decode(input);
    }
    setState(() => _base64Output = result);
  }
  
  void _processXOR() {
    final text = _xorTextController.text;
    final key = _xorKeyController.text;
    
    if (text.isEmpty) {
      setState(() => _xorOutput = 'Please enter text');
      return;
    }
    if (key.isEmpty) {
      setState(() => _xorOutput = 'Please enter key');
      return;
    }
    
    String result;
    if (_xorMode == 'Encrypt') {
      result = _crypto.xorEncrypt(text, key);
    } else {
      result = _crypto.xorDecrypt(text, key);
    }
    setState(() => _xorOutput = result);
  }
  
  void _processCaesar() {
    final text = _caesarTextController.text;
    if (text.isEmpty) {
      setState(() => _caesarOutput = 'Please enter text');
      return;
    }
    
    final result = _crypto.caesarEncrypt(text, _caesarShift);
    setState(() => _caesarOutput = result);
  }
  
  void _generatePassword() {
    final password = _crypto.generateSecurePassword(
      length: _passwordLength,
    );
    setState(() => _generatedPassword = password);
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Crypto & Security', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.fingerprint), text: 'Hash'),
            Tab(icon: Icon(Icons.code), text: 'Base64'),
            Tab(icon: Icon(Icons.security), text: 'XOR'),
            Tab(icon: Icon(Icons.moving), text: 'Caesar'),
            Tab(icon: Icon(Icons.password), text: 'Generator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHashTab(),
          _buildBase64Tab(),
          _buildXORTab(),
          _buildCaesarTab(),
          _buildGeneratorTab(),
        ],
      ),
    );
  }
  
  Widget _buildHashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedHashAlgo,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Color(0xFF00BCD4)),
                  decoration: const InputDecoration(
                    labelText: 'Algorithm',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  ),
                  items: _hashAlgos.map((algo) => DropdownMenuItem(value: algo, child: Text(algo))).toList(),
                  onChanged: (v) => setState(() => _selectedHashAlgo = v!),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _hashInputController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Input Text',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _processHash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Generate Hash'),
                ),
                if (_hashOutput.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _hashOutput,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
                          onPressed: () => _copyToClipboard(_hashOutput),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBase64Tab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Encode', label: Text('Encode'), icon: Icon(Icons.lock_open)),
                    ButtonSegment(value: 'Decode', label: Text('Decode'), icon: Icon(Icons.lock)),
                  ],
                  selected: {_base64Mode},
                  onSelectionChange: (set) => setState(() => _base64Mode = set.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF00BCD4);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _base64InputController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Input Text',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _processBase64,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_base64Mode == 'Encode' ? 'Encode' : 'Decode'),
                ),
                if (_base64Output.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _base64Output,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
                          onPressed: () => _copyToClipboard(_base64Output),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildXORTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Encrypt', label: Text('Encrypt'), icon: Icon(Icons.lock)),
                    ButtonSegment(value: 'Decrypt', label: Text('Decrypt'), icon: Icon(Icons.lock_open)),
                  ],
                  selected: {_xorMode},
                  onSelectionChange: (set) => setState(() => _xorMode = set.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF00BCD4);
                      }
                      return Colors.transparent;
                    }),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _xorTextController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Text',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _xorKeyController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _processXOR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_xorMode == 'Encrypt' ? 'Encrypt' : 'Decrypt'),
                ),
                if (_xorOutput.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _xorOutput,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
                          onPressed: () => _copyToClipboard(_xorOutput),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCaesarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _caesarTextController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Text',
                    labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Shift: ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _caesarShift.toDouble(),
                        min: 1,
                        max: 25,
                        divisions: 24,
                        activeColor: const Color(0xFF00BCD4),
                        onChanged: (v) => setState(() => _caesarShift = v.toInt()),
                      ),
                    ),
                    Text('$_caesarShift', style: const TextStyle(color: Color(0xFF00BCD4))),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _processCaesar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Encrypt / Decrypt'),
                ),
                if (_caesarOutput.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _caesarOutput,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
                          onPressed: () => _copyToClipboard(_caesarOutput),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('Password Generator', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Length: ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _passwordLength.toDouble(),
                        min: 6,
                        max: 32,
                        divisions: 26,
                        activeColor: const Color(0xFF00BCD4),
                        onChanged: (v) => setState(() => _passwordLength = v.toInt()),
                      ),
                    ),
                    Text('$_passwordLength', style: const TextStyle(color: Color(0xFF00BCD4))),
                  ],
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text('Include Numbers', style: TextStyle(color: Colors.white)),
                  value: _includeNumbers,
                  onChanged: (v) => setState(() => _includeNumbers = v),
                  activeColor: const Color(0xFF00BCD4),
                ),
                SwitchListTile(
                  title: const Text('Include Special Characters', style: TextStyle(color: Colors.white)),
                  value: _includeSpecial,
                  onChanged: (v) => setState(() => _includeSpecial = v),
                  activeColor: const Color(0xFF00BCD4),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _generatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Generate Password'),
                ),
                if (_generatedPassword.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generatedPassword,
                            style: const TextStyle(color: Color(0xFF00BCD4), fontFamily: 'monospace', fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Color(0xFF00BCD4)),
                          onPressed: () => _copyToClipboard(_generatedPassword),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
