import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  static const String _defaultBaseUrl = 'https://classpay.padat.net/api/v1';

  factory AppConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    return AppConfig(
      apiBaseUrl: configuredBaseUrl.isEmpty
          ? _defaultBaseUrl
          : _normaliseApiBaseUrl(configuredBaseUrl),
    );
  }

  final String apiBaseUrl;
  String get appName => 'ClassPay';

  static String _normaliseApiBaseUrl(String value) {
    final trimmed = value.trim().replaceFirst(RegExp(r'/+$'), '');
    return trimmed.endsWith('/api/v1') ? trimmed : '$trimmed/api/v1';
  }
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
