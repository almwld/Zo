import 'package:flutter/material.dart';

class ZionFileManager extends StatelessWidget {
  const ZionFileManager({super.key});

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
              IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41), size: 18), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30)),
              IconButton(icon: const Icon(Icons.arrow_forward, color: Color(0xFF00FF41), size: 18), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30)),
              IconButton(icon: const Icon(Icons.folder_open, color: Color(0xFF00FF41), size: 18), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30)),
              const SizedBox(width: 8),
              const Expanded(child: Text('/home/zion', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12))),
            ],
          ),
        ),
        // قائمة الملفات
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(4),
            children: [
              _FileItem(icon: Icons.folder, name: 'Desktop', isFolder: true),
              _FileItem(icon: Icons.folder, name: 'Documents', isFolder: true),
              _FileItem(icon: Icons.folder, name: 'Downloads', isFolder: true),
              _FileItem(icon: Icons.folder, name: 'Tools', isFolder: true),
              const Divider(color: Color(0xFF1A3A1A)),
              _FileItem(icon: Icons.description, name: 'readme.txt', isFolder: false),
              _FileItem(icon: Icons.code, name: 'zion_config.yaml', isFolder: false),
              _FileItem(icon: Icons.terminal, name: 'run_nmap.sh', isFolder: false),
            ],
          ),
        ),
        // شريط الحالة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E0A),
            border: Border(top: BorderSide(color: Color(0xFF1A3A1A))),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7 items', style: TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'monospace')),
              Text('Free: 2.1 GB', style: TextStyle(color: Color(0xFF00FF41), fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
        ),
      ],
    );
  }
}

class _FileItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isFolder;
  const _FileItem({required this.icon, required this.name, required this.isFolder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isFolder ? Colors.orange : const Color(0xFF00FF41), size: 20),
      title: Text(name, style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12)),
      dense: true,
      onTap: () {},
    );
  }
}
