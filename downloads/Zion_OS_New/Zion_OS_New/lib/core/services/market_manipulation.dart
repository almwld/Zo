import 'dart:async';
import 'dart:math';

class MarketManipulation {
  final List<Map<String, dynamic>> _trades = [];
  bool _isActive = false;
  double _portfolioValue = 1000000.0;

  List<Map<String, dynamic>> get trades => _trades;
  bool get isActive => _isActive;
  double get portfolioValue => _portfolioValue;

  /// هجوم "الضخ والتفريغ" (Pump and Dump)
  Future<Map<String, dynamic>> pumpAndDump(String symbol) async {
    _isActive = true;
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'pump_and_dump',
      'symbol': symbol,
      'status': 'in_progress',
      'startedAt': DateTime.now(),
      'phases': <String, dynamic>{},
    };

    // المرحلة 1: التجميع
    operation['phases']['accumulation'] = 'شراء 10,000 سهم بسعر منخفض';
    await Future.delayed(const Duration(seconds: 1));

    // المرحلة 2: الضخ
    operation['phases']['pump'] = 'نشر إشاعات إيجابية عبر بوتات تويتر وريديت';
    await Future.delayed(const Duration(seconds: 1));

    // المرحلة 3: التفريغ
    operation['phases']['dump'] = 'بيع جميع الأسهم عند السعر المرتفع';
    await Future.delayed(const Duration(seconds: 1));

    final profit = Random().nextDouble() * 500000;
    _portfolioValue += profit;

    operation['status'] = 'completed';
    operation['profit'] = profit;
    operation['completedAt'] = DateTime.now();
    _trades.add(operation);
    _isActive = false;
    return operation;
  }

  /// هجوم "البيع المكشوف" (Short & Distort)
  Future<Map<String, dynamic>> shortAndDistort(String symbol) async {
    _isActive = true;
    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'short_and_distort',
      'symbol': symbol,
      'status': 'in_progress',
      'startedAt': DateTime.now(),
    };

    operation['steps'] = [
      'اقتراض 5,000 سهم وبيعها',
      'نشر أخبار كاذبة عن فشل الشركة',
      'انتظار انهيار السهم',
      'شراء الأسهم بسعر منخفض وإعادتها',
      'الاحتفاظ بالفرق كربح',
    ];

    final profit = Random().nextDouble() * 300000;
    _portfolioValue += profit;
    operation['profit'] = profit;

    await Future.delayed(const Duration(seconds: 2));
    operation['status'] = 'completed';
    operation['completedAt'] = DateTime.now();
    _trades.add(operation);
    _isActive = false;
    return operation;
  }
}
