// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║                         Zion OS Terminal                                   ║
// ║                    Terminal Toolbar - شريط الأدوات                        ║
// ║                                                                            ║
// ║  Author: MiniMax Agent                                                     ║
// ║  Version: 1.0.0                                                            ║
// ║  Description: شريط الأدوات العلوي للطرفية                                   ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_manager.dart';
import '../services/theme_manager.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///                    TerminalToolbar - شريط الأدوات
///                    Terminal Toolbar Widget
/// ═══════════════════════════════════════════════════════════════════════════

class TerminalToolbar extends StatelessWidget {
  const TerminalToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          //                      زر تبديل اللغة
          // ═══════════════════════════════════════════════════════════════════

          _ToolbarButton(
            icon: LanguageManager.isArabic ? Icons.translate : Icons.language,
            tooltip: LanguageManager.t('settings.language'),
            onPressed: () async {
              await LanguageManager.toggleLanguage();
            },
          ),

          const SizedBox(width: 4),

          // ═══════════════════════════════════════════════════════════════════
          //                      أزرار المفاتيح
          // ═══════════════════════════════════════════════════════════════════

          _buildKeyButton(context, LanguageManager.t('toolbar.ctrl'), 'Ctrl'),
          _buildKeyButton(context, LanguageManager.t('toolbar.alt'), 'Alt'),
          _buildKeyButton(context, LanguageManager.t('toolbar.tab'), 'Tab'),
          _buildKeyButton(context, LanguageManager.t('toolbar.esc'), 'Esc'),

          const Spacer(),

          // ═══════════════════════════════════════════════════════════════════
          //                      زر المساعد الذكي
          // ═══════════════════════════════════════════════════════════════════

          _ToolbarButton(
            icon: Icons.psychology,
            tooltip: LanguageManager.t('ai.assistant'),
            color: Colors.green,
            onPressed: () {
              _showAIAssistantDialog(context);
            },
          ),

          const SizedBox(width: 4),

          // ═══════════════════════════════════════════════════════════════════
          //                      زر الإعدادات
          // ═══════════════════════════════════════════════════════════════════

          _ToolbarButton(
            icon: Icons.settings,
            tooltip: LanguageManager.t('settings'),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),

          const SizedBox(width: 4),

          // ═══════════════════════════════════════════════════════════════════
          //                      زر حول
          // ═══════════════════════════════════════════════════════════════════

          _ToolbarButton(
            icon: Icons.info_outline,
            tooltip: LanguageManager.t('about'),
            onPressed: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(BuildContext context, String label, String key) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showAIAssistantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.green),
            const SizedBox(width: 8),
            Text(LanguageManager.t('ai.assistant')),
          ],
        ),
        content: const SizedBox(
          width: 400,
          height: 300,
          child: Center(
            child: Text('AI Assistant Panel'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.t('messages.cancel')),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageManager.t('settings')),
        content: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager.t('messages.theme') ?? 'Theme',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemeManager.allThemes.map((themeInfo) {
                  return InkWell(
                    onTap: () {
                      ThemeManager.setTheme(themeInfo.name);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeInfo.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeInfo.color),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: themeInfo.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            themeInfo.name,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.t('messages.cancel')),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.terminal, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Zion OS Terminal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Author: MiniMax Agent'),
            const SizedBox(height: 8),
            const Text(
              'Advanced Bilingual Terminal Emulator\n'
              'with AI-powered command translation',
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Arabic/English bilingual support'),
            const Text('• AI command translation'),
            const Text('• Multiple Linux distributions'),
            const Text('• Package management'),
            const Text('• Security analysis'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LanguageManager.t('messages.confirm')),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
///                    _ToolbarButton - زر شريط الأدوات
///                    Toolbar Button Widget
/// ═══════════════════════════════════════════════════════════════════════════

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.white70, size: 20),
        onPressed: onPressed,
        splashRadius: 16,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//                      نهاية الملف: terminal_toolbar.dart
// ═══════════════════════════════════════════════════════════════════════════