import '../../../core/widgets/ui.dart';
class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.roadmap)),
    body: PageBody(children: [Text(S.roadmapTitle, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 20), const Text(S.roadmapBody), const SectionTitle('P2'),
      const Text(S.laterP2), const SectionTitle('P3'), const Text(S.laterP3),
      const SizedBox(height: 24), const Text(S.serverRequired), const SectionTitle(S.privacy), const Text(S.privacyBody)]));
}
