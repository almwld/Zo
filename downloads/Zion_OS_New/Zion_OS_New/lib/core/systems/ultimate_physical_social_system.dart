import 'dart:math';

class UltimatePhysicalSocialSystem {
  /// توليد هوية مزيفة كاملة
  static Map<String, dynamic> generateFakeIdentity() {
    final firstNames = ['James', 'Sarah', 'Michael', 'Emily', 'David', 'Jessica', 'Robert', 'Amanda', 'William', 'Jennifer'];
    final lastNames = ['Anderson', 'Martinez', 'Thompson', 'Williams', 'Brown', 'Davis', 'Wilson', 'Taylor', 'Thomas', 'Jackson'];
    final domains = ['gmail.com', 'outlook.com', 'protonmail.com', 'tutanota.com'];
    final cities = ['New York, NY', 'Los Angeles, CA', 'Chicago, IL', 'Houston, TX', 'Phoenix, AZ'];
    final streets = ['123 Main St', '456 Oak Ave', '789 Pine Rd', '321 Elm Dr', '654 Maple Ln'];

    final firstName = firstNames[Random().nextInt(firstNames.length)];
    final lastName = lastNames[Random().nextInt(lastNames.length)];
    final domain = domains[Random().nextInt(domains.length)];
    final birthYear = Random().nextInt(30) + 1970;

    return {
      'full_name': '$firstName $lastName',
      'first_name': firstName,
      'last_name': lastName,
      'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}@$domain',
      'phone': '+1-555-${Random().nextInt(900) + 100}-${Random().nextInt(9000) + 1000}',
      'dob': '${Random().nextInt(12) + 1}/${Random().nextInt(28) + 1}/$birthYear',
      'ssn': '${Random().nextInt(900) + 100}-${Random().nextInt(90) + 10}-${Random().nextInt(9000) + 1000}',
      'address': streets[Random().nextInt(streets.length)],
      'city': cities[Random().nextInt(cities.length)],
      'zip': '${Random().nextInt(90000) + 10000}',
      'credit_card': '${Random().nextInt(4) + 4}${_generateDigits(15)}',
      'occupation': _generateOccupation(),
      'company': _generateCompany(),
    };
  }

  /// توليد سيناريو تصيد متقدم (Pretexting)
  static String generatePretextScenario(String target, String goal) {
    final scenarios = [
      _itSupportScenario(target),
      _deliveryScenario(target),
      _recruiterScenario(target),
      _bankScenario(target),
      _emergencyScenario(target),
    ];
    return scenarios[Random().nextInt(scenarios.length)];
  }

  /// تقييم نقاط الضعف الفيزيائية لموقع
  static Map<String, dynamic> assessPhysicalVulnerability(String locationType) {
    final assessments = {
      'office': {
        'entry_points': ['main entrance', 'parking garage', 'loading dock', 'fire exits'],
        'weaknesses': ['tailgating risk', 'unlocked doors', 'unattended reception'],
        'best_attack_time': '08:00-09:00 (rush hour)',
        'uniform_suggestion': 'Delivery driver or maintenance worker',
        'success_probability': 0.65,
      },
      'data_center': {
        'entry_points': ['mantrap', 'loading dock', 'roof access'],
        'weaknesses': ['HVAC vulnerabilities', 'shared infrastructure'],
        'best_attack_time': '02:00-04:00 (graveyard shift)',
        'uniform_suggestion': 'HVAC technician or fire inspector',
        'success_probability': 0.35,
      },
      'retail': {
        'entry_points': ['main entrance', 'stock room', 'employee entrance'],
        'weaknesses': ['high traffic', 'distracted staff', 'multiple entry points'],
        'best_attack_time': '12:00-14:00 (lunch rush)',
        'uniform_suggestion': 'Health inspector or corporate auditor',
        'success_probability': 0.80,
      },
    };

    return assessments[locationType] ?? assessments['office']!;
  }

  /// توليد رسالة تصيد متقدمة
  static Map<String, String> generatePhishingEmail({
    required String targetName,
    required String targetCompany,
    required String targetRole,
  }) {
    final templates = [
      _urgentCeoEmail(targetName, targetCompany),
      _hrUpdateEmail(targetName, targetCompany),
      _securityAlertEmail(targetName, targetCompany),
      _invoiceEmail(targetName, targetCompany),
      _sharedDocumentEmail(targetName),
    ];

    final template = templates[Random().nextInt(templates.length)];
    return {
      'subject': template['subject']!,
      'body': template['body']!,
      'from': _generateFakeSender(targetCompany),
      'urgency': Random().nextDouble() < 0.5 ? 'HIGH' : 'MEDIUM',
    };
  }

  /// توليد صفحة تصيد ديناميكية
  static String generatePhishingPage(String site) {
    final pages = {
      'google': _googlePage(),
      'microsoft': _microsoftPage(),
      'apple': _applePage(),
      'facebook': _facebookPage(),
      'linkedin': _linkedinPage(),
    };
    return pages[site.toLowerCase()] ?? _googlePage();
  }

