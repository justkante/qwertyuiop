// To parse this JSON data, do
//
//     final walletDto = walletDtoFromJson(jsonString);

import 'dart:convert';

WalletDto walletDtoFromJson(String str) => WalletDto.fromJson(json.decode(str));

String walletDtoToJson(WalletDto data) => json.encode(data.toJson());

class WalletDto {
  final String? walletId;
  final num? availableBalance;
  final num? pendingBalance;
  final num? totalBalance;
  final String? currency;
  final bool? hasPin;
  final dynamic dva;

  WalletDto({
    this.walletId,
    this.availableBalance,
    this.pendingBalance,
    this.totalBalance,
    this.currency,
    this.hasPin,
    this.dva,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) => WalletDto(
        walletId: json["wallet_id"],
        availableBalance: json["available_balance"],
        pendingBalance: json["pending_balance"],
        totalBalance: json["total_balance"],
        currency: json["currency"],
        hasPin: json["has_pin"],
        dva: json["dva"],
      );

  Map<String, dynamic> toJson() => {
        "wallet_id": walletId,
        "available_balance": availableBalance,
        "pending_balance": pendingBalance,
        "total_balance": totalBalance,
        "currency": currency,
        "has_pin": hasPin,
        "dva": dva,
      };
}
