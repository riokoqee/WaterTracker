import 'dart:convert';
import 'api_client.dart';

class DashboardApi {
  final ApiClient _api;
  DashboardApi(this._api);

  Future<({String greeting, int targetMl, int currentMl, int progress, String lastIntakeTime, int glassSizeMl})> get() async {
    final r = await _api.get('/api/dashboard');
    if (r.statusCode != 200) throw Exception('Не удалось получить дашборд');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (
      greeting: (data['greeting'] ?? '') as String,
      targetMl: (data['targetMl'] as num?)?.toInt() ?? 0,
      currentMl: (data['currentMl'] as num?)?.toInt() ?? 0,
      progress: (data['progress'] as num?)?.toInt() ?? 0,
      lastIntakeTime: (data['lastIntakeTime'] ?? '') as String,
      glassSizeMl: (data['glassSizeMl'] as num?)?.toInt() ?? 250,
    );
  }
}

