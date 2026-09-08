import '../../../core/widgets/ui.dart';
import '../../reports/domain/report_service.dart';
import '../../gamification/domain/gamification_service.dart';
import '../../planning/presentation/plan_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final report = ReportService.build(data, 1, now);
    final progress = report.totalSeconds / (data.user.dailyGoalMinutes * 60);
    final plans = data.plansFor(now), insights = ReportService.insights(data, now);
    return PageBody(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const BrandMark(size: 48), const SizedBox(width: 16), Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.greeting(data.user.name), style: Theme.of(context).textTheme.headlineLarge),
            Text(fmt.date(now)),
          ])), IconButton(tooltip: S.notifications, onPressed: () => context.push('/notifications'),
            icon: Badge(isLabelVisible: data.notices.any((n) => !n.read),
              child: const Icon(Icons.notifications_none_rounded))),
      ]), const SizedBox(height: 28),
      Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(32)),
        child: LayoutBuilder(builder: (context, constraints) {
          final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.startFocus, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12), const Text(S.focusDescription), const SizedBox(height: 20),
            FilledButton.icon(onPressed: () => context.go('/study'), icon: const Icon(Icons.play_arrow_rounded),
              label: Text(data.timer == null ? S.startStudy : S.continueStudy)),
          ]);
          final ring = ProgressOrbit(progress: progress, label: '${fmt.n((progress * 100).floor())}٪');
          return constraints.maxWidth > 560 ? Row(children: [Expanded(child: text),
            const SizedBox(width: 32), ring]) : Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [text, const SizedBox(height: 32), Center(child: ring)]);
        })), const SizedBox(height: 24),
      Wrap(spacing: 24, runSpacing: 24, children: [
        Metric(S.studied, fmt.duration(report.totalSeconds), icon: Icons.schedule_outlined),
        Metric(S.dailyGoal, fmt.duration(data.user.dailyGoalMinutes * 60)),
        Metric(S.streak, fmt.n(GamificationService.streak(data.sessions, now)), icon: Icons.local_fire_department_outlined),
        Metric(S.tests, fmt.n(report.tests)),
      ]),
      SectionTitle(S.todayPlan, action: TextButton(onPressed: () => context.go('/planning'),
        child: const Text(S.viewAll))),
      if (plans.isEmpty) EmptyState(title: S.noPlans, body: S.noPlansBody,
        action: FilledButton(onPressed: () => context.push('/planning/new'), child: const Text(S.addPlan)))
      else ...plans.take(3).map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: PlanTile(plan: p))),
      SectionTitle(S.quickAccess), Wrap(spacing: 12, runSpacing: 12, children: [
        ActionChip(avatar: const Icon(Icons.style_outlined), label: const Text(S.flashcards), onPressed: () => context.push('/flashcards')),
        ActionChip(avatar: const Icon(Icons.calendar_month_outlined), label: const Text(S.calendar), onPressed: () => context.push('/calendar')),
        ActionChip(avatar: const Icon(Icons.calculate_outlined), label: const Text(S.tools), onPressed: () => context.push('/tools')),
        ActionChip(avatar: const Icon(Icons.route_outlined), label: const Text(S.roadmap), onPressed: () => context.push('/roadmap')),
      ]),
      SectionTitle(S.insights),
      if (insights.isEmpty) const Text(S.notEnoughData)
      else ...insights.take(3).map((i) => Padding(padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome_outlined, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12), Expanded(child: Text(insightText(i, data, fmt))),
        ]))),
      SectionTitle(S.recentActivity),
      if (data.sessions.isEmpty) const Text(S.noSessions)
      else ...data.sessions.take(3).map((s) => ListTile(contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.check_circle_outline), title: Text('${data.subject(s.subjectId).title} · ${s.topic}'),
        subtitle: Text(fmt.date(s.endedAt)), trailing: Text(fmt.duration(s.seconds)))),
      const SizedBox(height: 24), if (data.sessions.any((s) => s.id.startsWith('demo-')))
        Text(S.demoData, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
String insightText(StudyInsight i, AppData data, Fmt fmt) => switch (i.code) {
  'focusHour' => S.focusInsight(fmt.n(i.evidence['hour']!), fmt.n(i.evidence['count']!), fmt.n(i.evidence['focus']!)),
  'lowTests' => S.lowTestsInsight(data.subject(i.evidence['subjectId']! as String).title,
    fmt.n(i.evidence['minutes']!), fmt.n(i.evidence['tests']!)),
  'missedPlans' => S.missedInsight(fmt.n(i.evidence['count']!)),
  _ => S.notEnoughData,
};
