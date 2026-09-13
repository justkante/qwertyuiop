import 'package:creatify_mobile/data/models/requests/booking_request_req.dart';
import 'package:creatify_mobile/data/models/requests/cancel_booking_req.dart';
import 'package:creatify_mobile/data/models/requests/book_creator_req.dart';
import 'package:creatify_mobile/data/models/requests/renegotiate_booking_req.dart';
import 'package:creatify_mobile/data/models/requests/submit_review_req.dart';
import 'package:creatify_mobile/data/models/responses/cancel_reasons_dto.dart';
import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/draft_booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/notifications_dto.dart';
import 'package:creatify_mobile/data/models/responses/pending_review_tem_dto.dart';
import 'package:creatify_mobile/data/models/responses/unavailability_time_item_dto.dart';
import 'package:creatify_mobile/data/remote/bookings/bookings_service.dart';

abstract class BookingsRepo {
  Future<List<DraftingBookingItemDto>> getDraftBookings();
  Future<String> saveDraftBooking(BookCreatorReq req);
  Future<String> deleteDraftBooking(String draftId);
  Future<String> bookCreator(BookCreatorReq req);
  Future<List<CreatorUnavailabilityItemDto>> getCreatorUnavailability(String creatorId);
  Future<String> markTimeBasedBookingAsCompleted(String bookingId);
  Future<String> markDeliveryBasedBookingAsCompleted(String bookingId, String deliverableId);
  Future<String> renegotiateBooking({
    required RenegotiateBookingReq req,
    required String bookingId,
  });

  Future<String> recruiterRespondToRenegotiation({
    required String bookingId,
    required bool isAccepted,
  });
  Future<String> cancelBooking({
    required CancelBookingReq req,
    required String bookingId,
  });
  Future<List<BookingItemDto>> getSentBookings();
  Future<List<BookingItemDto>> getReceivedBookings();
  Future<BookingItemDto> getBookingDetails(String bookingId);
  Future<List<BookingDeliverable>> getBookingDeliverables(String bookingId);
  Future<String> acceptBooking(String bookingId);
  Future<List<CancelNegotationsReasonsItemDto>> getCancelReasons();
  Future<List<CancelNegotationsReasonsItemDto>> getRenegotiationReasons();
  Future<String> reportBooking(ReportBookingReq req);
  Future<String> requestBookingExtension(
      {required bool isTimeBased, required String bookingId, required int requestedDays});
  Future<String> recruiterRespondToExtension(
      {required String extensionId, required bool isAccepted});
  Future<String> updateTimeBasedBookingStatus({required String bookingId, required String status});
  Future<String> updateDeliverableBasedBookingStatus(
      {required String bookingId, required String deliverableId, required String status});
  Future<String> approveTimeBasedMarkCompleted(String bookingId);
  Future<bool> approveDeliverableBasedMarkCompleted(
      {required String bookingId, required String deliverableId, required String action});
  Future<NotificationDto> getNotifications();
  Future<String> markNotificationAsRead(String notificationId);
  Future<String> deleteNotification(String notificationId);
  Future<String> submitReview(String bookingId, SubmitReviewReq review);
  Future<List<PendingReviewItemDto>> getPendingReviews();
}

class BookingsRepoImpl implements BookingsRepo {
  final BookingsService _bookingsService;

  BookingsRepoImpl(this._bookingsService);

  @override
  Future<String> bookCreator(BookCreatorReq req) async {
    return await _bookingsService.bookCreator(req);
  }

  @override
  Future<List<CreatorUnavailabilityItemDto>> getCreatorUnavailability(String creatorId) async {
    return await _bookingsService.getCreatorUnavailability(creatorId);
  }

  @override
  Future<String> saveDraftBooking(BookCreatorReq req) async {
    return await _bookingsService.saveDraftBooking(req);
  }

  @override
  Future<String> acceptBooking(String bookingId) async {
    return await _bookingsService.acceptBooking(bookingId);
  }

  @override
  Future<String> cancelBooking({required CancelBookingReq req, required String bookingId}) async {
    return await _bookingsService.cancelBooking(req: req, bookingId: bookingId);
  }

  @override
  Future<BookingItemDto> getBookingDetails(String bookingId) async {
    return await _bookingsService.getBookingDetails(bookingId);
  }

