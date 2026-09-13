// To parse this JSON data, do
//
//     final creatorUnavailabilityItemDto = creatorUnavailabilityItemDtoFromJson(jsonString);

import 'dart:convert';

CreatorUnavailabilityItemDto creatorUnavailabilityItemDtoFromJson(String str) =>
    CreatorUnavailabilityItemDto.fromJson(json.decode(str));

String creatorUnavailabilityItemDtoToJson(CreatorUnavailabilityItemDto data) =>
    json.encode(data.toJson());

class CreatorUnavailabilityItemDto {
  final String? id;
  final DateTime? unavailableDate;
  final String? startTime;
  final String? endTime;
  final bool? isFullDay;
  final String? reason;

  CreatorUnavailabilityItemDto({
    this.id,
    this.unavailableDate,
    this.startTime,
    this.endTime,
    this.isFullDay,
    this.reason,
  });

  factory CreatorUnavailabilityItemDto.fromJson(Map<String, dynamic> json) =>
      CreatorUnavailabilityItemDto(
        id: json["id"],
        unavailableDate:
            json["unavailable_date"] == null ? null : DateTime.parse(json["unavailable_date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        isFullDay: json["is_full_day"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "unavailable_date":
            "${unavailableDate!.year.toString().padLeft(4, '0')}-${unavailableDate!.month.toString().padLeft(2, '0')}-${unavailableDate!.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "end_time": endTime,
        "is_full_day": isFullDay,
        "reason": reason,
      };
}
