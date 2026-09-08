import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:pazel/core/database/local_study_repository.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/core/models/failure.dart';
import 'package:pazel/features/flashcards/domain/review_service.dart';
void main() {
  late Database db;
  late LocalStudyRepository repo;
  setUp(() async {
    db = await databaseFactoryMemory.openDatabase('test-${DateTime.now().microsecondsSinceEpoch}');
    repo = LocalStudyRepository(db); await repo.initialize();
  });
  tearDown(() async { await repo.close(); });
  test('seed is idempotent and local snapshot has real typed entities', () async {
    final before = await repo.load(); await repo.initialize(); final after = await repo.load();
    expect(after.subjects.length, 8); expect(after.sessions.length, before.sessions.length);
    expect(after.cards.length, 3);
  });
  test('profile, settings and notes persist independently', () async {
    await repo.saveProfile(const UserProfile(name: 'Test', dailyGoalMinutes: 120));
    await repo.savePreferences(const Preferences(dark: true, persianDigits: false));
    await repo.saveNote('2026-09-08', 'hello');
    final data = await repo.load();
    expect(data.user.name, 'Test'); expect(data.preferences.dark, true);
    expect(data.notes['2026-09-08'], 'hello');
  });
  test('finalization atomic, idempotent, clears timer and completes plan', () async {
    final now = DateTime.now(), id = newId();
    final plan = StudyPlan(id: 'p', subjectId: 'math', topic: 'Q', day: '2030-01-01',
      startMinute: 600, minutes: 30);
    await repo.savePlan(plan);
    await repo.saveTimer(ActiveTimer(id: id, subjectId: 'math', topic: 'Q',
      startedAt: now.subtract(const Duration(minutes: 30)), elapsedSeconds: 1800, planId: plan.id));
    final session = StudySession(id: id, subjectId: 'math', topic: 'Q',
      startedAt: now.subtract(const Duration(minutes: 30)), endedAt: now,
      seconds: 1800, planId: plan.id);
    await Future.wait([repo.finish(session), repo.finish(session)]);
    final data = await repo.load();
    expect(data.sessions.where((s) => s.id == id).length, 1); expect(data.timer, isNull);
    expect(data.plans.firstWhere((p) => p.id == plan.id).done, true);
    final envelopes = await repo.store('outbox').find(db);
    expect(envelopes.where((e) => e.value['entity'] == 'study_sessions').length, 1);
  });
  test('refuses second active timer; invalid finish leaves timer intact', () async {
    final now = DateTime.now();
    await repo.saveTimer(ActiveTimer(id: 'one', subjectId: 'math', topic: 'Q', startedAt: now));
    await expectLater(repo.saveTimer(ActiveTimer(id: 'two', subjectId: 'math', topic: 'Q', startedAt: now)),
      throwsA(isA<AppFailure>()));
    await expectLater(repo.finish(StudySession(id: 'one', subjectId: 'math', topic: 'Q',
      startedAt: now, endedAt: now, seconds: -1)), throwsA(isA<AppFailure>()));
    expect((await repo.load()).timer?.id, 'one');
  });
  test('review log and card update are transactionally persisted; stale review rejected', () async {
    final c = (await repo.load()).cards.first;
    final next = ReviewService.review(c, ReviewRating.good, DateTime.now());
    await repo.reviewCard(c, next, ReviewRating.good);
    await expectLater(repo.reviewCard(c, next, ReviewRating.good), throwsA(isA<AppFailure>()));
    expect((await repo.load()).cards.firstWhere((x) => x.id == c.id).reviews, 1);
    expect((await repo.store('flashcard_reviews').find(db)).length, 1);
  });
  test('unsupported schema fails without deleting data', () async {
    await repo.store('meta').record('schema').put(db, {'version': 2});
    await expectLater(repo.initialize(), throwsA(isA<AppFailure>()));
    expect((await repo.store('subjects').find(db)).length, 8);
  });
}
