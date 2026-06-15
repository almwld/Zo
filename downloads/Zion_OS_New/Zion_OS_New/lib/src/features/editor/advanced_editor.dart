import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/theme_manager.dart';

class AdvancedEditor extends StatefulWidget {
  const AdvancedEditor({super.key});

  @override
  State<AdvancedEditor> createState() => _AdvancedEditorState();
}

class _AdvancedEditorState extends State<AdvancedEditor> with SingleTickerProviderStateMixin {
  final ThemeManager _themeManager = ThemeManager();
  late TabController _tabController;
  final List<EditorTab> _tabs = [];
  int _nextTabId = 1;
  int _currentTabIndex = 0;
  
  // إعدادات المحرر
  double _fontSize = 14;
  String _fontFamily = 'monospace';
  bool _wordWrap = true;
  bool _showLineNumbers = true;
  bool _autoSave = true;
  String _currentTheme = 'dark';

  @override
  void initState() {
    super.initState();
    _addNewTab();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadSettings();
  }

  void _loadSettings() async {
    // تحميل الإعدادات المحفوظة
    setState(() {
      _fontSize = 14;
      _fontFamily = 'monospace';
      _wordWrap = true;
      _showLineNumbers = true;
    });
  }

  void _addNewTab() {
    final newTab = EditorTab(
      id: _nextTabId++,
      title: 'Untitled',
      content: '',
      filePath: '',
      isModified: false,
    );
    setState(() {
      _tabs.add(newTab);
      _tabController = TabController(length: _tabs.length, vsync: this);
      _tabController.animateTo(_tabs.length - 1);
      _currentTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    final tab = _tabs[index];
    if (tab.isModified) {
      _showSaveDialog(() {
        setState(() {
          _tabs.removeAt(index);
          if (_tabs.isEmpty) _addNewTab();
          _tabController = TabController(length: _tabs.length, vsync: this);
        });
      });
    } else {
      setState(() {
        _tabs.removeAt(index);
        if (_tabs.isEmpty) _addNewTab();
        _tabController = TabController(length: _tabs.length, vsync: this);
      });
    }
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
      _tabController.animateTo(index);
    });
  }

  void _updateContent(String content) {
    setState(() {
      _tabs[_currentTabIndex].content = content;
      _tabs[_currentTabIndex].isModified = true;
    });
  }

  Future<void> _saveCurrentTab() async {
    final tab = _tabs[_currentTabIndex];
    if (tab.filePath.isEmpty) {
      await _saveAs();
    } else {
      final file = File(tab.filePath);
      await file.writeAsString(tab.content);
      setState(() {
        tab.isModified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File saved')),
      );
    }
  }

  Future<void> _saveAs() async {
    // محاكاة حفظ الملف (سيتم تحسينه لاحقاً)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/document_$timestamp.txt';
    final file = File(path);
    await file.writeAsString(_tabs[_currentTabIndex].content);
    setState(() {
      _tabs[_currentTabIndex].filePath = path;
      _tabs[_currentTabIndex].title = 'document_$timestamp.txt';
      _tabs[_currentTabIndex].isModified = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved as: document_$timestamp.txt')),
    );
  }

  Future<void> _openFile() async {
    // محاكاة فتح ملف (سيتم تحسينه لاحقاً)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open file feature coming soon')),
    );
  }

  void _showSaveDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Do you want to save changes?'),
        backgroundColor: Colors.grey.shade900,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveCurrentTab();
              onConfirm();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _cut() {
    final text = _tabs[_currentTabIndex].content;
    // محاكاة القص
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cut (Ctrl+X)')),
    );
  }

