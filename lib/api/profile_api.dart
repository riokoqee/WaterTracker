import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/water_state.dart';
import 'api_client.dart';

class ProfileApi {
  final ApiClient _api;
  ProfileApi(this._api);

  Future<Map<String, dynamic>> me() async {
    final r = await _api.get('/api/profile');
    if (r.statusCode != 200) throw Exception('Не удалось получить профиль');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String email,
    String? gender, 
    int? age,
    double? weightKg,
    double? heightCm,
    String? wakeTime, 
    String? sleepTime, 
  }) async {
    print("📤 Sending update to backend:");
    print(jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'wakeTime': wakeTime,
      'sleepTime': sleepTime,
    }));

    final r = await _api.put(
      '/api/profile',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (gender != null) 'gender': gender,
        if (age != null) 'age': age,
        if (weightKg != null) 'weightKg': weightKg,
        if (heightCm != null) 'heightCm': heightCm,
        if (wakeTime != null) 'wakeTime': wakeTime,
        if (sleepTime != null) 'sleepTime': sleepTime,
      },
    );

    if (r.statusCode != 200) {
      print("❌ Ошибка обновления: ${r.statusCode}");
      print("Ответ сервера: ${r.body}");
      throw Exception('Ошибка обновления профиля: ${r.statusCode}');
    }

    final updated = jsonDecode(r.body) as Map<String, dynamic>;
    print("✅ Profile updated: $updated");

    if (updated['goalTargetMl'] != null) {
      final waterState = context.read<WaterState>();
      waterState.goalMl = updated['goalTargetMl'];
      waterState.notifyListeners();
      print("💧 Water goal updated: ${updated['goalTargetMl']} мл");
    }
  }
}
