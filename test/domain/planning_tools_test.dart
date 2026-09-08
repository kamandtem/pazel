import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/core/models/failure.dart';
import 'package:pazel/features/planning/domain/planning_service.dart';
import 'package:pazel/features/tools/domain/tools_service.dart';
import 'package:pazel/core/localization/formatters.dart';
void main() {
  StudyPlan plan(String id, int start, {int minutes = 60}) => StudyPlan(id: id,
    subjectId: 'math', topic: 'functions', day: '2026-09-08', startMinute: start, minutes: minutes);
  test('overlap rejected; adjacent boundaries allowed', () {
    expect(() => PlanningService.validate(plan('b', 550), [plan('a', 540)]), throwsA(isA<AppFailure>()));
    expect(() => PlanningService.validate(plan('b', 600), [plan('a', 540)]), returnsNormally);
  });
  test('negative duration and cross-midnight plan rejected', () {
    expect(() => PlanningService.validate(plan('a', 0, minutes: -5), []), throwsA(isA<AppFailure>()));
    expect(() => PlanningService.validate(plan('a', 1400), []), throwsA(isA<AppFailure>()));
  });
  test('reorder updates positions, not study clock times', () {
    final result = PlanningService.reorder([plan('a', 540), plan('b', 600), plan('c', 660)], 0, 3);
    expect(result.map((p) => p.id), ['b', 'c', 'a']);
    expect(result.last.position, 2); expect(result.last.startMinute, 540);
  });
  test('exam correct-minus-one-third-wrong calculation', () {
    expect(ToolsService.examPercentage(correct: 20, wrong: 6, unanswered: 4), 60);
    expect(ToolsService.examPercentage(correct: 0, wrong: 3, unanswered: 0), closeTo(-100 / 3, 0.0001));
    expect(ToolsService.examPercentage(correct: 2, wrong: 1, unanswered: 1, negativeMarking: false), 50);
    expect(() => ToolsService.examPercentage(correct: 0, wrong: 0, unanswered: 0), throwsA(isA<AppFailure>()));
  });
  test('weighted grades account for credits', () {
    expect(ToolsService.weightedAverage([(20, 1), (10, 3)]), 12.5);
  });
  test('sleep calculator produces approximate bedtime before wake time', () {
    final wake = DateTime(2026, 9, 9, 7);
    expect(ToolsService.bedtimeOptions(wake).first, DateTime(2026, 9, 8, 21, 45));
  });
  test('Persian and Arabic input digits normalize; Jalali roundtrip', () {
    expect(latinDigits('۰۹۱٢'), '0912');
    expect(const Fmt(true).n(123), '۱۲۳');
    expect(Fmt.parseClock('۲۳:۵۹'), 1439); expect(Fmt.parseClock('۲۴:۰۰'), isNull);
    final civil = DateTime(2026, 9, 8);
    expect(Fmt.parseDate(const Fmt(false).dateInput(civil)), civil);
  });
}
