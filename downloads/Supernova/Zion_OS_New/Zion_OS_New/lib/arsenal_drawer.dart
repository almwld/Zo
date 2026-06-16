import 'package:flutter/material.dart';

class ArsenalDrawer extends StatelessWidget {
  const ArsenalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E0A).withOpacity(0.95),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF00FF41).withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text('الترسانة', style: TextStyle(color: Color(0xFF00FF41), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Container(width: 60, height: 2, color: const Color(0xFF00FF41)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _Category(title: 'أنظمة الاختراق', icon: Icons.bug_report, tools: ['SQLi', 'XSS', 'RFI', 'LFI', 'Buffer Overflow']),
                _Category(title: 'أنظمة المراقبة', icon: Icons.videocam, tools: ['Packet Sniffer', 'Keylogger', 'Screen Capture']),
                _Category(title: 'شبكات', icon: Icons.lan, tools: ['Port Scanner', 'DNS Lookup', 'ARP Spoofing']),
                _Category(title: 'لاسلكي', icon: Icons.wifi, tools: ['WiFi Scanner', 'WPS Attack', 'Handshake Capture']),
                _Category(title: 'كالي لينكس', icon: Icons.terminal, tools: ['Nmap', 'Metasploit', 'Hydra', 'John', 'Sqlmap']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Category extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> tools;
  const _Category({required this.title, required this.icon, required this.tools});

  @override
  State<_Category> createState() => _CategoryState();
}

class _CategoryState extends State<_Category> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(widget.icon, color: const Color(0xFF00FF41)),
          title: Text(widget.title, style: const TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF00FF41)),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          ...widget.tools.map((tool) => Padding(
            padding: const EdgeInsets.only(left: 40),
            child: ListTile(
              leading: const Icon(Icons.chevron_left, color: Color(0xFF00FF41), size: 20),
              title: Text(tool, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 14, fontFamily: 'Cairo')),
              onTap: () {},
            ),
          )),
        const Divider(color: Color(0xFF1A3A1A)),
      ],
    );
  }
}
