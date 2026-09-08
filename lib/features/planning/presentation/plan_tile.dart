import '../../../core/widgets/ui.dart';
class PlanTile extends ConsumerWidget {
  const PlanTile({super.key, required this.plan, this.dragHandle});
  final StudyPlan plan;
  final Widget? dragHandle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final subject = data.subject(plan.subjectId);
    return Panel(padding: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 40, height: 40,
        decoration: BoxDecoration(color: Color(subject.color).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.auto_stories_outlined, color: Color(subject.color))),
        const SizedBox(width: 12), Expanded(child: Text(subject.title,
          style: Theme.of(context).textTheme.titleMedium)),
        if (dragHandle != null) dragHandle!,
        PopupMenuButton<String>(tooltip: S.editPlan, onSelected: (value) async {
          if (value == 'edit') { context.push('/planning/edit/${plan.id}'); }
          if (value == 'tomorrow') {
            await perform(context, () => ref.read(appProvider.notifier).savePlan(
              plan.copyWith(day: civilDay(DateTime.now().add(const Duration(days: 1))))));
          }
          if (value == 'delete') {
            final yes = await confirmAction(context, S.deletePlan, S.deleteBody);
            if (yes && context.mounted) await perform(context,
              () => ref.read(appProvider.notifier).deletePlan(plan.id));
          }
        }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text(S.editPlan)),
          PopupMenuItem(value: 'tomorrow', child: Text(S.moveTomorrow)),
          PopupMenuItem(value: 'delete', child: Text(S.delete))]),
      ]), const SizedBox(height: 12), Text(plan.topic, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8), Text('${fmt.clock(plan.startMinute)} تا ${fmt.clock(plan.startMinute + plan.minutes)} · ${S.minutes(fmt.n(plan.minutes))}'),
      const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 4, children: [
        Chip(label: Text(S.activities[plan.activity] ?? S.study)),
        Chip(label: Text('${S.priority}: ${S.priorities[plan.priority]}')),
        if (plan.tests > 0) Chip(label: Text('${fmt.n(plan.tests)} ${S.tests}')),
      ]), Row(children: [
        Expanded(child: CheckboxListTile(contentPadding: EdgeInsets.zero,
          value: plan.done, title: Text(plan.done ? S.done : S.pending),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: ref.watch(busyProvider) ? null : (v) => perform(context,
            () => ref.read(appProvider.notifier).savePlan(plan.copyWith(done: v))))),
        if (!plan.done) IconButton.filled(tooltip: S.startStudy,
          onPressed: ref.watch(busyProvider) ? null : () async {
            final ok = await perform(context, () => ref.read(appProvider.notifier)
              .start(subjectId: plan.subjectId, topic: plan.topic, planId: plan.id));
            if (ok && context.mounted) context.go('/study');
          }, icon: const Icon(Icons.play_arrow_rounded)),
      ]),
    ]));
  }
}
