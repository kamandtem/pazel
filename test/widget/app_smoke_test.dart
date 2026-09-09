import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:pazel/app.dart';
import 'package:pazel/core/database/local_study_repository.dart';
import 'package:pazel/core/state/app_controller.dart';
import 'package:pazel/core/services/notification_service.dart';
import 'package:pazel/core/localization/strings.dart';

class _NoopNotificationService implements NotificationService {
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule(int id, String title, String body, DateTime at) async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll() async {}
}

void main() {
  testWidgets('mobile app renders Persian RTL onboarding without settling forever',
      timeout: const Timeout(Duration(seconds: 25)), (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    print('[smoke] opening database');
    final db = await databaseFactoryMemory.openDatabase('smoke');
    print('[smoke] database opened');
    final repository = LocalStudyRepository(db);
    print('[smoke] calling repository.initialize()');
    await repository.initialize();
    print('[smoke] repository.initialize() done');
    addTearDown(repository.close);

    print('[smoke] calling repository.load()');
    final initialData = await repository.load();
    print('[smoke] repository.load() done');

    print('[smoke] calling pumpWidget');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        initialDataProvider.overrideWithValue(initialData),
        notificationProvider.overrideWithValue(_NoopNotificationService()),
      ],
      child: const PazelApp(),
    ));
    print('[smoke] pumpWidget done');
    // Do not use pumpAndSettle: AppController owns a periodic timer.
    await tester.pump();
    print('[smoke] first pump() done');
    await tester.pump(const Duration(milliseconds: 100));
    print('[smoke] second pump(100ms) done');

    expect(find.text(S.welcomeTitle), findsOneWidget);
    expect(find.text(S.welcomeBody), findsOneWidget);
    expect(find.text(S.skip), findsOneWidget);
    expect(find.text(S.next), findsOneWidget);
    expect(Directionality.of(tester.element(find.text(S.welcomeTitle))), TextDirection.rtl);
    expect(tester.getSize(find.text(S.next)).height, greaterThan(0));
    print('[smoke] all expects passed');

    // Dispose the widget tree before closing the in-memory database. This also
    // cancels AppController's periodic ticker deterministically.
    await tester.pumpWidget(const SizedBox.shrink());
    print('[smoke] teardown pumpWidget(shrink) done');
    await tester.pump();
    print('[smoke] final pump() done — test body complete');
  });
}