  /// تحليل الهدف لبناء ملف نفسي
  static Map<String, dynamic> buildPsychologicalProfile({
    String? name,
    String? position,
    String? company,
  }) {
    final profile = <String, dynamic>{
      'estimated_traits': <String>[],
      'vulnerabilities': <String>[],
      'best_approach': '',
    };

    if (position != null && position.toLowerCase().contains('executive')) {
      profile['estimated_traits'].addAll(['ambitious', 'busy', 'delegates tasks']);
      profile['vulnerabilities'].addAll(['time pressure', 'authority respect', 'executive assistant reliance']);
      profile['best_approach'] = 'Urgent business matter via their assistant';
    } else if (position != null && position.toLowerCase().contains('it')) {
      profile['estimated_traits'].addAll(['technical', 'skeptical', 'detail-oriented']);
      profile['vulnerabilities'].addAll(['curiosity bait', 'technical challenge', 'new vulnerability alerts']);
      profile['best_approach'] = 'Fake security advisory with technical details';
    } else {
      profile['estimated_traits'].addAll(['average', 'routine-oriented', 'helpful']);
      profile['vulnerabilities'].addAll(['authority figures', 'urgency', 'helpfulness']);
      profile['best_approach'] = 'Fake IT support call or urgent email from boss';
    }

    return profile;
  }

  static String _itSupportScenario(String target) => '''
PRETEXT SCENARIO: IT Support Call
TARGET: $target
GOAL: Credential harvesting or malware installation

SCRIPT:
1. Call during lunch hours (11:30-13:00)
2. "Hello, this is [NAME] from IT Security. We've detected suspicious activity on your account from an IP in [FOREIGN COUNTRY]."
3. "We need to verify your identity to secure your account. Can you confirm your username?"
4. "Thank you. I'm sending a verification link to your email. Please click it immediately."
5. "The system shows you're verified. We'll monitor your account for 24 hours. Have a good day."

KEY POINTS:
- Sound professional but slightly rushed
- Use technical jargon sparingly
- Never ask for password directly (use phishing link)
- Mention a recent real event (system update, breach news)
''';

  static String _deliveryScenario(String target) => '''
PRETEXT SCENARIO: Failed Package Delivery
TARGET: $target
GOAL: Physical address confirmation or malware delivery

SCRIPT:
1. "Hello, this is [NAME] from FedEx. We have a package for you but the shipping label is damaged."
2. "It appears to be from [POPULAR COMPANY]. Can you confirm your current address?"
3. "Thank you. We'll reschedule delivery for tomorrow."
4. "I'm also sending a tracking number to your email. Please use it to track your package."
5. Send follow-up email with "tracking link" (malicious URL)
''';

  static String _recruiterScenario(String target) => '''
PRETEXT SCENARIO: Executive Recruiter
TARGET: $target
GOAL: Resume harvesting or malware via fake job offer

SCRIPT:
1. Research target on LinkedIn first
2. "Hello, I'm a recruiter from [FAKE FORTUNE 500]. Your profile impressed our hiring team."
3. "We have a confidential senior position that matches your skills perfectly."
4. "Can I send you the job description? The salary range is [ATTRACTIVE RANGE]."
5. Send "job description" PDF (malicious) or link to fake portal
''';

  static String _bankScenario(String target) => '''
PRETEXT SCENARIO: Bank Security Alert
TARGET: $target
GOAL: Banking credentials or 2FA bypass

SCRIPT:
1. "Hello, this is [NAME] from [BANK] Fraud Department. We've detected unusual charges on your account."
2. "For security verification, can you confirm your ZIP code and the last 4 digits of your SSN?"
3. "Thank you. The charges are from [FOREIGN CITY] for [LARGE AMOUNT]. We've blocked your card."
4. "We're sending a verification code to your phone. Please read it back to me to confirm your identity."
5. Use code for real-time 2FA bypass
''';

  static String _emergencyScenario(String target) => '''
PRETEXT SCENARIO: Family Emergency
TARGET: $target
GOAL: Immediate action (wire transfer, credential sharing)

SCRIPT:
1. "Hello, this is Officer [NAME] from [CITY] Police Department."
2. "There's been an accident involving [FAMILY MEMBER]. They're at [HOSPITAL]."
3. "We need you to come immediately. But first, we need your insurance information."
4. "Also, the hospital requires a deposit. Can you wire [AMOUNT] to this account?"
5. Use urgency to bypass rational thinking
''';

