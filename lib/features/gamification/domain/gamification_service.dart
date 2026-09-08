import '../../../core/models/models.dart';
class RankedMember {
  const RankedMember(this.id, this.seconds, this.sessions, this.tests);
  final String id;
  final int seconds, sessions, tests;
}
abstract final class GamificationService {
  static int xp(Iterable<StudySession> sessions) =>
    sessions.fold<int>(0, (sum, s) => sum + s.seconds) ~/ 1800 * 10;
  static int level(int xp) => 1 + xp ~/ 100;
  static int streak(Iterable<StudySession> sessions, DateTime now,
      {Set<String> freezeDays = const {}}) {
    final days = sessions.where((s) => s.seconds >= 60)
      .map((s) => civilDay(s.endedAt)).toSet();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(civilDay(cursor)) && !freezeDays.contains(civilDay(cursor))) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var count = 0;
    while (days.contains(civilDay(cursor)) || freezeDays.contains(civilDay(cursor))) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }
  static List<RankedMember> rank(List<RankedMember> members) =>
    List<RankedMember>.of(members)..sort((a, b) {
      var c = b.seconds.compareTo(a.seconds);
      if (c == 0) c = b.tests.compareTo(a.tests);
      if (c == 0) c = b.sessions.compareTo(a.sessions);
      return c == 0 ? a.id.compareTo(b.id) : c;
    });
}
