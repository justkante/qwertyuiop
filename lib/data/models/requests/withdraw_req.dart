// To parse this JSON data, do
//
//     final withdrawReq = withdrawReqFromJson(jsonString);

import 'dart:convert';

WithdrawReq withdrawReqFromJson(String str) => WithdrawReq.fromJson(json.decode(str));

String withdrawReqToJson(WithdrawReq data) => json.encode(data.toJson());

class WithdrawReq {
  final num? amount;
  final String? pin;
  final String? bankCode;
  final String? accountNumber;

  WithdrawReq({
    this.amount,
    this.pin,
    this.bankCode,
    this.accountNumber,
  });

  WithdrawReq copyWith({
    int? amount,
    String? pin,
    String? bankCode,
    String? accountNumber,
  }) =>
      WithdrawReq(
        amount: amount ?? this.amount,
        pin: pin ?? this.pin,
        bankCode: bankCode ?? this.bankCode,
        accountNumber: accountNumber ?? this.accountNumber,
      );

  factory WithdrawReq.fromJson(Map<String, dynamic> json) => WithdrawReq(
        amount: json["amount"],
        pin: json["pin"],
        bankCode: json["bank_code"],
        accountNumber: json["account_number"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "pin": pin,
        if (bankCode != null) "bank_code": bankCode,
        if (accountNumber != null) "account_number": accountNumber,
      };
}
