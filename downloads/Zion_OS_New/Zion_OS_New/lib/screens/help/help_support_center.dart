import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class HelpSupportCenter extends StatefulWidget {
  const HelpSupportCenter({super.key});

  @override
  State<HelpSupportCenter> createState() => _HelpSupportCenterState();
}

class _HelpSupportCenterState extends State<HelpSupportCenter> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isSending = false;

  final List<String> _categories = ['General', 'Technical Issue', 'Bug Report', 'Feature Request', 'Security', 'Other'];
  
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How to change the PIN?',
      'answer': 'Go to Settings → Security → Change PIN, then enter your current PIN and new PIN.',
      'icon': Icons.lock,
    },
    {
      'question': 'How to scan a network?',
      'answer': 'Open Network Scanner app, enter the target IP range, and tap "Start Scan".',
      'icon': Icons.network_wifi,
    },
    {
      'question': 'What is Stealth Mode?',
      'answer': 'Stealth Mode hides your activity and protects your privacy while using the system.',
      'icon': Icons.visibility_off,
    },
    {
      'question': 'How to update the system?',
      'answer': 'Go to Update Center and click "Check for Updates" to see available updates.',
      'icon': Icons.update,
    },
    {
      'question': 'Is my data encrypted?',
      'answer': 'Yes, all sensitive data is encrypted using AES-256 military-grade encryption.',
      'icon': Icons.encryption,
    },
    {
      'question': 'How to report a bug?',
      'answer': 'Use the feedback form below or email us directly at support@zion-os.com',
      'icon': Icons.bug_report,
    },
  ];

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSending = false;
      _feedbackController.clear();
      _subjectController.clear();
      _emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback sent successfully!'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@zion-os.com',
      query: 'subject=Zion%20OS%20Support%20Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse('https://zion-os.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openGitHub() async {
    final Uri url = Uri.parse('https://github.com/almwld/project-zion');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openTelegram() async {
    final Uri url = Uri.parse('https://t.me/zionos');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Contact Cards
            Row(
              children: [
                Expanded(child: _buildContactCard(Icons.email, 'Email', 'support@zion-os.com', _sendEmail)),
                const SizedBox(width: 12),
                Expanded(child: _buildContactCard(Icons.web, 'Website', 'zion-os.com', _openWebsite)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildContactCard(Icons.code, 'GitHub', 'github.com/almwld', _openGitHub)),
                const SizedBox(width: 12),
                Expanded(child: _buildContactCard(Icons.telegram, 'Telegram', '@zionos', _openTelegram)),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // FAQ Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help, color: Color(0xFF00BCD4)),
                      SizedBox(width: 8),
                      Text('Frequently Asked Questions', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ..._faqs.map((faq) => _buildFaqItem(faq)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Documentation Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description, color: Color(0xFF00BCD4)),
                      SizedBox(width: 8),
                      Text('Documentation', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDocItem(Icons.book, 'User Manual', 'Complete guide to Zion OS'),
                  _buildDocItem(Icons.security, 'Security Guide', 'Best practices for security'),
                  _buildDocItem(Icons.developer_mode, 'API Documentation', 'For developers and contributors'),
                  _buildDocItem(Icons.video_library, 'Video Tutorials', 'Step-by-step video guides'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feedback Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.feedback, color: Color(0xFF00BCD4)),
                      SizedBox(width: 8),
                      Text('Send Feedback', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Color(0xFF00BCD4)),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: Color(0xFF00BCD4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BCD4)),
                      ),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BCD4))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Your Email (optional)',
                      labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _feedbackController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Your Message',
                      labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BCD4))),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendFeedback,
                      icon: _isSending
                          ? const SizedBox(width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: Text(_isSending ? 'Sending...' : 'Send Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Version Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Zion OS v4.0.0',
                    style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Zion Security Team',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00BCD4), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        leading: Icon(faq['icon'], color: const Color(0xFF00BCD4), size: 20),
        title: Text(
          faq['question'],
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              faq['answer'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF00BCD4)),
        ],
      ),
    );
  }
}
