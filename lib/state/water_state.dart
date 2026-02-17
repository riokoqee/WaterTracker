import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/water_api.dart';
import '../api/goal_api.dart';

class WaterState extends ChangeNotifier {
  final _api = ApiClient();
  late final WaterApi _water = WaterApi(_api);
  late final GoalApi _goals = GoalApi(_api);

  int consumedMl = 0;
  int goalMl = 0;
  int glassSize = 250;

  // ✅ Загружаем цель и прогресс воды
  Future<void> load() async {
    try {
      final (consumed, _) = await _water.today();
      final goalData = await _goals.getGoal(); // ⚠️ теперь есть both

      consumedMl = consumed;
      goalMl = goalData.targetMl;
      if (goalData.glassSizeMl != null) {
        glassSize = goalData.glassSizeMl!;
      }
      notifyListeners();
    } catch (_) {}
  }

  // ✅ Обновляем ТОЛЬКО цель
  Future<void> setGoal(int ml) async {
    goalMl = ml;
    await _goals.upsert(targetMl: ml, glassSizeMl: glassSize);
    notifyListeners();
  }

  // ✅ Обновляем ТОЛЬКО размер стакана
  Future<void> changeGlassSize(int ml) async {
    glassSize = ml;
    await _goals.upsert(targetMl: goalMl, glassSizeMl: ml);
    notifyListeners();
  }

  // ✅ Когда пьём воду — обновляется и цель, и прогресс
  Future<void> drink(int ml) async {
    final (consumed, target) = await _water.drink(amountMl: ml);

    consumedMl = consumed;
    goalMl = target;

    notifyListeners();
  }
}
