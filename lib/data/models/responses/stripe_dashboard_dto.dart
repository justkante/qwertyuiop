// To parse this JSON data, do
//
//     final stripeDashboardDto = stripeDashboardDtoFromJson(jsonString);

import 'dart:convert';

StripeDashboardDto stripeDashboardDtoFromJson(String str) =>
    StripeDashboardDto.fromJson(json.decode(str));

String stripeDashboardDtoToJson(StripeDashboardDto data) => json.encode(data.toJson());

class StripeDashboardDto {
  final String? url;
  final DateTime? created;

  StripeDashboardDto({
    this.url,
    this.created,
  });

  factory StripeDashboardDto.fromJson(Map<String, dynamic> json) => StripeDashboardDto(
        url: json["url"],
        created: json["created"] == null ? null : DateTime.parse(json["created"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "created": created?.toIso8601String(),
      };
}
