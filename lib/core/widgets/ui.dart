import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import '../models/failure.dart';
import '../localization/strings.dart';
import '../localization/formatters.dart';
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:go_router/go_router.dart';
export '../state/app_controller.dart';
export '../models/models.dart';
export '../localization/strings.dart';
export '../localization/formatters.dart';
export '../theme/app_theme.dart';

Fmt formatFor(WidgetRef ref) => Fmt(ref.watch(appProvider).preferences.persianDigits);
Future<bool> perform(BuildContext context, Future<void> Function() action,
    {bool announce = false}) async {
  try {
    await action();
    if (announce && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.saved)));
    }
    return true;
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e is AppFailure ? S.error(e.code) : S.genericError)));
    return false;
  }
}
Future<bool> confirmAction(BuildContext context, String title, String body) async =>
  await showDialog<bool>(context: context, builder: (c) => AlertDialog(
    title: Text(title), content: Text(body), actions: [
      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text(S.cancel)),
      FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text(S.delete)),
    ])) ?? false;
String? requiredText(String? value) => value == null || value.trim().isEmpty ? S.required : null;
String? integerText(String? value) => int.tryParse(latinDigits(value ?? '')) == null ? S.invalidNumber : null;

/// Scrollable page body.
///
/// Uses `SingleChildScrollView` + `Column` instead of a lazy `ListView` on
/// purpose: page bodies hold a small, fixed number of children, and lazy
/// building meant widgets below the fold (for example the primary call to
/// action on the onboarding page) were never built at all. That broke both
/// widget tests and accessibility tooling on short viewports.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding = 24});
  final List<Widget> children;
  final double padding;
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.topCenter,
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1080),
      child: SingleChildScrollView(padding: EdgeInsets.all(padding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children))));
}
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color, this.padding = 24});
  final Widget child;
  final Color? color;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(color: color ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)), child: child);
}
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(top: 28, bottom: 16),
    child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20, children: [Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null) action!]));
}
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, this.action,
    this.icon = Icons.auto_stories_outlined});
  final String title, body;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(children: [Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 20), Text(title, style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center), const SizedBox(height: 8), Text(body, textAlign: TextAlign.center),
      if (action != null) ...[const SizedBox(height: 20), action!]]));
}
class Metric extends StatelessWidget {
  const Metric(this.label, this.value, {super.key, this.icon});
  final String label, value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(width: 145, child: Semantics(
    label: '$label: $value', excludeSemantics: true, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8), Text(value, style: Theme.of(context).textTheme.headlineLarge),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ])));
}
class ProgressOrbit extends StatelessWidget {
  const ProgressOrbit({super.key, required this.progress, required this.label, this.size = 144});
  final double progress, size;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(label: label, child: SizedBox(
    width: size, height: size, child: Stack(alignment: Alignment.center, children: [
      SizedBox(width: size, height: size, child: CircularProgressIndicator(
        value: progress.clamp(0, 1).toDouble(), strokeWidth: 10,
        strokeCap: StrokeCap.round, backgroundColor: Theme.of(context).colorScheme.primaryContainer)),
      Text(label, style: Theme.of(context).textTheme.headlineLarge),
    ])));
}
class FormGap extends StatelessWidget {
  const FormGap({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(size / 3)),
    child: Icon(Icons.extension_rounded, size: size * .55,
      color: Theme.of(context).colorScheme.onPrimary));
}
