import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/stats_api.dart';
import '../api/api_client.dart';

class StepsService {
  StepsService._();
  static final StepsService instance = StepsService._();

  final StatsApi _api = StatsApi(ApiClient());
  final ValueNotifier<int> todaySteps = ValueNotifier(0);

  Stream<StepCount>? _stream;
  bool _started = false;

  int? _startOfDayDeviceSteps; 

  Future<void> start() async {
    if (_started) return;
    _started = true;

    var status = await Permission.activityRecognition.request();
    if (!status.isGranted) return;

    todaySteps.value = await _api.getTodaySteps();

    _stream = Pedometer.stepCountStream;
    _stream?.listen((event) async {
      _startOfDayDeviceSteps ??= event.steps;

      final calculatedToday = event.steps - _startOfDayDeviceSteps!;

      todaySteps.value = calculatedToday;

      try {
        await _api.sendSteps(calculatedToday);
      } catch (e) {
        print("⚠️ Ошибка отправки: $e");
      }
    });
  }
  
  Future<Map<String, int>> getWeekStats() async {
    return await _api.getWeeklySteps();
  }
}
