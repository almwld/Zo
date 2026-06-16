import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'services/preferences_service.dart';
import 'responsive_desktop.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _enteredPin = '';
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkAndSetDefaultPin();
    // تحديث الساعة كل ثانية
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _now = DateTime.now());
      return true;
    });
  }

  Future<void> _checkAndSetDefaultPin() async {
    final saved = await _secureStorage.read(key: 'user_pin');
    if (saved == null) await _secureStorage.write(key: 'user_pin', value: '1234');
  }

  Future<void> _verifyPin() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    await Future.delayed(const Duration(milliseconds: 500));
    final savedPin = await _secureStorage.read(key: 'user_pin');
    if (_enteredPin == savedPin) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResponsiveDesktop()));
    } else {
      setState(() { _errorMessage = 'lock_screen.incorrect_pin'.tr(); _enteredPin = ''; _isLoading = false; });
    }
  }

  void _addDigit(String d) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += d);
      if (_enteredPin.length == 4) _verifyPin();
    }
  }

  void _deleteDigit() => setState(() { if (_enteredPin.isNotEmpty) _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1); });

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: RadialGradient(colors: [prefs.isDarkMode ? Colors.cyan.shade900 : Colors.cyan.shade100, prefs.isDarkMode ? Colors.black : Colors.white])),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Colors.cyan, Colors.teal]), boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 20)]), child: const Center(child: Text('Z', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)))),
              const SizedBox(height: 40),
              Text(DateFormat('HH:mm').format(_now), style: TextStyle(fontSize: 48 * prefs.fontScale, fontWeight: FontWeight.bold, color: prefs.isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              Text(DateFormat('EEEE, d MMMM y').format(_now), style: TextStyle(fontSize: 16 * prefs.fontScale, color: prefs.isDarkMode ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 50),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(width: 20, height: 20, margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(shape: BoxShape.circle, color: i < _enteredPin.length ? (prefs.isDarkMode ? Colors.white : Colors.black) : Colors.transparent, border: Border.all(color: prefs.isDarkMode ? Colors.white54 : Colors.black54, width: 2))))),
              if (_errorMessage.isNotEmpty) ... [ const SizedBox(height: 20), Text(_errorMessage, style: const TextStyle(color: Colors.red)) ],
              const SizedBox(height: 40),
              _buildNumberPad(prefs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(PreferencesService prefs) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: ['1','2','3'].map((d) => _buildNumberButton(d, prefs)).toList()),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: ['4','5','6'].map((d) => _buildNumberButton(d, prefs)).toList()),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: ['7','8','9'].map((d) => _buildNumberButton(d, prefs)).toList()),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 70), _buildNumberButton('0', prefs), _buildDeleteButton(prefs)]),
    ]);
  }

  Widget _buildNumberButton(String digit, PreferencesService prefs) => Padding(padding: const EdgeInsets.all(8), child: InkWell(onTap: () => _addDigit(digit), child: Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: prefs.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)), child: Center(child: Text(digit, style: TextStyle(fontSize: 28 * prefs.fontScale, fontWeight: FontWeight.bold, color: prefs.isDarkMode ? Colors.white : Colors.black))))));

  Widget _buildDeleteButton(PreferencesService prefs) => Padding(padding: const EdgeInsets.all(8), child: InkWell(onTap: _deleteDigit, child: Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: prefs.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)), child: Icon(Icons.backspace, size: 30, color: prefs.isDarkMode ? Colors.white : Colors.black))));
}
