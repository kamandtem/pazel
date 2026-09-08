import 'package:shamsi_date/shamsi_date.dart';
import '../../../core/widgets/ui.dart';
import '../../planning/presentation/plan_tile.dart';
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarState();
}
class _CalendarState extends ConsumerState<CalendarPage> {
  late Jalali month;
  DateTime selected = DateTime.now();
  final note = TextEditingController();
  @override
  void initState() {
    super.initState();
    final today = Jalali.now();
    month = Jalali(today.year, today.month, 1);
    note.text = ref.read(appProvider).notes[civilDay(selected)] ?? '';
  }
  @override
  void dispose() { note.dispose(); super.dispose(); }
  void shift(int offset) {
    var m = month.month + offset, y = month.year;
    if (m == 0) { m = 12; y--; } else if (m == 13) { m = 1; y++; }
    setState(() => month = Jalali(y, m, 1));
  }
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final startOffset = (month.toDateTime().weekday + 1) % 7;
    final plans = data.plansFor(selected);
    final cellCount = ((startOffset + month.monthLength) / 7).ceil() * 7;
    return Scaffold(appBar: AppBar(title: const Text(S.calendar)), body: PageBody(children: [
      Row(children: [IconButton(tooltip: S.previousMonth, onPressed: () => shift(-1),
        icon: const Icon(Icons.chevron_right)), Expanded(child: Text(
          '${month.formatter.mN} ${fmt.n(month.year)}', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge)),
        IconButton(tooltip: S.nextMonth, onPressed: () => shift(1), icon: const Icon(Icons.chevron_left))]),
      const FormGap(), Row(children: S.weekdays.map((s) => Expanded(child: Text(s, textAlign: TextAlign.center))).toList()),
      const FormGap(), LayoutBuilder(builder: (context, constraints) {
        return Wrap(children: [for (var i = 0; i < cellCount; i++)
          SizedBox(width: constraints.maxWidth / 7, height: 68,
            child: i < startOffset || i >= startOffset + month.monthLength ? const SizedBox.shrink() :
              _dayCell(data, fmt, Jalali(month.year, month.month, i - startOffset + 1))),
        ]);
      }), const SizedBox(height: 24),
      Text(fmt.date(selected), style: Theme.of(context).textTheme.titleLarge), const FormGap(),
      TextField(controller: note, maxLines: 3, decoration: const InputDecoration(
        labelText: S.dayNotes, hintText: S.addNote)), const FormGap(),
      OutlinedButton(onPressed: ref.watch(busyProvider) ? null : () => perform(context,
        () => ref.read(appProvider.notifier).saveNote(civilDay(selected), note.text), announce: true),
        child: const Text(S.save)),
      SectionTitle(S.planning),
      FilledButton.icon(onPressed: () => context.push('/planning/new?day=${civilDay(selected)}'),
        icon: const Icon(Icons.add), label: const Text(S.addPlan)), const FormGap(),
      if (plans.isEmpty) const Text(S.noPlans)
      else ...plans.map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: PlanTile(plan: p))),
      SectionTitle(S.sessionHistory),
      ...data.sessions.where((s) => civilDay(s.endedAt) == civilDay(selected)).map((s) => ListTile(
        title: Text(s.topic), subtitle: Text(data.subject(s.subjectId).title), trailing: Text(fmt.duration(s.seconds)))),
    ]));
  }
  Widget _dayCell(AppData data, Fmt fmt, Jalali j) {
    final date = j.toDateTime(), key = civilDay(j.toDateTime());
    final active = key == civilDay(selected);
    final marked = data.plans.any((p) => p.day == key) || data.notes.containsKey(key) ||
      data.sessions.any((s) => civilDay(s.endedAt) == key);
    return Semantics(label: fmt.date(date), selected: active, child: Padding(
      padding: const EdgeInsets.all(2), child: Material(
        color: active ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16), child: InkWell(borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() { selected = date; note.text = data.notes[key] ?? ''; }),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(fmt.n(j.day)),
            const SizedBox(height: 4), Icon(Icons.circle, size: 5,
              color: marked ? Theme.of(context).colorScheme.primary : Colors.transparent)])))));
  }
}
