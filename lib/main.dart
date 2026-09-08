import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/environment.dart';
import 'core/database/open_database.dart';
import 'core/database/local_study_repository.dart';
import 'core/models/models.dart';
import 'core/models/failure.dart';
import 'core/state/app_controller.dart';
import 'core/localization/strings.dart';
import 'core/theme/app_theme.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}
class _BootstrapState extends State<Bootstrap> {
  late Future<(LocalStudyRepository, AppData)> boot;
  LocalStudyRepository? repository;
  @override
  void initState() { super.initState(); boot = initialize(); }
  Future<(LocalStudyRepository, AppData)> initialize() async {
    if (!Environment.isDemo) throw const AppFailure('demoOnly');
    final r = LocalStudyRepository(await openPazelDatabase());
    try {
      await r.initialize();
      await r.event('app_open');
      final data = await r.load();
      repository = r;
      return (r, data);
    } catch (_) { await r.close(); rethrow; }
  }
  @override
  void dispose() { repository?.close(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FutureBuilder<(LocalStudyRepository, AppData)>(
    future: boot, builder: (context, snapshot) {
      if (snapshot.hasData) return ProviderScope(overrides: [
        repositoryProvider.overrideWithValue(snapshot.data!.$1),
        initialDataProvider.overrideWithValue(snapshot.data!.$2),
      ], child: const PazelApp());
      return MaterialApp(debugShowCheckedModeBanner: false, locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')], localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate], theme: buildTheme(Brightness.light),
        home: Scaffold(body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.extension_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24), const Text(S.app, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            if (snapshot.hasError) ...[
              Text(snapshot.error is AppFailure ? S.error((snapshot.error! as AppFailure).code) : S.loadError),
              const SizedBox(height: 16), FilledButton(onPressed: () => setState(() => boot = initialize()),
                child: const Text(S.retry)),
            ] else ...[
              const Text(S.loading), const SizedBox(height: 24),
              for (final width in [240.0, 180.0, 210.0]) Container(width: width, height: 16,
                margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(
                  color: DesignTokens.line, borderRadius: BorderRadius.circular(8))),
            ],
          ]))))));
    });
}
