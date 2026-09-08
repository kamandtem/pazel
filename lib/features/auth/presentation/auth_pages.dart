import '../../../core/widgets/ui.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});
  @override
  ConsumerState<WelcomePage> createState() => _WelcomeState();
}
class _WelcomeState extends ConsumerState<WelcomePage> {
  int step = 0;
  @override
  Widget build(BuildContext context) {
    const titles = [S.onboarding1, S.onboarding2, S.onboarding3];
    const bodies = [S.onboardingBody1, S.onboardingBody2, S.onboardingBody3];
    const icons = [Icons.calendar_month_outlined, Icons.timelapse_rounded, Icons.insights_outlined];
    Future<void> done() async {
      if (await perform(context, ref.read(appProvider.notifier).onboard) && context.mounted) {
        context.go('/login');
      }
    }
    return Scaffold(body: SafeArea(child: PageBody(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const BrandMark(size: 48), TextButton(onPressed: done, child: const Text(S.skip))]),
      const SizedBox(height: 48), Text(S.welcomeTitle, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12), const Text(S.welcomeBody), const SizedBox(height: 40),
      Panel(color: Theme.of(context).colorScheme.primaryContainer, child: Column(children: [
        Icon(icons[step], size: 112, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 32), Text(titles[step], style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center), const SizedBox(height: 16),
        Text(bodies[step], textAlign: TextAlign.center),
      ])), const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (var i = 0; i < 3; i++)
        Container(width: i == step ? 28 : 8, height: 8, margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
            color: i == step ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant))]),
      const SizedBox(height: 32), FilledButton(onPressed: ref.watch(busyProvider) ? null :
        () { if (step < 2) { setState(() => step++); } else { done(); } },
        child: Text(step == 2 ? S.letsGo : S.next)),
      const SizedBox(height: 16), const Text(S.demo, textAlign: TextAlign.center),
    ])));
  }
}
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginState();
}
class _LoginState extends ConsumerState<LoginPage> {
  final phone = TextEditingController();
  final form = GlobalKey<FormState>();
  bool sending = false;
  @override
  void dispose() { phone.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.login)),
    body: PageBody(children: [const SizedBox(height: 32), const Center(child: BrandMark()),
      const SizedBox(height: 32), Text(S.tagline, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 24), const Text(S.mockAuth), const SizedBox(height: 24),
      Form(key: form, child: TextFormField(controller: phone, keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: S.phone,
          hintText: S.phoneHint), validator: (v) => RegExp(r'^09[0-9]{9}$').hasMatch(
            latinDigits(v ?? '')) ? null : S.invalidPhone)), const SizedBox(height: 24),
      FilledButton(onPressed: sending ? null : () async {
        if (!form.currentState!.validate()) return;
        setState(() => sending = true);
        final normalized = latinDigits(phone.text);
        final ok = await perform(context, () => ref.read(authProvider).requestCode(normalized));
        if (!context.mounted) return;
        setState(() => sending = false);
        if (ok) context.go('/verify?phone=$normalized');
      }, child: const Text(S.sendCode)), const SizedBox(height: 24), const Text(S.privacyBody),
    ]));
}
class VerifyPage extends ConsumerStatefulWidget {
  const VerifyPage({super.key, required this.phone});
  final String phone;
  @override
  ConsumerState<VerifyPage> createState() => _VerifyState();
}
class _VerifyState extends ConsumerState<VerifyPage> {
  final code = TextEditingController();
  @override
  void dispose() { code.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.verify)),
    body: PageBody(children: [const Text(S.mockAuth), const FormGap(), const Text(S.codeHelp),
      const FormGap(), TextField(controller: code, keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr, maxLength: 6,
        decoration: const InputDecoration(labelText: S.code)), const FormGap(),
      FilledButton(onPressed: ref.watch(busyProvider) ? null : () async {
        final ok = await perform(context, () => ref.read(appProvider.notifier)
          .signIn(widget.phone, latinDigits(code.text)));
        if (ok && context.mounted) context.go('/profile/edit');
      }, child: const Text(S.verify)), const FormGap(),
      OutlinedButton(onPressed: () => perform(context,
        () => ref.read(authProvider).requestCode(widget.phone), announce: true), child: const Text(S.resend)),
      TextButton(onPressed: () => context.go('/login'), child: const Text(S.changePhone)),
    ]));
}