  static String _googlePage() => '<div style="text-align:center;margin-top:100px;font-family:sans-serif;"><img src="https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"><h2>Sign in</h2><input type="email" placeholder="Email" style="width:300px;padding:10px;margin:5px;border:1px solid #ccc;border-radius:4px;"><br><input type="password" placeholder="Password" style="width:300px;padding:10px;margin:5px;border:1px solid #ccc;border-radius:4px;"><br><button style="background:#1a73e8;color:white;padding:10px 30px;border:none;border-radius:4px;">Next</button></div>';
  static String _microsoftPage() => '<div style="text-align:center;margin-top:50px;font-family:sans-serif;"><h1 style="color:#0078d4;">Microsoft</h1><h2>Sign in</h2><input type="email" placeholder="Email, phone, or Skype" style="width:300px;padding:8px;border:1px solid #666;border-radius:2px;"><br><input type="password" placeholder="Password" style="width:300px;padding:8px;margin-top:10px;border:1px solid #666;border-radius:2px;"><br><button style="background:#0067b8;color:white;width:300px;padding:8px;margin-top:10px;border:none;">Sign in</button></div>';
  static String _applePage() => '<div style="text-align:center;margin-top:50px;font-family:sans-serif;"><h1 style="font-weight:300;">Apple ID</h1><p>Sign in to continue</p><input type="text" placeholder="Apple ID" style="width:300px;padding:10px;border:1px solid #ccc;border-radius:6px;"><br><input type="password" placeholder="Password" style="width:300px;padding:10px;margin-top:10px;border:1px solid #ccc;border-radius:6px;"><br><button style="background:#0071e3;color:white;width:300px;padding:10px;margin-top:10px;border:none;border-radius:6px;">Sign In</button></div>';
  static String _facebookPage() => '<div style="text-align:center;margin-top:50px;background:#f0f2f5;padding:20px;font-family:sans-serif;"><h1 style="color:#1877f2;">facebook</h1><div style="background:white;padding:20px;border-radius:8px;width:350px;margin:auto;"><input type="text" placeholder="Email address or phone number" style="width:100%;padding:10px;margin:5px 0;border:1px solid #ddd;border-radius:6px;"><br><input type="password" placeholder="Password" style="width:100%;padding:10px;margin:5px 0;border:1px solid #ddd;border-radius:6px;"><br><button style="background:#1877f2;color:white;width:100%;padding:10px;border:none;border-radius:6px;">Log In</button></div></div>';
  static String _linkedinPage() => '<div style="text-align:center;margin-top:30px;font-family:sans-serif;"><h1 style="color:#0a66c2;">LinkedIn</h1><div style="width:350px;margin:auto;padding:20px;"><input type="text" placeholder="Email" style="width:100%;padding:10px;border:1px solid #ccc;border-radius:4px;"><br><input type="password" placeholder="Password" style="width:100%;padding:10px;margin-top:10px;border:1px solid #ccc;border-radius:4px;"><br><button style="background:#0a66c2;color:white;width:100%;padding:10px;margin-top:10px;border:none;border-radius:20px;">Sign In</button></div></div>';

  static Map<String, String> _urgentCeoEmail(String name, String company) => {
    'subject': 'URGENT: Wire Transfer Needed Immediately',
    'body': '''$name,

I need you to process an urgent wire transfer for a client payment. The usual process can be bypassed for this one. I'll send the details shortly.

Please confirm receipt of this email immediately.

CEO Office
$company''',
  };

  static Map<String, String> _hrUpdateEmail(String name, String company) => {
    'subject': 'IMPORTANT: Update Your Employee Information',
    'body': '''Dear $name,

Our records indicate that your employee information is out of date. Please click the link below to update your details within 48 hours to avoid payroll disruption.

[UPDATE INFORMATION]

Best regards,
$company HR Department''',
  };

  static Map<String, String> _securityAlertEmail(String name, String company) => {
    'subject': 'Security Alert: Suspicious Login Attempt',
    'body': '''Dear $name,

We detected a suspicious login attempt on your account from an unrecognized device in Russia. If this was not you, please secure your account immediately by clicking below:

[SECURE ACCOUNT]

This link expires in 24 hours.

$company Security Team''',
  };

  static Map<String, String> _invoiceEmail(String name, String company) => {
    'subject': 'Invoice #${Random().nextInt(99999) + 10000} - Payment Due',
    'body': '''Dear $name,

Attached is your latest invoice for services rendered. Please remit payment by the due date to avoid late fees.

[VIEW INVOICE]

Thank you,
$company Billing''',
  };

  static Map<String, String> _sharedDocumentEmail(String name) => {
    'subject': '${name.split(' ').first} shared a document with you',
    'body': '''${name.split(' ').first},

I've shared an important document with you. Click below to view:

[OPEN DOCUMENT]

- ${name.split(' ').first}''',
  };

  static String _generateFakeSender(String company) {
    final names = ['IT Support', 'Security Team', 'HR Department', 'Admin', 'Billing'];
    return '${names[Random().nextInt(names.length)]} <${company.toLowerCase().replaceAll(' ', '')}@corporate.com>';
  }

  static String _generateOccupation() {
    final occs = ['Software Engineer', 'Project Manager', 'Consultant', 'Analyst', 'Director'];
    return occs[Random().nextInt(occs.length)];
  }

  static String _generateCompany() {
    final comps = ['TechCorp', 'DataSys', 'CloudNet', 'CyberSec', 'InnovateX'];
    return comps[Random().nextInt(comps.length)];
  }

  static String _generateDigits(int count) => List.generate(count, (_) => Random().nextInt(10)).join();
}
