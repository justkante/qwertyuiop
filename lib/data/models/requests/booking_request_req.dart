import 'dart:convert';

ReportBookingReq reportBookingReqFromJson(String str) =>
    ReportBookingReq.fromJson(json.decode(str));

String reportBookingReqToJson(ReportBookingReq data) => json.encode(data.toJson());

class ReportBookingReq {
  final String? reportId;
  final String? reporteeName;
  final String? reporterName;
  final String? reporterMessage;
  final String? bookingId;
  final String? reportedUserId;
  final String? reportedReasonId;
  final String? details;

  ReportBookingReq({
    this.reportId,
    this.reporteeName,
    this.reporterName,
    this.reporterMessage,
    this.bookingId,
    this.reportedUserId,
    this.reportedReasonId,
    this.details,
  });

  factory ReportBookingReq.fromJson(Map<String, dynamic> json) => ReportBookingReq(
        reportId: json["report_id"],
        reporteeName: json["reportee_name"],
        reporterName: json["reporter_name"],
        reporterMessage: json["reporter_message"],
        bookingId: json["booking_id"],
        reportedUserId: json["reported_user_id"],
        reportedReasonId: json["reported_reason_id"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() {
    final msg = reporterMessage ?? details ?? '';
    return {
      "report_id": reportId ?? 'REP-00000',
      "reportee_name": reporteeName ?? bookingId ?? 'Booking',
      "reporter_name": reporterName ?? 'User',
      "reporter_message": msg,
      if (bookingId != null && bookingId!.isNotEmpty) "booking_id": bookingId,
      if (reportedUserId != null && reportedUserId!.isNotEmpty) "reported_user_id": reportedUserId,
      if (reportedReasonId != null && reportedReasonId!.isNotEmpty) "report_reason_id": reportedReasonId,
      "details": msg,
    };
  }
}
