import '../../../core/models/models.dart';
abstract final class ReviewService {
  // Deterministic Leitner-inspired scheduler, not a claimed FSRS implementation.
  static Flashcard review(Flashcard c, ReviewRating rating, DateTime now) {
    final box = switch (rating) {
      ReviewRating.again => (c.box - 1).clamp(0, 4).toInt(),
      ReviewRating.hard => c.box,
      ReviewRating.good => (c.box + 1).clamp(0, 4).toInt(),
      ReviewRating.easy => (c.box + 2).clamp(0, 4).toInt(),
    };
    const days = [1, 2, 4, 7, 14];
    final interval = rating == ReviewRating.again ? 0 :
      rating == ReviewRating.hard ? 1 : days[box];
    return Flashcard(id: c.id, subjectId: c.subjectId, front: c.front, back: c.back,
      box: box, intervalDays: interval, reviews: c.reviews + 1,
      dueAt: now.add(rating == ReviewRating.again
        ? const Duration(minutes: 10) : Duration(days: interval)));
  }
}
