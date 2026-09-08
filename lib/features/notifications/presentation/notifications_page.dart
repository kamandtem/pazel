import '../../../core/widgets/ui.dart';
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    return Scaffold(appBar: AppBar(title: const Text(S.notifications)), body: PageBody(children: [
      if (data.notices.isEmpty) const EmptyState(title: S.notificationsEmpty,
        body: S.notificationsEmptyBody, icon: Icons.notifications_none_rounded)
      else ...data.notices.map((n) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n.title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8),
          Text(n.body), const SizedBox(height: 12), Text(fmt.date(n.createdAt)),
          if (!n.read) TextButton(onPressed: ref.watch(busyProvider) ? null :
            () => perform(context, () => ref.read(appProvider.notifier).readNotice(n.id)), child: const Text(S.markRead))
          else const Text(S.read),
        ])))),
    ]));
  }
}
