import 'dart:convert';
import 'api_client.dart';

class StatsApi {
  final ApiClient _api;
  StatsApi(this._api);

  Future<void> sendSteps(int steps) async {
    final r = await _api.post('/api/steps/save', body: {'steps': steps});
    if (r.statusCode != 200) throw Exception('❌ Не удалось сохранить шаги');
  }

  Future<int> getTodaySteps() async {
    final r = await _api.get('/api/steps/today');
    if (r.statusCode != 200) throw Exception('❌ Не удалось получить шаги');
    final data = jsonDecode(r.body);
    return (data['steps'] as num?)?.toInt() ?? 0;
  }

  Future<Map<String, int>> getWeeklySteps() async {
    final r = await _api.get('/api/steps/week');
    if (r.statusCode != 200) throw Exception('❌ Ошибка загрузки шагов за неделю');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, int.tryParse('$value') ?? 0));
  }

  Future<({int totalMl, int entries, String date})> dailyWater() async {
    final r = await _api.get('/api/stats/daily');
    if (r.statusCode != 200) {
      throw Exception('Не удалось получить дневную статистику воды');
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (
      totalMl: (data['totalMl'] ?? 0) as int,
      entries: (data['entries'] ?? 0) as int,
      date: (data['date'] ?? '').toString(),
    );
  }

  Future<({int totalMl, int entries, String weekStart, String weekEnd})> weeklyWater() async {
    final r = await _api.get('/api/stats/weekly');
    if (r.statusCode != 200) {
      throw Exception('Не удалось получить недельную статистику воды');
    }

    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (
      totalMl: (data['totalMl'] ?? 0) as int,
      entries: (data['entries'] ?? 0) as int,
      weekStart: (data['weekStart'] ?? '').toString(),
      weekEnd: (data['weekEnd'] ?? '').toString(),
    );
  }
}
