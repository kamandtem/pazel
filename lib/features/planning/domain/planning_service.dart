import '../../../core/models/models.dart';
import '../../../core/models/failure.dart';
abstract final class PlanningService {
  static void validate(StudyPlan p, List<StudyPlan> existing) {
    if (p.topic.trim().isEmpty || p.minutes < 1 || p.minutes > 720 ||
        p.startMinute < 0 || p.startMinute + p.minutes > 1440 || p.tests < 0 ||
        p.priority < 0 || p.priority > 2 || DateTime.tryParse(p.day) == null) {
      throw const AppFailure('invalidPlan');
    }
    final overlap = existing.any((x) => x.id != p.id && x.day == p.day &&
      !x.done && !p.done && p.startMinute < x.startMinute + x.minutes &&
      x.startMinute < p.startMinute + p.minutes);
    if (overlap) throw const AppFailure('overlap');
  }
  static List<StudyPlan> reorder(List<StudyPlan> plans, int oldIndex, int newIndex) {
    final result = List<StudyPlan>.of(plans);
    if (newIndex > oldIndex) newIndex--;
    result.insert(newIndex, result.removeAt(oldIndex));
    return [for (var i = 0; i < result.length; i++) result[i].copyWith(position: i)];
  }
}
