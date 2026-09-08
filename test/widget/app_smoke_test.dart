import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:pazel/app.dart';
import 'package:pazel/core/database/local_study_repository.dart';
import 'package:pazel/core/state/app_controller.dart';
import 'package:pazel/core/localization/strings.dart';

void main() {
  testWidgets('mobile app renders Persian RTL onboarding without settling forever', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = await databaseFactoryMemory.openDatabase('smoke');
    final repository = LocalStudyRepository(db);
    await repository.initialize();
    addTearDown(repository.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        initialDataProvider.overrideWithValue(await repository.load()),
      ],
      child: const PazelApp(),
    ));
    // Do not use pumpAndSettle: AppController owns a periodic timer.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(S.welcomeTitle), findsOneWidget);
    expect(find.text(S.welcomeBody), findsOneWidget);
    expect(find.text(S.skip), findsOneWidget);
    expect(find.text(S.next), findsOneWidget);
    expect(Directionality.of(tester.element(find.text(S.welcomeTitle))), TextDirection.rtl);
    expect(tester.getSize(find.text(S.next)).height, greaterThan(0));

    // Dispose the widget tree before closing the in-memory database. This also
    // cancels AppController's periodic ticker deterministically.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
