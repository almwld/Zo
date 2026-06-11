import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/theme_manager.dart';

class AdvancedBrowser extends StatefulWidget {
  const AdvancedBrowser({super.key});

  @override
  State<AdvancedBrowser> createState() => _AdvancedBrowserState();
}

class _AdvancedBrowserState extends State<AdvancedBrowser> with SingleTickerProviderStateMixin {
  final ThemeManager _themeManager = ThemeManager();
  late TabController _tabController;
  final List<BrowserTab> _tabs = [];
  final List<Bookmark> _bookmarks = [];
  final List<String> _history = [];
  int _nextTabId = 1;
  int _currentTabIndex = 0;
  bool _isLoading = false;
  bool _isPrivateMode = false;
  String _currentUrl = 'https://www.google.com';

  @override
  void initState() {
    super.initState();
    _addNewTab();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadBookmarks();
  }

  void _addNewTab({String? url}) {
    final newTab = BrowserTab(
      id: _nextTabId++,
      title: 'New Tab',
      url: url ?? 'https://www.google.com',
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
                final tab = _tabs[_currentTabIndex];
                tab.url = url;
                tab.title = _extractTitleFromUrl(url);
              });
            },
            onPageFinished: (url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              print('WebView error: $error');
            },
          ),
        )
        ..loadRequest(Uri.parse(url ?? 'https://www.google.com')),
    );
    setState(() {
      _tabs.add(newTab);
      _tabController = TabController(length: _tabs.length, vsync: this);
      _tabController.animateTo(_tabs.length - 1);
      _currentTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (_tabs.isEmpty) {
        _addNewTab();
      }
      _tabController = TabController(length: _tabs.length, vsync: this);
      _currentTabIndex = _tabController.index;
    });
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
      _tabController.animateTo(index);
      _currentUrl = _tabs[index].url;
    });
  }

  String _extractTitleFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final host = uri.host.replaceAll('www.', '');
      if (host.isNotEmpty) return host;
    }
    return 'Tab';
  }

  void _loadBookmarks() {
    _bookmarks.addAll([
      Bookmark('Google', 'https://www.google.com', Icons.search),
      Bookmark('GitHub', 'https://github.com', Icons.code),
      Bookmark('YouTube', 'https://youtube.com', Icons.play_circle),
      Bookmark('Wikipedia', 'https://wikipedia.org', Icons.book),
    ]);
  }

  void _addBookmark() {
    final currentTab = _tabs[_currentTabIndex];
    if (!_bookmarks.any((b) => b.url == currentTab.url)) {
      setState(() {
        _bookmarks.add(Bookmark(currentTab.title, currentTab.url, Icons.link));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark added')),
      );
    }
  }

  void _shareCurrentPage() {
    final currentTab = _tabs[_currentTabIndex];
    Share.share('Check out: ${currentTab.title}\n${currentTab.url}');
  }

  void _togglePrivateMode() {
    setState(() {
      _isPrivateMode = !_isPrivateMode;
      if (_isPrivateMode) {
        _history.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPrivateMode ? 'Private Mode ON' : 'Private Mode OFF')),
    );
  }

  void _showBookmarksDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Bookmarks', style: TextStyle(color: Colors.white, fontSize: 18)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _bookmarks.length,
                itemBuilder: (ctx, i) {
                  final bookmark = _bookmarks[i];
                  return ListTile(
                    leading: Icon(bookmark.icon, color: Colors.cyan),
                    title: Text(bookmark.title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(bookmark.url, style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _loadUrl(bookmark.url);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadUrl(String url) {
    var finalUrl = url;
    if (!url.startsWith('http')) {
      finalUrl = 'https://$url';
    }
    final currentTab = _tabs[_currentTabIndex];
    currentTab.controller.loadRequest(Uri.parse(finalUrl));
    setState(() {
      _currentUrl = finalUrl;
    });
    if (!_isPrivateMode) {
      _history.add(finalUrl);
    }
  }

  void _goBack() {
    final currentTab = _tabs[_currentTabIndex];
    currentTab.controller.goBack();
  }

  void _goForward() {
    final currentTab = _tabs[_currentTabIndex];
    currentTab.controller.goForward();
  }

  void _reload() {
    final currentTab = _tabs[_currentTabIndex];
    currentTab.controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          _buildTabBar(),
          _buildAddressBar(),
          Expanded(
            child: _tabs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) => WebViewWidget(controller: tab.controller)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
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
                        const Icon(Icons.tab, size: 14),
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
                onPressed: () => _addNewTab(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade800,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _goForward,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reload,
          ),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: TextEditingController(text: _currentUrl),
              decoration: InputDecoration(
                hintText: 'Enter URL',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.black,
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onSubmitted: _loadUrl,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.amber),
            onPressed: _showBookmarksDialog,
          ),
          IconButton(
            icon: Icon(_isPrivateMode ? Icons.visibility_off : Icons.visibility, color: Colors.white),
            onPressed: _togglePrivateMode,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green),
            onPressed: _shareCurrentPage,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMenu(),
          ),
        ],
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.amber),
              title: const Text('Add Bookmark', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _addBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('History', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Downloads', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showDownloads();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.cyan),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showAbout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('History'),
        backgroundColor: Colors.grey.shade900,
        content: _history.isEmpty
            ? const Text('No history', style: TextStyle(color: Colors.white))
            : SizedBox(
                width: 300,
                height: 300,
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(_history[i], style: const TextStyle(color: Colors.white), maxLines: 1),
                    onTap: () {
                      Navigator.pop(ctx);
                      _loadUrl(_history[i]);
                    },
                  ),
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDownloads() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Downloads'),
        backgroundColor: Colors.grey.shade900,
        content: const Text('Downloads feature coming soon', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zion Browser'),
        backgroundColor: Colors.grey.shade900,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Version: 2.0', style: TextStyle(color: Colors.white)),
            Text('Engine: WebView Flutter', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class BrowserTab {
  final int id;
  String title;
  String url;
  final WebViewController controller;

  BrowserTab({
    required this.id,
    required this.title,
    required this.url,
    required this.controller,
  });
}

class Bookmark {
  final String title;
  final String url;
  final IconData icon;

  Bookmark(this.title, this.url, this.icon);
}
