import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/tool.dart';
import '../../core/services/unified_core_service.dart';
import '../../core/tool_registry.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TOOL RUNNER SCREEN - Dynamic Tool Execution Interface
// ═══════════════════════════════════════════════════════════════════════════
// This is the main interface for running any tool from the registry.
// It dynamically generates input fields based on tool parameters and
// displays results in a formatted terminal-like output.
// ═══════════════════════════════════════════════════════════════════════════

/// Provider for the currently running tool
final activeToolProvider = StateProvider<Tool?>((ref) => null);

/// Provider for execution output text
final executionOutputProvider = StateProvider<String>((ref) => '');

/// Provider for execution status
final executionStatusProvider = StateProvider<ExecutionStatus>((ref) =>
    ExecutionStatus.idle);

enum ExecutionStatus { idle, running, completed, error }

class ToolRunnerScreen extends ConsumerStatefulWidget {
  final Tool? tool;

  const ToolRunnerScreen({super.key, this.tool});

  @override
  ConsumerState<ToolRunnerScreen> createState() => _ToolRunnerScreenState();
}

class _ToolRunnerScreenState extends ConsumerState<ToolRunnerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final ScrollController _outputScrollController = ScrollController();
  bool _isRunning = false;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controllers with tool parameters
    if (widget.tool?.parameters != null) {
      for (final entry in widget.tool!.parameters!.entries) {
        _controllers[entry.key] =
            TextEditingController(text: entry.value.toString());
      }
    }

    // Set active tool
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeToolProvider.notifier).state = widget.tool;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _outputScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;

    if (tool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tool Runner')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build_circle, size: 64, color: Color(0xFF8B949E)),
              SizedBox(height: 16),
              Text(
                'Select a tool to run',
                style: TextStyle(color: Color(0xFF8B949E), fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tool.name,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              tool.arabicName,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B949E),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tool.category.color,
          labelColor: tool.category.color,
          unselectedLabelColor: const Color(0xFF8B949E),
          tabs: const [
            Tab(icon: Icon(Icons.play_arrow), text: 'Run'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
        actions: [
          if (_output.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy output',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _output));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Output copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          if (_output.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear output',
              onPressed: () {
                setState(() {
                  _output = '';
                });
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Run Tab ───────────────────────
          _buildRunTab(tool),
          // ── Info Tab ──────────────────────
          _buildInfoTab(tool),
          // ── History Tab ───────────────────
          _buildHistoryTab(tool),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RUN TAB
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildRunTab(Tool tool) {
    return Column(
      children: [
        // ── Parameters Section ──────────
        if (tool.parameters != null && tool.parameters!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(
                bottom: BorderSide(color: Color(0xFF30363D)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: tool.category.color),
                    const SizedBox(width: 8),
                    Text(
                      'Parameters',
                      style: TextStyle(
                        color: tool.category.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        // Reset to defaults
                        if (tool.parameters != null) {
                          for (final entry in tool.parameters!.entries) {
                            _controllers[entry.key]?.text =
                                entry.value.toString();
                          }
                        }
                      },
                      icon: const Icon(Icons.restore, size: 14),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...tool.parameters!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _controllers[entry.key],
                      decoration: InputDecoration(
                        labelText: entry.key,
                        hintText: 'Enter ${entry.key}...',
                        hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                        prefixIcon: Icon(
                          _getParameterIcon(entry.key),
                          color: const Color(0xFF8B949E),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D1117),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF30363D)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF30363D)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: tool.category.color,
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFE6EDF3),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        // ── Execute Button ──────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : () => _executeTool(tool),
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Running...' : 'Execute Tool'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tool.category.color,
                foregroundColor: const Color(0xFF0D1117),
                disabledBackgroundColor: tool.category.color.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // ── Output Section ──────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Output header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161B22),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terminal,
                          size: 14, color: Color(0xFF8B949E)),
                      const SizedBox(width: 8),
                      const Text(
                        'Output',
                        style: TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_output.isNotEmpty)
                        Text(
                          '${_output.length} chars',
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                // Output content
                Expanded(
                  child: _output.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.terminal,
                                size: 48,
                                color: Color(0xFF30363D),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Output will appear here',
                                style: TextStyle(
                                  color: Color(0xFF8B949E),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Configure parameters and click Execute',
                                style: TextStyle(
                                  color: Color(0xFF30363D),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          controller: _outputScrollController,
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            _output,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFF00E676),
                              height: 1.5,
                            ),
                          ),
                        ),
                ),n              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // INFO TAB
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildInfoTab(Tool tool) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tool icon and name
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: tool.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  tool.icon,
                  size: 40,
                  color: tool.category.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tool.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6EDF3),
                ),
              ),
              Text(
                tool.arabicName,
                style: TextStyle(
                  fontSize: 18,
                  color: tool.category.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category badge
        _InfoSection(
          title: 'Category',
          child: Row(
            children: [
              Icon(tool.category.icon, color: tool.category.color, size: 20),
              const SizedBox(width: 8),
              Text(
                tool.category.englishName,
                style: TextStyle(color: tool.category.color, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: tool.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tool.category.arabicName,
                  style: TextStyle(
                    color: tool.category.color,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Description
        _InfoSection(
          title: 'Description',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tool.description,
                style: const TextStyle(
                  color: Color(0xFFE6EDF3),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tool.arabicDescription,
                style: const TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Parameters
        if (tool.parameters != null && tool.parameters!.isNotEmpty)
          _InfoSection(
            title: 'Parameters',
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: tool.parameters!.entries.map((entry) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(color: Color(0xFF8B949E)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

        // Execution info
        _InfoSection(
          title: 'Execution Info',
          child: Column(
            children: [
              _InfoRow(
                label: 'Tool ID',
                value: tool.id,
              ),
              _InfoRow(
                label: 'Requires Root',
                value: tool.requiresRoot ? 'Yes' : 'No',
                valueColor: tool.requiresRoot
                    ? const Color(0xFFF85149)
                    : const Color(0xFF00E676),
              ),
              _InfoRow(
                label: 'Implemented',
                value: tool.isImplemented ? 'Yes' : 'No',
                valueColor: tool.isImplemented
                    ? const Color(0xFF00E676)
                    : const Color(0xFFF85149),
              ),
              _InfoRow(
                label: 'Route',
                value: tool.route,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HISTORY TAB
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHistoryTab(Tool tool) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: const Color(0xFF30363D)),
          const SizedBox(height: 16),
          const Text(
            'Execution History',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'History will be available in future updates',
            style: TextStyle(
              color: Color(0xFF30363D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // EXECUTION
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _executeTool(Tool tool) async {
    setState(() {
      _isRunning = true;
      _output = 'Initializing ${tool.name}...\n';
    });

    // Collect parameters
    final params = <String, String>{};
    for (final entry in _controllers.entries) {
      params[entry.key] = entry.value.text;
    }

    try {
      final service = ref.read(unifiedCoreServiceProvider);

      setState(() {
        _output += 'Executing with parameters: $params\n';
        _output += '${'=' * 50}\n\n';
      });

      final result = await service.execute(
        command: tool.id,
        params: params,
      );

      setState(() {
        _output += result.output;
        _output += '\n${'=' * 50}\n';
        _output += 'Execution: ${result.success ? "SUCCESS" : "FAILED"}\n';
        _output += 'Duration: ${result.executionTime.inMilliseconds}ms\n';
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_outputScrollController.hasClients) {
          _outputScrollController.animateTo(
            _outputScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _output += '\nERROR: $e\n';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  IconData _getParameterIcon(String paramName) {
    final lower = paramName.toLowerCase();
    if (lower.contains('url') || lower.contains('host') || lower.contains('target'))
      return Icons.link;
    if (lower.contains('port')) return Icons.settings_ethernet;
    if (lower.contains('ip')) return Icons.router;
    if (lower.contains('key') || lower.contains('password'))
      return Icons.vpn_key;
    if (lower.contains('input') || lower.contains('text') || lower.contains('data'))
      return Icons.text_fields;
    if (lower.contains('file')) return Icons.insert_drive_file;
    if (lower.contains('domain')) return Icons.domain;
    if (lower.contains('timeout')) return Icons.timer;
    if (lower.contains('count')) return Icons.format_list_numbered;
    return Icons.edit;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00E676),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Color(0xFF30363D)),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFFE6EDF3),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
