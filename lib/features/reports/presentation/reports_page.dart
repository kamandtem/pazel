import '../../../core/widgets/ui.dart';
import '../domain/report_service.dart';
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});
  @override
  ConsumerState<ReportsPage> createState() => _ReportsState();
}
class _ReportsState extends ConsumerState<ReportsPage> {
  int days = 7;
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final r = ReportService.build(data, days, DateTime.now());
    return PageBody(children: [
      Text(S.reportTitle, style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 20),
      Wrap(spacing: 8, children: [for (final d in [7, 30, 90])
        ChoiceChip(label: Text('${fmt.n(d)} ${S.day}'), selected: days == d,
          onSelected: (_) => setState(() => days = d))]), const SizedBox(height: 28),
      if (r.totalSeconds == 0) EmptyState(title: S.noData, body: S.noSessionsBody,
        action: FilledButton(onPressed: () => context.go('/study'), child: const Text(S.startStudy)))
      else ...[
        Wrap(spacing: 28, runSpacing: 24, children: [
          Metric(S.totalTime, fmt.duration(r.totalSeconds), icon: Icons.timelapse),
          Metric(S.dailyAverage, fmt.duration(r.dailyAverageSeconds.round())),
          Metric(S.tests, fmt.n(r.tests)), Metric(S.sessionCount, fmt.n(r.sessions)),
          Metric(S.adherence, '${fmt.n((r.adherence * 100).round())}٪'),
          Metric(S.reviewCount, fmt.n(r.reviewCount)),
        ]), SectionTitle(S.dailyTrend),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(S.reportNote, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 24),
          _DailyBars(report: r, fmt: fmt),
        ])),
        SectionTitle(S.subjectShare),
        ...r.secondsBySubject.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(data.subject(e.key).title)),
              Text('${fmt.duration(e.value)} · ${fmt.n((e.value / r.totalSeconds * 100).round())}٪')]),
            const SizedBox(height: 12), LinearProgressIndicator(value: e.value / r.totalSeconds,
              color: Color(data.subject(e.key).color), minHeight: 8,
              borderRadius: BorderRadius.circular(8)),
          ]))),
        if (r.bestDay != null) ListTile(contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.wb_sunny_outlined), title: const Text(S.bestDay),
          subtitle: Text(fmt.date(DateTime.parse(r.bestDay!)))),
        if (r.weakestDay != null) ListTile(contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.nights_stay_outlined), title: const Text(S.weakestDay),
          subtitle: Text(fmt.date(DateTime.parse(r.weakestDay!)))),
      ], const SizedBox(height: 24),
      if (data.sessions.any((s) => s.id.startsWith('demo-'))) const Text(S.demoData),
    ]);
  }
}
class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.report, required this.fmt});
  final StudyReport report;
  final Fmt fmt;
  @override
  Widget build(BuildContext context) {
    final max = report.secondsByDay.values.fold<int>(1, (a, b) => a > b ? a : b);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
      crossAxisAlignment: CrossAxisAlignment.end, children: report.secondsByDay.entries.map((e) =>
        Semantics(label: S.dayMetric(fmt.date(DateTime.parse(e.key)), fmt.duration(e.value)),
          excludeSemantics: true, child: Tooltip(message: S.dayMetric(fmt.date(DateTime.parse(e.key)), fmt.duration(e.value)),
            child: SizedBox(width: 44, child: Column(children: [
              SizedBox(height: 160, child: Align(alignment: Alignment.bottomCenter,
                child: Container(width: 20, height: (e.value / max * 155).clamp(3, 155).toDouble(),
                  decoration: BoxDecoration(color: e.value == 0 ? Theme.of(context).colorScheme.outlineVariant :
                    Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8))))),
              const SizedBox(height: 12), Text(fmt.shortDate(DateTime.parse(e.key)),
                style: Theme.of(context).textTheme.bodySmall),
            ]))))).toList()));
  }
}
