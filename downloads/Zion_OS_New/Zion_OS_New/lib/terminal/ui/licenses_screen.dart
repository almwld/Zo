import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({Key? key}) : super(key: key);

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  final List<Map<String, dynamic>> _licenses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    try {
      final licenses = [
        {
          'name': 'Zion Terminal',
          'version': '1.0.0',
          'license': 'GPL-3.0',
          'description': 'Advanced Android terminal emulator with Linux distribution support',
          'homepage': 'https://github.com/zionlab/zion-terminal',
          'copyright': 'Copyright (C) 2024 Zion Lab',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-3.0.txt'),
        },
        {
          'name': 'Termux',
          'version': '0.118.0',
          'license': 'GPL-3.0',
          'description': 'Original terminal emulator application for Android - Primary source and inspiration',
          'homepage': 'https://termux.dev',
          'copyright': 'Copyright (C) 2024 Termux Authors',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-3.0.txt'),
        },
        {
          'name': 'Termux:API',
          'version': '0.50.1',
          'license': 'GPL-3.0',
          'description': 'Termux add-on exposing Android API to command line',
          'homepage': 'https://github.com/termux/termux-api',
          'copyright': 'Copyright (C) 2024 Termux Authors',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-3.0.txt'),
        },
        {
          'name': 'termux-app',
          'version': '0.118.0',
          'license': 'GPL-3.0',
          'description': 'Terminal emulator application and plug-in interfaces',
          'homepage': 'https://github.com/termux/termux-app',
          'copyright': 'Copyright (C) 2024 Termux Authors',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-3.0.txt'),
        },
        {
          'name': 'Flutter',
          'version': '3.24.0',
          'license': 'BSD-3-Clause',
          'description': 'Google\'s UI toolkit for building natively compiled applications',
          'homepage': 'https://flutter.dev',
          'copyright': 'Copyright (C) 2014-2024 Google LLC',
          'fullLicense': '''Copyright 2014 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following
   disclaimer in the documentation and/or other materials provided
   with the distribution.
3. Neither the name of Google LLC nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.''',
        },
        {
          'name': 'Dart',
          'version': '3.5.0',
          'license': 'BSD-3-Clause',
          'description': 'Programming language optimized for building mobile, desktop, server, and web applications',
          'homepage': 'https://dart.dev',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See BSD-3-Clause license',
        },
        {
          'name': 'xterm.dart',
          'version': '4.0.0',
          'license': 'MIT',
          'description': 'A terminal emulator UI for Flutter',
          'homepage': 'https://github.com/TerminalStudio/xterm.dart',
          'copyright': 'Copyright (C) 2024 Terminal Studio',
          'fullLicense': '''MIT License

Copyright (c) 2020 Terminal Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.''',
        },
        {
          'name': 'flutter_bloc',
          'version': '8.1.4',
          'license': 'MIT',
          'description': 'Flutter Widgets that make it easy to implement the BLoC design pattern',
          'homepage': 'https://bloclibrary.dev',
          'copyright': 'Copyright (C) 2024 Felix Angelov',
          'fullLicense': 'See MIT license',
        },
        {
          'name': 'path_provider',
          'version': '2.1.3',
          'license': 'BSD-3-Clause',
          'description': 'Flutter plugin for finding commonly used locations on the filesystem',
          'homepage': 'https://pub.dev/packages/path_provider',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See BSD-3-Clause license',
        },
        {
          'name': 'http',
          'version': '1.2.1',
          'license': 'BSD-3-Clause',
          'description': 'A composable, Future-based library for making HTTP requests',
          'homepage': 'https://pub.dev/packages/http',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See BSD-3-Clause license',
        },
        {
          'name': 'shared_preferences',
          'version': '2.2.3',
          'license': 'BSD-3-Clause',
          'description': 'Flutter plugin for reading and writing simple key-value pairs',
          'homepage': 'https://pub.dev/packages/shared_preferences',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See BSD-3-Clause license',
        },
        {
          'name': 'crypto',
          'version': '3.0.3',
          'license': 'BSD-3-Clause',
          'description': 'Implementations of SHA, MD5, and HMAC cryptographic functions',
          'homepage': 'https://pub.dev/packages/crypto',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See BSD-3-Clause license',
        },
        {
          'name': 'PRoot',
          'version': '5.3.1',
          'license': 'GPL-2.0',
          'description': 'User-space implementation of chroot, mount --bind, and binfmt_misc',
          'homepage': 'https://proot-me.github.io',
          'copyright': 'Copyright (C) 2024 PRoot Authors',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-2.0.txt'),
        },
        {
          'name': 'busybox',
          'version': '1.36.1',
          'license': 'GPL-2.0',
          'description': 'The Swiss Army Knife of Embedded Linux',
          'homepage': 'https://busybox.net',
          'copyright': 'Copyright (C) 2024 BusyBox Authors',
          'fullLicense': await _loadFullLicense('assets/licenses/gpl-2.0.txt'),
        },
        {
          'name': 'Debian',
          'version': '12 (bookworm)',
          'license': 'Various DFSG-compatible',
          'description': 'The Universal Operating System - RootFS images',
          'homepage': 'https://www.debian.org',
          'copyright': 'Copyright (C) 2024 Debian Project',
          'fullLicense': 'See Debian Social Contract and DFSG',
        },
        {
          'name': 'Ubuntu',
          'version': '22.04 LTS',
          'license': 'Various',
          'description': 'Linux distribution based on Debian - RootFS images',
          'homepage': 'https://ubuntu.com',
          'copyright': 'Copyright (C) 2024 Canonical Ltd.',
          'fullLicense': 'See Ubuntu License Policy',
        },
        {
          'name': 'Alpine Linux',
          'version': '3.18',
          'license': 'MIT',
          'description': 'A security-oriented, lightweight Linux distribution - RootFS images',
          'homepage': 'https://alpinelinux.org',
          'copyright': 'Copyright (C) 2024 Alpine Linux Development Team',
          'fullLicense': 'See MIT license',
        },
        {
          'name': 'Noto Sans Arabic',
          'version': '2.013',
          'license': 'OFL-1.1',
          'description': 'Arabic font from the Noto font family',
          'homepage': 'https://fonts.google.com/noto/specimen/Noto+Sans+Arabic',
          'copyright': 'Copyright (C) 2024 Google LLC',
          'fullLicense': 'See SIL Open Font License 1.1',
        },
      ];

      setState(() {
        _licenses.addAll(licenses);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load licenses: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _loadFullLicense(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      return 'License text not available. Please visit the project homepage for full license details.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Source Licenses'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: () => _copyAllLicenses(context),
            tooltip: 'Copy all licenses',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading licenses...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLicenses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _licenses.length,
      itemBuilder: (context, index) {
        final license = _licenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLicenseColor(license['license']),
              child: Text(
                license['name'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              license['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: ${license['version']}'),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getLicenseColor(license['license']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        license['license'],
                        style: TextStyle(
                          fontSize: 11,
                          color: _getLicenseColor(license['license']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _showLicenseDetail(license),
          ),
        );
      },
    );
  }

  void _showLicenseDetail(Map<String, dynamic> license) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            license['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Version: ${license['version']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getLicenseColor(license['license']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        license['license'],
                        style: TextStyle(
                          color: _getLicenseColor(license['license']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  license['description'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (license['homepage'] != null)
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Homepage'),
                  subtitle: Text(license['homepage']),
                  onTap: () {
                    _copyToClipboard(license['homepage'], 'Homepage URL copied');
                  },
                ),
              if (license['copyright'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    license['copyright'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    license['fullLicense'] ?? 'Full license text not available.',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getLicenseColor(String license) {
    switch (license.toLowerCase()) {
      case 'gpl-3.0':
      case 'gpl-2.0':
        return Colors.red;
      case 'mit':
        return Colors.green;
      case 'bsd-3-clause':
      case 'bsd-2-clause':
        return Colors.orange;
      case 'apache-2.0':
        return Colors.blue;
      case 'lgpl-3.0':
      case 'lgpl-2.1':
        return Colors.purple;
      case 'mpl-2.0':
        return Colors.teal;
      case 'ofl-1.1':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _copyAllLicenses(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Zion Terminal - Open Source Licenses');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final license in _licenses) {
      buffer.writeln('${license['name']} ${license['version']}');
      buffer.writeln('License: ${license['license']}');
      buffer.writeln(license['copyright'] ?? '');
      buffer.writeln(license['homepage'] ?? '');
      buffer.writeln();
      buffer.writeln(license['fullLicense'] ?? '');
      buffer.writeln();
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All licenses copied to clipboard')),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
