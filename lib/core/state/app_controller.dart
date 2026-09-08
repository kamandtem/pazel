import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/study_repository.dart';
import '../models/models.dart';
import '../models/failure.dart';
import '../services/notification_service.dart';
import '../localization/strings.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/flashcards/domain/review_service.dart';

final repositoryProvider = Provider<StudyRepository>((ref) => throw UnimplementedError());
final initialDataProvider = Provider<AppData>((ref) => throw UnimplementedError());
final notificationProvider = Provider<NotificationService>((ref) => LocalNotificationService());
final authProvider = Provider<AuthRepository>((ref) => MockAuthRepository());
final busyProvider = StateProvider<bool>((ref) => false);
final warningProvider = StateProvider<String?>((ref) => null);
final clockProvider = StreamProvider<DateTime>((ref) =>
  Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()));
final appProvider = StateNotifierProvider<AppController, AppData>((ref) => AppController(
  ref, ref.read(repositoryProvider), ref.read(initialDataProvider), ref.read(notificationProvider)));

class AppController extends StateNotifier<AppData> {
  AppController(this.ref, this.repository, AppData initial, this.notifications) : super(initial) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _checkPhase());
  }
  final Ref ref;
  final StudyRepository repository;
  final NotificationService notifications;
  late final Timer _ticker;
  Future<void> _run(Future<void> Function() action) async {
    if (ref.read(busyProvider)) throw const AppFailure('busy');
    ref.read(busyProvider.notifier).state = true;
    try { await action(); state = await repository.load(); }
    finally { ref.read(busyProvider.notifier).state = false; }
  }
  Future<void> _notify(Future<void> Function() action) async {
    try { await action(); }
    catch (_) { ref.read(warningProvider.notifier).state = S.notificationFailed; }
  }
  Future<void> _scheduleTimer(ActiveTimer t) async {
    if (!state.preferences.notifications || !t.running || t.mode != TimerMode.pomodoro) return;
    final remaining = t.phaseSeconds - t.countedAt(DateTime.now());
    if (remaining <= 0) return;
    await _notify(() => notifications.schedule(700,
      t.phase == TimerPhase.focus ? S.focusDoneTitle : S.restDoneTitle,
      t.phase == TimerPhase.focus ? S.focusDoneBody : S.restDoneBody,
      DateTime.now().add(Duration(seconds: remaining))));
  }
  Future<void> _checkPhase() async {
    final t = state.timer;
    if (t == null || !t.running || !t.completeAt(DateTime.now()) || ref.read(busyProvider)) return;
    try {
      await _run(() async {
        await repository.saveTimer(t.pause(DateTime.now()));
        await repository.addNotice(AppNotice(id: 'phase-${t.id}',
          title: t.phase == TimerPhase.focus ? S.focusDoneTitle : S.restDoneTitle,
          body: t.phase == TimerPhase.focus ? S.focusDoneBody : S.restDoneBody,
          createdAt: DateTime.now()));
      });
    } catch (_) { ref.read(warningProvider.notifier).state = S.genericError; }
  }
  Future<void> onboard() => _run(repository.setOnboarded);
  Future<void> signIn(String phone, String code) => _run(() async {
    await ref.read(authProvider).verifyCode(phone, code);
    await repository.saveProfile(UserProfile.fromJson({...state.user.toJson(), 'phone': phone}));
    await repository.setSignedIn(true);
  });
  Future<void> saveProfile(UserProfile profile) => _run(() async {
    if (profile.name.trim().isEmpty || profile.dailyGoalMinutes < 1 || profile.dailyGoalMinutes > 960) {
      throw const AppFailure('invalidPlan');
    }
    await repository.saveProfile(profile);
  });
  Future<void> logout() => _run(() async {
    final t = state.timer;
    if (t != null) await repository.saveTimer(t.pause(DateTime.now()));
    await repository.setSignedIn(false);
    await _notify(notifications.cancelAll);
  });
  Future<void> preferences(Preferences p) => _run(() async {
    if (p.notifications && !state.preferences.notifications) {
      final granted = await notifications.requestPermission();
      if (!granted) {
        ref.read(warningProvider.notifier).state = S.notificationDenied;
        p = p.copyWith(notifications: false);
      }
    }
    await repository.savePreferences(p);
    if (!p.notifications) await _notify(notifications.cancelAll);
  });
  int _planNotificationId(String id) => 1000 + id.codeUnits.fold<int>(0, (v, c) => (v * 31 + c) % 1000000);
  Future<void> savePlan(StudyPlan p) => _run(() async {
    await repository.savePlan(p);
    if (state.preferences.notifications) {
      await _notify(() => notifications.cancel(_planNotificationId(p.id)));
      if (!p.done) {
        final d = DateTime.parse(p.day);
        await _notify(() => notifications.schedule(_planNotificationId(p.id), S.planReminder,
          p.topic, DateTime(d.year, d.month, d.day, p.startMinute ~/ 60, p.startMinute % 60)));
      }
    }
  });
  Future<void> reorder(List<StudyPlan> plans) => _run(() => repository.savePlanOrder(plans));
  Future<void> deletePlan(String id) => _run(() async {
    await repository.deletePlan(id);
    await _notify(() => notifications.cancel(_planNotificationId(id)));
  });
  Future<void> saveNote(String day, String note) => _run(() => repository.saveNote(day, note));
  Future<void> start({required String subjectId, required String topic,
      TimerMode mode = TimerMode.tracker, int focusMinutes = 25, int breakMinutes = 5,
      String? planId}) => _run(() async {
    if (topic.trim().isEmpty || focusMinutes < 1 || focusMinutes > 180 ||
      breakMinutes < 1 || breakMinutes > 60) throw const AppFailure('invalidSession');
    final now = DateTime.now();
    final t = ActiveTimer(id: newId(), subjectId: subjectId, topic: topic,
      startedAt: now, anchor: now, mode: mode, focusMinutes: focusMinutes,
      breakMinutes: breakMinutes, planId: planId);
    await repository.saveTimer(t);
    await repository.event(mode == TimerMode.tracker ? 'study_start' : 'pomodoro_start');
    await _scheduleTimer(t);
  });
  Future<void> toggleTimer() => _run(() async {
    final t = state.timer;
    if (t == null) throw const AppFailure('timerMissing');
    if (t.completeAt(DateTime.now())) return;
    final next = t.running ? t.pause(DateTime.now()) : t.resume(DateTime.now());
    await repository.saveTimer(next);
    await _notify(() => notifications.cancel(700));
    await _scheduleTimer(next);
  });
  Future<void> pauseForFinish() => _run(() async {
    final t = state.timer;
    if (t != null && t.running) await repository.saveTimer(t.pause(DateTime.now()));
    await _notify(() => notifications.cancel(700));
  });
  Future<void> discardTimer() => _run(() async {
    await repository.discardTimer();
    await _notify(() => notifications.cancel(700));
  });
  Future<void> finish({required int tests, required int quality, required int focus,
      required int mood, required String note, bool rest = false}) => _run(() async {
    final t = state.timer;
    if (t == null || t.phase != TimerPhase.focus) throw const AppFailure('timerMissing');
    final now = DateTime.now(), seconds = t.countedAt(DateTime.now());
    final next = rest && t.mode == TimerMode.pomodoro ? ActiveTimer(
      id: newId(), subjectId: t.subjectId, topic: t.topic, startedAt: now, anchor: now,
      mode: TimerMode.pomodoro, phase: TimerPhase.rest, focusMinutes: t.focusMinutes,
      breakMinutes: t.breakMinutes, cycles: t.cycles + 1, planId: t.planId) : null;
    await repository.finish(StudySession(id: t.id, subjectId: t.subjectId, topic: t.topic,
      startedAt: t.startedAt, endedAt: now, seconds: seconds, tests: tests,
      quality: quality, focus: focus, mood: mood, note: note, planId: t.planId), next: next);
    await repository.addNotice(AppNotice(id: 'saved-${t.id}', title: S.sessionSavedTitle,
      body: S.sessionSavedBody, createdAt: now));
    await _notify(() => notifications.cancel(700));
    if (next != null) await _scheduleTimer(next);
  });
  Future<void> nextFocus() => _run(() async {
    final t = state.timer;
    if (t == null || t.phase != TimerPhase.rest) throw const AppFailure('timerMissing');
    final now = DateTime.now();
    // Same timer record ID can be reused: rest was never a saved study session.
    final next = ActiveTimer(id: t.id, subjectId: t.subjectId, topic: t.topic,
      startedAt: now, anchor: now, mode: TimerMode.pomodoro, phase: TimerPhase.focus,
      focusMinutes: t.focusMinutes, breakMinutes: t.breakMinutes,
      cycles: t.cycles, planId: t.planId);
    await repository.saveTimer(next);
    await _notify(() => notifications.cancel(700));
    await _scheduleTimer(next);
  });
  Future<void> saveCard(Flashcard c) => _run(() async {
    if (c.front.trim().isEmpty || c.back.trim().isEmpty) throw const AppFailure('invalidPlan');
    state.subject(c.subjectId);
    await repository.saveCard(c);
  });
  Future<void> review(Flashcard c, ReviewRating r) => _run(() async {
    await repository.reviewCard(c, ReviewService.review(c, r, DateTime.now()), r);
    await repository.event('flashcard_review');
  });
  Future<void> readNotice(String id) => _run(() => repository.readNotice(id));
  @override
  void dispose() { _ticker.cancel(); super.dispose(); }
}
