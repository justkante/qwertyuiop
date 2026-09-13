// To parse this JSON data, do
//
//     final savePayoutDetailsReq = savePayoutDetailsReqFromJson(jsonString);

import 'dart:convert';

SavePayoutDetailsReq savePayoutDetailsReqFromJson(String str) =>
    SavePayoutDetailsReq.fromJson(json.decode(str));

String savePayoutDetailsReqToJson(SavePayoutDetailsReq data) => json.encode(data.toJson());

class SavePayoutDetailsReq {
  final String? bankName;
  final String? bankCode;
  final String? accountNumber;

  SavePayoutDetailsReq({
    this.bankName,
    this.bankCode,
    this.accountNumber,
  });

  SavePayoutDetailsReq copyWith({
    String? bankName,
    String? bankCode,
    String? accountNumber,
    List<CreatorCategory>? categories,
  }) =>
      SavePayoutDetailsReq(
        bankName: bankName ?? this.bankName,
        bankCode: bankCode ?? this.bankCode,
        accountNumber: accountNumber ?? this.accountNumber,
      );

  factory SavePayoutDetailsReq.fromJson(Map<String, dynamic> json) => SavePayoutDetailsReq(
        bankName: json["bank_name"],
        bankCode: json["bank_code"],
        accountNumber: json["account_number"],
      );

  Map<String, dynamic> toJson() => {
        "bank_name": bankName,
        "bank_code": bankCode,
        "account_number": accountNumber,
      };
}

class CreatorCategory {
  final String? categoryId;
  final num? hourlyRate;

  CreatorCategory({
    this.categoryId,
    this.hourlyRate,
  });

  CreatorCategory copyWith({
    String? categoryId,
    int? hourlyRate,
  }) =>
      CreatorCategory(
        categoryId: categoryId ?? this.categoryId,
        hourlyRate: hourlyRate ?? this.hourlyRate,
      );

  factory CreatorCategory.fromJson(Map<String, dynamic> json) => CreatorCategory(
        categoryId: json["category_id"],
        hourlyRate: json["hourly_rate"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "hourly_rate": hourlyRate,
      };
}
