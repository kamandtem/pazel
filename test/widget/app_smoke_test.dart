import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:pazel/app.dart';
import 'package:pazel/core/database/local_study_repository.dart';
import 'package:pazel/core/state/app_controller.dart';
import 'package:pazel/core/localization/strings.dart';
void main() {
  testWidgets('mobile app opens onboarding then demo login with RTL', (tester) async {
    tester.view.physicalSize = const Size(390, 844); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    final db = await databaseFactoryMemory.openDatabase('smoke');
    final repo = LocalStudyRepository(db); await repo.initialize();
    await tester.pumpWidget(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo),
      initialDataProvider.overrideWithValue(await repo.load())], child: const PazelApp()));
    await tester.pumpAndSettle();
    expect(find.text(S.welcomeTitle), findsOneWidget);
    expect(Directionality.of(tester.element(find.text(S.welcomeTitle))), TextDirection.rtl);
    await tester.tap(find.text(S.skip)); await tester.pumpAndSettle();
    expect(find.text(S.mockAuth), findsOneWidget);
    expect(find.text(S.sendCode), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink()); await repo.close();
  });
}
