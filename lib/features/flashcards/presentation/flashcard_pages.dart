import '../../../core/widgets/ui.dart';
class FlashcardsPage extends ConsumerStatefulWidget {
  const FlashcardsPage({super.key});
  @override
  ConsumerState<FlashcardsPage> createState() => _FlashcardsState();
}
class _FlashcardsState extends ConsumerState<FlashcardsPage> {
  String? revealed;
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final now = ref.watch(clockProvider).valueOrNull ?? DateTime.now();
    final due = data.cards.where((c) => !c.dueAt.isAfter(now)).toList();
    final c = due.isEmpty ? null : due.first;
    return Scaffold(appBar: AppBar(title: const Text(S.flashcards), actions: [
      IconButton(tooltip: S.flashPacks, onPressed: () => context.push('/flash-packs'), icon: const Icon(Icons.storefront_outlined)),
      IconButton(tooltip: S.addCard, onPressed: () => context.push('/flashcards/new'), icon: const Icon(Icons.add)),
    ]), body: PageBody(children: [
      Text(S.dueReview, style: Theme.of(context).textTheme.headlineLarge),
      Text(S.countCards(fmt.n(due.length))), const SizedBox(height: 24),
      if (c == null) EmptyState(title: S.reviewEmpty, body: S.reviewEmptyBody,
        action: OutlinedButton(onPressed: () => context.push('/flashcards/new'), child: const Text(S.addCard)))
      else ...[
        Panel(color: Theme.of(context).colorScheme.primaryContainer, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${data.subject(c.subjectId).title} · ${S.box} ${fmt.n(c.box)}'),
            const SizedBox(height: 32), Text(c.front, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),
            if (revealed == c.id) ...[const Divider(), Text(c.back, style: Theme.of(context).textTheme.bodyLarge)]
            else OutlinedButton(onPressed: () => setState(() => revealed = c.id), child: const Text(S.showAnswer)),
          ])), const SizedBox(height: 24),
        if (revealed == c.id) Wrap(spacing: 8, runSpacing: 8, children: [
          for (final rating in ReviewRating.values) OutlinedButton(
            onPressed: ref.watch(busyProvider) ? null : () async {
              final ok = await perform(context, () => ref.read(appProvider.notifier).review(c, rating));
              if (ok && mounted) setState(() => revealed = null);
            }, child: Text(switch (rating) {ReviewRating.again => S.again,
              ReviewRating.hard => S.hard, ReviewRating.good => S.good, ReviewRating.easy => S.easy})),
        ]),
      ], SectionTitle(S.allCards),
      ...data.cards.map((card) => ListTile(contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.style_outlined), title: Text(card.front),
        subtitle: Text('${S.nextReview}: ${fmt.date(card.dueAt)}'),
        trailing: Text('${S.box} ${fmt.n(card.box)}'))),
    ]));
  }
}
class CardEditor extends ConsumerStatefulWidget {
  const CardEditor({super.key});
  @override
  ConsumerState<CardEditor> createState() => _CardEditorState();
}
class _CardEditorState extends ConsumerState<CardEditor> {
  final front = TextEditingController(), back = TextEditingController();
  final form = GlobalKey<FormState>();
  String? subject;
  @override
  void dispose() { front.dispose(); back.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appProvider);
    subject ??= data.subjects.first.id;
    return Scaffold(appBar: AppBar(title: const Text(S.addCard)), body: Form(key: form,
      child: PageBody(children: [
        DropdownButtonFormField<String>(value: subject, decoration: const InputDecoration(labelText: S.subject),
          items: data.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title))).toList(),
          onChanged: (v) => setState(() => subject = v)), const FormGap(),
        TextFormField(controller: front, maxLines: 3, decoration: const InputDecoration(labelText: S.front),
          validator: requiredText), const FormGap(),
        TextFormField(controller: back, maxLines: 5, decoration: const InputDecoration(labelText: S.back),
          validator: requiredText), const SizedBox(height: 24),
        FilledButton(onPressed: ref.watch(busyProvider) ? null : () async {
          if (!form.currentState!.validate()) return;
          final ok = await perform(context, () => ref.read(appProvider.notifier).saveCard(Flashcard(
            id: newId(), subjectId: subject!, front: front.text.trim(), back: back.text.trim(), dueAt: DateTime.now())));
          if (ok && context.mounted) context.pop();
        }, child: const Text(S.save)),
      ])));
  }
}
