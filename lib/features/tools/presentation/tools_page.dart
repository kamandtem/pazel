import '../../../core/widgets/ui.dart';
import '../domain/tools_service.dart';
class ToolsPage extends ConsumerStatefulWidget {
  const ToolsPage({super.key});
  @override
  ConsumerState<ToolsPage> createState() => _ToolsState();
}
class _ToolsState extends ConsumerState<ToolsPage> {
  final correct = TextEditingController(text: '20'), wrong = TextEditingController(text: '5');
  final unanswered = TextEditingController(text: '5'), wake = TextEditingController(text: '07:00');
  bool negative = true;
  double? percentage;
  List<DateTime> bedtimes = [];
  @override
  void dispose() { for (final c in [correct, wrong, unanswered, wake]) { c.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final fmt = formatFor(ref);
    return Scaffold(appBar: AppBar(title: const Text(S.tools)), body: PageBody(children: [
      Wrap(spacing: 12, runSpacing: 12, children: [
        ActionChip(avatar: const Icon(Icons.groups_outlined), label: const Text(S.roomMembers), onPressed: () => context.push('/room')),
        ActionChip(avatar: const Icon(Icons.leaderboard_outlined), label: const Text(S.leaderboard), onPressed: () => context.push('/leaderboard')),
        ActionChip(avatar: const Icon(Icons.percent_rounded), label: const Text(S.percentCalculator), onPressed: () => context.push('/percent')),
        ActionChip(avatar: const Icon(Icons.school_outlined), label: const Text(S.gradeAverage), onPressed: () => context.push('/grade-average')),
        ActionChip(avatar: const Icon(Icons.bedtime_outlined), label: const Text(S.sleepSettings), onPressed: () => context.push('/sleep-design')),
        ActionChip(avatar: const Icon(Icons.style_outlined), label: const Text(S.flashcards),
          onPressed: () => context.push('/flashcards')),
        ActionChip(avatar: const Icon(Icons.timer_outlined), label: const Text(S.timer),
          onPressed: () => context.go('/study')),
      ]), SectionTitle(S.examCalculator),
      Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final f in [(correct, S.correct), (wrong, S.wrong), (unanswered, S.unanswered)]) ...[
          TextField(controller: f.$1, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: f.$2)), const FormGap(),
        ], SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text(S.negativeMarking),
          value: negative, onChanged: (v) => setState(() { negative = v; percentage = null; })),
        FilledButton(onPressed: () => perform(context, () async {
          final result = ToolsService.examPercentage(correct: int.parse(latinDigits(correct.text)),
            wrong: int.parse(latinDigits(wrong.text)), unanswered: int.parse(latinDigits(unanswered.text)),
            negativeMarking: negative);
          setState(() => percentage = result);
        }), child: const Text(S.calculate)),
        if (percentage != null) Padding(padding: const EdgeInsets.only(top: 24),
          child: Text('${fmt.n(percentage!.toStringAsFixed(2))}٪', style: Theme.of(context).textTheme.headlineLarge)),
        const SizedBox(height: 16), const Text(S.examWarning),
      ])), SectionTitle(S.sleepCalculator),
      TextField(controller: wake, textDirection: TextDirection.ltr,
        decoration: const InputDecoration(labelText: S.wakeTime)), const FormGap(),
      OutlinedButton(onPressed: () async {
        final minute = Fmt.parseClock(wake.text);
        if (minute == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.invalidDate))); return; }
        final now = DateTime.now();
        var nextWake = DateTime(now.year, now.month, now.day, minute ~/ 60, minute % 60);
        if (!nextWake.isAfter(now)) nextWake = DateTime(now.year, now.month, now.day + 1, minute ~/ 60, minute % 60);
        setState(() => bedtimes = ToolsService.bedtimeOptions(nextWake));
      }, child: const Text(S.calculate)), const FormGap(),
      ...bedtimes.map((d) => ListTile(leading: const Icon(Icons.bedtime_outlined),
        title: Text('${S.bedtime}: ${fmt.clock(d.hour * 60 + d.minute)}'), subtitle: Text(fmt.date(d)))),
      const Text(S.fallAsleep), const FormGap(), const Text(S.sleepWarning),
    ]));
  }
}
