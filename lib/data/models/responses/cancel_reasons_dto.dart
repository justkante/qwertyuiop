// To parse this JSON data, do
//
//     final cancelReasonsItemDto = cancelReasonsItemDtoFromJson(jsonString);

import 'dart:convert';

CancelNegotationsReasonsItemDto cancelReasonsItemDtoFromJson(String str) =>
    CancelNegotationsReasonsItemDto.fromJson(json.decode(str));

String cancelReasonsItemDtoToJson(CancelNegotationsReasonsItemDto data) =>
    json.encode(data.toJson());

class CancelNegotationsReasonsItemDto {
  final String? id;
  final String? type;
  final String? reason;

  CancelNegotationsReasonsItemDto({
    this.id,
    this.type,
    this.reason,
  });

  factory CancelNegotationsReasonsItemDto.fromJson(Map<String, dynamic> json) =>
      CancelNegotationsReasonsItemDto(
        id: json["id"],
        type: json["type"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "reason": reason,
      };
}
