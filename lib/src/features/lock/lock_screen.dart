import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to unlock Zion OS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Biometric not available');
    }
  }

  void _unlockWithPin() {
    if (_pinController.text == '1234') {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = 'Wrong PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00FF41), Colors.black],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'ZION OS',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00FF41)),
                  ),
                  child: Column(
                    children: [
                      const Text('Enter PIN to Unlock', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '****',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00FF41)),
                          ),
                        ),
                        onSubmitted: (_) => _unlockWithPin(),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _authenticateWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Use Fingerprint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF41),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
