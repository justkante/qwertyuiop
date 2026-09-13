// To parse this JSON data, do
//
//     final bankItemDto = bankItemDtoFromJson(jsonString);

import 'dart:convert';

BankItemDto bankItemDtoFromJson(String str) => BankItemDto.fromJson(json.decode(str));

String bankItemDtoToJson(BankItemDto data) => json.encode(data.toJson());

class BankItemDto {
  final String? name;
  final String? code;
  final String? slug;

  BankItemDto({
    this.name,
    this.code,
    this.slug,
  });

  factory BankItemDto.fromJson(Map<String, dynamic> json) => BankItemDto(
        name: json["name"],
        code: json["code"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "slug": slug,
      };
}
