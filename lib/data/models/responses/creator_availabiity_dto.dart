// To parse this JSON data, do
//
//     final creatorAvailabilityDto = creatorAvailabilityDtoFromJson(jsonString);

import 'dart:convert';

CreatorAvailabilityDto creatorAvailabilityDtoFromJson(String str) =>
    CreatorAvailabilityDto.fromJson(json.decode(str));

String creatorAvailabilityDtoToJson(CreatorAvailabilityDto data) => json.encode(data.toJson());

class CreatorAvailabilityDto {
  final List<UnavailableDate>? unavailableDates;
  final WorkPreference? workPreference;

  CreatorAvailabilityDto({
    this.unavailableDates,
    this.workPreference,
  });

  factory CreatorAvailabilityDto.fromJson(Map<String, dynamic> json) => CreatorAvailabilityDto(
        unavailableDates: json["unavailable_dates"] == null
            ? []
            : List<UnavailableDate>.from(
                json["unavailable_dates"]!.map((x) => UnavailableDate.fromJson(x))),
        workPreference: json["work_preference"] == null
            ? null
            : WorkPreference.fromJson(json["work_preference"]),
      );

  Map<String, dynamic> toJson() => {
        "unavailable_dates": unavailableDates == null
            ? []
            : List<dynamic>.from(unavailableDates!.map((x) => x.toJson())),
        "work_preference": workPreference?.toJson(),
      };
}

class UnavailableDate {
  final String? id;
  final DateTime? unavailableDate;
  final String? startTime;
  final String? endTime;
  final bool? isFullDay;
  final int? isMonthBlock;
  final int? isAutoBlocked;
  final String? monthYear;
  final String? reason;

  UnavailableDate({
    this.id,
    this.unavailableDate,
    this.startTime,
    this.endTime,
    this.isFullDay,
    this.isMonthBlock,
    this.isAutoBlocked,
    this.monthYear,
    this.reason,
  });

  factory UnavailableDate.fromJson(Map<String, dynamic> json) => UnavailableDate(
        id: json["id"],
        unavailableDate:
            json["unavailable_date"] == null ? null : DateTime.parse(json["unavailable_date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        isFullDay: json["is_full_day"],
        isMonthBlock: json["is_month_block"],
        isAutoBlocked: json["is_auto_blocked"],
        monthYear: json["month_year"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "unavailable_date":
            "${unavailableDate!.year.toString().padLeft(4, '0')}-${unavailableDate!.month.toString().padLeft(2, '0')}-${unavailableDate!.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "end_time": endTime,
        "is_full_day": isFullDay,
        "is_month_block": isMonthBlock,
        "is_auto_blocked": isAutoBlocked,
        "month_year": monthYear,
        "reason": reason,
      };
}

class WorkPreference {
  final String? workMode;
  final StatesItemDto? state;
  final bool? availableToTravel;

  WorkPreference({
    this.workMode,
    this.state,
    this.availableToTravel,
  });

  factory WorkPreference.fromJson(Map<String, dynamic> json) => WorkPreference(
        workMode: json["work_mode"],
        state: json["state"] == null ? null : StatesItemDto.fromJson(json["state"]),
        availableToTravel: json["available_to_travel"],
      );

  Map<String, dynamic> toJson() => {
        "work_mode": workMode,
        "state": state?.toJson(),
        "available_to_travel": availableToTravel,
      };
}

class StatesItemDto {
  final String? id;
  final String? name;

  StatesItemDto({
    this.id,
    this.name,
  });

  factory StatesItemDto.fromJson(Map<String, dynamic> json) => StatesItemDto(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
