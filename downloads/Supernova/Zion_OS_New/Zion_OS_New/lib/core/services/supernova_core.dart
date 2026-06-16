import 'dart:async';
import 'dart:math';
import 'package:riverpod/riverpod.dart';
import 'mission_planner_service.dart';
import 'ghost_service.dart';
import 'target_profiler_service.dart';
import 'tool_smith_service.dart';
import 'auto_fuzzer_service.dart';
import 'adaptive_evasion_engine.dart';
import 'cross_platform_propagation.dart';
import 'deep_learning_engine.dart';
import 'self_awareness_service.dart';

final supernovaProvider = Provider<SupernovaCore>((ref) => SupernovaCore());

class SupernovaCore {
  final MissionPlanner planner = MissionPlanner();
  final GhostService ghost = GhostService();
  final TargetProfiler profiler = TargetProfiler();
  final ToolSmith toolSmith = ToolSmith();
  final AutoFuzzer fuzzer = AutoFuzzer();
  final AdaptiveEvasionEngine evasion = AdaptiveEvasionEngine();
  final CrossPlatformPropagation propagation = CrossPlatformPropagation();
  final DeepLearningEngine deepLearning = DeepLearningEngine();
  final SelfAwarenessService awareness = SelfAwarenessService();

  bool _isActive = false;
  final List<Map<String, dynamic>> _missionLog = [];

  Future<void> start() async {
    _isActive = true;
    awareness.think('starting full system');

    while (_isActive) {
      evasion.mutateFingerprint();
      final targets = awareness.suggestTargets();

      for (final target in targets) {
        if (!_isActive) break;
        await _attackTarget(target);
        await Future.delayed(Duration(seconds: Random().nextInt(5) + 1));
      }
    }
  }

  Future<void> _attackTarget(String target) async {
    final bestAttack = deepLearning.predictBestAttack(target);
    final risk = awareness.assessRisk(bestAttack['attack']);

    if (risk['risk_level'] > 7) {
      evasion.mutateFingerprint();
    }

    awareness.think('attacking $target with ${bestAttack['attack']}');
    toolSmith.registerSuccess(bestAttack['attack']);

    _missionLog.add({
      'target': target,
      'attack': bestAttack['attack'],
      'confidence': bestAttack['confidence'],
      'time': DateTime.now().toIso8601String(),
    });
  }

  void stop() {
    _isActive = false;
    awareness.think('shutting down');
  }

  List<Map<String, dynamic>> getMissionLog() => _missionLog;
  Map<String, dynamic> getSystemStatus() => awareness.getSelfReport();
}
