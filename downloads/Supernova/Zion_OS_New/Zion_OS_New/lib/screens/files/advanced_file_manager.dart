import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/services/file_service.dart';

class AdvancedFileManager extends StatefulWidget {
  const AdvancedFileManager({super.key});

  @override
  State<AdvancedFileManager> createState() => _AdvancedFileManagerState();
}

class _AdvancedFileManagerState extends State<AdvancedFileManager> {
  late FileService _fileService;
  String _searchQuery = '';
  bool _showHidden = false;
  
  @override
  void initState() {
    super.initState();
    _fileService = FileService();
    _fileService.init();
  }
  
  Future<void> _refresh() async {
    await _fileService.loadItems();
    setState(() {});
  }
  
  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Folder name',
            labelStyle: TextStyle(color: Color(0xFF00BCD4)),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create', style: TextStyle(color: Color(0xFF00BCD4)))),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      await _fileService.createFolder(result);
      await _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder created'), backgroundColor: Color(0xFF00BCD4)),
      );
    }
  }
  
  Future<void> _deleteSelected() async {
    if (_fileService.selectedItems.isEmpty) return;
    
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Files', style: TextStyle(color: Color(0xFF00BCD4))),
        content: Text('Delete ${_fileService.selectedItems.length} item(s)?', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _fileService.deleteItems(_fileService.selectedItems);
      await _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully'), backgroundColor: Color(0xFF00BCD4)),
      );
    }
  }
  
  void _showFileInfo(FileSystemEntity item) async {
    final info = await _fileService.getFileInfo(item);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('File Information', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInfoRow('Name', info['name']),
            _buildInfoRow('Path', info['path']),
            _buildInfoRow('Size', _fileService.formatSize(info['size'])),
            _buildInfoRow('Modified', '${info['modified'].day}/${info['modified'].month}/${info['modified'].year} ${info['modified'].hour}:${info['modified'].minute}'),
            _buildInfoRow('Type', info['isDirectory'] ? 'Folder' : 'File'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _searchQuery.isEmpty
        ? _fileService.items
        : _fileService.items.where((item) =>
            item.path.split('/').last.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
    
    final displayItems = _showHidden
        ? filteredItems
        : filteredItems.where((item) => !item.path.split('/').last.startsWith('.')).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _fileService.currentPath.split('/').last,
          style: const TextStyle(color: Color(0xFF00BCD4)),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => _fileService.isSelecting
              ? setState(() => _fileService.clearSelection())
              : Navigator.pop(context),
        ),
        actions: [
          if (!_fileService.isSelecting) ...[
            IconButton(
              icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00BCD4)),
              onPressed: () => setState(() => _showHidden = !_showHidden),
              tooltip: 'Show hidden files',
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder, color: Color(0xFF00BCD4)),
              onPressed: _createFolder,
              tooltip: 'New folder',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00BCD4)),
              onPressed: _refresh,
              tooltip: 'Refresh',
            ),
          ],
          if (_fileService.isSelecting && _fileService.selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelected,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Column(
        children: [
          // Path Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black.withOpacity(0.8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Color(0xFF00BCD4), size: 18),
                  onPressed: () async {
                    await _fileService.goBack();
                    setState(() {});
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _fileService.currentPath.split('/').asMap().entries.map((entry) {
                        final index = entry.key;
                        final part = entry.value;
                        if (part.isEmpty) return const SizedBox();
                        final path = '/' + _fileService.currentPath.split('/').sublist(0, index + 1).join('/');
                        return GestureDetector(
                          onTap: () async {
                            await _fileService.navigateTo(path);
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              Text(part, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
                              if (index < _fileService.currentPath.split('/').length - 1)
                                const Icon(Icons.chevron_right, color: Color(0xFF00BCD4), size: 16),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                hintText: 'Search files...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // File List
          Expanded(
            child: displayItems.isEmpty
                ? const Center(child: Text('Empty folder', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      final isDirectory = item is Directory;
                      final name = item.path.split('/').last;
                      final isSelected = _fileService.selectedItems.contains(item);
                      
                      return GestureDetector(
                        onTap: () async {
                          if (_fileService.isSelecting) {
                            setState(() => _fileService.toggleSelection(item));
                          } else if (isDirectory) {
                            await _fileService.navigateTo(item.path);
                            setState(() {});
                          } else {
                            _showFileInfo(item);
                          }
                        },
                        onLongPress: () => setState(() => _fileService.toggleSelection(item)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00BCD4).withOpacity(0.2)
                                : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00BCD4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isDirectory ? Icons.folder : _fileService.getFileIcon(name),
                                color: isDirectory ? const Color(0xFF00BCD4) : Colors.white54,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (!isDirectory)
                                      FutureBuilder(
                                        future: _fileService.getFileInfo(item),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final info = snapshot.data!;
                                            return Text(
                                              _fileService.formatSize(info['size']),
                                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Color(0xFF00BCD4), size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
