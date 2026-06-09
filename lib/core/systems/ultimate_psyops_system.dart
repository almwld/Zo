import 'dart:math';

class UltimatePsyopsSystem {
  /// إنشاء حملة تضليل كاملة
  static Map<String, dynamic> createDisinformationCampaign({
    required String target,
    required String goal,
    required String narrative,
    int durationDays = 7,
  }) {
    final campaign = <String, dynamic>{
      'id': Random().nextInt(99999) + 10000,
      'target': target,
      'goal': goal,
      'narrative': narrative,
      'duration_days': durationDays,
      'status': 'active',
      'assets': <Map<String, dynamic>>[],
      'channels': <String>[],
      'metrics': <String, int>{},
    };

    // إنشاء الأصول (شخصيات وهمية، مواقع، إلخ)
    campaign['assets'] = _generateCampaignAssets(narrative);
    campaign['channels'] = _selectChannels(target);
    campaign['metrics'] = {'reach': 0, 'engagement': 0, 'conversions': 0};

    return campaign;
  }

  /// إنشاء شخصية وهمية كاملة مع تاريخ
  static Map<String, dynamic> createFakePersona({String? role}) {
    final persona = {
      'identity': _generateIdentity(),
      'backstory': _generateBackstory(role),
      'social_media': _generateSocialMediaPresence(),
      'digital_footprint': _generateDigitalFootprint(),
      'psychological_profile': _generatePsychologicalProfile(),
    };

    return persona;
  }

  /// إنشاء موقع إخباري مزيف
  static Map<String, dynamic> createFakeNewsSite(String domain, String bias) {
    return {
      'domain': domain,
      'bias': bias,
      'articles': List.generate(5, (_) => _generateFakeArticle()),
      'design': 'Professional news template',
      'seo_optimized': true,
      'social_proof': {
        'fake_comments': Random().nextInt(500) + 50,
        'fake_shares': Random().nextInt(1000) + 100,
      },
    };
  }

  /// توليد شائعة قابلة للانتشار
  static String generateViralRumor(String target, String angle) {
    final rumors = [
      'SHOCKING: Insider reveals $target has been hiding a massive data breach affecting millions of users.',
      'EXCLUSIVE: Whistleblower from $target exposes illegal practices. The evidence is undeniable.',
      'LEAKED: Internal memo from $target shows plans to sell user data to foreign governments.',
      'BREAKING: Multiple employees at $target have come forward with allegations of fraud.',
    ];

    return rumors[Random().nextInt(rumors.length)];
  }

  /// إنشاء دليل مزيف (وثيقة، لقطة شاشة، إلخ)
  static String generateFakeEvidence(String target, String type) {
    switch (type) {
      case 'email':
        return '''
From: insider@${target.toLowerCase()}.com
To: journalist@news.com
Subject: I can't stay silent anymore

I've worked at $target for 5 years. What I've seen... I can't stay silent anymore. Meet me at the usual place.

- Concerned Employee''';
      case 'screenshot':
        return '[SCREENSHOT: Internal dashboard showing manipulated data]';
      case 'document':
        return '[DOCUMENT: Confidential memo marked "DO NOT DISTRIBUTE"]';
      default:
        return '[EVIDENCE: Compiled proof of allegations]';
    }
  }

  /// تحليل نفسي للهدف
  static Map<String, dynamic> psychologicalAssessment(String target) {
    return {
      'fears': ['Financial loss', 'Reputation damage', 'Legal consequences', 'Loss of control'],
      'desires': ['Security', 'Control', 'Validation', 'Power'],
      'triggers': ['Authority figures', 'Urgency', 'Social proof', 'Scarcity'],
      'decision_making_style': Random().nextDouble() < 0.5 ? 'Emotional' : 'Analytical',
      'suggestibility': Random().nextDouble() < 0.5 ? 'High' : 'Moderate',
    };
  }

  /// قياس فعالية الحملة
  static Map<String, int> measureEffectiveness(Map<String, dynamic> campaign) {
    return {
      'reach': Random().nextInt(100000) + 10000,
      'engagement': Random().nextInt(10000) + 1000,
      'shares': Random().nextInt(5000) + 500,
      'comments': Random().nextInt(2000) + 200,
      'news_pickups': Random().nextInt(10) + 1,
      'target_awareness': Random().nextInt(80) + 20,
    };
  }

  static List<Map<String, dynamic>> _generateCampaignAssets(String narrative) {
    return [
      {'type': 'fake_persona', 'role': 'whistleblower'},
      {'type': 'fake_persona', 'role': 'journalist'},
      {'type': 'fake_persona', 'role': 'victim'},
      {'type': 'fake_website', 'domain': 'news-${narrative.hashCode.abs()}.com'},
      {'type': 'fake_document', 'title': 'Internal Investigation Report'},
    ];
  }

  static List<String> _selectChannels(String target) {
    return ['Twitter/X', 'Reddit', 'Telegram', 'Fake News Sites', 'Anonymous Forums', 'YouTube Comments'];
  }

  static Map<String, dynamic> _generateIdentity() {
    final firstNames = ['Marcus', 'Elena', 'Dmitri', 'Sarah', 'James'];
    final lastNames = ['Kovac', 'Reynolds', 'Chen', 'Okafor', 'Ivanov'];
    final name = '${firstNames[Random().nextInt(firstNames.length)]} ${lastNames[Random().nextInt(lastNames.length)]}';
    return {
      'name': name,
      'age': Random().nextInt(30) + 25,
      'occupation': _generateOccupation(),
      'location': _generateLocation(),
    };
  }

  static String _generateBackstory(String? role) {
    return 'Former ${role ?? "employee"} with 10+ years of experience. Disillusioned with corporate practices. Decided to speak out after witnessing unethical behavior.';
  }

  static Map<String, dynamic> _generateSocialMediaPresence() {
    return {
      'twitter_followers': Random().nextInt(5000) + 500,
      'reddit_karma': Random().nextInt(10000) + 1000,
      'telegram_subscribers': Random().nextInt(3000) + 300,
    };
  }

  static Map<String, dynamic> _generateDigitalFootprint() {
    return {
      'email_accounts': 3,
      'forum_registrations': Random().nextInt(10) + 2,
      'dark_web_presence': Random().nextBool(),
    };
  }

  static Map<String, dynamic> _generatePsychologicalProfile() {
    return {
      'mbti': ['INTJ', 'INTP', 'ENTJ', 'INFJ'][Random().nextInt(4)],
      'motivations': ['Justice', 'Revenge', 'Recognition', 'Financial'],
      'risk_tolerance': Random().nextDouble() < 0.5 ? 'High' : 'Medium',
    };
  }

  static Map<String, dynamic> _generateFakeArticle() {
    return {
      'title': 'Breaking: New Evidence Emerges in Ongoing Investigation',
      'author': 'Staff Reporter',
      'date': DateTime.now().subtract(Duration(days: Random().nextInt(7))).toIso8601String(),
      'content': 'Sources close to the investigation have revealed...',
    };
  }

  static String _generateOccupation() {
    final occs = ['Whistleblower', 'Journalist', 'Security Researcher', 'Former Executive', 'Anonymous Source'];
    return occs[Random().nextInt(occs.length)];
  }

  static String _generateLocation() {
    final cities = ['London, UK', 'Berlin, DE', 'Zurich, CH', 'Stockholm, SE', 'Amsterdam, NL'];
    return cities[Random().nextInt(cities.length)];
  }
}
