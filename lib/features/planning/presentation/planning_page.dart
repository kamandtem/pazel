import '../../../core/widgets/ui.dart';
import '../domain/planning_service.dart';
import 'plan_tile.dart';
class PlanningPage extends ConsumerStatefulWidget {
  const PlanningPage({super.key});
  @override
  ConsumerState<PlanningPage> createState() => _PlanningState();
}
class _PlanningState extends ConsumerState<PlanningPage> {
  DateTime day = DateTime.now();
  bool weekly = false;
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final plans = data.plansFor(day);
    return PageBody(children: [
      Text(S.planning, style: Theme.of(context).textTheme.headlineLarge), const FormGap(),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ChoiceChip(label: const Text(S.daily), selected: !weekly, onSelected: (_) => setState(() => weekly = false)),
        ChoiceChip(label: const Text(S.weekly), selected: weekly, onSelected: (_) => setState(() => weekly = true)),
        ActionChip(label: const Text(S.monthly), onPressed: () => context.push('/calendar')),
      ]), const SizedBox(height: 20),
      Row(children: [IconButton(tooltip: S.previousDay, onPressed: () => setState(() =>
        day = DateTime(day.year, day.month, day.day - 1)), icon: const Icon(Icons.chevron_right)),
        Expanded(child: Text(fmt.date(day), textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium)),
        IconButton(tooltip: S.nextDay, onPressed: () => setState(() =>
          day = DateTime(day.year, day.month, day.day + 1)), icon: const Icon(Icons.chevron_left))]),
      const FormGap(), FilledButton.icon(onPressed: () => context.push('/planning/new?day=${civilDay(day)}'),
        icon: const Icon(Icons.add), label: const Text(S.addPlan)), const SizedBox(height: 24),
      if (!weekly) ...[
        const Text(S.reorderHelp), const FormGap(),
        if (plans.isEmpty) const EmptyState(title: S.noPlans, body: S.noPlansBody),
        ReorderableListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false, itemCount: plans.length,
          onReorder: (oldIndex, newIndex) => perform(context,
            () => ref.read(appProvider.notifier).reorder(PlanningService.reorder(plans, oldIndex, newIndex))),
          itemBuilder: (context, i) => Padding(key: ValueKey(plans[i].id),
            padding: const EdgeInsets.only(bottom: 16), child: PlanTile(plan: plans[i],
              dragHandle: ReorderableDragStartListener(index: i,
                child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.drag_handle))))),
        ),
      ] else ...[
        for (var i = 0; i < 7; i++) ...[
          SectionTitle(fmt.date(DateTime(day.year, day.month, day.day + i))),
          if (data.plansFor(DateTime(day.year, day.month, day.day + i)).isEmpty) const Text(S.noPlans),
          ...data.plansFor(DateTime(day.year, day.month, day.day + i)).map((p) =>
            Padding(padding: const EdgeInsets.only(bottom: 12), child: PlanTile(plan: p))),
        ],
      ],
    ]);
  }
}
class PlanEditor extends ConsumerStatefulWidget {
  const PlanEditor({super.key, this.id, this.day});
  final String? id, day;
  @override
  ConsumerState<PlanEditor> createState() => _PlanEditorState();
}
class _PlanEditorState extends ConsumerState<PlanEditor> {
  final form = GlobalKey<FormState>();
  final topic = TextEditingController(), date = TextEditingController(), time = TextEditingController();
  final minutes = TextEditingController(), tests = TextEditingController(), note = TextEditingController();
  String? subject;
  String activity = 'study';
  int priority = 1, position = 0;
  bool done = false;
  @override
  void initState() {
    super.initState();
    final data = ref.read(appProvider);
    final matches = data.plans.where((p) => p.id == widget.id);
    final p = matches.isEmpty ? null : matches.first;
    subject = p?.subjectId ?? data.subjects.first.id;
    topic.text = p?.topic ?? '';
    date.text = const Fmt(false).dateInput(DateTime.tryParse(p?.day ?? widget.day ?? '') ?? DateTime.now());
    time.text = const Fmt(false).clock(p?.startMinute ?? 18 * 60);
    minutes.text = '${p?.minutes ?? 45}'; tests.text = '${p?.tests ?? 0}'; note.text = p?.note ?? '';
    activity = p?.activity ?? 'study'; priority = p?.priority ?? 1;
    done = p?.done ?? false; position = p?.position ?? data.plans.length;
  }
  @override
  void dispose() {
    for (final c in [topic, date, time, minutes, tests, note]) { c.dispose(); }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider);
    return Scaffold(appBar: AppBar(title: Text(widget.id == null ? S.addPlan : S.editPlan)),
      body: Form(key: form, child: PageBody(children: [
        DropdownButtonFormField<String>(value: subject, isExpanded: true,
          decoration: const InputDecoration(labelText: S.subject), items: data.subjects.map((s) =>
            DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
          onChanged: (v) => setState(() => subject = v)), const FormGap(),
        TextFormField(controller: topic, decoration: const InputDecoration(labelText: S.topic), validator: requiredText),
        const FormGap(), TextFormField(controller: date, textDirection: TextDirection.ltr,
          decoration: const InputDecoration(labelText: S.date, hintText: '1405/06/17'),
          validator: (v) => Fmt.parseDate(v ?? '') == null ? S.invalidDate : null), const FormGap(),
        TextFormField(controller: time, textDirection: TextDirection.ltr,
          decoration: const InputDecoration(labelText: S.time, hintText: '18:00'),
          validator: (v) => Fmt.parseClock(v ?? '') == null ? S.invalidDate : null), const FormGap(),
        TextFormField(controller: minutes, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.duration), validator: integerText), const FormGap(),
        TextFormField(controller: tests, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.testCount), validator: integerText), const FormGap(),
        DropdownButtonFormField<String>(value: activity, decoration: const InputDecoration(labelText: S.activity),
          items: S.activities.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: (v) => setState(() => activity = v!)), const FormGap(),
        DropdownButtonFormField<int>(value: priority, decoration: const InputDecoration(labelText: S.priority),
          items: [for (var i = 0; i < 3; i++) DropdownMenuItem(value: i, child: Text(S.priorities[i]))],
          onChanged: (v) => setState(() => priority = v!)), const FormGap(),
        TextFormField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: S.note)),
        const SizedBox(height: 24), FilledButton(onPressed: ref.watch(busyProvider) ? null : () async {
          if (!form.currentState!.validate()) return;
          final p = StudyPlan(id: widget.id ?? newId(), subjectId: subject!, topic: topic.text.trim(),
            day: civilDay(Fmt.parseDate(date.text)!), startMinute: Fmt.parseClock(time.text)!,
            minutes: int.parse(latinDigits(minutes.text)), tests: int.parse(latinDigits(tests.text)),
            priority: priority, activity: activity, note: note.text, done: done, position: position);
          final ok = await perform(context, () => ref.read(appProvider.notifier).savePlan(p));
          if (ok && context.mounted) context.go('/planning');
        }, child: const Text(S.save)),
      ])));
  }
}
