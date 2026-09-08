import 'package:flutter_test/flutter_test.dart';
import 'package:pazel/core/models/models.dart';
import 'package:pazel/features/flashcards/domain/review_service.dart';
void main() {
  final now = DateTime.utc(2026, 9, 8, 9);
  Flashcard card({int box = 2}) => Flashcard(id: 'c', subjectId: 'biology',
    front: 'Q', back: 'A', dueAt: now, box: box);
  test('again returns to preceding Leitner box and schedules relearning', () {
    final c = ReviewService.review(card(), ReviewRating.again, now);
    expect(c.box, 1); expect(c.dueAt, now.add(const Duration(minutes: 10)));
  });
  test('Leitner boxes stay inside 0..4', () {
    expect(ReviewService.review(card(box: 0), ReviewRating.again, now).box, 0);
    expect(ReviewService.review(card(box: 4), ReviewRating.easy, now).box, 4);
  });
  test('hard retains box; good advances; easy schedules farther away', () {
    final hard = ReviewService.review(card(), ReviewRating.hard, now);
    final good = ReviewService.review(card(), ReviewRating.good, now);
    final easy = ReviewService.review(card(), ReviewRating.easy, now);
    expect(hard.box, 2); expect(good.box, 3); expect(easy.box, 4);
    expect(hard.intervalDays, 1); expect(good.intervalDays, 7); expect(easy.intervalDays, 14);
    expect(good.reviews, 1);
  });
  test('card codec roundtrip preserves scheduling state', () {
    expect(Flashcard.fromJson(card().toJson()).toJson(), card().toJson());
  });
}
