import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/features/reports/domain/report_service.dart';
void main() {
  final now = DateTime(2026, 9, 8, 12);
  StudySession s(int offset) => StudySession(id: '$offset', subjectId: 'math', topic: 'functions',
    startedAt: DateTime(2026, 9, 8 - offset, 9), endedAt: DateTime(2026, 9, 8 - offset, 9, 30),
    seconds: 1800, tests: 10);
  for (final days in [7, 30, 90]) {
    test('$days day report uses inclusive civil dates and excludes older/future sessions', () {
      final data = AppData(sessions: [for (var i = -1; i < 100; i++) s(i)]);
      final report = ReportService.build(data, days, now);
      expect(report.totalSeconds, days * 1800);
      expect(report.sessions, days); expect(report.tests, days * 10);
      expect(report.secondsByDay.length, days); expect(report.dailyAverageSeconds, 1800);
    });
  }
  test('average includes six empty days', () {
    final report = ReportService.build(AppData(sessions: [s(0)]), 7, now);
    expect(report.dailyAverageSeconds, 1800 / 7);
    expect(report.weakestDay, isNot('2026-09-08'));
  });
  test('session crossing midnight allocates duration between days', () {
    final session = StudySession(id: 'night', subjectId: 'math', topic: 'Q',
      startedAt: DateTime(2026, 9, 7, 23, 30), endedAt: DateTime(2026, 9, 8, 0, 30), seconds: 3600);
    final report = ReportService.build(AppData(sessions: [session]), 7, now);
    expect(report.secondsByDay['2026-09-07'], 1800);
    expect(report.secondsByDay['2026-09-08'], 1800); expect(report.totalSeconds, 3600);
  });
  test('insights refuse unsupported focus conclusion with tiny sample', () {
    expect(ReportService.insights(AppData(sessions: [s(0)]), now), isEmpty);
  });
  test('focus insight includes sample evidence instead of random text', () {
    final insight = ReportService.insights(AppData(sessions: [for (var i = 0; i < 5; i++) s(i)]), now);
    expect(insight.first.code, 'focusHour'); expect(insight.first.evidence['count'], 5);
  });
}
