// To parse this JSON data, do
//
//     final resolveBankAccountReq = resolveBankAccountReqFromJson(jsonString);

import 'dart:convert';

ResolveBankAccountReq resolveBankAccountReqFromJson(String str) =>
    ResolveBankAccountReq.fromJson(json.decode(str));

String resolveBankAccountReqToJson(ResolveBankAccountReq data) => json.encode(data.toJson());

class ResolveBankAccountReq {
  final String? accountNumber;
  final String? bankCode;

  ResolveBankAccountReq({
    this.accountNumber,
    this.bankCode,
  });

  ResolveBankAccountReq copyWith({
    String? accountNumber,
    String? bankCode,
  }) =>
      ResolveBankAccountReq(
        accountNumber: accountNumber ?? this.accountNumber,
        bankCode: bankCode ?? this.bankCode,
      );

  factory ResolveBankAccountReq.fromJson(Map<String, dynamic> json) => ResolveBankAccountReq(
        accountNumber: json["account_number"],
        bankCode: json["bank_code"],
      );

  Map<String, dynamic> toJson() => {
        "account_number": accountNumber,
        "bank_code": bankCode,
      };
}
