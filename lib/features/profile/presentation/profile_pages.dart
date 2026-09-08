import '../../../core/widgets/ui.dart';
import '../../gamification/domain/gamification_service.dart';
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appProvider), fmt = formatFor(ref);
    final xp = GamificationService.xp(data.sessions);
    final p = data.preferences;
    return PageBody(children: [
      Center(child: Column(children: [const BrandMark(size: 88), const SizedBox(height: 16),
        Text('${data.user.name} ${data.user.surname}', style: Theme.of(context).textTheme.headlineLarge),
        Text('${data.user.grade} · ${data.user.field}'), const SizedBox(height: 16),
        OutlinedButton(onPressed: () => context.push('/profile/edit'), child: const Text(S.editProfile))])),
      const SizedBox(height: 24), Wrap(spacing: 24, runSpacing: 16, children: [
        Metric(S.xp, fmt.n(xp)), Metric(S.level, fmt.n(GamificationService.level(xp))),
        Metric(S.streak, fmt.n(GamificationService.streak(data.sessions, DateTime.now()))),
      ]), SectionTitle(S.settings),
      SwitchListTile(title: const Text(S.darkMode), value: p.dark,
        onChanged: ref.watch(busyProvider) ? null : (v) => perform(context,
          () => ref.read(appProvider.notifier).preferences(p.copyWith(dark: v)))),
      SwitchListTile(title: const Text(S.persianDigits), value: p.persianDigits,
        onChanged: ref.watch(busyProvider) ? null : (v) => perform(context,
          () => ref.read(appProvider.notifier).preferences(p.copyWith(persianDigits: v)))),
      SwitchListTile(title: const Text(S.localNotifications), subtitle: const Text(S.permissionHelp),
        value: p.notifications, onChanged: ref.watch(busyProvider) ? null : (v) => perform(context,
          () => ref.read(appProvider.notifier).preferences(p.copyWith(notifications: v)))),
      ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text(S.notifications),
        trailing: const Icon(Icons.chevron_left), onTap: () => context.push('/notifications')),
      ListTile(leading: const Icon(Icons.route_outlined), title: const Text(S.roadmap),
        trailing: const Icon(Icons.chevron_left), onTap: () => context.push('/roadmap')),
      SectionTitle(S.privacy), const Text(S.privacyBody), const SizedBox(height: 24),
      const Text(S.logoutHelp), const FormGap(), OutlinedButton(onPressed: ref.watch(busyProvider) ? null :
        () async { if (await perform(context, ref.read(appProvider.notifier).logout) && context.mounted) {
          context.go('/login');
        } }, child: const Text(S.logout)), const SizedBox(height: 24),
      const Text(S.demo), if (data.sessions.any((s) => s.id.startsWith('demo-'))) const Text(S.demoData),
    ]);
  }
}
class ProfileEditor extends ConsumerStatefulWidget {
  const ProfileEditor({super.key});
  @override
  ConsumerState<ProfileEditor> createState() => _ProfileEditorState();
}
class _ProfileEditorState extends ConsumerState<ProfileEditor> {
  final form = GlobalKey<FormState>();
  late Map<String, TextEditingController> fields;
  String gender = '';
  static const labels = {'name': S.name, 'surname': S.surname, 'grade': S.grade,
    'field': S.field, 'examYear': S.examYear, 'goal': S.goal, 'city': S.city,
    'school': S.school, 'sleep': S.sleepTime, 'wake': S.wakeTime, 'dailyGoalMinutes': S.goalMinutes};
  @override
  void initState() {
    super.initState();
    final u = ref.read(appProvider).user;
    fields = {for (final k in labels.keys) k: TextEditingController(text: '${u.toJson()[k]}')};
    gender = u.gender;
  }
  @override
  void dispose() { for (final c in fields.values) { c.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.personalInfo)),
    body: Form(key: form, child: PageBody(children: [
      for (final e in fields.entries) ...[
        TextFormField(controller: e.value, decoration: InputDecoration(labelText: labels[e.key]),
          keyboardType: ['dailyGoalMinutes', 'examYear'].contains(e.key) ? TextInputType.number : TextInputType.text,
          validator: (v) {
            if (e.key == 'name') return requiredText(v);
            if (e.key == 'dailyGoalMinutes') return integerText(v);
            if (['sleep', 'wake'].contains(e.key) && Fmt.parseClock(v ?? '') == null) return S.invalidDate;
            return null;
          }), const FormGap(),
      ], DropdownButtonFormField<String>(value: gender,
        decoration: const InputDecoration(labelText: S.gender), items: const [
          DropdownMenuItem(value: '', child: Text(S.notSpecified)),
          DropdownMenuItem(value: 'female', child: Text(S.female)),
          DropdownMenuItem(value: 'male', child: Text(S.male)),
        ], onChanged: (v) => setState(() => gender = v!)), const SizedBox(height: 24),
      FilledButton(onPressed: ref.watch(busyProvider) ? null : () async {
        if (!form.currentState!.validate()) return;
        final json = <String, Object?>{...ref.read(appProvider).user.toJson(),
          for (final e in fields.entries) e.key: e.value.text.trim(),
          'gender': gender, 'dailyGoalMinutes': int.parse(latinDigits(fields['dailyGoalMinutes']!.text))};
        final ok = await perform(context, () => ref.read(appProvider.notifier).saveProfile(UserProfile.fromJson(json)));
        if (ok && context.mounted) context.go('/home');
      }, child: const Text(S.saveProfile)),
    ])));
}
