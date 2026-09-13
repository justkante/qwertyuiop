// To parse this JSON data, do
//
//     final bookingItemDto = bookingItemDtoFromJson(jsonString);

import 'dart:convert';

import 'package:creatify_mobile/view/utils/extensions.dart';

BookingItemDto bookingItemDtoFromJson(String str) => BookingItemDto.fromJson(json.decode(str));

String bookingItemDtoToJson(BookingItemDto data) => json.encode(data.toJson());

class BookingItemDto {
  final String? id;
  final String? bookingType;
  final String? jobDescription;
  final DateTime? startDate;
  final DateTime? endDate;

  final String? startTime;
  final String? duration;
  final String? location;
  final String? workMode;
  final String? offeredPrice;
  final String? finalPrice;
  final BookingStatus? status;
  final BookingPaymentStatus? paymentStatus;
  final bool? isRenegotiated;
  final Creator? recruiter;
  final Creator? creator;
  final Service? service;
  final List<BookingDeliverable>? deliverables;
  final DateTime? createdAt;
  final String? currency;
  final String? paymentGateway;
  final PricingClass? pricing;
  final DateTime? acceptedAt;
  final List<RenegotiationHistory>? renegotiationHistory;
  final List<ExtensionRequest>? extensionRequests;
  final Cancellation? cancellation;

  BookingItemDto({
    this.id,
    this.bookingType,
    this.jobDescription,
    this.startDate,
    this.startTime,
    this.endDate,
    this.duration,
    this.location,
    this.workMode,
    this.offeredPrice,
    this.finalPrice,
    this.status,
    this.paymentStatus,
    this.isRenegotiated,
    this.recruiter,
    this.creator,
    this.service,
    this.deliverables,
    this.createdAt,
    this.currency,
    this.paymentGateway,
    this.pricing,
    this.acceptedAt,
    this.renegotiationHistory,
    this.extensionRequests,
    this.cancellation,
  });

