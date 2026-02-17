import 'dart:convert';
import 'api_client.dart';

class GoalApi {
  final ApiClient _api;
  GoalApi(this._api);

  Future<({int targetMl, int? glassSizeMl, bool? remindersEnabled, int? everyMin})> getGoal() async {
    final r = await _api.get('/api/goal');
    if (r.statusCode != 200) throw Exception('Не удалось получить цель');
    final data = jsonDecode(r.body) as Map<String, dynamic>;

    return (
      targetMl: (data['targetMl'] as num).toInt(),
      glassSizeMl: data['glassSizeMl'] != null ? (data['glassSizeMl'] as num).toInt() : null,
      remindersEnabled: data['remindersEnabled'] as bool?,
      everyMin: data['reminderEveryMin'] as int?
    );
  }

  Future<int> getTargetMl() async {
    final r = await _api.get('/api/goal');
    if (r.statusCode != 200) throw Exception('Не удалось получить цель');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (data['targetMl'] as num).toInt();
  }

  Future<void> upsert({
    required int targetMl,
    int? glassSizeMl,
    bool? enabled,
    int? everyMin,
  }) async {
    final r = await _api.put('/api/goal', body: {
      'targetMl': targetMl,
      if (glassSizeMl != null) 'glassSizeMl': glassSizeMl,
      if (enabled != null) 'remindersEnabled': enabled,
      if (everyMin != null) 'reminderEveryMin': everyMin,
    });
    if (r.statusCode != 200) {
      throw Exception('Ошибка обновления цели: ${r.statusCode}');
    }
  }

  Future<void> setTargetMl(int ml) async {
    final r = await _api.put('/api/goal', body: {
      'targetMl': ml,
    });
    if (r.statusCode != 200) {
      throw Exception('Ошибка сохранения цели: ${r.statusCode}');
    }
  }
}
