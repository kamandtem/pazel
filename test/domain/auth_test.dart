import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/features/auth/domain/auth_repository.dart';
import 'package:pazel/core/models/failure.dart';
void main() {
  test('demo OTP challenge requires phone and valid code, rejects replay', () async {
    final auth = MockAuthRepository();
    await expectLater(auth.requestCode('123'), throwsA(isA<AppFailure>()));
    await auth.requestCode('09123456789');
    await expectLater(auth.verifyCode('09123456789', '111111'), throwsA(isA<AppFailure>()));
    expect(await auth.verifyCode('09123456789', '123456'), true);
    await expectLater(auth.verifyCode('09123456789', '123456'), throwsA(isA<AppFailure>()));
  });
  test('resend rate limit and maximum attempts apply to mock too', () async {
    final auth = MockAuthRepository();
    await auth.requestCode('09123456789');
    await expectLater(auth.requestCode('09123456789'), throwsA(isA<AppFailure>()));
    for (var i = 0; i < 5; i++) {
      await expectLater(auth.verifyCode('09123456789', '000000'), throwsA(isA<AppFailure>()));
    }
    await expectLater(auth.verifyCode('09123456789', '123456'), throwsA(isA<AppFailure>()));
  });
}
