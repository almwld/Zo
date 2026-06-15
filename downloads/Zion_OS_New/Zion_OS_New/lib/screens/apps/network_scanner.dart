import 'package:flutter/material.dart';
import '../../core/network/network_engine.dart';

class NetworkScannerApp extends StatefulWidget {
  const NetworkScannerApp({super.key});

  @override
  State<NetworkScannerApp> createState() => _NetworkScannerAppState();
}

class _NetworkScannerAppState extends State<NetworkScannerApp> {
  final TextEditingController _subnetController = TextEditingController(text: '192.168.1');
  final TextEditingController _hostController = TextEditingController(text: '192.168.1.1');
  String _output = '';
  bool _isScanning = false;

  Future<void> _scanNetwork() async {
    setState(() {
      _isScanning = true;
      _output = '🔍 جاري فحص الشبكة الفرعية ${_subnetController.text}.0/24...\n\n';
    });
    
    final hosts = await NetworkEngine.pingSweep(_subnetController.text);
    
    setState(() {
      _output += '✅ تم العثور على ${hosts.length} جهاز نشط:\n\n';
      if (hosts.isEmpty) {
        _output += '   ❌ لا توجد أجهزة نشطة\n';
      } else {
        for (final host in hosts) {
          _output += '   📡 $host\n';
        }
      }
      _output += '\n⏱️ اكتمل الفحص';
      _isScanning = false;
    });
  }

  Future<void> _scanPorts() async {
    final ports = [21, 22, 23, 25, 53, 80, 443, 8080, 3306, 5432, 27017];
    setState(() {
      _isScanning = true;
      _output = '🔍 جاري فحص المنافذ على ${_hostController.text}...\n\n';
    });
    
    final openPorts = await NetworkEngine.scanPorts(_hostController.text, ports);
    
    setState(() {
      _output += '✅ نتائج فحص ${_hostController.text}:\n\n';
      if (openPorts.isEmpty) {
        _output += '   ❌ لا توجد منافذ مفتوحة\n';
      } else {
        for (final port in openPorts) {
          _output += '   🔓 المنفذ $port مفتوح\n';
        }
      }
      _output += '\n⏱️ اكتمل الفحص';
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Network Scanner', style: TextStyle(color: Color(0xFF00FF41))),
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
            TextField(
              controller: _subnetController,
              style: const TextStyle(color: Color(0xFF00FF41), fontSize: 16),
              decoration: const InputDecoration(
                labelText: '🌐 الشبكة الفرعية (مثال: 192.168.1)',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41), width: 2)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _hostController,
              style: const TextStyle(color: Color(0xFF00FF41), fontSize: 16),
              decoration: const InputDecoration(
                labelText: '🎯 المضيف المستهدف (للمنافذ)',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF41), width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanNetwork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF41),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('📡 فحص الشبكة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanPorts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF41),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('🔓 فحص المنافذ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isScanning)
              const LinearProgressIndicator(color: Color(0xFF00FF41)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 13),
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
