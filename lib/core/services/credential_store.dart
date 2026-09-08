import 'package:flutter_secure_storage/flutter_secure_storage.dart';
abstract interface class CredentialStore {
  Future<void> writeAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> clear();
}
// For future real auth only. Demo auth never invents or stores a real credential.
class SecureCredentialStore implements CredentialStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  @override
  Future<void> writeAccessToken(String token) => _storage.write(key: 'access_token', value: token);
  @override
  Future<String?> readAccessToken() => _storage.read(key: 'access_token');
  @override
  Future<void> clear() => _storage.delete(key: 'access_token');
}
