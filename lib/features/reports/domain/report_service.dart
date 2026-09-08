import '../../../core/models/models.dart';
class StudyReport {
  const StudyReport({required this.days, required this.secondsByDay,
    required this.secondsBySubject, required this.totalSeconds, required this.tests,
    required this.sessions, required this.adherence, required this.reviewCount});
  final int days, totalSeconds, tests, sessions, reviewCount;
  final double adherence;
  final Map<String, int> secondsByDay, secondsBySubject;
  double get dailyAverageSeconds => totalSeconds / days;
  String? get bestDay => _extreme(true);
  String? get weakestDay => _extreme(false);
  String? _extreme(bool high) {
    if (secondsByDay.isEmpty || totalSeconds == 0) return null;
    final e = secondsByDay.entries.toList()..sort((a, b) => high
      ? b.value.compareTo(a.value) : a.value.compareTo(b.value));
    return e.first.key;
  }
}
class StudyInsight {
  const StudyInsight(this.code, this.evidence);
  final String code;
  final Map<String, Object> evidence;
}
abstract final class ReportService {
  static StudyReport build(AppData data, int days, DateTime now) {
    if (![1, 7, 30, 90].contains(days)) throw ArgumentError.value(days);
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(today.year, today.month, today.day - days + 1);
    final buckets = <String, int>{for (var i = 0; i < days; i++)
      civilDay(DateTime(start.year, start.month, start.day + i)): 0};
    final subjects = <String, int>{};
    var tests = 0, count = 0;
    for (final s in data.sessions) {
      final a = s.startedAt.toLocal(), b = s.endedAt.toLocal();
      if (b.isBefore(start) || a.isAfter(now)) continue;
      var allocated = 0;
      final wall = b.difference(a).inMilliseconds;
      if (wall <= 0) continue;
      for (final key in buckets.keys) {
        final d = DateTime.parse(key);
        final end = DateTime(d.year, d.month, d.day + 1);
        final lo = a.isAfter(d) ? a : d;
        var hi = b.isBefore(end) ? b : end;
        if (hi.isAfter(now)) hi = now;
        if (!hi.isAfter(lo)) continue;
        // Cumulative rounding preserves seconds when split at midnight.
        final before = (s.seconds * lo.difference(a).inMilliseconds / wall).round();
        final after = (s.seconds * hi.difference(a).inMilliseconds / wall).round();
        final value = (after - before).clamp(0, s.seconds).toInt();
        buckets[key] = buckets[key]! + value;
        allocated += value;
      }
      if (allocated > 0) {
        count++;
        subjects[s.subjectId] = (subjects[s.subjectId] ?? 0) + allocated;
      }
      if (!b.isBefore(start) && !b.isAfter(now)) tests += s.tests;
    }
    final plans = data.plans.where((p) => buckets.containsKey(p.day)).toList();
    return StudyReport(days: days, secondsByDay: Map.unmodifiable(buckets),
      secondsBySubject: Map.unmodifiable(subjects),
      totalSeconds: buckets.values.fold(0, (a, b) => a + b), tests: tests,
      sessions: count, adherence: plans.isEmpty ? 0 :
        plans.where((p) => p.done).length / plans.length,
      reviewCount: plans.where((p) => p.done && p.activity == 'review').length);
  }
  static List<StudyInsight> insights(AppData data, DateTime now) {
    final recent = data.sessions.where((s) =>
      s.endedAt.isAfter(now.subtract(const Duration(days: 30))) &&
      !s.endedAt.isAfter(now)).toList();
    final result = <StudyInsight>[];
    if (recent.length >= 5) {
      final byHour = <int, List<StudySession>>{};
      for (final s in recent) {
        byHour.putIfAbsent(s.startedAt.toLocal().hour, () => []).add(s);
      }
      final eligible = byHour.entries.where((e) => e.value.length >= 3).toList();
      double average(List<StudySession> s) =>
        s.fold<int>(0, (v, x) => v + x.focus) / s.length;
      eligible.sort((a, b) => average(b.value).compareTo(average(a.value)));
      if (eligible.isNotEmpty) result.add(StudyInsight('focusHour', {
        'hour': eligible.first.key, 'count': eligible.first.value.length,
        'focus': average(eligible.first.value).toStringAsFixed(1),
      }));
    }
    final week = build(data, 7, now);
    for (final entry in week.secondsBySubject.entries) {
      final attempts = recent.where((s) => s.subjectId == entry.key &&
        !s.endedAt.toLocal().isBefore(DateTime(now.year, now.month, now.day - 6)))
        .fold<int>(0, (n, s) => n + s.tests);
      if (entry.value >= 7200 && attempts < 20) {
        result.add(StudyInsight('lowTests', {'subjectId': entry.key,
          'minutes': entry.value ~/ 60, 'tests': attempts}));
      }
    }
    final pending = data.plans.where((p) => !p.done &&
      DateTime.parse(p.day).isBefore(DateTime(now.year, now.month, now.day))).length;
    if (pending > 0) result.add(StudyInsight('missedPlans', {'count': pending}));
    return result;
  }
}
