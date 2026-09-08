import '../../../core/widgets/ui.dart';
import '../../tools/domain/tools_service.dart';

class StudyRoomPage extends StatelessWidget {
  const StudyRoomPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🌊 اتاق موج... | ۱۴۰۶')),
    body: PageBody(children: [
      const Panel(child: Text(S.roomMotto)),
      const SectionTitle(S.roomDetailsTab),
      SizedBox(height: 360, child: Stack(alignment: Alignment.center, children: [
        for (final size in [300.0, 235.0, 170.0]) Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0xFFBDEFD7)))),
        Column(mainAxisSize: MainAxisSize.min, children: [Text('۷', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: DesignTokens.mint)), const Text(S.peopleStudying)]),
        const Positioned(top: 38, right: 42, child: CircleAvatar(backgroundColor: DesignTokens.violet, child: Text('A', style: TextStyle(color: Colors.white)))),
        const Positioned(bottom: 44, left: 36, child: CircleAvatar(backgroundColor: Color(0xFF4DBFD0), child: Text('🌊'))),
        const Positioned(top: 120, left: 20, child: CircleAvatar(backgroundColor: DesignTokens.apricot, child: Text('🔥'))),
      ])),
      const SectionTitle(S.roomMembers),
      for (final name in ['@Wave_Room', '@Ariana', '@MojStudy']) ListTile(
        contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name), subtitle: const Text('در حال مطالعه'), trailing: const Chip(label: Text('● آنلاین'))),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.group_add_outlined), label: const Text(S.roomJoin)),
    ]));
}

class FlashPackStorePage extends StatelessWidget {
  const FlashPackStorePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(S.flashPacks)), body: PageBody(children: [
      Row(children: [
        Expanded(child: Panel(color: const Color(0xFFEDE9FF), child: Column(children: [const Icon(Icons.layers_outlined), const Text(S.leitnerBox), const Text('۱ کارت')]))),
        const SizedBox(width: 10), Expanded(child: Panel(color: const Color(0xFFFFEEE8), child: Column(children: [const Icon(Icons.description_outlined), const Text(S.myPacks), const Text(S.noPack)]))),
        const SizedBox(width: 10), Expanded(child: Panel(color: const Color(0xFFEAF3FF), child: Column(children: [const Icon(Icons.bookmark_border), const Text(S.archivedCards), const Text(S.noPack)]))),
      ]),
      const SectionTitle(S.gradeFilter), Wrap(spacing: 8, children: [
        ChoiceChip(label: Text(S.allSubjects), selected: true, onSelected: (_) {}), ChoiceChip(label: Text('فارسی'), selected: false, onSelected: (_) {}), ChoiceChip(label: Text('عربی'), selected: false, onSelected: (_) {}), ChoiceChip(label: Text('دینی'), selected: false, onSelected: (_) {}),
      ]), const SizedBox(height: 16), const TextField(decoration: InputDecoration(labelText: S.browsePacks, prefixIcon: Icon(Icons.search))), const SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82, children: [
        _Pack(title: 'کتاب‌های فارسی دوازدهم', subject: 'فارسی'), _Pack(title: 'لغات عربی دهم', subject: 'عربی'), _Pack(title: 'آیات و روایات دینی یازدهم', subject: 'دینی'), _Pack(title: 'لغات انگلیسی یازدهم', subject: 'انگلیسی'),
      ]),
    ]));
}
class _Pack extends StatelessWidget {
  const _Pack({required this.title, required this.subject}); final String title, subject;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1F2D46), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Align(alignment: Alignment.topLeft, child: Icon(Icons.chevron_left, color: Colors.white)), const Spacer(), Text(subject, style: const TextStyle(color: Color(0xFFFFCE92))), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white)), const Spacer(), const Text('۶۵,۰۰۰ تومان', style: TextStyle(color: Color(0xFFA7C4F3)))]));
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.leaderboard)), body: PageBody(children: [
    SegmentedButton<String>(segments: [ButtonSegment(value: 'users', label: Text(S.topUsers)), ButtonSegment(value: 'rooms', label: Text(S.topRooms))], selected: {'users'}),
    const SizedBox(height: 16), Wrap(spacing: 8, children: [ChoiceChip(label: Text(S.todayLabel), selected: false, onSelected: null), ChoiceChip(label: Text(S.thisWeek), selected: true, onSelected: null), ChoiceChip(label: Text(S.lastWeek), selected: false, onSelected: null), ChoiceChip(label: Text(S.thisMonth), selected: false, onSelected: null)]),
    const SizedBox(height: 18), Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF2D3042), borderRadius: BorderRadius.circular(28)), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _Podium(rank: '۳', name: 'علی'), _Podium(rank: '۱', name: 'مینا'), _Podium(rank: '۲', name: 'سارا') ])),
    const SizedBox(height: 18), for (final entry in const [ ['Kiana_2010', '۲۶:۱۲:۰۹'], ['Arash_O', '۲۵:۳۰:۱۵'], ['Hediyeh_Slj', '۲۵:۰۵:۱۴'] ]) Panel(padding: 14, child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Text('@${entry[0]}')), Chip(label: Text(entry[1]))])),
  ]));
}
class _Podium extends StatelessWidget { const _Podium({required this.rank, required this.name}); final String rank, name; @override Widget build(BuildContext context) => Column(children: [Text(rank, style: const TextStyle(color: Color(0xFFFFCE92), fontSize: 24)), const CircleAvatar(radius: 28, backgroundColor: Color(0xFFE4AE42), child: Icon(Icons.person, color: Colors.white)), Text(name, style: const TextStyle(color: Colors.white))]); }

