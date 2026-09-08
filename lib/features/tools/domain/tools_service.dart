import '../../../core/models/failure.dart';
abstract final class ToolsService {
  static double examPercentage({required int correct, required int wrong,
      required int unanswered, bool negativeMarking = true}) {
    final total = correct + wrong + unanswered;
    if (correct < 0 || wrong < 0 || unanswered < 0 || total == 0) {
      throw const AppFailure('invalidExam');
    }
    return (correct - (negativeMarking ? wrong / 3 : 0)) / total * 100;
  }
  static double weightedAverage(List<(double, double)> grades) {
    if (grades.isEmpty || grades.any((g) => g.$1 < 0 || g.$1 > 20 || g.$2 <= 0)) {
      throw const AppFailure('invalidExam');
    }
    return grades.fold<double>(0, (s, g) => s + g.$1 * g.$2) /
      grades.fold<double>(0, (s, g) => s + g.$2);
  }
  // A rough planning aid, not a medical recommendation or fixed sleep science.
  static List<DateTime> bedtimeOptions(DateTime wake, {int fallAsleepMinutes = 15}) =>
    [for (final cycles in [6, 5])
      wake.subtract(Duration(minutes: cycles * 90 + fallAsleepMinutes))];
}
