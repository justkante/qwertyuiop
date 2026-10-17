import 'dart:convert';

ReportAccountReq reportAccountReqFromJson(String str) =>
    ReportAccountReq.fromJson(json.decode(str));

String reportAccountReqToJson(ReportAccountReq data) => json.encode(data.toJson());

class ReportAccountReq {
  final String? reportId;
  final String? reporteeName;
  final String? reporterName;
  final String? reporterMessage;
  final String? reportedUserId;
  final String? reportReasonId;
  final String? details;

  ReportAccountReq({
    this.reportId,
    this.reporteeName,
    this.reporterName,
    this.reporterMessage,
    this.reportedUserId,
    this.reportReasonId,
    this.details,
  });

  factory ReportAccountReq.fromJson(Map<String, dynamic> json) => ReportAccountReq(
        reportId: json["report_id"],
        reporteeName: json["reportee_name"],
        reporterName: json["reporter_name"],
        reporterMessage: json["reporter_message"],
        reportedUserId: json["reported_user_id"],
        reportReasonId: json["report_reason_id"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() {
    final msg = reporterMessage ?? details ?? '';
    return {
      "report_id": reportId ?? 'REP-00000',
      "reportee_name": reporteeName ?? reportedUserId ?? 'Creator',
      "reporter_name": reporterName ?? 'User',
      "reporter_message": msg,
      if (reportedUserId != null && reportedUserId!.isNotEmpty) "reported_user_id": reportedUserId,
      if (reportReasonId != null && reportReasonId!.isNotEmpty) "report_reason_id": reportReasonId,
      "details": msg,
    };
  }
}
