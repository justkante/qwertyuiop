// To parse this JSON data, do
//
//     final payoutDetailsDto = payoutDetailsDtoFromJson(jsonString);

import 'dart:convert';

PayoutDetailsDto payoutDetailsDtoFromJson(String str) =>
    PayoutDetailsDto.fromJson(json.decode(str));

String payoutDetailsDtoToJson(PayoutDetailsDto data) => json.encode(data.toJson());

class PayoutDetailsDto {
  final String? bankName;
  final String? bankCode;
  final String? accountNumber;
  final String? accountName;
  final DateTime? verifiedAt;
  final List<CategoryElement>? categories;

  PayoutDetailsDto({
    this.bankName,
    this.bankCode,
    this.accountNumber,
    this.accountName,
    this.verifiedAt,
    this.categories,
  });

  factory PayoutDetailsDto.fromJson(Map<String, dynamic> json) => PayoutDetailsDto(
        bankName: json["bank_name"],
        bankCode: json["bank_code"],
        accountNumber: json["account_number"],
        accountName: json["account_name"],
        verifiedAt: json["verified_at"] == null ? null : DateTime.parse(json["verified_at"]),
        categories: json["categories"] == null
            ? []
            : List<CategoryElement>.from(
                json["categories"]!.map((x) => CategoryElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bank_name": bankName,
        "bank_code": bankCode,
        "account_number": accountNumber,
        "account_name": accountName,
        "verified_at": verifiedAt?.toIso8601String(),
        "categories":
            categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
      };
}

class CategoryElement {
  final String? id;
  final String? categoryId;
  final String? hourlyRate;
  final CategoryCategory? category;

  CategoryElement({
    this.id,
    this.categoryId,
    this.hourlyRate,
    this.category,
  });

  factory CategoryElement.fromJson(Map<String, dynamic> json) => CategoryElement(
        id: json["id"],
        categoryId: json["category_id"],
        hourlyRate: json["hourly_rate"],
        category: json["category"] == null ? null : CategoryCategory.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "hourly_rate": hourlyRate,
        "category": category?.toJson(),
      };
}

class CategoryCategory {
  final String? id;
  final String? name;

  CategoryCategory({
    this.id,
    this.name,
  });

  factory CategoryCategory.fromJson(Map<String, dynamic> json) => CategoryCategory(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
