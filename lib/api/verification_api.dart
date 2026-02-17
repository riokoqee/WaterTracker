import 'dart:convert';
import 'api_client.dart';

class VerificationApi {
  final ApiClient _api;
  VerificationApi(this._api);

  Future<void> sendCode(String email) async {
    final r = await _api.post('/api/auth/verify-email/send', body: {
      'email': email,
    });
    if (r.statusCode != 200) {
      _throwFriendly(r.body, 'Не удалось отправить код');
    }
  }

  Future<void> confirm(String email, String code) async {
    final r = await _api.post('/api/auth/verify-email/confirm', body: {
      'email': email,
      'code': code,
    });
    if (r.statusCode != 200) {
      _throwFriendly(r.body, 'Неверный или просроченный код');
    }
  }

  Never _throwFriendly(String body, String fallback) {
    try {
      final m = jsonDecode(body);
      if (m is Map) {
        final msg = m['message'] ?? m['error'] ?? m['detail'];
        if (msg is String && msg.trim().isNotEmpty) {
          throw Exception(msg);
        }
      }
    } catch (_) {}
    throw Exception(fallback);
  }
}

