import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
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

class BookingsService {
  final HttpService _networkService;

  BookingsService({required HttpService networkService}) : _networkService = networkService;

  Future<String> bookCreator(BookCreatorReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.createBooking,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> saveDraftBooking(BookCreatorReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.saveDraftBooking,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> deleteDraftBooking(String draftId) async {
    try {
      final response = await _networkService.request(
        endpoints.deleteDraftBooking(draftId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CreatorUnavailabilityItemDto>> getCreatorUnavailability(String creatorId) async {
    try {
      final response = await _networkService.request(
        endpoints.getCreatorUnavailability(creatorId),
        RequestMethod.get,
      );

      final List<CreatorUnavailabilityItemDto> unavailabilityItems = (response.data['data'] as List)
          .map((item) => CreatorUnavailabilityItemDto.fromJson(item))
          .toList();

      return unavailabilityItems;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<DraftingBookingItemDto>> getDraftBookings() async {
    try {
      final response = await _networkService.request(
        endpoints.getDraftBookings,
        RequestMethod.get,
      );

      final List<DraftingBookingItemDto> bookings = (response.data['data'] as List)
          .map((item) => DraftingBookingItemDto.fromJson(item))
          .toList();

      return bookings;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<BookingItemDto>> getSentBookings() async {
    try {
      final response = await _networkService.request(
        endpoints.getSentBookings,
        RequestMethod.get,
      );

      final List<BookingItemDto> bookings =
          (response.data['data'] as List).map((item) => BookingItemDto.fromJson(item)).toList();

      return bookings;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<BookingItemDto>> getReceivedBookings() async {
    try {
      final response = await _networkService.request(
        endpoints.getReceivedBookings,
        RequestMethod.get,
      );

      final List<BookingItemDto> bookings =
          (response.data['data'] as List).map((item) => BookingItemDto.fromJson(item)).toList();

      return bookings;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<BookingItemDto> getBookingDetails(String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.getBookingDetails(bookingId),
        RequestMethod.get,
      );

      return BookingItemDto.fromJson(response.data['data']);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<BookingDeliverable>> getBookingDeliverables(String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.getDeliverablesList(bookingId),
        RequestMethod.get,
      );

      final List<BookingDeliverable> deliverables =
          (response.data['data'] as List).map((item) => BookingDeliverable.fromJson(item)).toList();

      return deliverables;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> acceptBooking(String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.acceptBooking(bookingId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> renegotiateBooking({
    required RenegotiateBookingReq req,
    required String bookingId,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.renegotiateBooking(bookingId),
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> recruiterRespondToRenegotiation({
    required String bookingId,
    required bool isAccepted,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.recruiterRespondToRenegotiation(bookingId),
        RequestMethod.post,
        data: {
          "action": isAccepted ? "accept" : "reject",
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> cancelBooking({
    required CancelBookingReq req,
    required String bookingId,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.cancelBooking(bookingId),
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CancelNegotationsReasonsItemDto>> getCancelReasons() async {
    try {
      final response = await _networkService.request(
        endpoints.getCancelReasons,
        RequestMethod.get,
      );

      final List<CancelNegotationsReasonsItemDto> reasons = (response.data['data'] as List)
          .map((item) => CancelNegotationsReasonsItemDto.fromJson(item))
          .toList();

      return reasons;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<CancelNegotationsReasonsItemDto>> getRenegotiationReasons() async {
    try {
      final response = await _networkService.request(
        endpoints.getRenegotationReasons,
        RequestMethod.get,
      );

      final List<CancelNegotationsReasonsItemDto> reasons = (response.data['data'] as List)
          .map((item) => CancelNegotationsReasonsItemDto.fromJson(item))
          .toList();

      return reasons;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> markTimeBasedBookingAsCompleted(String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.markTimeBasedBookingAsCompleted(bookingId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> markDeliveryBasedBookingAsCompleted({
    required String bookingId,
    required String deliverableId,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.markDeliveryBasedBookingAsCompleted(bookingId, deliverableId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> reportBooking(ReportBookingReq req) async {
    try {
      final response = await _networkService.request(
        endpoints.reportBooking,
        RequestMethod.post,
        data: req.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> requestBookingExtension({
    required bool isTimeBased,
    required String bookingId,
    required int requestedDays,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.requestBookingExtension(bookingId),
        RequestMethod.post,
        data: {
          isTimeBased ? "duration" : "days_requested": requestedDays,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> recruiterRespondToExtension({
    required String extensionId,
    required bool isAccepted,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.recruiterRespondToExtension(extensionId),
        RequestMethod.post,
        data: {
          "action": isAccepted ? "approve" : "reject",
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> updateTimeBasedBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.updateTimeBasedBookingStatus(bookingId),
        RequestMethod.post,
        data: {
          "status": status,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> updateDeliverableBasedBookingStatus({
    required String bookingId,
    required String deliverableId,
    required String status,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.updateDeliverableBasedBookingStatus(bookingId, deliverableId),
        RequestMethod.post,
        data: {
          "status": status,
        },
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> approveTimeBasedMarkCompleted(String bookingId) async {
    try {
      final response = await _networkService.request(
        endpoints.approveTimeMarkCompleted(bookingId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> approveDeliverableBasedMarkCompleted({
    required String bookingId,
    required String deliverableId,
    required String action,
  }) async {
    try {
      final response = await _networkService.request(
        endpoints.approveDeliverableMarkCompleted(bookingId, deliverableId),
        RequestMethod.post,
        data: {
          "action": action,
        },
      );

      return response.data['all_deliverables_completed'] as bool;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<NotificationDto> getNotifications() async {
    try {
      final response = await _networkService.request(
        endpoints.getNotifications,
        RequestMethod.get,
      );

      return NotificationDto.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _networkService.request(
        endpoints.markNotificationAsRead(notificationId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> deleteNotification(String notificationId) async {
    try {
      final response = await _networkService.request(
        endpoints.deleteNotification(notificationId),
        RequestMethod.post,
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> submitReview(String bookingId, SubmitReviewReq review) async {
    try {
      final response = await _networkService.request(
        endpoints.submitReview(bookingId),
        RequestMethod.post,
        data: review.toJson(),
      );

      return response.data['message'];
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<PendingReviewItemDto>> getPendingReviews() async {
    try {
      final response = await _networkService.request(
        endpoints.pendingReviews,
        RequestMethod.get,
      );

      final List<PendingReviewItemDto> pendingReviews = (response.data['data'] as List)
          .map((item) => PendingReviewItemDto.fromJson(item))
          .toList();

      return pendingReviews;
    } catch (e) {
      throw e.toString();
    }
  }
}
