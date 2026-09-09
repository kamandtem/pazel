import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:pazel/core/database/local_study_repository.dart';
import 'package:pazel/core/database/seed.dart';
import 'package:pazel/core/models/failure.dart';
import 'package:pazel/core/models/models.dart';

/// Persistence tests for [LocalStudyRepository].
///
/// These are plain (real-async) tests on purpose. sembast relies on real
/// timers, so its calls must never be awaited inside a `testWidgets` fake-async
/// zone. The UI smoke test lives in `test/widget/app_smoke_test.dart` and uses
/// an in-memory fake repository instead.
void main() {
  late Database db;
  late LocalStudyRepository repository;

  setUp(() async {
    db = await databaseFactoryMemory
        .openDatabase('repo-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalStudyRepository(db);
    await repository.initialize();
  });

  tearDown(() async => repository.close());

  test('initialize seeds demo content once', () async {
    final first = await repository.load();
    expect(first.subjects.length, seedSubjects.length);
    expect(first.plans.length, seedPlans(DateTime.now()).length);
    expect(first.sessions, isNotEmpty);
    expect(first.cards, isNotEmpty);
    expect(first.onboarded, isFalse);
    expect(first.signedIn, isFalse);

    // Re-running initialize must be idempotent (no duplicated seed rows).
    await repository.initialize();
    final second = await repository.load();
    expect(second.subjects.length, first.subjects.length);
    expect(second.plans.length, first.plans.length);
    expect(second.cards.length, first.cards.length);
  });

  test('onboarding, auth, profile and preferences round-trip', () async {
    await repository.setOnboarded();
    await repository.setSignedIn(true);
    await repository.saveProfile(const UserProfile(name: 'سارا', phone: '09120000000'));
    await repository.savePreferences(const Preferences(dark: true, persianDigits: false));

    final data = await repository.load();
    expect(data.onboarded, isTrue);
    expect(data.signedIn, isTrue);
    expect(data.user.name, 'سارا');
    expect(data.user.phone, '09120000000');
    expect(data.preferences.dark, isTrue);
    expect(data.preferences.persianDigits, isFalse);
  });

  test('notes are stored per day', () async {
    final day = civilDay(DateTime.now());
    await repository.saveNote(day, 'مرور شب امتحان');
    expect((await repository.load()).notes[day], 'مرور شب امتحان');
  });

  test('deletePlan removes the plan', () async {
    final before = await repository.load();
    final target = before.plans.first;
    await repository.deletePlan(target.id);
    final after = await repository.load();
    expect(after.plans.any((p) => p.id == target.id), isFalse);
    expect(after.plans.length, before.plans.length - 1);
  });

  test('timer round-trips and rejects an unknown subject', () async {
    final now = DateTime(2026, 1, 1, 9);
    await repository.saveTimer(ActiveTimer(
        id: 'timer-1', subjectId: 'math', topic: 'تابع', startedAt: now));
    expect((await repository.load()).timer?.id, 'timer-1');

    await expectLater(
      repository.saveTimer(ActiveTimer(
          id: 'timer-1', subjectId: 'unknown', topic: 'x', startedAt: now)),
      throwsA(isA<AppFailure>()),
    );

    await repository.discardTimer();
    expect((await repository.load()).timer, isNull);
  });

  test('notices can be added and marked read', () async {
    await repository.addNotice(AppNotice(
        id: 'n1', title: 'یادآوری', body: 'وقت مطالعه', createdAt: DateTime.now()));
    expect((await repository.load()).notices.single.read, isFalse);
    await repository.readNotice('n1');
    expect((await repository.load()).notices.single.read, isTrue);
  });
}
