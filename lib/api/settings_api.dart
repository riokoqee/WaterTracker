import 'dart:convert';
import 'api_client.dart';

class SettingsApi {
  final ApiClient _api;
  SettingsApi(this._api);

  Future<({bool notificationsEnabled, bool darkMode})> get() async {
    final r = await _api.get('/api/settings');
    if (r.statusCode != 200) throw Exception('Не удалось получить настройки');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    return (
      notificationsEnabled: (data['notificationsEnabled'] as bool?) ?? false,
      darkMode: (data['darkMode'] as bool?) ?? false,
    );
  }

  Future<void> update({bool? notificationsEnabled, bool? darkMode}) async {
    final r = await _api.put('/api/settings', body: {
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
    });
    if (r.statusCode != 200) throw Exception('Не удалось обновить настройки');
  }
}

