import '../../../core/models/failure.dart';
abstract interface class AuthRepository {
  Future<void> requestCode(String phone);
  Future<bool> verifyCode(String phone, String code);
}
class MockAuthRepository implements AuthRepository {
  String? _phone;
  DateTime? _issued;
  int _attempts = 0;
  @override
  Future<void> requestCode(String phone) async {
    if (!RegExp(r'^09[0-9]{9}$').hasMatch(phone)) throw const AppFailure('invalidPhone');
    if (_issued != null && DateTime.now().difference(_issued!).inSeconds < 30) {
      throw const AppFailure('waitForCode');
    }
    _phone = phone;
    _issued = DateTime.now();
    _attempts = 0;
  }
  @override
  Future<bool> verifyCode(String phone, String code) async {
    if (_phone != phone || _issued == null ||
      DateTime.now().difference(_issued!).inMinutes >= 2 || _attempts >= 5) {
      throw const AppFailure('expiredCode');
    }
    _attempts++;
    if (code != '123456') throw const AppFailure('invalidCode');
    _phone = null;
    return true;
  }
}
