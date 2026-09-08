import '../models/models.dart';
abstract interface class StudyRepository {
  Future<void> initialize();
  Future<AppData> load();
  Future<void> saveProfile(UserProfile profile);
  Future<void> setOnboarded();
  Future<void> setSignedIn(bool value);
  Future<void> savePreferences(Preferences preferences);
  Future<void> savePlan(StudyPlan plan);
  Future<void> savePlanOrder(List<StudyPlan> plans);
  Future<void> deletePlan(String id);
  Future<void> saveTimer(ActiveTimer timer);
  Future<void> discardTimer();
  Future<void> finish(StudySession session, {ActiveTimer? next});
  Future<void> saveNote(String day, String text);
  Future<void> saveCard(Flashcard card);
  Future<void> reviewCard(Flashcard before, Flashcard after, ReviewRating rating);
  Future<void> readNotice(String id);
  Future<void> addNotice(AppNotice notice);
  Future<void> event(String name);
  Future<void> close();
}
