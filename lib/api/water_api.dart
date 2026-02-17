import 'dart:convert';
import 'api_client.dart';

class WaterApi {
  final ApiClient _api;
  WaterApi(this._api);

  Future<(int consumedMl, int targetMl)> today() async {
    final r = await _api.get('/api/water/progress/today');
    if (r.statusCode != 200) throw Exception('Не удалось получить прогресс');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return ((data['consumedMl'] as num).toInt(), (data['targetMl'] as num).toInt());
  }

  Future<(int consumedMl, int targetMl)> drink({required int amountMl, String? note}) async {
    final r = await _api.post('/api/water/drink', body: {
      'amountMl': amountMl,
      'note': note,
    });
    if (r.statusCode != 200) throw Exception('Не удалось добавить запись');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return ((data['consumedMl'] as num).toInt(), (data['targetMl'] as num).toInt());
  }

  Future<({List<String> labels, List<int> totalsMl, int targetMl})> stats8Days() async {
    final r = await _api.get('/api/water/stats/8-days');
    if (r.statusCode != 200) throw Exception('Не удалось получить статистику');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final labels = (data['labels'] as List).map((e) => e.toString()).toList();
    final totals = (data['totalsMl'] as List).map((e) => (e as num).toInt()).toList();
    final target = (data['targetMl'] as num).toInt();
    return (labels: labels, totalsMl: totals, targetMl: target);
  }
}

