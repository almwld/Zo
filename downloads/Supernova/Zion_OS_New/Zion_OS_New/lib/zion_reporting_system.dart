import 'package:flutter/material.dart';

enum ReportFormat { pdf, html, json, txt }
enum ReportType { scanResult, vulnerability, penetration, audit, summary }

class ZionReport {
  final String id;
  final String title;
  final ReportType type;
  final DateTime createdAt;
  final ReportFormat format;
  final int size;
  final String summary;

  ZionReport({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.format,
    required this.size,
    required this.summary,
  });
}

class ZionReportingSystem extends ChangeNotifier {
  final List<ZionReport> _reports = [];
  bool _isGenerating = false;
  int _progress = 0;

  List<ZionReport> get reports => _reports.reversed.toList();
  bool get isGenerating => _isGenerating;
  int get progress => _progress;

  Future<ZionReport> generateReport({
    required String title,
    required ReportType type,
    required ReportFormat format,
    required Map<String, dynamic> data,
  }) async {
    _isGenerating = true;
    _progress = 0;
    notifyListeners();

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      _progress = i;
      notifyListeners();
    }

    final report = ZionReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      createdAt: DateTime.now(),
      format: format,
      size: 250000 + DateTime.now().millisecond * 100,
      summary: 'تقرير $title - ${type.name} - ${format.name}',
    );

    _reports.add(report);
    _isGenerating = false;
    notifyListeners();

    return report;
  }

  void deleteReport(String id) {
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void exportReport(ZionReport report) {
    // محاكاة تصدير التقرير
  }
}
