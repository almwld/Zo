import 'package:flutter/material.dart';
import '../../core/services/help_service.dart';

class AdvancedHelpCenter extends StatefulWidget {
  const AdvancedHelpCenter({super.key});

  @override
  State<AdvancedHelpCenter> createState() => _AdvancedHelpCenterState();
}

class _AdvancedHelpCenterState extends State<AdvancedHelpCenter> with SingleTickerProviderStateMixin {
  late HelpService _helpService;
  late TabController _tabController;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  // Feedback Form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _helpService = HelpService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _sendFeedback() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    setState(() => _isSending = true);
    
    await _helpService.sendFeedback(
      _nameController.text,
      _emailController.text,
      _subjectController.text,
      _messageController.text,
    );
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isSending = false;
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback sent successfully!'), backgroundColor: Color(0xFF00BCD4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _helpService.getCategories();
    final filteredFaqs = _searchQuery.isEmpty
        ? _helpService.getFaqsByCategory(_selectedCategory)
        : _helpService.searchFaqs(_searchQuery);
    final tutorials = _helpService.getTutorials();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF00BCD4),
          tabs: const [
            Tab(icon: Icon(Icons.help), text: 'FAQs'),
            Tab(icon: Icon(Icons.school), text: 'Tutorials'),
            Tab(icon: Icon(Icons.feedback), text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqsTab(filteredFaqs, categories),
          _buildTutorialsTab(tutorials),
          _buildContactTab(),
        ],
      ),
    );
  }
  
  Widget _buildFaqsTab(List<Map<String, dynamic>> faqs, List<String> categories) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
              hintText: 'Search FAQs...',
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
        
        // Category Filter
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category, style: TextStyle(color: _selectedCategory == category ? Colors.black : const Color(0xFF00BCD4))),
                selected: _selectedCategory == category,
                onSelected: (_) => setState(() => _selectedCategory = category),
                backgroundColor: Colors.transparent,
                selectedColor: const Color(0xFF00BCD4),
              ),
            )).toList(),
          ),
        ),
        
        const Divider(color: Color(0xFF00BCD4), height: 1),
        
        // FAQs List
        Expanded(
          child: faqs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help_outline, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text('No FAQs found', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
                      ),
                      child: ExpansionTile(
                        leading: Icon(_getIconData(faq['icon']), color: const Color(0xFF00BCD4)),
                        title: Text(faq['question'], style: const TextStyle(color: Colors.white)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(faq['answer'], style: const TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildTutorialsTab(List<Map<String, dynamic>> tutorials) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = tutorials[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.play_circle_filled, color: Color(0xFF00BCD4)),
            title: Text(tutorial['title'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('Duration: ${tutorial['duration']}', style: const TextStyle(color: Colors.white54)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tutorial['steps'].map<Widget>((step) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFF00BCD4))),
                          Expanded(child: Text(step, style: const TextStyle(color: Colors.white70))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildContactTab() {
    return SingleChildScrollWidget('Phone', Icons.phone),child: Column(
      children: [
        // Contact Cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildContactCard('Email', Icons.email, 'support@zion-os.com', () => _helpService.sendEmail('support@zion-os.com', 'Support Request', ''))),
              const SizedBox(width: 12),
              Expanded(child: _buildContactCard('Website', Icons.web, 'zion-os.com', () => _helpService.openWebsite('https://zion-os.com'))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _buildContactCard('GitHub', Icons.code, 'github.com/almwld', _helpService.openGitHub)),
              const SizedBox(width: 12),
              Expanded(child: _buildContactCard('Telegram', Icons.telegram, '@zionos', _helpService.openTelegram)),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Feedback Form
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send Feedback', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Name *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Message *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: _isSending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send Feedback'),
                ),
              ),
            ],
          ),
        ),
        
        // Version Info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text('Zion OS v4.0.0', style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
              const SizedBox(height: 4),
              Text('© 2025 Zion Security Team', style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00BCD4), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lock': return Icons.lock;
      case 'network_wifi': return Icons.network_wifi;
      case 'visibility_off': return Icons.visibility_off;
      case 'update': return Icons.update;
      case 'encryption': return Icons.encryption;
      case 'bug_report': return Icons.bug_report;
      case 'check_circle': return Icons.check_circle;
      case 'backup': return Icons.backup;
      default: return Icons.help;
    }
  }
}','Phone', Icons.phone),child: Column(
      children: [
        // Contact Cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildContactCard('Email', Icons.email, 'support@zion-os.com', () => _helpService.sendEmail('support@zion-os.com', 'Support Request', ''))),
              const SizedBox(width: 12),
              Expanded(child: _buildContactCard('Website', Icons.web, 'zion-os.com', () => _helpService.openWebsite('https://zion-os.com'))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _buildContactCard('GitHub', Icons.code, 'github.com/almwld', _helpService.openGitHub)),
              const SizedBox(width: 12),
              Expanded(child: _buildContactCard('Telegram', Icons.telegram, '@zionos', _helpService.openTelegram)),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Feedback Form
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send Feedback', style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Name *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Message *',
                  labelStyle: TextStyle(color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                  ),
                  child: _isSending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send Feedback'),
                ),
              ),
            ],
          ),
        ),
        
        // Version Info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text('Zion OS v4.0.0', style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12)),
              const SizedBox(height: 4),
              Text('© 2025 Zion Security Team', style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00BCD4), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lock': return Icons.lock;
      case 'network_wifi': return Icons.network_wifi;
      case 'visibility_off': return Icons.visibility_off;
      case 'update': return Icons.update;
      case 'encryption': return Icons.encryption;
      case 'bug_report': return Icons.bug_report;
      case 'check_circle': return Icons.check_circle;
      case 'backup': return Icons.backup;
      default: return Icons.help;
    }
  }
}
