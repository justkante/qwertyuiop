import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final creatorUnavailabilityProvider = FutureProvider.autoDispose
    .family<List<CreatorUnavailabilityItemDto>, String>((ref, String creatorId) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getCreatorUnavailability(creatorId);
});

final fetchSentBookingsProvider = FutureProvider.autoDispose((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getSentBookings();
});

final fetchReceivedBookingsProvider = FutureProvider.autoDispose((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getReceivedBookings();
});

final fetchDraftBookingsProvider = FutureProvider.autoDispose((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getDraftBookings();
});

final fetchBookingDetailsProvider =
    FutureProvider.autoDispose.family<BookingItemDto, String>((ref, String bookingId) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getBookingDetails(bookingId);
});

final fetchCancelReasonsProvider = FutureProvider((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getCancelReasons();
});

final fetchRenegotiationReasonsProvider = FutureProvider((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getRenegotiationReasons();
});

final fetchBookingDeliverablesProvider =
    FutureProvider.autoDispose.family<List<BookingDeliverable>, String>((ref, String bookingId) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getBookingDeliverables(bookingId);
});

final fetchNotificationsProvider = FutureProvider.autoDispose((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getNotifications();
});

final fetchPendingReviewsProvider = FutureProvider.autoDispose((ref) {
  final bookingsRepo = ref.watch(bookingsRepository);
  return bookingsRepo.getPendingReviews();
});