  void _copy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copy (Ctrl+C)')),
    );
  }

  void _paste() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paste (Ctrl+V)')),
    );
  }

  void _findAndReplace() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Find and Replace'),
        backgroundColor: Colors.grey.shade900,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Find',
                labelStyle: TextStyle(color: Colors.cyan),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Replace with',
                labelStyle: TextStyle(color: Colors.cyan),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Replace')),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editor Settings'),
        backgroundColor: Colors.grey.shade900,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Font Size', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<double>(
                value: _fontSize,
                items: [10, 12, 14, 16, 18, 20, 24].map((size) => DropdownMenuItem(
                  value: size.toDouble(),
                  child: Text('$size', style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (v) => setState(() => _fontSize = v!),
              ),
            ),
            ListTile(
              title: const Text('Font Family', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: _fontFamily,
                items: ['monospace', 'courier', 'roboto', 'ubuntu'].map((family) => DropdownMenuItem(
                  value: family,
                  child: Text(family, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (v) => setState(() => _fontFamily = v!),
              ),
            ),
            SwitchListTile(
              title: const Text('Word Wrap', style: TextStyle(color: Colors.white)),
              value: _wordWrap,
              onChanged: (v) => setState(() => _wordWrap = v),
            ),
            SwitchListTile(
              title: const Text('Show Line Numbers', style: TextStyle(color: Colors.white)),
              value: _showLineNumbers,
              onChanged: (v) => setState(() => _showLineNumbers = v),
            ),
            SwitchListTile(
              title: const Text('Auto Save', style: TextStyle(color: Colors.white)),
              value: _autoSave,
              onChanged: (v) => setState(() => _autoSave = v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _shareContent() {
    final content = _tabs[_currentTabIndex].content;
    if (content.isNotEmpty) {
      Share.share(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    final currentTab = _tabs[_currentTabIndex];
    final lineCount = currentTab.content.split('\n').length;
    final charCount = currentTab.content.length;
    
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          _buildTabBar(),
          _buildToolbar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showLineNumbers) _buildLineNumbers(lineCount),
                Expanded(
                  child: _wordWrap
                      ? TextField(
                          controller: TextEditingController(text: currentTab.content)
                            ..addListener(() {
                              _updateContent(TextEditingController(text: currentTab.content).text);
                            }),
                          maxLines: null,
                          expands: true,
                          style: TextStyle(color: Colors.white, fontFamily: _fontFamily, fontSize: _fontSize),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          onChanged: _updateContent,
                        )
                      : SingleChildScrollView(
                          child: TextField(
                            controller: TextEditingController(text: currentTab.content)
                              ..addListener(() {
                                _updateContent(TextEditingController(text: currentTab.content).text);
                              }),
                            maxLines: null,
                            style: TextStyle(color: Colors.white, fontFamily: _fontFamily, fontSize: _fontSize),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onChanged: _updateContent,
                          ),
                        ),
                ),
              ],
            ),
          ),
          _buildStatusBar(lineCount, charCount, currentTab.isModified),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade900,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: _themeManager.currentTheme.accent,
              onTap: _switchTab,
              tabs: _tabs.map((tab) => Tab(
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 14),
                    const SizedBox(width: 4),
                    Text(tab.title, maxLines: 1),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _closeTab(_tabs.indexOf(tab)),
                      child: const Icon(Icons.close, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.cyan),
            onPressed: _addNewTab,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 40,
      color: Colors.grey.shade800,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.blue, size: 20),
            onPressed: _openFile,
            tooltip: 'Open',
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.green, size: 20),
            onPressed: _saveCurrentTab,
            tooltip: 'Save',
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.content_cut, color: Colors.orange, size: 20),
            onPressed: _cut,
            tooltip: 'Cut',
          ),
          IconButton(
            icon: const Icon(Icons.content_copy, color: Colors.orange, size: 20),
            onPressed: _copy,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.content_paste, color: Colors.orange, size: 20),
            onPressed: _paste,
            tooltip: 'Paste',
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.cyan, size: 20),
            onPressed: _findAndReplace,
            tooltip: 'Find/Replace',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green, size: 20),
            onPressed: _shareContent,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 20),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbers(int lineCount) {
    return Container(
      width: 40,
      color: Colors.grey.shade900,
      child: ListView.builder(
        itemCount: lineCount,
        itemBuilder: (ctx, i) => Container(
          height: _fontSize * 1.5,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '${i + 1}',
            style: TextStyle(color: Colors.grey, fontSize: _fontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(int lineCount, int charCount, bool isModified) {
    return Container(
      height: 30,
      color: Colors.grey.shade900,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text('Lines: $lineCount', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(width: 16),
          Text('Chars: $charCount', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const Spacer(),
          if (isModified)
            const Text('Modified', style: TextStyle(color: Colors.amber, fontSize: 11)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class EditorTab {
  final int id;
  String title;
  String content;
  String filePath;
  bool isModified;

  EditorTab({
    required this.id,
    required this.title,
    required this.content,
    required this.filePath,
    required this.isModified,
  });
}
