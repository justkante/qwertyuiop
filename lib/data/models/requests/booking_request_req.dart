// To parse this JSON data, do
//
//     final reportBookingReq = reportBookingReqFromJson(jsonString);

import 'dart:convert';

ReportBookingReq reportBookingReqFromJson(String str) =>
    ReportBookingReq.fromJson(json.decode(str));

String reportBookingReqToJson(ReportBookingReq data) => json.encode(data.toJson());

class ReportBookingReq {
  final String? bookingId;
  final String? reportedUserId;
  final String? reportedReasonId;
  final String? details;

  ReportBookingReq({
    this.bookingId,
    this.reportedUserId,
    this.reportedReasonId,
    this.details,
  });

  ReportBookingReq copyWith({
    String? bookingId,
    String? reportedUserId,
    String? reportedReasonId,
    String? details,
  }) =>
      ReportBookingReq(
        bookingId: bookingId ?? this.bookingId,
        reportedUserId: reportedUserId ?? this.reportedUserId,
        reportedReasonId: reportedReasonId ?? this.reportedReasonId,
        details: details ?? this.details,
      );

  factory ReportBookingReq.fromJson(Map<String, dynamic> json) => ReportBookingReq(
        bookingId: json["booking_id"],
        reportedUserId: json["reported_user_id"],
        reportedReasonId: json["report_reason_id"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (bookingId != null && bookingId!.isNotEmpty) {
      map["booking_id"] = bookingId;
    }
    if (reportedUserId != null && reportedUserId!.isNotEmpty) {
      map["reported_user_id"] = reportedUserId;
      map["user_id"] = reportedUserId;
      map["reported_id"] = reportedUserId;
    }
    if (reportedReasonId != null && reportedReasonId!.isNotEmpty) {
      map["report_reason_id"] = reportedReasonId;
      map["reason_id"] = reportedReasonId;
      map["reported_reason_id"] = reportedReasonId;
    }
    if (details != null && details!.isNotEmpty) {
      map["details"] = details;
      map["description"] = details;
    }
    return map;
  }
}
