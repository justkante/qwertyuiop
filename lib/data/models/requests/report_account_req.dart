// To parse this JSON data, do
//
//     final reportAccountReq = reportAccountReqFromJson(jsonString);

import 'dart:convert';

ReportAccountReq reportAccountReqFromJson(String str) =>
    ReportAccountReq.fromJson(json.decode(str));

String reportAccountReqToJson(ReportAccountReq data) => json.encode(data.toJson());

class ReportAccountReq {
  final String? reportedUserId;
  final String? reportReasonId;
  final String? details;

  ReportAccountReq({
    this.reportedUserId,
    this.reportReasonId,
    this.details,
  });

  ReportAccountReq copyWith({
    String? reportedUserId,
    String? reportReasonId,
    String? details,
  }) =>
      ReportAccountReq(
        reportedUserId: reportedUserId ?? this.reportedUserId,
        reportReasonId: reportReasonId ?? this.reportReasonId,
        details: details ?? this.details,
      );

  factory ReportAccountReq.fromJson(Map<String, dynamic> json) => ReportAccountReq(
        reportedUserId: json["reported_user_id"],
        reportReasonId: json["report_reason_id"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "reported_user_id": reportedUserId,
        "report_reason_id": reportReasonId,
        "details": details,
      };
}
