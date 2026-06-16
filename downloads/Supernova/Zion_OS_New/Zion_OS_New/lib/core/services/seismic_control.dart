import 'dart:async';
import 'dart:math';

class SeismicControl {
  bool _isActive = false;
  final List<Map<String, dynamic>> _operations = [];
  final List<Map<String, dynamic>> _detectedFaults = [];

  bool get isActive => _isActive;
  List<Map<String, dynamic>> get operations => _operations;
  List<Map<String, dynamic>> get detectedFaults => _detectedFaults;

  Future<void> scanFaultLines() async {
    _detectedFaults.clear();
    final faults = ['San Andreas', 'North Anatolian', 'Japan Trench', 'Himalayan Thrust', 'New Madrid'];
    for (final fault in faults) {
      _detectedFaults.add({
        'name': fault,
        'stress': Random().nextInt(100),
        'depth': '${Random().nextInt(30) + 5} km',
        'critical': Random().nextBool(),
      });
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<Map<String, dynamic>> induceEarthquake(String faultName, double magnitude) async {
    _isActive = true;
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fault': faultName,
      'magnitude': magnitude,
      'status': 'in_progress',
      'startedAt': DateTime.now(),
    };

    await Future.delayed(const Duration(seconds: 2));
    operation['status'] = 'completed';
    operation['aftershocks'] = Random().nextInt(10) + 3;
    operation['radius'] = '${magnitude * 10} km';
    _operations.add(operation);
    _isActive = false;
    return operation;
  }
}
