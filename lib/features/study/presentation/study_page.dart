import '../../../core/widgets/ui.dart';
class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});
  @override
  ConsumerState<StudyPage> createState() => _StudyState();
}
class _StudyState extends ConsumerState<StudyPage> {
  String? subject;
  TimerMode mode = TimerMode.tracker;
  final topic = TextEditingController();
  final focus = TextEditingController(text: '25'), rest = TextEditingController(text: '5');
  final form = GlobalKey<FormState>();
  @override
  void dispose() { topic.dispose(); focus.dispose(); rest.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final t = data.timer;
    subject ??= data.subjects.first.id;
    return PageBody(children: [
      Text(S.study, style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 24),
      if (t == null) Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 12, children: [
          ChoiceChip(label: const Text(S.timer), selected: mode == TimerMode.tracker,
            onSelected: (_) => setState(() => mode = TimerMode.tracker)),
          ChoiceChip(label: const Text(S.pomodoro), selected: mode == TimerMode.pomodoro,
            onSelected: (_) => setState(() => mode = TimerMode.pomodoro)),
        ]), const SizedBox(height: 24),
        DropdownButtonFormField<String>(value: subject, decoration: const InputDecoration(labelText: S.subject),
          items: data.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
          onChanged: (v) => setState(() => subject = v)), const FormGap(),
        TextFormField(controller: topic, decoration: const InputDecoration(labelText: S.topic), validator: requiredText),
        if (mode == TimerMode.pomodoro) ...[
          const FormGap(), Wrap(spacing: 8, runSpacing: 8, children: [for (final preset in [(25, 5), (50, 10), (90, 20)])
            ActionChip(label: Text(fmt.n('${preset.$1}/${preset.$2}')), onPressed: () => setState(() {
              focus.text = '${preset.$1}'; rest.text = '${preset.$2}';
            }))]), const FormGap(),
          TextFormField(controller: focus, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: S.focusMinutes), validator: integerText), const FormGap(),
          TextFormField(controller: rest, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: S.breakMinutes), validator: integerText),
        ], const SizedBox(height: 28),
        FilledButton.icon(onPressed: ref.watch(busyProvider) ? null : () async {
          if (!form.currentState!.validate()) return;
          await perform(context, () => ref.read(appProvider.notifier).start(subjectId: subject!,
            topic: topic.text.trim(), mode: mode, focusMinutes: int.parse(latinDigits(focus.text)),
            breakMinutes: int.parse(latinDigits(rest.text))));
        }, icon: const Icon(Icons.play_arrow_rounded), label: const Text(S.startStudy)),
        const SizedBox(height: 20), const Text(S.timerRecovery),
      ])) else ...[
        Panel(color: Theme.of(context).colorScheme.primaryContainer, child: Column(children: [
          Chip(avatar: Icon(t.phase == TimerPhase.focus ? Icons.spa_outlined : Icons.coffee_outlined),
            label: Text(t.phase == TimerPhase.rest ? S.resting : t.running ? S.running : S.paused)),
          const SizedBox(height: 20), Text(data.subject(t.subjectId).title,
            style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(t.topic),
          const SizedBox(height: 32), Semantics(label: S.duration,
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(
              fmt.timer(t.mode == TimerMode.pomodoro ? t.phaseSeconds - t.countedAt(now) : t.countedAt(now)),
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 56, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 28),
          if (t.mode == TimerMode.pomodoro) LinearProgressIndicator(
            value: (t.countedAt(now) / t.phaseSeconds).clamp(0, 1).toDouble(), minHeight: 6),
          const SizedBox(height: 24),
          Text(t.completeAt(now) ? S.phaseComplete : S.timerRecovery, textAlign: TextAlign.center),
          if (t.mode == TimerMode.pomodoro) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text('${fmt.n(t.cycles)} ${S.cycles}')),
        ])), const SizedBox(height: 24),
        if (!t.completeAt(now)) FilledButton.icon(onPressed: ref.watch(busyProvider) ? null :
          () => perform(context, ref.read(appProvider.notifier).toggleTimer),
          icon: Icon(t.running ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(t.running ? S.pause : S.resume)),
        const FormGap(),
        if (t.phase == TimerPhase.focus) OutlinedButton.icon(onPressed:
          ref.watch(busyProvider) || t.countedAt(now) < 1 ? null : () async {
            final ok = await perform(context, ref.read(appProvider.notifier).pauseForFinish);
            if (ok && context.mounted) context.push('/study/finish');
          }, icon: const Icon(Icons.check_rounded), label: const Text(S.finish))
        else ...[
          const Text(S.restNotCounted), const FormGap(),
          OutlinedButton(onPressed: ref.watch(busyProvider) ? null :
            () => perform(context, ref.read(appProvider.notifier).nextFocus), child: const Text(S.nextFocus)),
        ],
        TextButton(onPressed: ref.watch(busyProvider) ? null : () async {
          final yes = await confirmAction(context, S.discardTitle, S.discardBody);
          if (yes && context.mounted) await perform(context, ref.read(appProvider.notifier).discardTimer);
        }, child: const Text(S.discard)),
      ],
      SectionTitle(S.sessionHistory),
      if (data.sessions.isEmpty) const EmptyState(title: S.noSessions, body: S.noSessionsBody)
      else ...data.sessions.take(30).map((s) => ListTile(contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.check_circle_outline), title: Text(s.topic),
        subtitle: Text('${data.subject(s.subjectId).title} · ${fmt.date(s.endedAt)}'),
        trailing: Text(fmt.duration(s.seconds)))),
    ]);
  }
}
class FinishPage extends ConsumerStatefulWidget {
  const FinishPage({super.key});
  @override
  ConsumerState<FinishPage> createState() => _FinishState();
}
class _FinishState extends ConsumerState<FinishPage> {
  final tests = TextEditingController(text: '0'), note = TextEditingController();
  final form = GlobalKey<FormState>();
  int quality = 3, focus = 3, mood = 2;
  @override
  void dispose() { tests.dispose(); note.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appProvider).timer, fmt = formatFor(ref);
    Future<void> finish(bool rest) async {
      if (!form.currentState!.validate()) return;
      final ok = await perform(context, () => ref.read(appProvider.notifier).finish(
        tests: int.parse(latinDigits(tests.text)), quality: quality, focus: focus,
        mood: mood, note: note.text, rest: rest));
      if (ok && context.mounted) context.go(rest ? '/study' : '/reports');
    }
    return Scaffold(appBar: AppBar(title: const Text(S.finishTitle)), body:
      t == null || t.phase != TimerPhase.focus ? const PageBody(children: [Text(S.nothingToFinish)]) :
      Form(key: form, child: PageBody(children: [
        Text(t.topic, style: Theme.of(context).textTheme.headlineLarge),
        Text(fmt.duration(t.countedAt(DateTime.now()))), const SizedBox(height: 24),
        TextFormField(controller: tests, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.testCount), validator: (v) {
            final n = int.tryParse(latinDigits(v ?? ''));
            return n == null || n < 0 ? S.invalidNumber : null;
          }), const SizedBox(height: 24),
        Text('${S.quality}: ${fmt.n(quality)}'), Slider(min: 1, max: 5, divisions: 4,
          label: fmt.n(quality), value: quality.toDouble(), onChanged: (v) => setState(() => quality = v.round())),
        Text('${S.concentration}: ${fmt.n(focus)}'), Slider(min: 1, max: 5, divisions: 4,
          label: fmt.n(focus), value: focus.toDouble(), onChanged: (v) => setState(() => focus = v.round())),
        const Text(S.mood), const FormGap(), Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < 5; i++)
          ChoiceChip(label: Text(S.moods[i], style: const TextStyle(fontSize: 24)), selected: mood == i,
            onSelected: (_) => setState(() => mood = i))]), const SizedBox(height: 24),
        TextFormField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: S.note)),
        const SizedBox(height: 24), FilledButton(onPressed: ref.watch(busyProvider) ? null : () => finish(false),
          child: const Text(S.saveSession)),
        if (t.mode == TimerMode.pomodoro) ...[const FormGap(),
          OutlinedButton(onPressed: ref.watch(busyProvider) ? null : () => finish(true), child: const Text(S.saveAndRest))],
      ])));
  }
}
