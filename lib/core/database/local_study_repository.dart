import 'package:sembast/sembast.dart';
import '../models/models.dart';
import '../models/failure.dart';
import '../../features/planning/domain/planning_service.dart';
import 'study_repository.dart';
import 'seed.dart';

class LocalStudyRepository implements StudyRepository {
  LocalStudyRepository(this.db);
  final Database db;
  StoreRef<String, Json> store(String name) => stringMapStoreFactory.store(name);
  Future<void> _write(Transaction tx, String entity, String id, Json value,
      {bool sync = true}) async {
    await store(entity).record(id).put(tx, value);
    if (sync) await store('outbox').record(newId()).put(tx, {
      'entity': entity, 'recordId': id, 'operation': 'upsert', 'payload': value,
      'createdAt': DateTime.now().toUtc().toIso8601String(), 'attempts': 0,
    });
  }
  Future<void> _put(String entity, String id, Json value, {bool sync = true}) =>
    db.transaction((tx) => _write(tx, entity, id, value, sync: sync));
  Future<List<Json>> _all(String entity, {Finder? finder}) async =>
    (await store(entity).find(db, finder: finder)).map((r) => r.value).toList();
  @override
  Future<void> initialize() async {
    final schema = await store('meta').record('schema').get(db);
    if (schema != null && schema['version'] != 1) throw const AppFailure('schema');
    await db.transaction((tx) async {
      await store('meta').record('schema').put(tx, {'version': 1});
      if (await store('meta').record('seeded').exists(tx)) return;
      final now = DateTime.now();
      for (final s in seedSubjects) {
        await store('subjects').record(s.id).put(tx, s.toJson());
      }
      for (final p in seedPlans(now)) {
        await store('study_plans').record(p.id).put(tx, p.toJson());
      }
      for (final s in seedSessions(now)) {
        await store('study_sessions').record(s.id).put(tx, s.toJson());
      }
      for (final c in seedCards(now)) {
        await store('flashcards').record(c.id).put(tx, c.toJson());
      }
      await store('meta').record('seeded').put(tx, {'value': true});
    });
  }
  @override
  Future<AppData> load() async {
    final u = await store('users').record('local').get(db);
    final p = await store('settings').record('local').get(db);
    final t = await store('active_timer').record('current').get(db);
    final notes = await store('notes').find(db);
    final cutoff = DateTime.now().subtract(const Duration(days: 91)).toUtc().toIso8601String();
    return AppData(user: u == null ? const UserProfile() : UserProfile.fromJson(u),
      preferences: p == null ? const Preferences() : Preferences.fromJson(p),
      onboarded: (await store('meta').record('onboarding').get(db))?['value'] == true,
      signedIn: (await store('meta').record('auth').get(db))?['value'] == true,
      timer: t == null ? null : ActiveTimer.fromJson(t),
      subjects: (await _all('subjects')).map(Subject.fromJson).toList(),
      plans: (await _all('study_plans')).map(StudyPlan.fromJson).toList(),
      sessions: (await _all('study_sessions', finder: Finder(
        filter: Filter.greaterThanOrEquals('endedAt', cutoff),
        sortOrders: [SortOrder('endedAt', false)]))).map(StudySession.fromJson).toList(),
      cards: (await _all('flashcards', finder: Finder(sortOrders: [SortOrder('dueAt')]))).
        map(Flashcard.fromJson).toList(),
      notices: (await _all('notifications', finder: Finder(limit: 100,
        sortOrders: [SortOrder('createdAt', false)]))).map(AppNotice.fromJson).toList(),
      notes: {for (final n in notes) n.key: n.value['text']! as String});
  }
  @override
  Future<void> saveProfile(UserProfile profile) => _put('users', 'local', profile.toJson(), sync: false);
  @override
  Future<void> setOnboarded() => _put('meta', 'onboarding', {'value': true}, sync: false);
  @override
  Future<void> setSignedIn(bool value) => _put('meta', 'auth', {'value': value}, sync: false);
  @override
  Future<void> savePreferences(Preferences p) => _put('settings', 'local', p.toJson(), sync: false);
  @override
  Future<void> savePlan(StudyPlan plan) async {
    if (!await store('subjects').record(plan.subjectId).exists(db)) {
      throw const AppFailure('invalidSubject');
    }
    await db.transaction((tx) async {
      final records = await store('study_plans').find(tx);
      PlanningService.validate(plan, records.map((r) => StudyPlan.fromJson(r.value)).toList());
      await _write(tx, 'study_plans', plan.id, plan.toJson());
    });
  }
  @override
  Future<void> savePlanOrder(List<StudyPlan> plans) => db.transaction((tx) async {
    for (final p in plans) {
      final current = await store('study_plans').record(p.id).get(tx);
      if (current != null) await _write(tx, 'study_plans', p.id,
        StudyPlan.fromJson(current).copyWith(position: p.position).toJson());
    }
  });
  @override
  Future<void> deletePlan(String id) => db.transaction((tx) async {
    final timer = await store('active_timer').record('current').get(tx);
    if (timer?['planId'] == id) throw const AppFailure('activePlan');
    await store('study_plans').record(id).delete(tx);
    await store('outbox').record(newId()).put(tx, {'entity': 'study_plans',
      'recordId': id, 'operation': 'delete', 'payload': <String, Object?>{},
      'createdAt': DateTime.now().toUtc().toIso8601String(), 'attempts': 0});
  });
  @override
  Future<void> saveTimer(ActiveTimer timer) => db.transaction((tx) async {
    final active = await store('active_timer').record('current').get(tx);
    if (active != null && active['id'] != timer.id) throw const AppFailure('timerExists');
    if (!await store('subjects').record(timer.subjectId).exists(tx)) {
      throw const AppFailure('invalidSubject');
    }
    await store('active_timer').record('current').put(tx, timer.toJson());
  });
  @override
  Future<void> discardTimer() async { await store('active_timer').record('current').delete(db); }
  @override
  Future<void> finish(StudySession session, {ActiveTimer? next}) => db.transaction((tx) async {
    if (await store('study_sessions').record(session.id).exists(tx)) return;
    final active = await store('active_timer').record('current').get(tx);
    if (active == null || active['id'] != session.id) throw const AppFailure('timerMissing');
    if (session.seconds < 1 || session.tests < 0 || session.focus < 1 ||
      session.focus > 5 || session.quality < 1 || session.quality > 5 ||
      session.mood < 0 || session.mood > 4) throw const AppFailure('invalidSession');
    await _write(tx, 'study_sessions', session.id, session.toJson());
    if (session.planId != null && next == null) {
      final p = await store('study_plans').record(session.planId!).get(tx);
      if (p != null) await _write(tx, 'study_plans', session.planId!,
        StudyPlan.fromJson(p).copyWith(done: true).toJson());
    }
    await store('active_timer').record('current').delete(tx);
    if (next != null) await store('active_timer').record('current').put(tx, next.toJson());
    await store('analytics').record(newId()).put(tx, {
      'name': 'study_complete', 'at': DateTime.now().toUtc().toIso8601String()});
  });
  @override
  Future<void> saveNote(String day, String text) => _put('notes', day, {'text': text});
  @override
  Future<void> saveCard(Flashcard c) => _put('flashcards', c.id, c.toJson());
  @override
  Future<void> reviewCard(Flashcard before, Flashcard after, ReviewRating rating) =>
    db.transaction((tx) async {
      final actual = await store('flashcards').record(before.id).get(tx);
      if (actual == null || actual['reviews'] != before.reviews) {
        throw const AppFailure('staleReview');
      }
      await _write(tx, 'flashcards', after.id, after.toJson());
      await _write(tx, 'flashcard_reviews', newId(), {'cardId': before.id,
        'rating': rating.name, 'reviewedAt': DateTime.now().toUtc().toIso8601String(),
        'previousBox': before.box, 'nextBox': after.box,
        'nextDueAt': after.dueAt.toUtc().toIso8601String()});
    });
  @override
  Future<void> readNotice(String id) => db.transaction((tx) async {
    final n = await store('notifications').record(id).get(tx);
    if (n != null) await store('notifications').record(id).put(tx, {...n, 'read': true});
  });
  @override
  Future<void> addNotice(AppNotice n) => _put('notifications', n.id, n.toJson(), sync: false);
  @override
  Future<void> event(String name) => _put('analytics', newId(), {
    'name': name, 'at': DateTime.now().toUtc().toIso8601String()}, sync: false);
  @override
  Future<void> close() => db.close();
}
