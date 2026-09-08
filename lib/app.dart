import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/strings.dart';
import 'core/routing/app_router.dart';
import 'core/state/app_controller.dart';
import 'core/theme/app_theme.dart';
class PazelApp extends ConsumerWidget {
  const PazelApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: S.app, debugShowCheckedModeBanner: false, locale: const Locale('fa'),
    supportedLocales: const [Locale('fa')], localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate],
    theme: buildTheme(Brightness.light), darkTheme: buildTheme(Brightness.dark),
    themeMode: ref.watch(appProvider.select((s) => s.preferences.dark)) ? ThemeMode.dark : ThemeMode.light,
    themeAnimationDuration: MediaQueryData.fromView(View.of(context)).disableAnimations
      ? Duration.zero : const Duration(milliseconds: 200),
    routerConfig: ref.watch(routerProvider), builder: (context, child) => Column(children: [
      if (ref.watch(warningProvider) case final String warning) Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: SafeArea(bottom: false, child: ListTile(title: Text(warning),
          trailing: IconButton(tooltip: S.cancel, onPressed: () => ref.read(warningProvider.notifier).state = null,
            icon: const Icon(Icons.close))))),
      Expanded(child: child ?? const SizedBox.shrink()),
    ]));
}
