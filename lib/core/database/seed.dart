import '../models/models.dart';
const seedSubjects = [
  Subject('math', 'ریاضی', 0xFF7152D9), Subject('physics', 'فیزیک', 0xFF367DAD),
  Subject('chemistry', 'شیمی', 0xFFBE633D), Subject('biology', 'زیست', 0xFF23846B),
  Subject('literature', 'ادبیات', 0xFFA05890), Subject('arabic', 'عربی', 0xFF80752C),
  Subject('religion', 'دینی', 0xFF427E75), Subject('english', 'زبان', 0xFF6475AC),
];
List<StudyPlan> seedPlans(DateTime now) => [
  StudyPlan(id: 'demo-plan-1', subjectId: 'biology', topic: 'ژنتیک؛ از مفهوم تا تست',
    day: civilDay(now), startMinute: 9 * 60, minutes: 60, tests: 20, position: 0),
  StudyPlan(id: 'demo-plan-2', subjectId: 'math', topic: 'تابع و نمودار',
    day: civilDay(now), startMinute: 16 * 60, minutes: 50, tests: 15, position: 1),
  StudyPlan(id: 'demo-plan-3', subjectId: 'chemistry', topic: 'مرور پیوندهای شیمیایی',
    day: civilDay(now.add(const Duration(days: 1))), startMinute: 10 * 60,
    minutes: 45, activity: 'review', position: 0),
];
List<StudySession> seedSessions(DateTime now) => [
  for (var i = 1; i <= 7; i++) StudySession(id: 'demo-session-$i',
    subjectId: i.isEven ? 'math' : 'biology', topic: i.isEven ? 'تابع' : 'ژنتیک',
    startedAt: DateTime(now.year, now.month, now.day - i, 9),
    endedAt: DateTime(now.year, now.month, now.day - i, 10, i * 3),
    seconds: 3600 + i * 180, tests: i.isEven ? 20 : 3, focus: 4),
];
List<Flashcard> seedCards(DateTime now) => [
  Flashcard(id: 'demo-card-1', subjectId: 'biology', front: 'واحد سازندهٔ پروتئین چیست؟',
    back: 'آمینواسید. آمینواسیدها با پیوند پپتیدی به هم متصل می‌شوند.', dueAt: now),
  Flashcard(id: 'demo-card-2', subjectId: 'math', front: 'دامنهٔ تابع رادیکال x چیست؟',
    back: 'اعداد حقیقی نامنفی: x بزرگ‌تر یا مساوی صفر.', dueAt: now),
  Flashcard(id: 'demo-card-3', subjectId: 'chemistry', front: 'عدد اتمی چه چیزی را نشان می‌دهد؟',
    back: 'تعداد پروتون‌های هستهٔ اتم.', dueAt: now),
];
