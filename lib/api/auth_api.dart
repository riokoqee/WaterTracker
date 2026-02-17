import 'dart:convert';
import 'api_client.dart';
import 'token_storage.dart';

class AuthApi {
  final ApiClient _api;
  final TokenStorage _storage;
  AuthApi(this._api, this._storage);

  Future<void> login(String email, String password) async {
    final r = await _api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    if (r.statusCode != 200) {
      throw Exception(_extractError(r.body) ?? 'Ошибка входа');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    await _storage.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final r = await _api.post('/api/auth/register', body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
    if (r.statusCode != 200) {
      throw Exception(_extractError(r.body) ?? 'Ошибка регистрации');
    }
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    await _storage.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
  }

  Future<void> logout() => _storage.clear();

  Future<void> startPasswordReset(String email) async {
    final r = await _api.post('/api/auth/forgot-password', body: {
      'email': email,
    });
    if (r.statusCode != 200) {
      throw Exception(_extractError(r.body) ?? 'Не удалось отправить письмо');
    }
  }

  String? _extractError(String body) {
    try {
      final m = jsonDecode(body);
      if (m is Map) {
        final msg = m['message'] ?? m['error'] ?? m['detail'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
    } catch (_) {}
    if (body.isNotEmpty && body.length < 200) return body;
    return null;
  }
}
