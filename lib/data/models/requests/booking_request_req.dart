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

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "reported_user_id": reportedUserId,
        "report_reason_id": reportedReasonId,
        "details": details,
      };
}
