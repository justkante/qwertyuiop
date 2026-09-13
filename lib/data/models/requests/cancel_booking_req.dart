// To parse this JSON data, do
//
//     final cancelBookingReq = cancelBookingReqFromJson(jsonString);

import 'dart:convert';

CancelBookingReq cancelBookingReqFromJson(String str) =>
    CancelBookingReq.fromJson(json.decode(str));

String cancelBookingReqToJson(CancelBookingReq data) => json.encode(data.toJson());

class CancelBookingReq {
  final String? reasonId;
  final String? reason;
  final String? details;

  CancelBookingReq({
    this.reasonId,
    this.reason,
    this.details,
  });

  CancelBookingReq copyWith({
    String? reasonId,
    String? reason,
    String? details,
  }) =>
      CancelBookingReq(
        reasonId: reasonId ?? this.reasonId,
        reason: reason ?? this.reason,
        details: details ?? this.details,
      );

  factory CancelBookingReq.fromJson(Map<String, dynamic> json) => CancelBookingReq(
        reasonId: json["reason_id"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "reason_id": reasonId,
        "details": details,
      };
}
