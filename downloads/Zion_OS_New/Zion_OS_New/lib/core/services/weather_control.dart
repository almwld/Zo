import 'dart:async';
import 'dart:math';

class WeatherControl {
  bool _haarpActive = false;
  bool _isActive = false;
  String _currentTarget = '';
  final List<Map<String, dynamic>> _operations = [];

  bool get haarpActive => _haarpActive;
  bool get isActive => _isActive;
  String get currentTarget => _currentTarget;
  List<Map<String, dynamic>> get operations => _operations;

  void toggleHAARP() { _haarpActive = !_haarpActive; }

  Future<Map<String, dynamic>> createStorm(String target, String type) async {
    _isActive = true;
    _currentTarget = target;
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'target': target,
      'status': 'in_progress',
      'startedAt': DateTime.now(),
    };

    await Future.delayed(const Duration(seconds: 2));
    operation['status'] = 'completed';
    operation['intensity'] = '${Random().nextInt(10) + 5}/10';
    operation['effect'] = type == 'hurricane' ? 'إعصار من الفئة ${Random().nextInt(5) + 1}' : type == 'flood' ? 'فيضانات عارمة' : type == 'drought' ? 'جفاف شديد' : 'عاصفة رعدية عنيفة';
    _operations.add(operation);
    _isActive = false;
    return operation;
  }

  Future<Map<String, dynamic>> manipulateIonosphere(String target, double frequency) async {
    if (!_haarpActive) return {'error': 'HAARP not active'};
    await Future.delayed(const Duration(seconds: 1));
    return {
      'target': target,
      'frequency': '${frequency} MHz',
      'power': '${Random().nextInt(100) + 50} MW',
      'effect': 'تسخين الأيونوسفير - تغيير مسار التيار النفاث',
    };
  }
}