  factory BookingItemDto.fromJson(Map<String, dynamic> json) => BookingItemDto(
        id: json["id"],
        bookingType: json["booking_type"],
        jobDescription: json["job_description"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"])
                .addTimeFromString(json["start_time"] ?? "00:00:00"),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        startTime: json["start_time"],
        duration: json["duration"],
        location: json["location"],
        workMode: json["work_mode"],
        offeredPrice: json["offered_price"],
        finalPrice: json["final_price"],
        status:
            json["status"] == null ? null : bookingStatusValues.map[json["status"]!.toLowerCase()],
        paymentStatus: json["payment_status"] == null
            ? null
            : paymentStatusValues.map[json["payment_status"]!.toLowerCase()],
        isRenegotiated: json["is_renegotiated"],
        recruiter: json["recruiter"] == null ? null : Creator.fromJson(json["recruiter"]),
        creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
        service: json["service"] == null ? null : Service.fromJson(json["service"]),
        deliverables: json["deliverables"] == null
            ? []
            : List<BookingDeliverable>.from(
                json["deliverables"]!.map((x) => BookingDeliverable.fromJson(x))),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        currency: json["currency"],
        paymentGateway: json["payment_gateway"],
        pricing: json["pricing"] == null ? null : PricingClass.fromJson(json["pricing"]),
        acceptedAt: json["accepted_at"] == null ? null : DateTime.parse(json["accepted_at"]),
        renegotiationHistory: json["renegotiation_history"] == null
            ? []
            : List<RenegotiationHistory>.from(
                json["renegotiation_history"]!.map((x) => RenegotiationHistory.fromJson(x))),
        extensionRequests: json["extension_requests"] == null
            ? []
            : List<ExtensionRequest>.from(
                json["extension_requests"]!.map((x) => ExtensionRequest.fromJson(x))),
        cancellation:
            json["cancellation"] == null ? null : Cancellation.fromJson(json["cancellation"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_type": bookingType,
        "job_description": jobDescription,
        "start_date":
            "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "end_date":
            "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "duration": duration,
        "location": location,
        "work_mode": workMode,
        "offered_price": offeredPrice,
        "final_price": finalPrice,
        "status": status,
        "payment_status": paymentStatus,
        "is_renegotiated": isRenegotiated,
        "recruiter": recruiter?.toJson(),
        "creator": creator?.toJson(),
        "service": service?.toJson(),
        "deliverables":
            deliverables == null ? [] : List<dynamic>.from(deliverables!.map((x) => x.toJson())),
        "created_at": createdAt?.toIso8601String(),
        "accepted_at": acceptedAt?.toIso8601String(),
        "currency": currency,
        "payment_gateway": paymentGateway,
        "pricing": pricing?.toJson(),
        "renegotiation_history": renegotiationHistory == null
            ? []
            : List<dynamic>.from(renegotiationHistory!.map((x) => x.toJson())),
        "extension_requests": extensionRequests == null
            ? []
            : List<dynamic>.from(extensionRequests!.map((x) => x.toJson())),
        "cancellation": cancellation?.toJson(),
      };
}

class Cancellation {
  final String? reasonId;
  final String? details;
  final String? cancelledByRole;
  final bool? isWithin48Hours;
  final dynamic refundAmount;
  final dynamic penaltyAmount;
  final DateTime? cancelledAt;

  Cancellation({
    this.reasonId,
    this.details,
    this.cancelledByRole,
    this.isWithin48Hours,
    this.refundAmount,
    this.penaltyAmount,
    this.cancelledAt,
  });

  factory Cancellation.fromJson(Map<String, dynamic> json) => Cancellation(
        reasonId: json["reason_id"],
        details: json["details"],
        cancelledByRole: json["cancelled_by_role"],
        isWithin48Hours: json["is_within_48_hours"],
        refundAmount: json["refund_amount"],
        penaltyAmount: json["penalty_amount"],
        cancelledAt: json["cancelled_at"] == null ? null : DateTime.parse(json["cancelled_at"]),
      );

  Map<String, dynamic> toJson() => {
        "reason_id": reasonId,
        "details": details,
        "cancelled_by_role": cancelledByRole,
        "is_within_48_hours": isWithin48Hours,
        "refund_amount": refundAmount,
        "penalty_amount": penaltyAmount,
        "cancelled_at": cancelledAt?.toIso8601String(),
      };
}

class Creator {
  final String? id;
  final String? name;
  final String? email;
  final String? profileImage;
  final String? countryCode;

  String get initials {
    if (name == null || name!.isEmpty) return '';
    var names = name!.split(' ');
    if (names.length == 1) return names[0][0];
    return names[0][0] + names[1][0];
  }

  Creator({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.countryCode,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        profileImage: json["profile_image"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "profile_image": profileImage,
        "country_code": countryCode,
      };
}

class BookingDeliverable {
  final String? id;
  final String? description;
  final String? price;
  final String? status;
  final int? revisionCount;
  final int? maxRevisions;
  final bool? canRequestMoreRevisions;
  final bool? isBeingRevised;
  final bool? isCompleted;
  final DateTime? creatorCompletedAt;
  final DateTime? recruiterApprovedAt;
  final DateTime? completedAt;
  final DateTime? disputedAt;
  final PricingClass? pricing;

  BookingDeliverable({
    this.id,
    this.description,
    this.price,
    this.status,
    this.revisionCount,
    this.maxRevisions,
    this.canRequestMoreRevisions,
    this.isBeingRevised,
    this.isCompleted,
    this.creatorCompletedAt,
    this.recruiterApprovedAt,
    this.completedAt,
    this.disputedAt,
    this.pricing,
  });

  factory BookingDeliverable.fromJson(Map<String, dynamic> json) => BookingDeliverable(
        id: json["id"],
        description: json["description"],
        price: json["price"],
        status: json["status"],
        revisionCount: json["revision_count"],
        maxRevisions: json["max_revisions"],
        canRequestMoreRevisions: json["can_request_more_revisions"],
        isBeingRevised: json["is_being_revised"],
        isCompleted: json["is_completed"],
        creatorCompletedAt: json["creator_completed_at"] == null
            ? null
            : DateTime.parse(json["creator_completed_at"]),
        recruiterApprovedAt: json["recruiter_approved_at"] == null
            ? null
            : DateTime.parse(json["recruiter_approved_at"]),
        completedAt: json["completed_at"] == null ? null : DateTime.parse(json["completed_at"]),
        disputedAt: json["disputed_at"] == null ? null : DateTime.parse(json["disputed_at"]),
        pricing: json["pricing"] == null ? null : PricingClass.fromJson(json["pricing"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "price": price,
        "status": status,
        "revision_count": revisionCount,
        "max_revisions": maxRevisions,
        "can_request_more_revisions": canRequestMoreRevisions,
        "is_being_revised": isBeingRevised,
        "is_completed": isCompleted,
        "creator_completed_at": creatorCompletedAt?.toIso8601String(),
        "recruiter_approved_at": recruiterApprovedAt?.toIso8601String(),
        "completed_at": completedAt?.toIso8601String(),
        "disputed_at": disputedAt?.toIso8601String(),
        "pricing": pricing?.toJson(),
      };
}

class RenegotiationHistory {
  final String? id;
  final String? newPrice;
  final String? details;
  final String? status;
  final RenegotiatedBy? renegotiatedBy;
  final dynamic respondedAt;
  final DateTime? createdAt;

  RenegotiationHistory({
    this.id,
    this.newPrice,
    this.details,
    this.status,
    this.renegotiatedBy,
    this.respondedAt,
    this.createdAt,
  });

  factory RenegotiationHistory.fromJson(Map<String, dynamic> json) => RenegotiationHistory(
        id: json["id"],
        newPrice: json["new_price"],
        details: json["details"],
        status: json["status"],
        renegotiatedBy: json["renegotiated_by"] == null
            ? null
            : RenegotiatedBy.fromJson(json["renegotiated_by"]),
        respondedAt: json["responded_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "new_price": newPrice,
        "details": details,
        "status": status,
        "renegotiated_by": renegotiatedBy?.toJson(),
        "responded_at": respondedAt,
        "created_at": createdAt?.toIso8601String(),
      };
}

class RenegotiatedBy {
  final String? id;
  final String? name;

  RenegotiatedBy({
    this.id,
    this.name,
  });

  factory RenegotiatedBy.fromJson(Map<String, dynamic> json) => RenegotiatedBy(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class ExtensionRequest {
  final String? id;
  final int? daysRequested;
  final String? status;
  final bool? isAutoApproved;
  final DateTime? originalEndDate;
  final DateTime? newEndDate;
  final DateTime? newEndTime;
  final DateTime? requestedAt;
  final dynamic respondedAt;

  ExtensionRequest({
    this.id,
    this.daysRequested,
    this.status,
    this.isAutoApproved,
    this.originalEndDate,
    this.newEndDate,
    this.newEndTime,
    this.requestedAt,
    this.respondedAt,
  });

  factory ExtensionRequest.fromJson(Map<String, dynamic> json) => ExtensionRequest(
        id: json["id"],
        daysRequested: json["days_requested"],
        status: json["status"],
        isAutoApproved: json["is_auto_approved"],
        originalEndDate:
            json["original_end_date"] == null ? null : DateTime.parse(json["original_end_date"]),
        newEndDate: json["new_end_date"] == null ? null : DateTime.parse(json["new_end_date"]),
        newEndTime: json["new_end_time"] == null ? null : DateTime.parse(json["new_end_time"]),
        requestedAt: json["requested_at"] == null ? null : DateTime.parse(json["requested_at"]),
        respondedAt: json["responded_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "days_requested": daysRequested,
        "status": status,
        "is_auto_approved": isAutoApproved,
        "original_end_date":
            "${originalEndDate!.year.toString().padLeft(4, '0')}-${originalEndDate!.month.toString().padLeft(2, '0')}-${originalEndDate!.day.toString().padLeft(2, '0')}",
        "new_end_date":
            "${newEndDate!.year.toString().padLeft(4, '0')}-${newEndDate!.month.toString().padLeft(2, '0')}-${newEndDate!.day.toString().padLeft(2, '0')}",
        "new_end_time": newEndTime?.toIso8601String(),
        "requested_at": requestedAt?.toIso8601String(),
        "responded_at": respondedAt,
      };
}

class Service {
  final String? id;
  final String? name;
  final String? hourlyRate;

  Service({
    this.id,
    this.name,
    this.hourlyRate,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        name: json["name"],
        hourlyRate: json["hourly_rate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "hourly_rate": hourlyRate,
      };
}

class PricingClass {
  final CreatorX? creator;
  final CreatorX? recruiter;
  final bool? isCrossBorder;
  final num? exchangeRate;
  final DateTime? exchangeRateLockedAt;
  final String? displayForRecruiter;
  final String? displayForCreator;

  PricingClass({
    this.creator,
    this.recruiter,
    this.isCrossBorder,
    this.exchangeRate,
    this.exchangeRateLockedAt,
    this.displayForRecruiter,
    this.displayForCreator,
  });

  PricingClass copyWith({
    CreatorX? creator,
    CreatorX? recruiter,
    bool? isCrossBorder,
    num? exchangeRate,
    DateTime? exchangeRateLockedAt,
    String? displayForRecruiter,
    String? displayForCreator,
  }) =>
      PricingClass(
        creator: creator ?? this.creator,
        recruiter: recruiter ?? this.recruiter,
        isCrossBorder: isCrossBorder ?? this.isCrossBorder,
        exchangeRate: exchangeRate ?? this.exchangeRate,
        exchangeRateLockedAt: exchangeRateLockedAt ?? this.exchangeRateLockedAt,
        displayForRecruiter: displayForRecruiter ?? this.displayForRecruiter,
        displayForCreator: displayForCreator ?? this.displayForCreator,
      );

  factory PricingClass.fromJson(Map<String, dynamic> json) => PricingClass(
        creator: json["creator"] == null ? null : CreatorX.fromJson(json["creator"]),
        recruiter: json["recruiter"] == null ? null : CreatorX.fromJson(json["recruiter"]),
        isCrossBorder: json["is_cross_border"],
        exchangeRate: json["exchange_rate"],
        exchangeRateLockedAt: json["exchange_rate_locked_at"] == null
            ? null
            : DateTime.parse(json["exchange_rate_locked_at"]),
        displayForRecruiter: json["display_for_recruiter"],
        displayForCreator: json["display_for_creator"],
      );

  Map<String, dynamic> toJson() => {
        "creator": creator?.toJson(),
        "recruiter": recruiter?.toJson(),
        "is_cross_border": isCrossBorder,
        "exchange_rate": exchangeRate,
        "exchange_rate_locked_at": exchangeRateLockedAt?.toIso8601String(),
        "display_for_recruiter": displayForRecruiter,
        "display_for_creator": displayForCreator,
      };
}

class CreatorX {
  final num? amount;
  final String? currency;
  final String? formatted;

  CreatorX({
    this.amount,
    this.currency,
    this.formatted,
  });

  CreatorX copyWith({
    num? amount,
    String? currency,
    String? formatted,
  }) =>
      CreatorX(
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        formatted: formatted ?? this.formatted,
      );

  factory CreatorX.fromJson(Map<String, dynamic> json) => CreatorX(
        amount: json["amount"],
        currency: json["currency"],
        formatted: json["formatted"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "formatted": formatted,
      };
}

enum BookingStatus {
  pending,
  accepted,
  cancelled,
  completed,
  negotiated,
}

var bookingStatusValues = EnumValues({
  "pending": BookingStatus.pending,
  "accepted": BookingStatus.accepted,
  "cancelled": BookingStatus.cancelled,
  "completed": BookingStatus.completed,
  "negotiated": BookingStatus.negotiated,
});

enum BookingPaymentStatus {
  unpaid,
  paid,
  refunded,
}

var paymentStatusValues = EnumValues({
  "unpaid": BookingPaymentStatus.unpaid,
  "paid": BookingPaymentStatus.paid,
  "refunded": BookingPaymentStatus.refunded,
});

enum DeliveryStatus {
  notStarted,
  inProgress,
  completed,
}

var deliveryStatusValues = EnumValues({
  "not_started": DeliveryStatus.notStarted,
  "in_progress": DeliveryStatus.inProgress,
  "completed": DeliveryStatus.completed,
});
