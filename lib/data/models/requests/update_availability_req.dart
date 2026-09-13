// To parse this JSON data, do
//
//     final updateAvailabilityReq = updateAvailabilityReqFromJson(jsonString);

import 'dart:convert';

UpdateAvailabilityReq updateAvailabilityReqFromJson(String str) =>
    UpdateAvailabilityReq.fromJson(json.decode(str));

String updateAvailabilityReqToJson(UpdateAvailabilityReq data) => json.encode(data.toJson());

class UpdateAvailabilityReq {
  final String? workMode;
  final String? stateId;
  final bool? availableToTravel;
  final List<String>? unavailableMonths;
  final List<UnavailableDate>? unavailableDates;

  UpdateAvailabilityReq({
    this.workMode,
    this.stateId,
    this.availableToTravel,
    this.unavailableMonths,
    this.unavailableDates,
  });

  UpdateAvailabilityReq copyWith({
    String? workMode,
    String? stateId,
    bool? availableToTravel,
    List<String>? unavailableMonths,
    List<UnavailableDate>? unavailableDates,
  }) =>
      UpdateAvailabilityReq(
        workMode: workMode ?? this.workMode,
        stateId: stateId ?? this.stateId,
        availableToTravel: availableToTravel ?? this.availableToTravel,
        unavailableMonths: unavailableMonths ?? this.unavailableMonths,
        unavailableDates: unavailableDates ?? this.unavailableDates,
      );

  factory UpdateAvailabilityReq.fromJson(Map<String, dynamic> json) => UpdateAvailabilityReq(
        workMode: json["work_mode"],
        stateId: json["state_id"],
        availableToTravel: json["available_to_travel"],
        unavailableMonths: json["unavailable_months"] == null
            ? []
            : List<String>.from(json["unavailable_months"]!.map((x) => x)),
        unavailableDates: json["unavailable_dates"] == null
            ? []
            : List<UnavailableDate>.from(
                json["unavailable_dates"]!.map((x) => UnavailableDate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "work_mode": workMode,
        "state_id": stateId,
        "available_to_travel": availableToTravel,
        "unavailable_months":
            unavailableMonths == null ? [] : List<dynamic>.from(unavailableMonths!.map((x) => x)),
        "unavailable_dates": unavailableDates == null
            ? []
            : List<dynamic>.from(unavailableDates!.map((x) => x.toJson())),
      };
}

class UnavailableDate {
  final DateTime? date;
  final bool? isFullDay;
  final String? startTime;
  final String? endTime;
  final String? reason;

  UnavailableDate({
    this.date,
    this.isFullDay,
    this.startTime,
    this.endTime,
    this.reason,
  });

  UnavailableDate copyWith({
    DateTime? date,
    bool? isFullDay,
    String? startTime,
    String? endTime,
    String? reason,
  }) =>
      UnavailableDate(
        date: date ?? this.date,
        isFullDay: isFullDay ?? this.isFullDay,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        reason: reason ?? this.reason,
      );

  factory UnavailableDate.fromJson(Map<String, dynamic> json) => UnavailableDate(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        isFullDay: json["is_full_day"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "is_full_day": isFullDay,
        if (startTime != null) "start_time": startTime,
        if (endTime != null) "end_time": endTime,
        if (reason != null) "reason": reason,
      };
}
