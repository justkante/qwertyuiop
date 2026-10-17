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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (reportedUserId != null && reportedUserId!.isNotEmpty) {
      map["reported_user_id"] = reportedUserId;
      map["user_id"] = reportedUserId;
      map["reported_id"] = reportedUserId;
    }
    if (reportReasonId != null && reportReasonId!.isNotEmpty) {
      map["report_reason_id"] = reportReasonId;
      map["reason_id"] = reportReasonId;
      map["reported_reason_id"] = reportReasonId;
    }
    if (details != null && details!.isNotEmpty) {
      map["details"] = details;
      map["description"] = details;
    }
    return map;
  }
}