class GradeAveragePage extends StatefulWidget { const GradeAveragePage({super.key}); @override State<GradeAveragePage> createState() => _AverageState(); }
class _AverageState extends State<GradeAveragePage> { final fields = [TextEditingController(), TextEditingController(), TextEditingController()]; double? result; @override void dispose() { for (final f in fields) f.dispose(); super.dispose(); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.gradeAverage)), body: PageBody(children: [const TextField(decoration: InputDecoration(labelText: S.grade, hintText: S.selectGrade)), const SizedBox(height: 20), const Text(S.finalTab), for (var i = 0; i < 3; i++) Padding(padding: const EdgeInsets.only(top: 16), child: TextField(controller: fields[i], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: ['دینی', 'عربی', 'فارسی'][i], hintText: 'نمره'))), const SizedBox(height: 20), const Text(S.calculateAverage), const SizedBox(height: 16), FilledButton(onPressed: () { try { setState(() => result = ToolsService.weightedAverage([for (final field in fields) (double.parse(latinDigits(field.text)), 1)])); } catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.invalidNumber))); } }, child: const Text(S.calculate)), if (result != null) Text('${S.finalAverage}: ${result!.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineLarge)])); }

class PercentCalculatorPage extends StatefulWidget { const PercentCalculatorPage({super.key}); @override State<PercentCalculatorPage> createState() => _PercentState(); }
class _PercentState extends State<PercentCalculatorPage> { final fields = [TextEditingController(), TextEditingController(), TextEditingController()]; double? result; @override void dispose() { for (final field in fields) field.dispose(); super.dispose(); } @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text(S.percentCalculator)), body: PageBody(children: [for (final row in [[S.correctAnswer, '✅'], [S.wrongAnswer, '❌'], [S.emptyAnswer, 'ⓘ']]) Padding(padding: const EdgeInsets.only(bottom: 16), child: TextField(controller: fields[['✅', '❌', 'ⓘ'].indexOf(row[1])], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${row[1]} ${row[0]}'))), const SizedBox(height: 20), Panel(color: const Color(0xFFEAF4FF), child: Column(children: [Text(result == null ? '٪۰٫۰۰' : '${result!.toStringAsFixed(2)}٪', style: Theme.of(context).textTheme.headlineLarge), const Text(S.percentage)])), const SizedBox(height: 24), FilledButton(onPressed: () { try { setState(() => result = ToolsService.examPercentage(correct: int.parse(latinDigits(fields[0].text)), wrong: int.parse(latinDigits(fields[1].text)), unanswered: int.parse(latinDigits(fields[2].text)))); } catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.invalidNumber))); } }, child: const Text(S.calculate))])); }

class SleepDesignPage extends StatelessWidget { const SleepDesignPage({super.key}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF191B2C), body: SafeArea(child: PageBody(children: [const Text(S.sleepSettings, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)), Panel(color: const Color(0xFFF4F4F6), child: Row(children: [const Text('🌙', style: TextStyle(fontSize: 52)), const SizedBox(width: 16), Expanded(child: Text(S.sleepBackground, style: TextStyle(color: Color(0xFF35364A))))])), const SizedBox(height: 28), const Text(S.sleepAverage, style: TextStyle(color: Colors.white70)), const Text(S.sleepAverageValue, style: TextStyle(color: Colors.white, fontSize: 38)), for (final title in [S.calculateSleep, S.calculateWake, S.relax, S.sleepTips]) Panel(color: const Color(0xFF2D3042), child: ListTile(title: Text(title, style: const TextStyle(color: Colors.white)), subtitle: const Text('با چند پیشنهاد ساده، روتین بهتری بساز', style: TextStyle(color: Colors.white60)), trailing: const Icon(Icons.chevron_left, color: Colors.white))), const Text(S.sleepWarning, style: TextStyle(color: Colors.white60))]))); }
