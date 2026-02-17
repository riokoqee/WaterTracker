import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/env.dart';
import 'token_storage.dart';

class ApiClient {
  final String baseUrl;
  final TokenStorage _tokens;
  final http.Client _client;

  ApiClient({String? baseUrl, TokenStorage? storage, http.Client? client})
      : baseUrl = (() {
          const override = String.fromEnvironment('BACKEND_URL');
          final url = baseUrl ?? (override.isNotEmpty ? override : Env.baseUrl);
          return url.replaceAll(RegExp(r"/+$"), '');
        })(),
        _tokens = storage ?? TokenStorage(),
        _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? qp]) =>
      Uri.parse('$baseUrl${path.startsWith('/') ? '' : '/'}$path')
          .replace(queryParameters: qp?.map((k, v) => MapEntry(k, '$v')));

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    return _withAuth((h) => _client.get(_uri(path, query), headers: h));
  }

  Future<http.Response> post(String path, {Object? body}) async {
    return _withAuth((h) => _client.post(_uri(path), headers: h, body: jsonEncode(body)));
  }

  Future<http.Response> put(String path, {Object? body}) async {
    return _withAuth((h) => _client.put(_uri(path), headers: h, body: jsonEncode(body)));
  }

  Future<http.Response> delete(String path) async {
    return _withAuth((h) => _client.delete(_uri(path), headers: h));
  }

  Future<http.Response> _withAuth(
      Future<http.Response> Function(Map<String, String> headers) send) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final acc = await _tokens.access;
    if (acc != null) headers['Authorization'] = 'Bearer $acc';

    http.Response r = await send(headers);
    if (r.statusCode != 401) return r;

    final ok = await _refresh();
    if (!ok) return r;

    final headers2 = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final acc2 = await _tokens.access;
    if (acc2 != null) headers2['Authorization'] = 'Bearer $acc2';
    return send(headers2);
  }

  Future<bool> _refresh() async {
    final ref = await _tokens.refresh;
    if (ref == null) return false;
    final r = await _client.post(_uri('/api/auth/refresh'), headers: {
      'Authorization': 'Bearer $ref',
      'Content-Type': 'application/json'
    });
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      await _tokens.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return true;
    }
    return false;
  }
}

