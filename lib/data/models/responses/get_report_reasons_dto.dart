// To parse this JSON data, do
//
//     final reportReasonsDto = reportReasonsDtoFromJson(jsonString);

import 'dart:convert';

ReportReasonsDto reportReasonsDtoFromJson(String str) =>
    ReportReasonsDto.fromJson(json.decode(str));

String reportReasonsDtoToJson(ReportReasonsDto data) => json.encode(data.toJson());

class ReportReasonsDto {
  final String? id;
  final String? reason;
  final String? description;

  ReportReasonsDto({
    this.id,
    this.reason,
    this.description,
  });

  factory ReportReasonsDto.fromJson(Map<String, dynamic> json) => ReportReasonsDto(
        id: json["id"],
        reason: json["reason"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reason": reason,
        "description": description,
      };
}
