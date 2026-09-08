typedef Json = Map<String, Object?>;
DateTime readDate(Object? v) => DateTime.parse(v! as String);
String civilDay(DateTime value) {
  final d = value.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
int _counter = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

class Subject {
  const Subject(this.id, this.title, this.color);
  final String id, title;
  final int color;
  Json toJson() => {'id': id, 'title': title, 'color': color};
  factory Subject.fromJson(Json j) => Subject(j['id']! as String,
    j['title']! as String, j['color']! as int);
}
class UserProfile {
  const UserProfile({this.name = '', this.surname = '', this.phone = '',
    this.gender = '', this.grade = '', this.field = '', this.examYear = '',
    this.goal = '', this.city = '', this.school = '', this.sleep = '23:00',
    this.wake = '07:00', this.dailyGoalMinutes = 360});
  final String name, surname, phone, gender, grade, field, examYear, goal;
  final String city, school, sleep, wake;
  final int dailyGoalMinutes;
  Json toJson() => {'name': name, 'surname': surname, 'phone': phone,
    'gender': gender, 'grade': grade, 'field': field, 'examYear': examYear,
    'goal': goal, 'city': city, 'school': school, 'sleep': sleep, 'wake': wake,
    'dailyGoalMinutes': dailyGoalMinutes};
  factory UserProfile.fromJson(Json j) => UserProfile(name: j['name']! as String,
    surname: j['surname']! as String, phone: j['phone']! as String,
    gender: j['gender']! as String, grade: j['grade']! as String,
    field: j['field']! as String, examYear: j['examYear']! as String,
    goal: j['goal']! as String, city: j['city']! as String,
    school: j['school']! as String, sleep: j['sleep']! as String,
    wake: j['wake']! as String, dailyGoalMinutes: j['dailyGoalMinutes']! as int);
}
class Preferences {
  const Preferences({this.dark = false, this.persianDigits = true,
    this.notifications = false});
  final bool dark, persianDigits, notifications;
  Preferences copyWith({bool? dark, bool? persianDigits, bool? notifications}) =>
    Preferences(dark: dark ?? this.dark, persianDigits: persianDigits ?? this.persianDigits,
      notifications: notifications ?? this.notifications);
  Json toJson() => {'dark': dark, 'persianDigits': persianDigits,
    'notifications': notifications};
  factory Preferences.fromJson(Json j) => Preferences(dark: j['dark']! as bool,
    persianDigits: j['persianDigits']! as bool, notifications: j['notifications']! as bool);
}
class StudyPlan {
  const StudyPlan({required this.id, required this.subjectId, required this.topic,
    required this.day, required this.startMinute, required this.minutes,
    this.tests = 0, this.priority = 1, this.activity = 'study', this.note = '',
    this.done = false, this.position = 0});
  final String id, subjectId, topic, day, activity, note;
  final int startMinute, minutes, tests, priority, position;
  final bool done;
  StudyPlan copyWith({bool? done, int? position, String? day}) => StudyPlan(id: id,
    subjectId: subjectId, topic: topic, day: day ?? this.day, startMinute: startMinute,
    minutes: minutes, tests: tests, priority: priority, activity: activity, note: note,
    done: done ?? this.done, position: position ?? this.position);
  Json toJson() => {'id': id, 'subjectId': subjectId, 'topic': topic, 'day': day,
    'startMinute': startMinute, 'minutes': minutes, 'tests': tests, 'priority': priority,
    'activity': activity, 'note': note, 'done': done, 'position': position};
  factory StudyPlan.fromJson(Json j) => StudyPlan(id: j['id']! as String,
    subjectId: j['subjectId']! as String, topic: j['topic']! as String,
    day: j['day']! as String, startMinute: j['startMinute']! as int,
    minutes: j['minutes']! as int, tests: j['tests']! as int,
    priority: j['priority']! as int, activity: j['activity']! as String,
    note: j['note']! as String, done: j['done']! as bool, position: j['position']! as int);
}
class StudySession {
  const StudySession({required this.id, required this.subjectId, required this.topic,
    required this.startedAt, required this.endedAt, required this.seconds,
    this.tests = 0, this.quality = 3, this.focus = 3, this.mood = 2,
    this.note = '', this.planId});
  final String id, subjectId, topic, note;
  final String? planId;
  final DateTime startedAt, endedAt;
  final int seconds, tests, quality, focus, mood;
  Json toJson() => {'id': id, 'subjectId': subjectId, 'topic': topic,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endedAt': endedAt.toUtc().toIso8601String(), 'seconds': seconds,
    'tests': tests, 'quality': quality, 'focus': focus, 'mood': mood,
    'note': note, 'planId': planId};
  factory StudySession.fromJson(Json j) => StudySession(id: j['id']! as String,
    subjectId: j['subjectId']! as String, topic: j['topic']! as String,
    startedAt: readDate(j['startedAt']), endedAt: readDate(j['endedAt']),
    seconds: j['seconds']! as int, tests: j['tests']! as int,
    quality: j['quality']! as int, focus: j['focus']! as int,
    mood: j['mood']! as int, note: j['note']! as String, planId: j['planId'] as String?);
}
enum TimerMode { tracker, pomodoro }
enum TimerPhase { focus, rest }
class ActiveTimer {
  const ActiveTimer({required this.id, required this.subjectId, required this.topic,
    required this.startedAt, this.anchor, this.elapsedSeconds = 0,
    this.mode = TimerMode.tracker, this.phase = TimerPhase.focus,
    this.focusMinutes = 25, this.breakMinutes = 5, this.cycles = 0, this.planId});
  final String id, subjectId, topic;
  final String? planId;
  final DateTime startedAt;
  final DateTime? anchor;
  final int elapsedSeconds, focusMinutes, breakMinutes, cycles;
  final TimerMode mode;
  final TimerPhase phase;
  bool get running => anchor != null;
  int elapsedAt(DateTime now) {
    final d = anchor == null ? 0 : now.difference(anchor!).inSeconds;
    return elapsedSeconds + (d < 0 ? 0 : d);
  }
  int get phaseSeconds => (phase == TimerPhase.focus ? focusMinutes : breakMinutes) * 60;
  int countedAt(DateTime now) => mode == TimerMode.pomodoro
    ? elapsedAt(now).clamp(0, phaseSeconds).toInt() : elapsedAt(now);
  bool completeAt(DateTime now) => mode == TimerMode.pomodoro && elapsedAt(now) >= phaseSeconds;
  ActiveTimer pause(DateTime now) => _with(null, countedAt(now));
  ActiveTimer resume(DateTime now) => _with(now, elapsedSeconds);
  ActiveTimer _with(DateTime? anchor, int elapsed) => ActiveTimer(id: id,
    subjectId: subjectId, topic: topic, startedAt: startedAt, anchor: anchor,
    elapsedSeconds: elapsed, mode: mode, phase: phase, focusMinutes: focusMinutes,
    breakMinutes: breakMinutes, cycles: cycles, planId: planId);
  Json toJson() => {'id': id, 'subjectId': subjectId, 'topic': topic,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'anchor': anchor?.toUtc().toIso8601String(), 'elapsedSeconds': elapsedSeconds,
    'mode': mode.name, 'phase': phase.name, 'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes, 'cycles': cycles, 'planId': planId};
  factory ActiveTimer.fromJson(Json j) => ActiveTimer(id: j['id']! as String,
    subjectId: j['subjectId']! as String, topic: j['topic']! as String,
    startedAt: readDate(j['startedAt']), anchor: j['anchor'] == null ? null : readDate(j['anchor']),
    elapsedSeconds: j['elapsedSeconds']! as int,
    mode: TimerMode.values.byName(j['mode']! as String),
    phase: TimerPhase.values.byName(j['phase']! as String),
    focusMinutes: j['focusMinutes']! as int, breakMinutes: j['breakMinutes']! as int,
    cycles: j['cycles']! as int, planId: j['planId'] as String?);
}
enum ReviewRating { again, hard, good, easy }
class Flashcard {
  const Flashcard({required this.id, required this.subjectId, required this.front,
    required this.back, required this.dueAt, this.box = 0, this.intervalDays = 0,
    this.reviews = 0});
  final String id, subjectId, front, back;
  final DateTime dueAt;
  final int box, intervalDays, reviews;
  Json toJson() => {'id': id, 'subjectId': subjectId, 'front': front, 'back': back,
    'dueAt': dueAt.toUtc().toIso8601String(), 'box': box,
    'intervalDays': intervalDays, 'reviews': reviews};
  factory Flashcard.fromJson(Json j) => Flashcard(id: j['id']! as String,
    subjectId: j['subjectId']! as String, front: j['front']! as String,
    back: j['back']! as String, dueAt: readDate(j['dueAt']), box: j['box']! as int,
    intervalDays: j['intervalDays']! as int, reviews: j['reviews']! as int);
}
class AppNotice {
  const AppNotice({required this.id, required this.title, required this.body,
    required this.createdAt, this.read = false});
  final String id, title, body;
  final DateTime createdAt;
  final bool read;
  Json toJson() => {'id': id, 'title': title, 'body': body,
    'createdAt': createdAt.toUtc().toIso8601String(), 'read': read};
  factory AppNotice.fromJson(Json j) => AppNotice(id: j['id']! as String,
    title: j['title']! as String, body: j['body']! as String,
    createdAt: readDate(j['createdAt']), read: j['read']! as bool);
}
class AppData {
  AppData({this.user = const UserProfile(), this.preferences = const Preferences(),
    this.onboarded = false, this.signedIn = false, this.timer,
    List<Subject> subjects = const [], List<StudyPlan> plans = const [],
    List<StudySession> sessions = const [], List<Flashcard> cards = const [],
    List<AppNotice> notices = const [], Map<String, String> notes = const {}})
    : subjects = List.unmodifiable(subjects), plans = List.unmodifiable(plans),
      sessions = List.unmodifiable(sessions), cards = List.unmodifiable(cards),
      notices = List.unmodifiable(notices), notes = Map.unmodifiable(notes);
  final UserProfile user;
  final Preferences preferences;
  final bool onboarded, signedIn;
  final ActiveTimer? timer;
  final List<Subject> subjects;
  final List<StudyPlan> plans;
  final List<StudySession> sessions;
  final List<Flashcard> cards;
  final List<AppNotice> notices;
  final Map<String, String> notes;
  Subject subject(String id) => subjects.firstWhere((s) => s.id == id);
  List<StudyPlan> plansFor(DateTime day) =>
    plans.where((p) => p.day == civilDay(day)).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
}
