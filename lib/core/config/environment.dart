abstract final class Environment {
  static const name = String.fromEnvironment('APP_ENV', defaultValue: 'demo');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'https://api.example.invalid/v1');
  static bool get isDemo => name == 'demo';
}
