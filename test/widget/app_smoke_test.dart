import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/app.dart';
import 'package:pazel/core/database/seed.dart';
import 'package:pazel/core/database/study_repository.dart';
import 'package:pazel/core/localization/strings.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/core/services/notification_service.dart';
import 'package:pazel/core/state/app_controller.dart';

/// Pure in-memory repository for widget tests.
///
/// The widget smoke test deliberately does NOT use sembast. `testWidgets` runs
/// its body inside a fake-async zone, and sembast's transaction/lock machinery
/// depends on real timers, so `initialize()` never completes there and the test
/// times out. Persistence itself is already covered by
/// `test/data/repository_test.dart`, which runs as a plain (real-async) test.
class FakeStudyRepository implements StudyRepository {
  FakeStudyRepository({DateTime? now}) : _now = now ?? DateTime(2026, 1, 1, 9);
  final DateTime _now;
  AppData _data = AppData();
  bool closed = false;

  @override
  Future<void> initialize() async {
    _data = AppData(
      subjects: seedSubjects,
      plans: seedPlans(_now),
      sessions: seedSessions(_now),
      cards: seedCards(_now),
    );
  }

  @override
  Future<AppData> load() async => _data;

  @override
  Future<void> setOnboarded() async => _data = _copy(onboarded: true);

  @override
  Future<void> setSignedIn(bool value) async => _data = _copy(signedIn: value);

  @override
  Future<void> saveProfile(UserProfile profile) async =>
      _data = _copy(user: profile);

  @override
  Future<void> savePreferences(Preferences preferences) async =>
      _data = _copy(preferences: preferences);

  @override
  Future<void> savePlan(StudyPlan plan) async {}
  @override
  Future<void> savePlanOrder(List<StudyPlan> plans) async {}
  @override
  Future<void> deletePlan(String id) async {}
  @override
  Future<void> saveTimer(ActiveTimer timer) async =>
      _data = _copy(timer: timer);
  @override
  Future<void> discardTimer() async => _data = _copy(clearTimer: true);
  @override
  Future<void> finish(StudySession session, {ActiveTimer? next}) async =>
      _data = _copy(timer: next, clearTimer: next == null);
  @override
  Future<void> saveNote(String day, String text) async {}
  @override
  Future<void> saveCard(Flashcard card) async {}
  @override
  Future<void> reviewCard(
      Flashcard before, Flashcard after, ReviewRating rating) async {}
  @override
  Future<void> readNotice(String id) async {}
  @override
  Future<void> addNotice(AppNotice notice) async {}
  @override
  Future<void> event(String name) async {}
  @override
  Future<void> close() async => closed = true;

  AppData _copy({
    UserProfile? user,
    Preferences? preferences,
    bool? onboarded,
    bool? signedIn,
    ActiveTimer? timer,
    bool clearTimer = false,
  }) =>
      AppData(
        user: user ?? _data.user,
        preferences: preferences ?? _data.preferences,
        onboarded: onboarded ?? _data.onboarded,
        signedIn: signedIn ?? _data.signedIn,
        timer: clearTimer ? null : (timer ?? _data.timer),
        subjects: _data.subjects,
        plans: _data.plans,
        sessions: _data.sessions,
        cards: _data.cards,
        notices: _data.notices,
        notes: _data.notes,
      );
}

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
  testWidgets(
      'mobile app renders Persian RTL onboarding without settling forever',
      timeout: const Timeout(Duration(seconds: 25)), (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeStudyRepository();
    await repository.initialize();
    final initialData = await repository.load();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        initialDataProvider.overrideWithValue(initialData),
        notificationProvider.overrideWithValue(_NoopNotificationService()),
      ],
      child: const PazelApp(),
    ));
    // Do not use pumpAndSettle: AppController owns a periodic timer.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(S.welcomeTitle), findsOneWidget);
    expect(find.text(S.welcomeBody), findsOneWidget);
    expect(find.text(S.skip), findsOneWidget);
    expect(Directionality.of(tester.element(find.text(S.welcomeTitle))),
        TextDirection.rtl);

    // The primary CTA sits in a fixed footer, so it must be present, laid out
    // and tappable without any scrolling, on any viewport height.
    final cta = find.widgetWithText(FilledButton, S.next);
    expect(cta, findsOneWidget);
    expect(find.text(S.next), findsOneWidget);
    expect(tester.getSize(find.text(S.next)).height, greaterThan(0));
    expect(cta.hitTestable(), findsOneWidget);

    // Stepping forward keeps the CTA visible and swaps the label on the last
    // onboarding step.
    await tester.tap(cta);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, S.next));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, S.letsGo).hitTestable(),
        findsOneWidget);

    // Dispose the widget tree so AppController's periodic ticker is cancelled
    // deterministically before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await repository.close();
  });
}
