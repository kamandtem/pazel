import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/core/models/models.dart';
void main() {
  final start = DateTime.utc(2026, 9, 8, 9);
  ActiveTimer timer({TimerMode mode = TimerMode.tracker, TimerPhase phase = TimerPhase.focus}) =>
    ActiveTimer(id: 't', subjectId: 'math', topic: 'functions', startedAt: start,
      anchor: start, mode: mode, phase: phase);
  test('tracker derives elapsed from persisted anchor', () {
    expect(timer().elapsedAt(start.add(const Duration(minutes: 30))), 1800);
  });
  test('pause excludes paused time; resume continues accumulated duration', () {
    final paused = timer().pause(start.add(const Duration(minutes: 10)));
    expect(paused.running, false);
    expect(paused.elapsedAt(start.add(const Duration(hours: 1))), 600);
    final resumed = paused.resume(start.add(const Duration(hours: 1)));
    expect(resumed.elapsedAt(start.add(const Duration(hours: 1, minutes: 5))), 900);
  });
  test('timer JSON roundtrip restores process death state', () {
    final restored = ActiveTimer.fromJson(timer().toJson());
    expect(restored.countedAt(start.add(const Duration(minutes: 15))), 900);
    expect(restored.toJson(), timer().toJson());
  });
  test('Pomodoro focus caps at one phase instead of inventing sessions', () {
    final p = timer(mode: TimerMode.pomodoro);
    expect(p.countedAt(start.add(const Duration(hours: 3))), 1500);
    expect(p.completeAt(start.add(const Duration(minutes: 25))), true);
    expect(p.completeAt(start.add(const Duration(minutes: 24))), false);
  });
  test('Pomodoro rest uses independent break duration', () {
    final p = timer(mode: TimerMode.pomodoro, phase: TimerPhase.rest);
    expect(p.phaseSeconds, 300);
    expect(p.countedAt(start.add(const Duration(minutes: 20))), 300);
  });
  test('backward wall clock cannot make elapsed negative', () {
    expect(timer().elapsedAt(start.subtract(const Duration(minutes: 1))), 0);
  });
}
