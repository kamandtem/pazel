import '../models/models.dart';
// Future module contracts only. No server implementation or fake success.
class PageSlice<T> {
  const PageSlice(this.items, this.nextCursor);
  final List<T> items;
  final String? nextCursor;
}
class League {
  const League({required this.id, required this.name, required this.startsAt,
    required this.endsAt, required this.memberCount, required this.theme});
  final String id, name, theme;
  final DateTime startsAt, endsAt;
  final int memberCount;
}
class StudyRoom {
  const StudyRoom(this.id, this.name, this.isPrivate, this.memberCount);
  final String id, name;
  final bool isPrivate;
  final int memberCount;
}
class Podcast {
  const Podcast(this.id, this.title, this.audioUrl, this.coverUrl, this.durationSeconds);
  final String id, title, audioUrl, coverUrl;
  final int durationSeconds;
}
class AIMessage {
  const AIMessage(this.id, this.role, this.text, this.createdAt);
  final String id, role, text;
  final DateTime createdAt;
}
class Product {
  const Product(this.id, this.title, this.priceRials);
  final String id, title;
  final int priceRials;
}
class WalletTransaction {
  const WalletTransaction(this.id, this.deltaRials, this.createdAt, this.status);
  final String id, status;
  final int deltaRials;
  final DateTime createdAt;
}
class AdvisorRequest {
  const AdvisorRequest(this.id, this.advisorId, this.scheduledAt, this.status);
  final String id, advisorId, status;
  final DateTime scheduledAt;
}
class SyncEnvelope {
  const SyncEnvelope(this.eventId, this.entity, this.recordId, this.payload);
  final String eventId, entity, recordId;
  final Json payload;
}
abstract interface class LeagueRepository {
  Future<PageSlice<League>> list({String? cursor});
  Future<void> join(String leagueId);
}
abstract interface class StudyRoomRepository {
  Stream<StudyRoom> watch(String roomId);
  Future<void> join(String roomId, {String? inviteToken});
  Future<void> leave(String roomId);
}
abstract interface class PodcastRepository {
  Future<PageSlice<Podcast>> list({String? cursor});
}
abstract interface class AIRepository {
  Stream<AIMessage> ask(String text, {required bool consentToStudyContext});
}
abstract interface class AdvisorRepository {
  Future<AdvisorRequest> request(String advisorId, DateTime at, String reason);
}
abstract interface class StoreRepository {
  Future<PageSlice<Product>> list({String? cursor});
  Future<Uri> createCheckout(List<String> productIds, {String? coupon});
}
abstract interface class WalletRepository {
  Future<int> balanceRials();
  Future<PageSlice<WalletTransaction>> history({String? cursor});
}
abstract interface class SyncService {
  Future<Set<String>> push(List<SyncEnvelope> envelopes);
  Future<PageSlice<SyncEnvelope>> pull({String? cursor});
}
