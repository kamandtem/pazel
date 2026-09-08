import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/features/gamification/domain/gamification_service.dart';
StudySession session(DateTime day, int seconds) => StudySession(
  id: '$day-$seconds', subjectId: 'math', topic: 'test',
  startedAt: day.subtract(Duration(seconds: seconds)), endedAt: day, seconds: seconds);
void main() {
  test('30 minutes aggregate study yields 10 XP even across sessions', () {
    final now = DateTime(2026, 9, 8, 10);
    expect(GamificationService.xp([session(now, 900), session(now, 900)]), 10);
    expect(GamificationService.xp([session(now, 1799)]), 0);
    expect(GamificationService.level(200), 3);
  });
  test('streak tolerates unfinished today and handles year boundary', () {
    final now = DateTime(2027, 1, 1, 12);
    final s = [session(DateTime(2026, 12, 31, 10), 60), session(DateTime(2026, 12, 30, 10), 60)];
    expect(GamificationService.streak(s, now), 2);
    expect(GamificationService.streak(s, now.add(const Duration(days: 1))), 0);
  });
  test('freeze can bridge one missing day in domain service', () {
    final now = DateTime(2026, 9, 8, 12);
    final s = [session(now, 60), session(DateTime(2026, 9, 6, 12), 60)];
    expect(GamificationService.streak(s, now), 1);
    expect(GamificationService.streak(s, now, freezeDays: {'2026-09-07'}), 3);
  });
  test('league tie break is tests, sessions, then stable id', () {
    final ranked = GamificationService.rank(const [
      RankedMember('b', 100, 1, 10), RankedMember('a', 100, 1, 10),
      RankedMember('c', 100, 1, 20), RankedMember('d', 200, 1, 0),
    ]);
    expect(ranked.map((m) => m.id), ['d', 'c', 'a', 'b']);
  });
}
