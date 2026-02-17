import 'package:flutter/foundation.dart';

class Env {
  // Базовый URL бэкенда. Можно переопределить через --dart-define.
  static String get baseUrl {
    const override = String.fromEnvironment('BACKEND_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:8080';
    // По умолчанию для мобильных устройств используем IP из локальной сети
    return 'http://192.168.1.79:8080';
  }
}

