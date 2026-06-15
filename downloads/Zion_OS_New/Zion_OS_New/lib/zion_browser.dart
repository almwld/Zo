import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZionBrowser extends StatefulWidget {
  const ZionBrowser({super.key});

  @override
  State<ZionBrowser> createState() => _ZionBrowserState();
}

class _ZionBrowserState extends State<ZionBrowser> {
  final TextEditingController _urlCtrl = TextEditingController(text: 'https://google.com');
  String _currentUrl = 'https://google.com';
  bool _isSecure = true;

  void _navigate() {
    String url = _urlCtrl.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    setState(() {
      _currentUrl = url;
      _isSecure = url.startsWith('https://');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط العنوان
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E0A),
            border: Border(bottom: BorderSide(color: Color(0xFF1A3A1A))),
          ),
          child: Row(
            children: [
              // أزرار التنقل
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41), size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF00FF41), size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF00FF41), size: 18),
                onPressed: _navigate,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              // أيقونة القفل
              Icon(
                _isSecure ? Icons.lock : Icons.lock_open,
                color: _isSecure ? Colors.green : Colors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              // حقل URL
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onSubmitted: (_) => _navigate(),
                ),
              ),
              // زر البحث
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF00FF41), size: 18),
                onPressed: _navigate,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
            ],
          ),
        ),
        // منطقة العرض (محاكاة بسيطة)
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Zion Browser',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUrl,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المتصفح الكامل قيد التطوير...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ),
        // شريط الحالة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E0A),
            border: Border(top: BorderSide(color: Color(0xFF1A3A1A))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_currentUrl, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'monospace')),
              const Text('Done', style: TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
        ),
      ],
    );
  }
}