  @override
  Future<List<CancelNegotationsReasonsItemDto>> getCancelReasons() async {
    return await _bookingsService.getCancelReasons();
  }

  @override
  Future<List<BookingItemDto>> getReceivedBookings() async {
    return await _bookingsService.getReceivedBookings();
  }

  @override
  Future<List<CancelNegotationsReasonsItemDto>> getRenegotiationReasons() async {
    return await _bookingsService.getRenegotiationReasons();
  }

  @override
  Future<List<BookingItemDto>> getSentBookings() async {
    return await _bookingsService.getSentBookings();
  }

  @override
  Future<String> markDeliveryBasedBookingAsCompleted(String bookingId, String deliverableId) async {
    return await _bookingsService.markDeliveryBasedBookingAsCompleted(
      bookingId: bookingId,
      deliverableId: deliverableId,
    );
  }

  @override
  Future<String> markTimeBasedBookingAsCompleted(String bookingId) async {
    return await _bookingsService.markTimeBasedBookingAsCompleted(bookingId);
  }

  @override
  Future<String> recruiterRespondToRenegotiation(
      {required String bookingId, required bool isAccepted}) async {
    return await _bookingsService.recruiterRespondToRenegotiation(
      bookingId: bookingId,
      isAccepted: isAccepted,
    );
  }

  @override
  Future<String> renegotiateBooking({
    required RenegotiateBookingReq req,
    required String bookingId,
  }) async {
    return await _bookingsService.renegotiateBooking(
      req: req,
      bookingId: bookingId,
    );
  }

  @override
  Future<String> reportBooking(ReportBookingReq req) async {
    return await _bookingsService.reportBooking(req);
  }

  @override
  Future<String> approveTimeBasedMarkCompleted(String bookingId) async {
    return await _bookingsService.approveTimeBasedMarkCompleted(bookingId);
  }

  @override
  Future<String> recruiterRespondToExtension(
      {required String extensionId, required bool isAccepted}) async {
    return await _bookingsService.recruiterRespondToExtension(
      extensionId: extensionId,
      isAccepted: isAccepted,
    );
  }

  @override
  Future<String> requestBookingExtension(
      {required bool isTimeBased, required String bookingId, required int requestedDays}) async {
    return await _bookingsService.requestBookingExtension(
      isTimeBased: isTimeBased,
      bookingId: bookingId,
      requestedDays: requestedDays,
    );
  }

  @override
  Future<String> updateTimeBasedBookingStatus(
      {required String bookingId, required String status}) async {
    return await _bookingsService.updateTimeBasedBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }

  @override
  Future<List<BookingDeliverable>> getBookingDeliverables(String bookingId) async {
    return await _bookingsService.getBookingDeliverables(bookingId);
  }

  @override
  Future<String> updateDeliverableBasedBookingStatus(
      {required String bookingId, required String deliverableId, required String status}) async {
    return await _bookingsService.updateDeliverableBasedBookingStatus(
      bookingId: bookingId,
      deliverableId: deliverableId,
      status: status,
    );
  }

  @override
  Future<bool> approveDeliverableBasedMarkCompleted(
      {required String bookingId, required String deliverableId, required String action}) async {
    return await _bookingsService.approveDeliverableBasedMarkCompleted(
      bookingId: bookingId,
      deliverableId: deliverableId,
      action: action,
    );
  }

  @override
  Future<NotificationDto> getNotifications() async {
    return await _bookingsService.getNotifications();
  }

  @override
  Future<String> markNotificationAsRead(String notificationId) async {
    return await _bookingsService.markNotificationAsRead(notificationId);
  }

  @override
  Future<String> submitReview(String bookingId, SubmitReviewReq review) async {
    return await _bookingsService.submitReview(bookingId, review);
  }

  @override
  Future<String> deleteNotification(String notificationId) {
    return _bookingsService.deleteNotification(notificationId);
  }

  @override
  Future<List<DraftingBookingItemDto>> getDraftBookings() async {
    return await _bookingsService.getDraftBookings();
  }

  @override
  Future<String> deleteDraftBooking(String draftId) async {
    return await _bookingsService.deleteDraftBooking(draftId);
  }

  @override
  Future<List<PendingReviewItemDto>> getPendingReviews() async {
    return await _bookingsService.getPendingReviews();
  }
}
